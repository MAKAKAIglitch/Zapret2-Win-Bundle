# Repository layout

The repository owns a small Windows BAT launcher layer and uses the upstream Zapret 2 Windows bundle as its runtime.

Root:
- service.bat — service manager and profile selector.
- general.bat, general (ALT).bat, general (AUTO).bat, ipset-any.bat — selectable strategy profiles.

Folders:
- bin/ — local upstream runtime; excluded from Git.
- lists/ — copied domain and IP-set lists plus user-editable lists.
- utils/ — helper scripts used by root-level profiles.
- data/ — local selected profile state; selected-profile.txt is ignored by Git.
- docs/ — project documentation.

Strategy BAT files export PROFILE_TITLE and PROFILE_ARGS when called with --profile. service.bat discovers them by scanning root-level BAT files, excluding itself.
