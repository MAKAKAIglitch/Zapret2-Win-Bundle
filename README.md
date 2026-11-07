# Zapret2-Win-Bundle

A Windows BAT-based bundle manager for Zapret 2. The service manager and strategy BAT files live in the repository root; runtime files, lists and helpers are separated into folders.

## Layout

- service.bat — service manager and strategy selector
- general.bat, general (ALT).bat, general (AUTO).bat, ipset-any.bat — root-level strategies
- bin/ — upstream Windows runtime (not committed)
- lists/ — domain lists and IP sets
- utils/ — helper BAT files
- docs/ — project notes
- data/ — local selected-strategy state

## Prepare runtime

1. Download the Windows bundle from [bol-van/zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle).
2. Copy the contents of its zapret-winws folder into this repository's bin folder.
3. Keep winws2.exe and all Lua files from the same upstream revision.
4. Run service.bat and choose option 6 to check the runtime.

## Strategies

- General — static HTTP/TLS/QUIC rules, IP-set rules, and the requested ports.
- General ALT — alternative TLS initialization.
- General AUTO — automatic per-host strategy rotation using zapret-auto.lua.
- IPSet ANY AUTO — automatic per-host rotation for all TCP/UDP ports matched by ipset-all.txt, with payload=all.

The automatic profiles use the upstream circular orchestrator. It rotates among strategy variants when connection failure feedback is detected. This is feedback-based automation, not an external connectivity test, and cannot guarantee the best strategy on every network.

## Requested ports

General, General ALT and General AUTO intercept TCP and UDP ports 500, 1701, 2408, 4500 and 8095 in both directions. These profiles include payload=all rules for the five ports.

IPSet ANY AUTO is broader: it captures TCP and UDP ports 1-65535 in both directions, then selects addresses using lists/ipset-all.txt. It is not limited to the five additional ports.

The inbound filters provide connection feedback; the Lua desync actions principally affect outgoing packets. Windows WinDivert does not correctly intercept forwarded traffic behind Windows NAT; this bundle is intended for traffic to/from the local PC.

The profiles enable --wf-tcp-empty=1. Capturing empty TCP ACK packets improves packet-counter feedback but can increase CPU usage, particularly with all-port capture.

## Lists

Lists were copied from [MAKAKAIglitch/zapret-discord-youtube-warp/lists](https://github.com/MAKAKAIglitch/zapret-discord-youtube-warp/tree/main/lists).

In the source repository, lists/ipset-all.txt was a 17-byte placeholder. Its full 33,336-entry IPv4/IPv6 list was stored in lists/ipset-all.txt.backup. This project promotes that full backup content to lists/ipset-all.txt and keeps the placeholder under lists/source/.

See lists/SOURCES.md for details.

## Service manager

Run service.bat as administrator. It manages the dedicated Zapret2WinBundle service. Stop/remove operations target only that service. Strategy BAT files can also be run directly.

The upstream Zapret 2 Windows bundle leaves its service creation example commented out and warns that service mode requires manual configuration. Therefore this project's service mode remains experimental until tested on the target Windows installation.

## Upstream

- [Zapret 2 Windows bundle](https://github.com/bol-van/zapret-win-bundle)
- [Zapret 2 source and manual](https://github.com/bol-van/zapret2)
- [Upstream Zapret 2 preset](https://github.com/bol-van/zapret-win-bundle/blob/master/zapret-winws/preset2_example.cmd)
- [Zapret 2 automatic strategy library](https://github.com/bol-van/zapret-win-bundle/blob/master/zapret-winws/lua/zapret-auto.lua)
