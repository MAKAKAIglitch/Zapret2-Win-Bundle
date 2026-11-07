# Root-level strategies

All selectable strategy BAT files and service.bat live directly in the repository root, like the Flowseal bundle layout. The old strategies/ subfolder is not used.

## Profiles

- general.bat — static HTTP/TLS/QUIC profile, host lists, IP-set rules, and the five requested extra ports.
- general (ALT).bat — alternative TLS initialization with the same port coverage.
- general (AUTO).bat — per-host automatic strategy rotation using Zapret 2's circular orchestrator.
- ipset-any.bat — automatic per-host rotation for all TCP and UDP ports matched by lists/ipset-all.txt, using payload=all.

Each profile exports PROFILE_TITLE and PROFILE_ARGS when called with --profile. service.bat scans root-level *.bat files, excluding itself, and offers profiles that export PROFILE_ARGS.

## Requested ports

The regular General, General ALT, and General AUTO profiles capture TCP and UDP ports 500, 1701, 2408, 4500, and 8095 in both directions. They use payload=all for these port-specific rules, so the profile filter does not restrict handling to HTTP/TLS/QUIC payloads.

The IPSet ANY profile is broader: it captures local TCP and UDP ports 1-65535 in both directions, then applies the IP-set filter to select addresses from ipset-all.txt. It is not limited to the five extra ports.

WinDivert on Windows handles traffic to/from the local machine. It does not correctly intercept forwarded traffic behind Windows NAT, as documented by the upstream Zapret 2 manual. Inbound filters provide feedback/connection tracking; Lua desync actions principally affect outgoing packets.

## Automatic selection

The AUTO profiles use the upstream zapret-auto.lua circular orchestrator. TCP strategy rotation observes retransmissions, RST and HTTP redirect feedback; UDP rotation observes outbound packets without corresponding inbound replies. Rotation is per host/IP and is heuristic, not a guarantee that every destination or protocol will be classified correctly.

The orchestrator requires incoming feedback to be captured. The profiles therefore include inbound WinDivert filters alongside outbound filters.

## Performance

IPSet ANY captures every local TCP/UDP port before applying the IP-set match in the engine. This is intentionally broad and can increase CPU use, especially with --wf-tcp-empty=1. Use it when broad IP-set coverage is actually needed; General AUTO is narrower.
