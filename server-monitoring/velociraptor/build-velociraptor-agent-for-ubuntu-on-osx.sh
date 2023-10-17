#!/bin/bash
# Tim H 2022
# Create a Velociraptor agent installer for Ubuntu Linux
# Designed to be run from OS X, not on Linux.
#
# References:
#   https://docs.velociraptor.app/docs/deployment/clients/#linux
#   https://medium.com/@0D0AResearch/getting-started-with-velociraptor-2f20de22b491
#
##############################################################################
#   STEP 3:
#       BUILDING AN AGENT FOR UBUNTU
##############################################################################

set -e

# DEPENDENCIES:
# create the directory if it doesn't exit
# don't throw error if it does exist
mkdir -p ~/velociraptor-builder
brew install gpg

cd ~/velociraptor-builder || exit 1

# download the latest Linux binary, verify the integrity
LINUX_BINARY_URL=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq --raw-output 'limit(1 ; ( .assets[].browser_download_url | select ( contains("linux-amd64") )))')
LINUX_BINARY_BASENAME=$(basename "$LINUX_BINARY_URL")
wget --quiet "$LINUX_BINARY_URL" "$LINUX_BINARY_URL.sig"
gpg --verify "$LINUX_BINARY_BASENAME.sig"

# fetch the server config file:
# ssh onto the velociraptor server
# generate a client config file, nothing really sensitive in it, unlike
# the server config file
# /usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml config client > /etc/velociraptor/client.config.yaml
# sudo chmod +r /etc/velociraptor/client.config.yaml

# build the installer for DEB
wget "http://somewhere-on-your-lan/velociraptor-client.config.yaml"
velociraptor --config velociraptor-client.config.yaml debian client --binary "$LINUX_BINARY_BASENAME"

ls -lah velociraptor_*_client.deb
