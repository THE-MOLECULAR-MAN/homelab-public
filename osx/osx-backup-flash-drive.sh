#!/bin/bash
# Tim H 2021
#
# Backup a whole flash drive, including all partitions, to a single image file
# on the local OS X system. This compresses the image file too.

# make sure you've got the right one, easy to get it wrong and fill up your 
# whole hdd

# https://kb.plugable.com/data-storage/trim-an-ssd-in-macos
# sudo trimforce enable

# brew install --cask gdisk

diskutil list
DISK_TO_BACKUP="/dev/disk2"

# get the current date and time in string that doesn't have any whitespace
NOW=$(date +"%Y_%m_%d_%I_%M_%p_%z")

# gather the disk size, but it includes whitespce
DISK_SIZE_WITH_WHITESPACE=$(diskutil list | grep "$(basename $DISK_TO_BACKUP)" | grep 'FDisk_partition_scheme' | cut -d '*' -f2 | cut -d ' ' -f1-2)

# replace the whitespace with underscores
# DISK_SIZE_CLEAN=$(echo ${DISK_SIZE_WITH_WHITESPACE// /_})
DISK_SIZE_CLEAN="${DISK_SIZE_WITH_WHITESPACE// /_}"

# construct a non-whitespace filename that clearly describes the backup file
BACKUP_FILE="$HOME/usb-device-full-disk-backup-$NOW-$DISK_SIZE_CLEAN.img"
INFO_FILE="$HOME/usb-device-full-disk-backup-$NOW-$DISK_SIZE_CLEAN.info.txt"

# debugging, view the filename:
echo "$BACKUP_FILE"

# unmount - this seems to break things sometimes but not always
# the FAT32 /boot file system will mount but the EXT4 root file system 
# won't mount on OS X by default
# seems like this might be necessary for FAT32 devices like microsd cards
diskutil unmountDisk "$DISK_TO_BACKUP"

# image it
# requires sudo to gain full disk access to USB drive
rm "$BACKUP_FILE"
touch "$BACKUP_FILE"
sudo dd if="$DISK_TO_BACKUP" of="$BACKUP_FILE" bs=1m status=progress
# 63864569856 bytes transferred in 14842.816183 secs (4302726 bytes/sec)

# hashsum
md5sum "$BACKUP_FILE" > "$BACKUP_FILE.md5"

# list important info about disk in text file
rm -f "$INFO_FILE"
sudo gdisk -l "$DISK_TO_BACKUP" | sudo tee "$INFO_FILE"
# df -h "$DISK_TO_BACKUP" > "$INFO_FILE"

# compress the file after the fact, deletes the original
# -1 flag uses fastest compression
gzip -1 "$BACKUP_FILE"

# sudo dd if="$DISK_TO_BACKUP" | gzip -c > "$BACKUP_FILE"
# only transferring at 13 megabytes per second = 41 minutes for 32 GB :-(

# ./send_slack_notification "Finished imaging $BACKUP_FILE"
