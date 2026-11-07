# Lists

Copied source lists:
- ipset-all.txt — active 33,336-entry IP/CIDR list (promoted from the source repository's backup).
- ipset-exclude.txt — reserved/local IP ranges.
- list-general.txt — general hostlist.
- list-google.txt — Google/YouTube hostlist.
- list-exclude.txt — hostlist exclusions.
- dns-servers.txt — DNS resolver hostnames.
- hostlist-auto.txt.example — autohostlist template from source.
- minecraft-domains.txt and minecraft-servers.txt — reference lists.

User-editable files:
- list-general-user.txt — additional hostnames to include.
- list-exclude-user.txt — hostnames to exclude.
- ipset-exclude-user.txt — IP addresses/CIDRs to exclude.

The service strategies combine the standard lists with the corresponding user lists. One hostname or IP/CIDR per line. Keep comments on lines beginning with #.

The service menu offers IPSet modes ANY (no include filter), LOADED (use ipset-all.txt) and NONE (skip IPSet-only rules). ANY is not represented by an empty file in Zapret 2; it is represented by omitting the --ipset include filter. The separate ipset-any.bat and ipset-loaded-auto.bat profiles run their fixed mode across all local TCP/UDP ports.
