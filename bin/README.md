# Runtime files

Run SETUP_RUNTIME.bat to download the required Zapret 2 runtime files from the official bol-van/zapret-win-bundle repository.

The installer is pinned to one upstream commit. It downloads the required files to a temporary staging directory, verifies every Git blob SHA-1, backs up an existing local runtime to data/runtime-backup, and only then replaces the files in bin.

Expected files include:

- winws2.exe
- WinDivert.dll
- WinDivert64.sys
- cygwin1.dll
- lua/zapret-lib.lua
- lua/zapret-antidpi.lua
- lua/zapret-auto.lua
- files/quic_initial_www_google_com.bin
- windivert.filter/ with the filters used by the profiles

Runtime files are local and excluded from Git. UPSTREAM-VERSION.txt records the exact upstream commit installed on this PC.
