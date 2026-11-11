#!/bin/bash
# Intune custom compliance discovery: Microsoft Defender for Endpoint status on macOS.
# Outputs one JSON line; rules live in defender-rules.json.

MDATP="/usr/local/bin/mdatp"

field() {
    # mdatp prints strings quoted ("up_to_date"); strip quotes, empty on error
    "$MDATP" health --field "$1" 2>/dev/null | tr -d '"'
}

bool() { [ "$1" = "true" ] && echo true || echo false; }

if [ ! -x "$MDATP" ]; then
    echo '{"DefenderInstalled":false,"Healthy":false,"RealTimeProtection":false,"DefinitionsStatus":"not_installed","OrgId":""}'
    exit 0
fi

echo "{\"DefenderInstalled\":true,\"Healthy\":$(bool "$(field healthy)"),\"RealTimeProtection\":$(bool "$(field real_time_protection_enabled)"),\"DefinitionsStatus\":\"$(field definitions_status)\",\"OrgId\":\"$(field org_id)\"}"
exit 0
