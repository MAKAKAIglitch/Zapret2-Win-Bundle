# Runtime files

This folder intentionally contains no executable files in Git.

Download the Windows bundle from:
https://github.com/bol-van/zapret-win-bundle

Copy the **contents** of its zapret-winws directory into this bin directory.
Do not create an extra nested zapret-winws directory.

The resulting layout must include at least:

- winws2.exe
- WinDivert.dll
- WinDivert64.sys
- cygwin1.dll
- lua\zapret-lib.lua
- lua\zapret-antidpi.lua
- lua\zapret-auto.lua
- files\list-youtube.txt
- files\quic_initial_www_google_com.bin
- windivert.filter\windivert_part.*.txt

Keep winws2.exe and all Lua files from the **same upstream bundle revision**.
Mixing versions can cause Lua compatibility errors.
