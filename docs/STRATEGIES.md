# Root-level strategies

All selectable strategy BAT files and service.bat live directly in the repository root, like the Flowseal bundle layout. Runtime components, lists, helper scripts and docs remain in folders.

## Profiles

- `general.bat` — static HTTP/TLS/QUIC profile, hostlists, optional IPSet blocks, and the five requested extra ports.
- `general (ALT).bat` — alternative TLS initialization with the same port coverage.
- `general (AUTO).bat` — per-host automatic rotation using Zapret 2's circular orchestrator.
- `ipset-any.bat` — automatic rotation on all local TCP/UDP ports (1–65535), without an include IP-set filter.
- `ipset-loaded-auto.bat` — the same all-port automatic profile, restricted to `lists/ipset-all.txt`.

Each profile exports `PROFILE_TITLE` and `PROFILE_ARGS` when called with `--profile`. `service.bat` scans root-level `*.bat` files, excluding itself, and offers profiles that export `PROFILE_ARGS`.

## Requested ports

General, General ALT and General AUTO capture TCP and UDP ports 500, 1701, 2408, 4500 and 8095 in both directions. Their profile rules use `--payload=all` and their Lua actions explicitly use `payload=all` so unknown and non-HTTP/TLS/QUIC traffic is not filtered out by the payload type.

The five extra ports are broad. Fake/desync actions on IKE/IPsec, L2TP, WireGuard-over-UDP or other VPN traffic can affect handshakes. Test the intended VPN/protocols on the target network.

## IPSet modes

The service menu cycles the optional IPSet blocks in General, General ALT and General AUTO:

- **ANY** (default): no `--ipset` include filter; IPSet rules apply to all eligible remote addresses, subject to exclusion lists.
- **LOADED**: include only addresses/subnets from `lists/ipset-all.txt`.
- **NONE**: skip IPSet-only profile blocks; domain hostlists and the five additional ports remain active.

Zapret 2 does not accept a zero-byte file as an ordinary include IPSet. ANY is correctly represented by omitting the `--ipset` parameter. The dedicated `ipset-any.bat` and `ipset-loaded-auto.bat` profiles have fixed ANY/LOADED behavior independent of this service setting.

## Automatic selection

AUTO profiles use the upstream `zapret-auto.lua` circular orchestrator. For each profile block, inbound processing is enabled for the circular detector and then turned off for the remaining Lua desync actions. TCP rotation uses retransmission/RST/redirect feedback; UDP rotation observes outbound packets and inbound replies. Rotation is per host/IP and heuristic; it cannot guarantee the right strategy for every protocol or network.

## Capture scope and performance

WinDivert on Windows handles traffic to/from the local PC. It does not correctly intercept forwarded traffic behind Windows NAT. The dedicated IPSet AUTO profiles capture all local TCP/UDP ports 1–65535 and can use significantly more CPU, especially with `--wf-tcp-empty=1`. The General profiles are narrower.
