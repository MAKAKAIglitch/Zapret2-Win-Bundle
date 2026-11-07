# Official runtime pin

The runtime is downloaded on the user's PC from the official repository:

- Repository: https://github.com/bol-van/zapret-win-bundle
- Pinned commit: bb6a20af35ed74778eb669f5413990eb8209c711
- Upstream commit date: 2026-11-05
- Runtime directory: bin/

INSTALL.bat calls utils/install-runtime.ps1. The installer uses commit-pinned raw.githubusercontent.com URLs and verifies each downloaded file against its Git blob SHA-1 before moving it into bin/.

This confirms exact correspondence with the pinned GitHub commit. It is not a security audit of upstream software.

## Downloaded files

| Runtime file | Upstream path |
| --- | --- |
| winws2.exe | zapret-winws/winws2.exe |
| WinDivert.dll | zapret-winws/WinDivert.dll |
| WinDivert64.sys | zapret-winws/WinDivert64.sys |
| cygwin1.dll | zapret-winws/cygwin1.dll |
| lua/zapret-lib.lua | zapret-winws/lua/zapret-lib.lua |
| lua/zapret-antidpi.lua | zapret-winws/lua/zapret-antidpi.lua |
| lua/zapret-auto.lua | zapret-winws/lua/zapret-auto.lua |
| files/quic_initial_www_google_com.bin | zapret-winws/files/quic_initial_www_google_com.bin |
| windivert.filter/windivert_part.*.txt | zapret-winws/windivert.filter/ |

The installer intentionally does not download Zapret 1, unrelated diagnostic tools, or extra executable utilities.

## Updating the runtime pin

When updating the pin, inspect the upstream commit and tree first. Update every file's Git blob SHA in utils/install-runtime.ps1 together with UpstreamCommit. Never change only the commit while leaving old hashes in place.
