#!/bin/bash
# Tim H 2022
# Pre-reqs: download the client.config.yaml file from the server and
# place it in the local directory
#
##############################################################################
#   STEP 4:
#       INSTALLING THE VELOCIRAPTOR AGENT ON OS X AND MAKING IT AUTOSTART
##############################################################################

# bail immediately if any errors occur
set -e

if [ ! -f "client.config.yaml" ]; then
    echo "client.config.yaml does not exist, cannot proceed."
    exit 1
fi

# install Brew if necessary:
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install jq wget gpg # cannot run with sudo powers

VELOC_OSX_BINARY_URL=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq --raw-output 'limit(1 ; ( .assets[].browser_download_url | select ( contains("darwin") )))')
VELOC_OSX_BINARY_BASENAME=$(basename "$VELOC_OSX_BINARY_URL")

# delete old versions in case installer is run multiple times:
find . -maxdepth 1 -type f -iname "velociraptor-v*darwin*" -delete

# download it
wget --quiet "$VELOC_OSX_BINARY_URL" "$VELOC_OSX_BINARY_URL.sig"

# install Velociraptor's GPG public key
# https://docs.velociraptor.app/docs/deployment/#verifying-your-download
# Key ID: 9CB6CFA1  (0572F28B4EF19A043F4CBBE0B22A7FB19CB6CFA1)
wget --quiet "https://keys.openpgp.org/vks/v1/by-fingerprint/0572F28B4EF19A043F4CBBE0B22A7FB19CB6CFA1"
gpg --import 0572F28B4EF19A043F4CBBE0B22A7FB19CB6CFA1

# verify the authenticity of the file:
gpg --verify "$VELOC_OSX_BINARY_BASENAME.sig"

# mark it as executable
sudo chmod u+x "$VELOC_OSX_BINARY_BASENAME"

# install it using the config file for this particular deployment
sudo ./"$VELOC_OSX_BINARY_BASENAME" --config client.config.yaml service install

# see if process is running:
# can't use pgrep on OSX, doesn't have the latest version that supports all
# the flags
sudo ps aux | grep veloc

# test if it is set to autostart in OS X
sudo launchctl list | grep velociraptor

echo "script finished successfully"
