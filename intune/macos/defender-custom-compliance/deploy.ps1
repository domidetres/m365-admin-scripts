# Creates the macOS custom compliance script + policy for Defender status in Intune and assigns it to all devices.
# Run: pwsh -NoProfile -File deploy.ps1   (needs DeviceManagementConfiguration.ReadWrite.All + DeviceManagementScripts.ReadWrite.All)
$ErrorActionPreference = 'Stop'

# Without your real org ID every Mac would be noncompliant (and blocked after the grace period)
if ((Get-Content (Join-Path $PSScriptRoot 'defender-rules.json') -Raw) -match '<YOUR-DEFENDER-ORG-ID>') {
    throw "Set your Defender org ID in defender-rules.json first (on an onboarded Mac: mdatp health --field org_id)"
}

Connect-MgGraph -Scopes DeviceManagementConfiguration.ReadWrite.All, DeviceManagementScripts.ReadWrite.All -NoWelcome
$g    = 'https://graph.microsoft.com/beta/deviceManagement'
$name = 'MAC - Compliance - Defender Status'
$b64  = { param($p) [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot $p))) }

# Abort if already deployed (no duplicates)
if ((Invoke-MgGraphRequest -Uri "$g/deviceComplianceScripts").value | Where-Object displayName -eq $name) { throw "Script '$name' exists already" }
if ((Invoke-MgGraphRequest -Uri "$g/deviceCompliancePolicies?`$select=displayName").value | Where-Object displayName -eq $name) { throw "Policy '$name' exists already" }

$script = Invoke-MgGraphRequest -Method POST -Uri "$g/deviceComplianceScripts" -Body (@{
    displayName            = $name
    description            = 'Defender for Endpoint status via mdatp health (installed, healthy, RTP, definitions, org id)'
    publisher              = 'IT'
    platform               = 'macOS'
    runAsAccount           = 'system'
    enforceSignatureCheck  = $false
    runAs32Bit             = $false
    detectionScriptContent = & $b64 'defender-discovery.sh'
} | ConvertTo-Json)
"Script:  $($script.id)"

$policy = Invoke-MgGraphRequest -Method POST -Uri "$g/deviceCompliancePolicies" -Body (@{
    '@odata.type' = '#microsoft.graph.macOSCompliancePolicy'
    displayName   = $name
    description   = 'Custom compliance: Microsoft Defender for Endpoint installed, healthy and onboarded to the correct org'
    deviceCompliancePolicyScript = @{
        deviceComplianceScriptId = $script.id
        rulesContent             = & $b64 'defender-rules.json'
    }
    scheduledActionsForRule = @(@{
        ruleName = 'PasswordRequired'   # Graph requires this placeholder rule name for the action
        scheduledActionConfigurations = @(@{ actionType = 'block'; gracePeriodHours = 24; notificationTemplateId = ''; notificationMessageCCList = @() })
    })
} | ConvertTo-Json -Depth 6)
"Policy:  $($policy.id)"

Invoke-MgGraphRequest -Method POST -Uri "$g/deviceCompliancePolicies/$($policy.id)/assign" -Body (@{
    assignments = @(@{ target = @{ '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget' } })
} | ConvertTo-Json -Depth 5) | Out-Null
"Assigned: All Devices"
