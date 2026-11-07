# List sources

Copied from:
https://github.com/MAKAKAIglitch/zapret-discord-youtube-warp/tree/main/lists

The linked source repository's active lists/ipset-all.txt was a 17-byte placeholder containing 203.0.113.113/32. Its full 33,336-entry IPv4/IPv6 CIDR list is stored in lists/ipset-all.txt.backup. The source repository also has .service/ipset-service.txt, which is the same 33,336 CIDR entries after normalizing line endings (LF vs CRLF); its service.bat uses that file as the list-update source. This bundle promotes the linked lists/ipset-all.txt.backup content to the active lists/ipset-all.txt and retains the original placeholder under lists/source/ipset-all-placeholder.txt.

Other files in the source lists directory were copied without changing their contents. User-editable lists are separate files ending in -user.txt.
