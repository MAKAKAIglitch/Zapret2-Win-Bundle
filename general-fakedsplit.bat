@echo off
set "ROOT=%~dp0"
set "IPSET_MODE=any"
if exist "%ROOT%data\ipset-mode.txt" set /p "IPSET_MODE="<"%ROOT%data\ipset-mode.txt"
if /i not "%IPSET_MODE%"=="any" if /i not "%IPSET_MODE%"=="loaded" if /i not "%IPSET_MODE%"=="none" set "IPSET_MODE=any"
set "IPSET_INCLUDE="
if /i "%IPSET_MODE%"=="loaded" set IPSET_INCLUDE=--ipset="%ROOT%lists\ipset-all.txt"
set "PROFILE_TITLE=General — Fake + FakeDSplit"
set "PROFILE_DESCRIPTION=Комбинация fake и fakedsplit для HTTP/TLS; QUIC остаётся на штатном fake."
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

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=80 --filter-l7=http --hostlist="%ROOT%lists\list-general.txt" --hostlist="%ROOT%lists\list-general-user.txt" --hostlist-exclude="%ROOT%lists\list-exclude.txt" --hostlist-exclude="%ROOT%lists\list-exclude-user.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=http_req
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_http:payload=http_req:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fakedsplit:payload=http_req:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=443 --filter-l7=tls --hostlist="%ROOT%lists\list-general.txt" --hostlist="%ROOT%lists\list-general-user.txt" --hostlist="%ROOT%lists\list-google.txt" --hostlist-exclude="%ROOT%lists\list-exclude.txt" --hostlist-exclude="%ROOT%lists\list-exclude-user.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=tls_client_hello
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_tls:payload=tls_client_hello:repeats=8:tls_mod=rnd,dupsid,sni=www.google.com
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fakedsplit:payload=tls_client_hello:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 --filter-l7=quic --hostlist="%ROOT%lists\list-general.txt" --hostlist="%ROOT%lists\list-general-user.txt" --hostlist="%ROOT%lists\list-google.txt" --hostlist-exclude="%ROOT%lists\list-exclude.txt" --hostlist-exclude="%ROOT%lists\list-exclude-user.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=quic_initial
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=quic_google:payload=quic_initial:repeats=8
set PROFILE_ARGS=%PROFILE_ARGS% --new

if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=80,443 %IPSET_INCLUDE% --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 %IPSET_INCLUDE% --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=500,1701,2408,4500,8095 --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=500,1701,2408,4500,8095 --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20

if /i "%~1"=="--profile" exit /b 0
call "%ROOT%utils\run-profile.bat" "%~f0" %*
