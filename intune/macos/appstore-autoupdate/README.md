# App Store Automatic Updates – macOS (Intune)

macOS has no MDM/DDM setting for the App Store checkbox *Automatic Updates* (tested on macOS 27). Users can turn it off, and then App Store apps stop updating.

This script turns it back on system-wide (`/Library/Preferences/com.apple.commerce` → `AutoUpdate = true`). Run it on a schedule so it re-applies if a user disables it.

## Files

| File | Purpose |
|---|---|
| `Enable-AppStoreAutoUpdate.sh` | Sets `AutoUpdate` to `true` if not already set, logs to `/Library/Logs/Microsoft/IntuneScripts/AppStoreAutoUpdate/` |

## Setup

1. **Test locally** on a Mac:
   ```bash
   sudo bash Enable-AppStoreAutoUpdate.sh
   defaults read /Library/Preferences/com.apple.commerce AutoUpdate   # expect 1
   ```
2. **Deploy in Intune**: *Devices > macOS > Scripts > Add*
   - Run script as signed-in user: **No** (runs as root)
   - Script frequency: **Every 1 day**
   - Max number of times to retry if script fails: **3**
   - Assign to your Macs (device or user group)

## Notes

- Only covers App Store **apps**. macOS updates are handled by the Intune/DDM software update policy.
- Users can still turn the checkbox off; the script turns it back on at its next run.
- Provided as-is, no warranty. Test in your own tenant before rolling out.
