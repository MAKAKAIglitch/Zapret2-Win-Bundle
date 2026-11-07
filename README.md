# Zapret2-Win-Bundle

A Windows BAT-based bundle manager for Zapret 2. The service manager and strategy BAT files live in the repository root; runtime files, lists and helpers are separated into folders.

## Layout

- service.bat — service manager and strategy selector
- SETUP_RUNTIME.bat — downloads and verifies the pinned upstream Windows runtime
- general.bat, general (ALT).bat, general (AUTO).bat, ipset-any.bat, ipset-loaded-auto.bat — root-level strategies
- bin/ — upstream Windows runtime (not committed)
- lists/ — domain lists and IP sets
- utils/ — helper BAT files
- docs/ — project notes
- data/ — local selected-strategy state

## Prepare runtime

1. Run SETUP_RUNTIME.bat (or choose option 8 in service.bat).
2. The installer downloads a pinned commit of the official [bol-van/zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle), extracts only zapret-winws, and verifies the required Zapret 2, Lua and WinDivert files before copying them into bin.
3. When an older runtime is already present, the installer asks for UPDATE and backs up the previous bin contents under data/runtime-backup/.
4. Run service.bat and choose option 6 to check the runtime and lists.

The installer does not execute the downloaded binaries. The selected upstream commit is recorded in bin/runtime-version.txt.

## Strategies

- General — static HTTP/TLS/QUIC rules, IP-set rules, and the requested ports.
- General ALT — alternative TLS initialization.
- General AUTO — automatic per-host strategy rotation using zapret-auto.lua.
- IPSet ANY AUTO — automatic rotation for all local TCP/UDP ports (1–65535), with no include IP-set restriction.
- IPSet LOADED AUTO — the same all-port automatic profile, restricted to the 33,336-entry lists/ipset-all.txt.

The automatic profiles use Zapret 2's upstream circular orchestrator. It rotates among strategy variants based on connection-feedback counters. For each profile block, incoming packets are enabled while the circular detector runs and then disabled for the outgoing desync actions. This is feedback-based automation, not an external connectivity test, and cannot guarantee the best strategy on every network.

## Requested ports

General, General ALT and General AUTO intercept TCP and UDP ports 500, 1701, 2408, 4500 and 8095 in both directions. These profiles include payload=all rules for the five ports.

The two IPSet AUTO profiles are broader: they capture TCP and UDP ports 1–65535 in both directions. ANY omits the IP-set include filter and applies to all eligible remote addresses; LOADED selects addresses using lists/ipset-all.txt. They are not limited to the five additional ports.

The inbound filters provide connection feedback; the Lua desync actions principally affect outgoing packets. Windows WinDivert does not correctly intercept forwarded traffic behind Windows NAT; this bundle is intended for traffic to/from the local PC.

The profiles enable --wf-tcp-empty=1. Capturing empty TCP ACK packets improves packet-counter feedback but can increase CPU usage, particularly with all-port capture.

## Lists

Lists were copied from [MAKAKAIglitch/zapret-discord-youtube-warp/lists](https://github.com/MAKAKAIglitch/zapret-discord-youtube-warp/tree/main/lists).

In the source repository, lists/ipset-all.txt was a 17-byte placeholder. Its full 33,336-entry IPv4/IPv6 CIDR set was stored in lists/ipset-all.txt.backup. The source's .service/ipset-service.txt contains the same CIDR entries with different line endings. This project promotes the requested lists/ipset-all.txt.backup content to lists/ipset-all.txt and keeps the placeholder under lists/source/.

See lists/SOURCES.md for details.

## IPSet modes

The service menu cycles the optional IPSet inclusion blocks used by General, General ALT and General AUTO: **ANY** (default; no include filter), **LOADED** (the full lists/ipset-all.txt list), and **NONE** (skip those broad IPSet-only blocks). Domain hostlist rules and the five extra port rules remain active in all three modes; reserved/private IP exclusion lists remain attached to the domain rules. The dedicated IPSet ANY AUTO and IPSet LOADED AUTO profiles have fixed behavior independent of this switch. Zapret 2 does not treat a zero-byte include list as ANY; ANY is implemented by omitting `--ipset` while retaining the exclusion lists.

## Service manager

Run service.bat as administrator. It manages the dedicated Zapret2WinBundle service. Stop/remove operations target only that service. Strategy BAT files can also be run directly.

The upstream Zapret 2 Windows bundle leaves its service creation example commented out and warns that service mode requires manual configuration. This project's service mode is therefore marked experimental. Runtime download and hash verification are automated, but actual WinDivert driver loading and service startup must still be tested on the target Windows PC.

## Upstream

- [Zapret 2 Windows bundle](https://github.com/bol-van/zapret-win-bundle)
- [Zapret 2 source and manual](https://github.com/bol-van/zapret2)
- [Upstream Zapret 2 preset](https://github.com/bol-van/zapret-win-bundle/blob/master/zapret-winws/preset2_example.cmd)
- [Zapret 2 automatic strategy library](https://github.com/bol-van/zapret-win-bundle/blob/master/zapret-winws/lua/zapret-auto.lua)
