#!/bin/bash
# Tim H 2011
#
# Wipes all a hard disk's free space with zeros
#
# Example usage - only takes one parameter
#   ./quick-wipe.sh /
#   ./quick-wipe.sh /home/
#
# Don't use set -e with this script

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

WIPE_LOCATION=$1

# If wipe location doesn't exist
if [ ! -d "$WIPE_LOCATION" ]
then
    echo "$WIPE_LOCATION path is invalid. Aborting wipe of this path."
    exit 2
fi

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 3
fi

# define 
WIPE_FILE_SMALL="$WIPE_LOCATION/zero.small.file"
WIPE_FILE_BIG="$WIPE_LOCATION/zero.file"

#su REDACTED_USERNAME -c "trash-empty"

# create a 1 GB file that's quick and easy to delete so the OS won't crash
echo "==== starting wiping (small) of $WIPE_LOCATION ===="
date
dd if=/dev/zero of="$WIPE_FILE_SMALL" bs=1024 count=102400

# output to file until the disk is full
echo "starting wiping (big)"
date
cat /dev/zero > "$WIPE_FILE_BIG"

echo "wiping compelte, clearing small file"
date
rm -f "$WIPE_FILE_SMALL"

echo "wiping compelte, clearing large file"
date
rm -f "$WIPE_FILE_BIG"

echo "wiping of $WIPE_LOCATION finished"
date

df -h
