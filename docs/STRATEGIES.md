# Root-level strategies

The selectable strategy BAT files are stored in the repository root.

- general.bat — static HTTP/TLS/QUIC profile with IP-set rules and the requested ports.
- general (ALT).bat — alternative TLS variant.
- general (AUTO).bat — automatic per-host strategy rotation via Zapret 2's circular orchestrator.
- ipset-any.bat — IP-set matching with payload=all.

service.bat scans root-level BAT files and offers each file that exports PROFILE_ARGS when called with --profile.

The automatic profile uses zapret-auto.lua. It captures incoming and outgoing traffic on TCP/UDP 80/443 and the requested additional ports so the standard success/failure detectors can inspect connection feedback. The detectors are heuristics; they cannot guarantee strategy selection on every protocol or network.

The requested ports are captured in both directions for TCP and UDP: 500, 1701, 2408, 4500, 8095.

--wf-tcp-empty=1 is enabled so empty TCP packets are captured too. This affects all TCP ports selected by the profile and can increase CPU overhead.

IP-set matching (--ipset) selects addresses/subnets. --payload=all selects all payload types, including unknown and empty payloads at the C filter level. Lua functions from zapret-antidpi.lua have their own payload filter, so the custom-port and IP-set rules explicitly set payload=all on the Lua action as well.
