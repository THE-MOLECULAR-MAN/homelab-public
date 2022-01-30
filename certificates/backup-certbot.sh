#!/bin/bash
# Tim H 2020
# backup-certbot.sh
#   Makes a backup of all the files for certbot. Stores in a tarball that is read-only for root user.

# bomb out immediately if any error occur
set -e

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

NOW=$(gdate -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
DESTINATION_ARCHIVE_PATH="$HOME/Documents/no_backup/certbot-backup-$NOW.tar.gz"

# compress the files that could be alerted by running the certbot command
# store them in a uniquely named tarball
tar -czf "$DESTINATION_ARCHIVE_PATH" /var/log/letsencrypt /etc/letsencrypt

chmod 400 "$DESTINATION_ARCHIVE_PATH"
ls -lah "$DESTINATION_ARCHIVE_PATH"
