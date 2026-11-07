@echo off
set "ROOT=%~dp0"
set "PROFILE_TITLE=IPSet LOADED AUTO"
set "PROFILE_DESCRIPTION=Automatic strategy rotation for all local TCP/UDP ports in lists/ipset-all.txt."
set "PROFILE_NEEDS_AUTO_LUA=1"
set "PROFILE_NEEDS_LISTS=1"
set "PROFILE_NEEDS_IPSET_ALWAYS=1"
set "PROFILE_NEEDS_IPSET=1"

rem Capture all local TCP/UDP ports in both directions. The IP-set filters
rem below restrict desync actions to addresses in ipset-all.txt.
set "PROFILE_ARGS=--wf-tcp-empty=1 --wf-tcp-in=1-65535 --wf-tcp-out=1-65535 --wf-udp-in=1-65535 --wf-udp-out=1-65535"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-lib.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-antidpi.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-auto.lua"

rem TCP: rotate per host after repeated connection-failure feedback.
set PROFILE_ARGS=%PROFILE_ARGS% --in-range=a
set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=* --ipset="%ROOT%lists\ipset-all.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:retrans=2:maxseq=16384:inseq=4096
set PROFILE_ARGS=%PROFILE_ARGS% --in-range=x
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=1:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=1
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fakedsplit:payload=all:strategy=2
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multisplit:pos=2:payload=all:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

rem UDP: rotate after repeated outbound packets without a corresponding reply.
set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=* --ipset="%ROOT%lists\ipset-all.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:udp_out=4:udp_in=1
set PROFILE_ARGS=%PROFILE_ARGS% --in-range=x
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=1:strategy=1
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x0000000000000000000000000000000000000000000000000000000000000000:payload=all:repeats=2:strategy=2
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=4:strategy=3:final

if /i "%~1"=="--profile" exit /b 0
call "%ROOT%utils\run-profile.bat" "%~f0" %*
