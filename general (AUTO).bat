@echo off
set "ROOT=%~dp0"
set "IPSET_MODE=any"
if exist "%ROOT%data\ipset-mode.txt" set /p "IPSET_MODE="<"%ROOT%data\ipset-mode.txt"
if /i not "%IPSET_MODE%"=="any" if /i not "%IPSET_MODE%"=="loaded" if /i not "%IPSET_MODE%"=="none" set "IPSET_MODE=any"
set "IPSET_INCLUDE="
if /i "%IPSET_MODE%"=="loaded" set IPSET_INCLUDE=--ipset="%ROOT%lists\ipset-all.txt"
set "PROFILE_TITLE=General AUTO"
set "PROFILE_DESCRIPTION=Automatic per-host strategy rotation via Zapret 2 circular orchestrator."
set "PROFILE_NEEDS_AUTO_LUA=1"
set "PROFILE_NEEDS_LISTS=1"
set "PROFILE_NEEDS_IPSET=1"
set "PROFILE_ARGS=--wf-tcp-empty=1 --wf-tcp-in=80,443,500,1701,2408,4500,8095 --wf-tcp-out=80,443,500,1701,2408,4500,8095 --wf-udp-in=443,500,1701,2408,4500,8095 --wf-udp-out=443,500,1701,2408,4500,8095"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-lib.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-antidpi.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@"%ROOT%bin\lua\zapret-auto.lua"
set PROFILE_ARGS=%PROFILE_ARGS% --blob=quic_google:@"%ROOT%bin\files\quic_initial_www_google_com.bin"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.discord_media.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.stun.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.wireguard.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@"%ROOT%bin\windivert.filter\windivert_part.quic_initial_ietf.txt"
set PROFILE_ARGS=%PROFILE_ARGS% --in-range=a

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=80 --filter-l7=http --hostlist="%ROOT%lists\list-general.txt" --hostlist="%ROOT%lists\list-general-user.txt" --hostlist-exclude="%ROOT%lists\list-exclude.txt" --hostlist-exclude="%ROOT%lists\list-exclude-user.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=http_req
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:retrans=2:maxseq=16384:inseq=4096
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_http:payload=http_req:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=1
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fakedsplit:payload=http_req:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=2
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multisplit:pos=2:payload=http_req:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=443 --filter-l7=tls --hostlist="%ROOT%lists\list-general.txt" --hostlist="%ROOT%lists\list-general-user.txt" --hostlist="%ROOT%lists\list-google.txt" --hostlist-exclude="%ROOT%lists\list-exclude.txt" --hostlist-exclude="%ROOT%lists\list-exclude-user.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=tls_client_hello
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:retrans=2:maxseq=16384:inseq=4096
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_tls:payload=tls_client_hello:repeats=8:tls_mod=rnd,dupsid,sni=www.google.com:strategy=1
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multidisorder:payload=tls_client_hello:pos=1,midsld:strategy=2
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multisplit:payload=tls_client_hello:pos=midsld:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 --filter-l7=quic --hostlist="%ROOT%lists\list-general.txt" --hostlist="%ROOT%lists\list-general-user.txt" --hostlist="%ROOT%lists\list-google.txt" --hostlist-exclude="%ROOT%lists\list-exclude.txt" --hostlist-exclude="%ROOT%lists\list-exclude-user.txt" --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=quic_initial
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:udp_out=4:udp_in=1
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=quic_google:payload=quic_initial:repeats=8:strategy=1
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_quic:payload=quic_initial:repeats=6:strategy=2
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=quic_google:payload=quic_initial:repeats=12:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=80,443 %IPSET_INCLUDE% --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:retrans=2:maxseq=16384:inseq=4096
if /i not "%IPSET_MODE%"=="none" if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=1:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=1
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fakedsplit:payload=all:strategy=2
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multisplit:pos=2:payload=all:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 %IPSET_INCLUDE% --ipset-exclude="%ROOT%lists\ipset-exclude.txt" --ipset-exclude="%ROOT%lists\ipset-exclude-user.txt" --payload=all
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:udp_out=4:udp_in=1
if /i not "%IPSET_MODE%"=="none" if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=1:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=1
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x0000000000000000000000000000000000000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=2
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=4:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=500,1701,2408,4500,8095 --payload=all
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:retrans=2:maxseq=4096:inseq=1024
if /i not "%IPSET_MODE%"=="none" if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=1:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=1
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x0000000000000000000000000000000000000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=2
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=4:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=3:final
set PROFILE_ARGS=%PROFILE_ARGS% --new --in-range=a

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=500,1701,2408,4500,8095 --payload=all
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=circular:fails=3:time=120:udp_out=4:udp_in=1
if /i not "%IPSET_MODE%"=="none" if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=1:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=1
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x0000000000000000000000000000000000000000000000000000000000000000:payload=all:repeats=2:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=2
if /i not "%IPSET_MODE%"=="none" set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:payload=all:repeats=4:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:strategy=3:final

if /i "%~1"=="--profile" exit /b 0
call "%ROOT%utils\run-profile.bat" "%~f0" %*
