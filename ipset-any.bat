@echo off
set "ROOT=%~dp0"
set "PROFILE_TITLE=IPSet ANY"
set "PROFILE_DESCRIPTION=IP-set matching with all payload types, including unknown payloads."
set "PROFILE_NEEDS_AUTO_LUA=0"
set "PROFILE_NEEDS_LISTS=1"
set "PROFILE_NEEDS_IPSET=1"
set "PROFILE_ARGS=--wf-tcp-empty=1 --wf-tcp-in=80,443,500,1701,2408,4500,8095 --wf-tcp-out=80,443,500,1701,2408,4500,8095 --wf-udp-in=443,500,1701,2408,4500,8095 --wf-udp-out=443,500,1701,2408,4500,8095"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-lib.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-antidpi.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --blob=quic_google:@"%ROOT%bin\files\quic_initial_www_google_com.bin"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.discord_media.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.stun.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.wireguard.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.quic_initial_ietf.txt"

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=80,443 --ipset="%ROOT%lists\ipset-all.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 --ipset="%ROOT%lists\ipset-all.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=500,1701,2408,4500,8095 --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=500,1701,2408,4500,8095 --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20

if /i "%~1"=="--profile" exit /b 0
call "%ROOT%utils\run-profile.bat" "%~f0" %*
