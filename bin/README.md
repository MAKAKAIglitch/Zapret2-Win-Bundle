# Runtime files

This directory is populated automatically by the root-level INSTALL.bat.

Run INSTALL.bat to download the required Zapret 2 runtime files from the official bol-van/zapret-win-bundle repository. The installer is pinned to a specific upstream commit and checks every downloaded file against its Git blob SHA-1 before moving it into this directory.

The expected layout includes:

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
