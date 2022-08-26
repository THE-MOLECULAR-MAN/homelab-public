#!/bin/bash
# Tim H 2022
# MOVE_TO_GRAVEYARD
# Backing up NXLog from CentOS 7

set -e

# custom:
SERVICE_NAME="nxlog"
VERSION_INFO=$(nxlog --help | head -n1)
BACKUP_SOURCE_PATHS="/etc/nxlog /var/log/nxlog"

# don't change:
DEST_BACKUP_PATH="/nfs_backup/$(hostname)"
TODAYS_DATE=$(date +%Y-%m-%d)
DEST_BACKUP_FILENAME="backup-$SERVICE_NAME-$VERSION_INFO-$TODAYS_DATE.tar.gz"

# make sure destination exists
cd "$DEST_BACKUP_PATH" || exit 1

# stop the service
sudo service "$SERVICE_NAME" stop

# check for open files
#sudo lsof $BACKUP_SOURCE_PATHS

# check size of source:
#du -sh "$BACKUP_SOURCE_PATHS"

# check for available free space in destination
df -h "$DEST_BACKUP_PATH"

# compress it, not verbose, no progress meter
# intentionally NOT quoting so it will expand multiple paths
tar -zcf "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME" $BACKUP_SOURCE_PATHS

# show the contents of the backup:
tar -ztvf "$DEST_BACKUP_FILENAME"

# view the size of backup
ls -lah "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME"

# create checksum of the backup file next to original
sha256sum "$DEST_BACKUP_FILENAME" > "$DEST_BACKUP_FILENAME.sha256"

# restart the service
sudo service "$SERVICE_NAME" start
