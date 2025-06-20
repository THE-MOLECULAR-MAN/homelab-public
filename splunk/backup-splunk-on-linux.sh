#!/bin/bash
# Tim H 2022
# Backs up Splunk directory, as they recommend
# Linux distro-independent
# on my system the splunk path was 5.6 GB and compressed
# down to 1.78 GB tarball ~32% of the original size
# https://lantern.splunk.com/Splunk_Success_Framework/Platform_Management/Managing_backup_and_restore_processes
# https://docs.splunk.com/Documentation/Splunk/8.0.2/Admin/Backupconfigurations

# the only variable you'll really need to define, just path to a directory
# that already exists.
DEST_BACKUP_PATH="/nfs_backup/splunk01.int.butters.me"

# define more variables about the backup
VERSION_INFO=$(sudo /opt/splunk/bin/splunk --version | cut -d ' ' -f2,4 | cut -d ')' -f1 | tr ' ' '-')
TODAYS_DATE=$(date +%Y-%m-%d)
DEST_BACKUP_FILENAME="splunk-backup-$VERSION_INFO-$TODAYS_DATE.tar.gz"
BACKUP_SOURCE_PATH="/opt/splunk"

# stop the service
sudo /opt/splunk/bin/splunk stop

# check for open files
sudo lsof "$BACKUP_SOURCE_PATH"

# check size of source:
du -sh "$BACKUP_SOURCE_PATH"

# check for available free space in destination
df -h "$DEST_BACKUP_PATH"

# compress it, not verbose, no progress meter
tar -zcf "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME" "$BACKUP_SOURCE_PATH"

# view the size of backup
ls -lah "$DEST_BACKUP_PATH/$DEST_BACKUP_FILENAME"

# verify remote backup directory exists
cd "$DEST_BACKUP_PATH" || exit 1

# create checksum of the backup file next to original
sha256sum "$DEST_BACKUP_FILENAME" > "$DEST_BACKUP_FILENAME.sha256"

# restart the splunk service
sudo /opt/splunk/bin/splunk start
