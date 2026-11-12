# M365 Admin Scripts

Scripts and configs from real-world Microsoft 365 / Intune / Entra work. Free to use and adapt – test in your own tenant first.

| Path | What it does |
|---|---|
| [`intune/macos/defender-custom-compliance`](intune/macos/defender-custom-compliance) | Intune custom compliance for macOS: Mac is noncompliant if Microsoft Defender for Endpoint is missing, unhealthy, has real-time protection off, outdated definitions or the wrong org ID |
| [`intune/macos/appstore-autoupdate`](intune/macos/appstore-autoupdate) | Script that turns App Store *Automatic Updates* back on for all users on macOS (no MDM/DDM key exists for it); run daily via Intune |
