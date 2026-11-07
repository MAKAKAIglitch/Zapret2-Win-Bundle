@echo off
rem Based on bol-van/zapret-win-bundle zapret-winws/preset2_wireguard.cmd.
rem This profile only targets WireGuard initiation traffic.

set "PROFILE_TITLE=WireGuard"
set "PROFILE_DESCRIPTION=Отдельный профиль для WireGuard handshake; не заменяет General."
set "PROFILE_NEEDS_GENERAL_ASSETS=0"
set "PROFILE_NEEDS_AUTO_LUA=1"

set PROFILE_ARGS=--wf-raw-part=@\"%ROOT%bin\windivert.filter\windivert_part.wireguard.txt\"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@\"%ROOT%bin\lua\zapret-lib.lua\"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@\"%ROOT%bin\lua\zapret-antidpi.lua\"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@\"%ROOT%bin\lua\zapret-auto.lua\"
set PROFILE_ARGS=%PROFILE_ARGS% --filter-l7=wireguard --payload=wireguard_initiation
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=repeater:instances=2:repeats=3
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=luaexec:code=\"desync.rnd=brandom(math.random(32,64))\"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=rnd

exit /b 0
