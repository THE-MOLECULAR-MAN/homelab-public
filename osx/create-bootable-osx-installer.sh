#!/bin/bash
# Tim H 2022
# create bootable flash drive for OSX Big Sur (macOS 11.x) installer
# https://support.apple.com/en-mide/HT201372
# latest OS X version based on hardware SKU:
#   https://eshop.macsales.com/guides/Mac_OS_X_Compatibility
# 
# Step 1: install this on a different Mac. Takes 45-60 min @ 60 mbps
#   macappstores://apps.apple.com/us/app/macos-big-sur/id1526878132?mt=12
# Step 2: insert flash drive with RW capability
# Step 3: run this command and replace the last part with the mount point for
#  your flash drive

sudo /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/createinstallmedia --volume /Volumes/silverFlash
sudo diskutil unmount "/Volumes/Install macOS Big Sur"

