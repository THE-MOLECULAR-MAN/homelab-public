#!/bin/bash
# Tim H 2022
# Manual uninstall of Sophos Home for OS X
# Do NOT just drag their icon to the trash in OS X, you have to run their
# specific uninstall tool.
#
# References:
#   https://support.home.sophos.com/hc/en-us/articles/115005499786-Uninstalling-Sophos-Home-on-Mac-computers

# visit this page and manually download the file
# they've got protection against automated downloads,
# so scripts can't download it.
#   https://download.sophos.com/tools/RemoveSophosEndpoint.zip

# try this first, but it usually fails:
unzip RemoveSophosEndpoint.zip

# run that app

# if that didn't work:

# reboot into recovery mode and disable System Integrity Protection
# https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection
# only available in recovery mode:
csrutil disable

# reboot into normal mode and run these commands:
sudo systemextensionsctl uninstall 2H5GFH3774 com.sophos.endpoint.scanextension
sudo systemextensionsctl uninstall 2H5GFH3774 com.sophos.endpoint.networkextension

# reboot into recovery mode and re-enable System Integrity Protection
csrutil enable

# reboot into normal mode again:
# run sophos's uninstaller. It should be successful this time.

# reboot to finish applying changes
# clean up any other leftover files:
# sudo find / -iname '*sophos*' 2> /dev/null > ~/sophosfinds.txt