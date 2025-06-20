#!/bin/bash
# Tim H 2019
#	Designed for OS X bash
#   finds any OVA files that aren't included in the MD5 hashsum file and adds them
#
set -e
OVA_PATH="$HOME/Lab_VM_Images"
MD5_FILENAME="md5s.txt"

# make sure the directory to dump the downloads exists (might be mounted)
if [[ ! -d "$OVA_PATH" ]]; then
    log "$OVA_PATH directory does not exist. Exiting."
    exit 2
fi

cd "$OVA_PATH" || exit 1 # to prevent pathnames in find command

# generate some fake files with unique hashes so there is new data to test with:
# for testing if necessary
# make_random_ova_file () {
#	# generate minimum amount of random data necessary to have a 256-bit body
#	dd if=/dev/random of="fake_file_$RANDOM.ova" bs=1 count=32	# 256 bits
# }
# make_random_ova_file

# generate list of all the OVA files in the directory, just list of filenames
LIST_OF_OVA_FILES=$(find . -type f -iname '*.ova' -exec basename {} \; | sort) 	# just a list of filenames.

# using awk since OS X version of bash doesn't support -printf
# calculate the list of files I've previously gotten the MD5s for:
MD5s_ALREADY_CALCULATED=$(awk -F"[()]" '{print $2}' "$MD5_FILENAME" | sort) 
#" #because Sublime Text Editor cant see the proper quote in previous line

# calculate list of files that need to be hashed (what's new in file list that isn't in MD5 list)
# remove the starting > from each line
FILES_TO_HASH=$(diff <(echo "$MD5s_ALREADY_CALCULATED") <(echo "$LIST_OF_OVA_FILES") | grep "^>" | cut -c3-)

# iterate through list of new files that need to be hashed
for hash_me in $FILES_TO_HASH; do
	echo "hashing new file: $hash_me"
	md5 "$hash_me" >> "$MD5_FILENAME"
done

# update the timestamp either way so it is synced to gCloud
touch "$MD5_FILENAME"

# future options for other hashing methods:
# openssl dgst -sha256 [filename]
# shasum -a 256 [filename]
