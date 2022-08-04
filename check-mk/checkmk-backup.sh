#!/bin/bash
# Tim H 2022
# Don't bother with the GUI backup, it's worthless
# https://docs.checkmk.com/latest/en/omd_basics.html#omd_backup_restore
# https://docs.checkmk.com/latest/en/backup.html
# must be same Edition and same Version

MK_VERSION_INFO="free-edition-$(omd version --bare)"
TODAYS_DATE=$(date +%Y-%m-%d)
OMD_BACKUP_FILENAME="check-mk-omd-backup-$MK_VERSION_INFO-$TODAYS_DATE.tar.gz"
DIR_BACKUP_FILENAME="omd_directory-$TODAYS_DATE.tar.gz"
MK_SITE_NAME="homelab2"
BACKUP_PATH="/tmp"

# list of sites:
omd sites

# do the backup of a single site
omd backup "$MK_SITE_NAME" "$BACKUP_PATH/$OMD_BACKUP_FILENAME"

# see size of backup:
ls -lah "$BACKUP_PATH/$OMD_BACKUP_FILENAME"

# see contents of backup:
tar tvzf "$BACKUP_PATH/$OMD_BACKUP_FILENAME"  | less

######## full manual backup:
omd stop homelab2
omd stop homelab
sudo service omd stop
sudo service httpd stop

# list all services:
# systemctl list-units --type service
# see if there are any other open files in the directory you're about to
# compress
lsof /opt/omd

# compress it, not verbose
tar -zcf "$BACKUP_PATH/$DIR_BACKUP_FILENAME" /opt/omd

ls -lah "$BACKUP_PATH/$DIR_BACKUP_FILENAME"
