# Runtime files

This folder is intentionally kept separate from the project's own BAT files.

Download the Windows bundle from:
https://github.com/bol-van/zapret-win-bundle

Copy the **contents** of the upstream zapret-winws directory into this bin directory. Do not create an extra nested zapret-winws directory.

The resulting layout must include:

- winws2.exe
- WinDivert.dll
- WinDivert64.sys
- cygwin1.dll
- lua\zapret-lib.lua
- lua\zapret-antidpi.lua
- lua\zapret-auto.lua
- files\quic_initial_www_google_com.bin
- windivert.filter\windivert_part.discord_media.txt
- windivert.filter\windivert_part.stun.txt
- windivert.filter\windivert_part.wireguard.txt
- windivert.filter\windivert_part.quic_initial_ietf.txt

Keep winws2.exe and all Lua files from the same upstream bundle revision. Zapret 2 checks the Lua compatibility version.
