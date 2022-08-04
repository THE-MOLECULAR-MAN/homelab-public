#!/bin/bash
# Tim H 2022
# restores a backup created by the backup-splunk.sh script in this repo
# https://lantern.splunk.com/Splunk_Success_Framework/Platform_Management/Managing_backup_and_restore_processes
# https://docs.splunk.com/Documentation/Splunk/8.0.2/Admin/Backupconfigurations

BACKUP_FULL_PATH="/nfs_backup/splunk01.int.butters.me/splunk-backup-9.0.0.1-9e907cedecb1-2022-08-04.tar.gz"

# stop the service
sudo /opt/splunk/bin/splunk stop

# check for open files, make sure none are open
sudo lsof "/opt/splunk"

# check size of backup
du -sh "$BACKUP_FULL_PATH"

# check for available free space in destination
# assume restoring it will take 3-5x as much space as the tarball
df -h "/opt/splunk"

cd $(dirname "$BACKUP_FULL_PATH") || exit 1

# verify integrity of backup with hashsum:
sha256sum --check *.sha256

# rename original splunk directory to retain it just in case
mv /opt/splunk /opt/splunk.old

# check extraction path of tarball
tar -ztvf "$BACKUP_FULL_PATH" | head -n5

# decompress the backup, no progress, no verbose
# must extract to "/" since it includes the /opt/splunk in the tarball
# do not change next line
tar -zxf "$BACKUP_FULL_PATH" --directory /

# restart the splunk service
sudo /opt/splunk/bin/splunk start
