#!/bin/bash
# Tim H 2022
# forces OS X to update MDM profiles from MDM server
# just restarts a service. There is not a "reload" or "restart" action.

# check if System Integrity Protection is enabled
csrutil status
# if it is enabled, then you gotta reboot into Recovery mode and disable it
# you can also force and MDM profile update by rebooting. It's not possible
# to disable SIP without rebooting into Recovery mode.

# stop the service gracefully
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.mdmclient.daemon.plist

# start the service again
sudo launchctl load /System/Library/LaunchDaemons/com.apple.mdmclient.daemon.plist
