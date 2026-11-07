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
