# Microsoft Defender for Endpoint – macOS Custom Compliance (Intune)

The built-in Intune compliance policy for macOS checks things like encryption, firewall, Gatekeeper and OS version – but **not** whether Microsoft Defender for Endpoint is actually installed and working.

This custom compliance check marks a Mac **noncompliant** if Defender is:

- not installed
- not healthy (`mdatp health`)
- running with real-time protection turned off
- using outdated definitions
- onboarded to the wrong organization

Each failed check shows its own message (English/German) in Company Portal, so users know what to do.

## Files

| File | Purpose |
|---|---|
| `defender-discovery.sh` | Discovery script (runs as root, reads `mdatp health`, prints one JSON line) |
| `defender-rules.json` | Compliance rules (5 settings, remediation text en/de) |
| `deploy.ps1` | Optional: creates script + compliance policy via Microsoft Graph, assigns **All Devices**, marks noncompliant after 24 h |

## Setup

1. **Set your org ID**: in `defender-rules.json` replace `<YOUR-DEFENDER-ORG-ID>` with your Defender org ID. On an onboarded Mac, run:
   ```bash
   mdatp health --field org_id
   ```
   If you skip this step, every Mac fails the check.
2. **Test locally** on a Mac:
   ```bash
   sudo bash defender-discovery.sh
   ```
   Expected output: `{"DefenderInstalled":true,"Healthy":true,"RealTimeProtection":true,"DefinitionsStatus":"up_to_date","OrgId":"..."}`
3. **Deploy** – either
   - **in the portal**: *Devices > Compliance > Scripts > Add (macOS)* with `defender-discovery.sh`, then create a macOS compliance policy, enable *Custom compliance*, select the script and upload `defender-rules.json`, or
   - **via Graph**: `pwsh -NoProfile -File deploy.ps1` (scopes `DeviceManagementConfiguration.ReadWrite.All`, `DeviceManagementScripts.ReadWrite.All`). Run `Get-MgContext` first to check you are connected to the right tenant.

> ⚠️ `deploy.ps1` assigns the policy to **All Devices** right away. Combined with Conditional Access ("require compliant device"), Macs without a working Defender lose access after the grace period. Test with a pilot group first if you are unsure.

## Prerequisites

- Defender deployed as an Intune **app** (macOS PKG / Defender app type), not as a one-time shell script. A one-time script that fails is not retried.
- Onboarding, system extension, full disk access (PPPC) and network filter profiles deployed – otherwise `healthy` stays `false`.

## Notes

- Machine risk score from Defender is not used here; this check only uses local `mdatp health` data.
- Provided as-is, no warranty. Test in your own tenant before rolling out.
