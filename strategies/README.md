# Strategies

These profiles are for **Zapret 2 (winws2.exe)**. They are not compatible with Flowseal's Zapret 1 winws.exe command lines.

| File | Purpose |
| --- | --- |
| general.strategy.cmd | General HTTP/TLS/QUIC preset adapted from upstream preset2_example.cmd. |
| general-alt.strategy.cmd | General preset with the upstream TLS randomization initialization example. |
| wireguard.strategy.cmd | Separate WireGuard initiation profile adapted from upstream preset2_wireguard.cmd. |

service.bat loads the selected profile and uses its PROFILE_ARGS variable to create the Windows service.

When creating a profile:
1. Use the *.strategy.cmd suffix so it appears in the menu.
2. Set PROFILE_TITLE, PROFILE_DESCRIPTION, PROFILE_NEEDS_GENERAL_ASSETS, PROFILE_NEEDS_AUTO_LUA, and PROFILE_ARGS.
3. Use %ROOT% for paths relative to the repository root.
4. Keep the Lua options and winws2.exe from the same upstream bundle revision.

The presets are starting configurations, not a guarantee that a strategy works on every ISP or network. They have not been runtime-tested on this machine.
