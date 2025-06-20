#!/bin/bash
# Tim H 2022, 2024
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

# find available installers:
find /Applications -type f -name 'createinstallmedia'

# list flash drives:
diskutil list

# flash drive needs to be "formatted as Mac OS Extended" (journaled)
# seems like the partition table needs to be Apple Partition Map

# create the installer on the flash drive
sudo /Applications/Install\ macOS\ Ventura.app/Contents/Resources/createinstallmedia --volume /Volumes/f1

# it will rename the mount point, need to unmount before removing it
sudo diskutil unmount "/Volumes/Install macOS Ventura"



# Next steps:
# 1) boot up Macbook Pro and hold the Option button
# 2) Boot into the Disk Manager
# 3) Format the local HDD with the GUID Partition Table schema
# 4) Start the installer