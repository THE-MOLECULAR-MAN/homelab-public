#!/bin/bash
# Tim H 2021
#
# Backup a whole flash drive, including all partitions, to a single image file
# on the local OS X system. This compresses the image file too.

# make sure you've got the right one, easy to get it wrong and fill up your 
# whole hdd

# TODO: add date or name to compressed filename
diskutil list

DISK_TO_BACKUP="/dev/disk4"
BACKUP_FILE="$HOME/flash-drive-backup.img.dd.gz"

# unmount - this seems to break things sometimes but not always
# the FAT32 /boot file system will mount but the EXT4 root file system 
# won't mount on OS X by default
# diskutil unmountDisk "$DISK_TO_BACKUP"

# create the file so it has the right permissions on it
touch "$BACKUP_FILE"

# image it and compress it at the same time
# the dd command doesn't show progress, no easy way to know how long it will
# take or show remaining time
sudo dd if="$DISK_TO_BACKUP" | gzip -c > "$BACKUP_FILE"
