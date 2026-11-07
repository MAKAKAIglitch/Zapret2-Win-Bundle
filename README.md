# Zapret2-Win-Bundle

Windows BAT-based bundle manager for **Zapret 2**. The project keeps the launcher and strategy profiles separate from upstream engine files.

## Structure

- service.bat — service manager and strategy selector
- strategies/ — Zapret 2 profiles
- bin/ — upstream runtime files (not committed)
- docs/ — project documentation
- LICENSE — applies to this repository's original scripts and documentation

## Preparing the runtime

1. Download the Windows bundle from [bol-van/zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle).
2. Open its zapret-winws directory.
3. Copy the **contents** of zapret-winws into this repository's bin directory.
4. Check that bin\winws2.exe, bin\lua\zapret-lib.lua, and the WinDivert files exist.

Do not mix winws2.exe with Lua scripts from another revision. Zapret 2 checks Lua compatibility.

## Usage

Run service.bat. The manager requests administrator rights because Windows service operations require them.

1. Select a strategy.
2. Run the component check.
3. Install/update the Zapret2WinBundle service.
4. Start or stop the service from the same menu.

The service is configured for automatic startup with Windows. The manager only stops or removes its own service; it does not terminate every winws2.exe process on the machine.

## Included profiles

- **General** — general HTTP, TLS, QUIC and protocol filters, based on the upstream preset2_example.cmd.
- **General ALT** — same profile with the upstream TLS randomization initialization example.
- **WireGuard** — separate WireGuard initiation profile based on the upstream preset2_wireguard.cmd; it is not a general browsing profile.

See [strategies/README.md](strategies/README.md) for details.

## Important service-mode note

The upstream Windows bundle includes a Zapret 2 service-creation example, but its automatic sc create calls are commented out and the file warns that service installation needs manual configuration. This project exposes service installation through an explicit confirmation prompt and performs file checks first, but the service mode is still **experimental** and has not been runtime-tested here. If the service does not start correctly, use the upstream standalone preset workflow and report the exact error/status.

## Upstream components and licensing

This repository does not include winws2.exe, WinDivert binaries, or the upstream Lua runtime. Those files remain separate upstream components and retain their own licenses and notices. The root LICENSE applies to the original scripts and documentation in this repository only.

Upstream references:
- [Zapret Windows bundle](https://github.com/bol-van/zapret-win-bundle)
- [Zapret 2 source](https://github.com/bol-van/zapret2)
- [Upstream Zapret 2 Windows preset](https://github.com/bol-van/zapret-win-bundle/blob/master/zapret-winws/preset2_example.cmd)
- [Upstream WireGuard preset](https://github.com/bol-van/zapret-win-bundle/blob/master/zapret-winws/preset2_wireguard.cmd)
