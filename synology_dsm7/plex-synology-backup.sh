#!/bin/bash
# Tim H 2022

# backup the Plex installation on a Synology
# for my 46 GB deloyment on a Synology DS218+ it took about 41 min to run total

# References:
#   https://support.plex.tv/articles/201539237-backing-up-plex-media-server-data/
#   https://community.synology.com/enu/forum/1/post/149358
#   https://support.plex.tv/articles/202915258-where-is-the-plex-media-server-data-directory-located/

set -e

# user set variables:
SERVICE_NAME="PlexMediaServer"    # name of service
DEST_BACKUP_PATH="/volume1/time_machine_central/synology-plex-backup"

# don't change:
TODAYS_DATE=$(date +%Y-%m-%d)
DEST_BACKUP_FILENAME="backup-$SERVICE_NAME-$VERSION_INFO-$TODAYS_DATE.tar.gz"
VERSION_INFO=$(sudo synopkg version "$SERVICE_NAME")
BACKUP_SOURCE_PATH="/volume1/PlexMediaServer/AppData/Plex Media Server" # DSM 7 backup location

# stop the service, sudo is required
sudo synopkg stop "$SERVICE_NAME"

# clear out unnecessary files, tmp, cache stuff that doesn't need to be
# migrated
#sudo find "$BACKUP_SOURCE_PATH/Cache" "$BACKUP_SOURCE_PATH/Crash Reports" \
#    "$BACKUP_SOURCE_PATH/Logs" -mindepth 1 -delete

# create directory if it doesn't exist
sudo mkdir -p "$DEST_BACKUP_PATH"
sudo chown "$USER" "$DEST_BACKUP_PATH"

# check size of source data that will be compressed:
du -sh "$BACKUP_SOURCE_PATH"

# check for available free space in destination
df -h "$DEST_BACKUP_PATH"

# compress it:
# can't start a screen session first since Synology doesn't have "screen"
# also doesn't have "pv" to view progress
# time it too
# took 37 minutes wall time for 46 GB to be compressed into 24 GB
# average compression ratio was 50%
time tar -zcf "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME" "$BACKUP_SOURCE_PATH"
# faster version - with no compression, twice as fast, twice the file size
# took 16 minutes for 46 GB to be copied as 46 GB
# time tar -cf "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME" "$BACKUP_SOURCE_PATH"

# view the size of backup
ls -lah "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME"

# create checksum of the backup file next to original
# sha256 of the 46 GB tar file took about 10 minutes
time sha256sum "$DEST_BACKUP_FILENAME" > "$DEST_BACKUP_FILENAME.sha256"

# start the service again now that backup is finished
# skip if you're going to immediately restore it somewhere else
# don't run the original and backup at the same time
# sudo synopkg start "$SERVICE_NAME"

echo "backup script finished successfully."
