#!/bin/bash
# Tim H 2022
#
# This script is designed to be run from OS X.
# It will generate a DEB package for installing the Velociraptor server
# in Ubuntu.
# Velociraptor has a very roundabout way of installing
# First you download an executable and run it to build a server installer
# for a specific server OS such as Ubuntu.
#
# References: 
#   https://docs.velociraptor.app/docs/deployment/self-signed/
#   https://www.atlantic.net/dedicated-server-hosting/how-to-install-and-configure-velociraptor-on-ubuntu-20-04/
#   latest releases: https://github.com/Velocidex/velociraptor/releases

##############################################################################
#   STEP 1
#   CREATING THE SERVER INSTALLER
#   DONE FROM YOUR PERSONAL LAPTOP, _NOT_ ON THE SERVER
##############################################################################

# install dependencies in OS X
brew install jq gsed

mkdir "$HOME/velociraptor-builder"
cd "$HOME/velociraptor-builder" || exit 1

# install Velociraptor's GPG public key
# https://docs.velociraptor.app/docs/deployment/#verifying-your-download
# Key ID: 9CB6CFA1  (0572F28B4EF19A043F4CBBE0B22A7FB19CB6CFA1)
wget --quiet "https://keys.openpgp.org/vks/v1/by-fingerprint/0572F28B4EF19A043F4CBBE0B22A7FB19CB6CFA1"
gpg --import 0572F28B4EF19A043F4CBBE0B22A7FB19CB6CFA1

# determine URL of latest OS X binary
OSX_BINARY_URL=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq --raw-output 'limit(1 ; ( .assets[].browser_download_url | select ( contains("darwin") )))')
OSX_BINARY_BASENAME=$(basename "$OSX_BINARY_URL")
# download the latest OSX binary for Velociraptor, and it's GPG signature
wget --quiet "$OSX_BINARY_URL" "$OSX_BINARY_URL.sig"
# verify the GPG signature of the binary
gpg --verify "$OSX_BINARY_BASENAME.sig"

# move it into a permanent home that's in $PATH
sudo mv -f "$OSX_BINARY_BASENAME" /usr/local/bin/velociraptor

# mark it as executable
sudo chmod u+x /usr/local/bin/velociraptor
#ls -lah /usr/local/bin/velociraptor

# verify it runs, check version installed
velociraptor version

# generate a generic/blank config file:
velociraptor config generate -i
ls -lah

# make the server listen on ALL IPs, not just the loopback one
    # allows agents to communicate with it
gsed -i 's/bind_address: 127.0.0.1/bind_address: 0.0.0.0/' server.config.yaml

# Download the Linux binary so it can build the Ubuntu DEB package:
LINUX_BINARY_URL=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq --raw-output 'limit(1 ; ( .assets[].browser_download_url | select ( contains("linux-amd64") )))')
LINUX_BINARY_BASENAME=$(basename "$LINUX_BINARY_URL")
wget --quiet "$LINUX_BINARY_URL" "$LINUX_BINARY_URL.sig"
gpg --verify "$LINUX_BINARY_BASENAME.sig"

# create the server installer package:
velociraptor --config server.config.yaml debian server --binary "$LINUX_BINARY_BASENAME"
ls -lah ./*.deb

# now you can proceed on to the next step
