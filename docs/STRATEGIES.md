# Root-level strategies

All selectable strategy BAT files and service.bat live directly in the repository root, like the Flowseal bundle layout. Runtime components, lists, helper scripts and docs remain in folders.

## Profiles

The service selector discovers root-level BAT files that export PROFILE_ARGS. Current selectable profiles:

| Profile file | Technique / purpose | Notes |
|---|---|---|
| `general.bat` | Balanced HTTP/TLS/QUIC, optional IPSet blocks | Starting point |
| `general (ALT).bat` | Alternate TLS initialization / SNI handling | Compare if default TLS is unstable |
| `general (AUTO).bat` | Per-host circular strategy rotation | Feedback-based heuristic |
| `general-fake-only.bat` | Fake only | Minimal baseline |
| `general-fakedsplit.bat` | Fake + fakedsplit | Fake segments inserted around real segments |
| `general-multisplit.bat` | Pure multisplit | TCP segmentation without fake |
| `general-multidisorder.bat` | Multidisorder | Sends split TCP segments in reverse order |
| `general-hostfakesplit.bat` | HostFakeSplit | Experimental host-focused method |
| `general-legacy-disorder.bat` | multidisorder_legacy | Compatibility comparison |
| `general-window.bat` | WSSIZE + multisplit | Experimental; can reduce throughput |
| `ipset-any.bat` | All-port automatic profile, no IPSet include | Captures local TCP/UDP 1–65535 |
| `ipset-loaded-auto.bat` | All-port automatic profile, loaded IPSet only | Uses `lists/ipset-all.txt` |

Each profile exports `PROFILE_TITLE` and `PROFILE_ARGS` when called with `--profile`. `service.bat` scans root-level `*.bat` files, excluding itself, and offers profiles that export `PROFILE_ARGS`.

## How to compare profiles

1. Stop the currently running Zapret2 process/service before launching another profile.
2. Select one profile in `service.bat` or launch its BAT file directly.
3. Test the same blocked domains/services and the same protocol each time.
4. Keep the profile that works reliably; a larger number of desync actions does not automatically mean better speed or compatibility.

The profiles are deliberately different algorithms, not merely copies with changed names. Fake-only is a useful control. Fakedsplit combines fake traffic with split segments. Multisplit and multidisorder are alternatives without fake packets. Legacy disorder exists to compare the older algorithm. HostFakeSplit and WSSIZE are marked experimental.

## Requested ports

All General-family profiles capture TCP and UDP ports 500, 1701, 2408, 4500 and 8095 in both directions. The rules use `--payload=all` so unknown and non-HTTP/TLS/QUIC traffic on these ports is not filtered out by the payload type.

These five extra ports are broad. Fake/desync actions on IKE/IPsec, L2TP, WireGuard-over-UDP or other VPN traffic can affect handshakes. The port coverage is preserved across the strategy variants; the actual desync method differs.

## IPSet modes

The service menu cycles the optional IPSet blocks in General-family profiles:

- **ANY** (default): no `--ipset` include filter; IPSet rules apply to all eligible remote addresses, subject to exclusion lists.
- **LOADED**: include only addresses/subnets from `lists/ipset-all.txt`.
- **NONE**: skip the broad IPSet-only include blocks; domain hostlists and the five additional ports remain active.

Zapret 2 does not accept a zero-byte file as an ordinary include IPSet. ANY is correctly represented by omitting the `--ipset` parameter. The dedicated `ipset-any.bat` and `ipset-loaded-auto.bat` profiles have fixed ANY/LOADED behavior independent of this service setting.

## Automatic selection

AUTO profiles use the upstream `zapret-auto.lua` circular orchestrator. TCP rotation uses retransmission/RST/redirect feedback; UDP rotation observes outbound packets and inbound replies. Rotation is per host/IP and heuristic; it cannot guarantee the right strategy for every protocol or network.

## Capture scope and performance

WinDivert on Windows handles traffic to/from the local PC. It does not correctly intercept forwarded traffic behind Windows NAT. The dedicated IPSet AUTO profiles capture all local TCP/UDP ports 1–65535 and can use significantly more CPU, especially with `--wf-tcp-empty=1`. General profiles are narrower.
