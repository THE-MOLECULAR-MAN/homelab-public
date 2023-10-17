#!/bin/bash
# Tim H 2022
# Backing up Velociraptor server on Ubuntu 20.04

set -e

SERVICE_NAME="velociraptor_server"    # name of service

# this is a pain and I had to remove some non-critical commands to support
# this space delimited version:
BACKUP_SOURCE_PATHS="/opt/velociraptor $HOME" # space delimited paths to backup

# requires sudo
VERSION_INFO=$(sudo velociraptor version | grep version | cut -d " " -f2)

# don't change:
DEST_BACKUP_PATH="/tmp"
TODAYS_DATE=$(date +%Y-%m-%d)
DEST_BACKUP_FILENAME="backup-$SERVICE_NAME-$VERSION_INFO-$TODAYS_DATE.tar.gz"
DEST_BACKUP_FULLPATH="$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME"

# make sure destination exists
cd "$DEST_BACKUP_PATH" || exit 1

# delete if it already exists
sudo rm -f "$DEST_BACKUP_FILENAME"

# stop the service
sudo service "$SERVICE_NAME" stop

# compress it, not verbose, no progress meter
# intentionally NOT quoting so it will expand multiple paths
sudo tar -zcf "$DEST_BACKUP_FULLPATH" $BACKUP_SOURCE_PATHS

# show the contents of the backup, this should show ALL the paths
tar -ztvf "$DEST_BACKUP_FULLPATH"

# view the size of backup
ls -lah "$DEST_BACKUP_FULLPATH"

# create checksum of the backup file next to original
sha256sum "$DEST_BACKUP_FULLPATH" > "$DEST_BACKUP_FULLPATH.sha256"

# mark it as global readable to allow easy retrieval over SCP
# better support for EC2
sudo mv "$DEST_BACKUP_FULLPATH*" "$HOME/"
sudo chmod 777 "$HOME/backup-*"

# restart the service
sudo service "$SERVICE_NAME" start

# this was very particular for some reason and didn't like wildcard
# scp velociraptor.REDACTED:/home/ubuntu/backup-velociraptor_server-0.6.5-2-2022-10-31.tar.gz.sha256 /Users/redacted/Documents/no_backup
# scp velociraptor.REDACTED:/home/ubuntu/backup-velociraptor_server-0.6.5-2-2022-10-31.tar.gz        /Users/redacted/Documents/no_backup
