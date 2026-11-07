# Runtime files

This folder receives the Windows runtime from the pinned upstream bundle.

Preferred setup:
- Run SETUP_RUNTIME.bat from the repository root, or choose option 8 in service.bat.
- The installer downloads a pinned commit from https://github.com/bol-van/zapret-win-bundle.
- It extracts only the upstream zapret-winws folder and verifies the expected winws2.exe, WinDivert, Lua and filter files before copying them here.
- Existing runtime contents are backed up under data/runtime-backup when the user confirms an update.

Manual setup is also possible: copy the contents of the upstream zapret-winws directory into this bin directory. Do not create an extra nested zapret-winws directory.

Keep winws2.exe and all Lua files from the same upstream bundle revision. Zapret 2 checks the Lua compatibility version.
