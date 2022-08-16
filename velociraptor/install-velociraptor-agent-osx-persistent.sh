#!/bin/bash
# Tim H 2022
# Pre-reqs: download the client.config.yaml file from the server and
# place it in the local directory
#
##############################################################################
#   STEP 4:
#       INSTALLING THE VELOCIRAPTOR AGENT ON OS X AND MAKING IT AUTOSTART
##############################################################################

if [ ! -f "client.config.yaml" ]; then
    echo "client.config.yaml does not exist, cannot proceed.
    exit 1"
fi

VELOC_OSX_BINARY_URL=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq --raw-output 'limit(1 ; ( .assets[].browser_download_url | select ( contains("darwin") )))')
VELOC_OSX_BINARY_BASENAME=$(basename "$VELOC_OSX_BINARY_URL")
wget --quiet "$VELOC_OSX_BINARY_URL" "$VELOC_OSX_BINARY_URL.sig"
gpg --verify "$VELOC_OSX_BINARY_BASENAME.sig"

# install it
sudo ./"$VELOC_OSX_BINARY_BASENAME" --config client.config.yaml service install

# see if process is running:
pgrep --list-full "velociraptor"

# test if it is set to autostart in OS X
sudo launchctl list | grep velociraptor
