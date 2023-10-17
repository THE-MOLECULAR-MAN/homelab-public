#!/bin/bash
# Tim H 2022
# Cisco Umbrella Dynamic DNS agent installation for OS X

DOWNLOAD_URL="https://s3-us-west-1.amazonaws.com/opendns-downloads/OpenDNS-Updater-Mac-3.1.zip"
DOWNLOAD_FILENAME=$(basename "$DOWNLOAD_URL")

cd "$HOME/Downloads" || exit 2
# download it and set the filename:
wget --clobber https://s3-us-west-1.amazonaws.com/opendns-downloads/OpenDNS-Updater-Mac-3.1.zip

# test the integrity before continuing
unzip -t "$DOWNLOAD_FILENAME"

unzip "$DOWNLOAD_FILENAME"
