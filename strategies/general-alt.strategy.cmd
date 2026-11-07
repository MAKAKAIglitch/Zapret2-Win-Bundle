@echo off
rem Alternate TLS variant of the General Zapret 2 profile.

set "PROFILE_TITLE=General ALT"
set "PROFILE_DESCRIPTION=General с дополнительной рандомизацией TLS ClientHello."
set "PROFILE_NEEDS_GENERAL_ASSETS=1"
set "PROFILE_NEEDS_AUTO_LUA=0"

set PROFILE_ARGS=--wf-tcp-out=80,443
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@\"%ROOT%bin\lua\zapret-lib.lua\"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=@\"%ROOT%bin\lua\zapret-antidpi.lua\"
set PROFILE_ARGS=%PROFILE_ARGS% --lua-init=\"fake_default_tls = tls_mod(fake_default_tls,'rnd,rndsni')\"
set PROFILE_ARGS=%PROFILE_ARGS% --blob=quic_google:@\"%ROOT%bin\files\quic_initial_www_google_com.bin\"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@\"%ROOT%bin\windivert.filter\windivert_part.discord_media.txt\"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@\"%ROOT%bin\windivert.filter\windivert_part.stun.txt\"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@\"%ROOT%bin\windivert.filter\windivert_part.wireguard.txt\"
set PROFILE_ARGS=%PROFILE_ARGS% --wf-raw-part=@\"%ROOT%bin\windivert.filter\windivert_part.quic_initial_ietf.txt\"

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=80 --filter-l7=http --out-range=-d10 --payload=http_req
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_http:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:tcp_md5
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fakedsplit:ip_autottl=-2,3-20:ip6_autottl=-2,3-20:tcp_md5
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=443 --filter-l7=tls --hostlist=\"%ROOT%bin\files\list-youtube.txt\"
set PROFILE_ARGS=%PROFILE_ARGS% --out-range=-d10 --payload=tls_client_hello
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_tls:tcp_md5:repeats=11:tls_mod=rnd,dupsid,sni=www.google.com
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multidisorder:pos=1,midsld
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-tcp=443 --filter-l7=tls --out-range=-d10 --payload=tls_client_hello
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_tls:tcp_md5:tcp_seq=-10000:repeats=6
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=multidisorder:pos=midsld
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 --filter-l7=quic --hostlist=\"%ROOT%bin\files\list-youtube.txt\" --payload=quic_initial
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=quic_google:repeats=11
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-udp=443 --filter-l7=quic --payload=quic_initial
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=fake_default_quic:repeats=11
set PROFILE_ARGS=%PROFILE_ARGS% --new

set PROFILE_ARGS=%PROFILE_ARGS% --filter-l7=wireguard,stun,discord
set PROFILE_ARGS=%PROFILE_ARGS% --payload=wireguard_initiation,wireguard_cookie,stun,discord_ip_discovery
set PROFILE_ARGS=%PROFILE_ARGS% --lua-desync=fake:blob=0x00000000000000000000000000000000:repeats=2

exit /b 0
