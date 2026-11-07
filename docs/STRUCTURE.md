# Repository layout

The repository keeps project-owned Windows scripts separate from third-party runtime files.

- service.bat is the only root-level launcher. It handles elevation, service operations, and the strategy menu.
- strategies/ contains one profile per file. Only files ending in .strategy.cmd are shown in the menu.
- bin/ is the local copy of the upstream zapret-winws runtime and is intentionally excluded from Git.
- docs/ contains project-maintenance notes.

## Why Zapret 2 profiles are separate

Zapret 2 uses winws2.exe and Lua initialization. Flowseal's common BAT profiles are written for the Zapret 1 winws.exe command-line interface, so their command lines cannot be reused as-is. The strategy files in this repository are adapted from the upstream Zapret 2 Windows examples.

## Service ownership

The manager uses the dedicated service name Zapret2WinBundle. Stop/remove operations target this service only. It deliberately does not taskkill every winws2.exe process, because another installation or a manually started instance may be using that executable.
