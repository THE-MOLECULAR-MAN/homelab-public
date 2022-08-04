#!/bin/bash
# Tim H 2022
# Building a Velociraptor agent for CentOS 7 Linux, done on OS X command line
#
# References:
#   https://docs.velociraptor.app/docs/deployment/clients/#linux
#
##############################################################################
#   STEP 3
#       BUILDING AN AGENT FOR CENTOS 7
##############################################################################

# get the client.config.yaml file from step 2.

set -e

cd ~/velociraptor-builder || exit 1

LINUX_BINARY_URL=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq --raw-output 'limit(1 ; ( .assets[].browser_download_url | select ( contains("linux-amd64") )))')
LINUX_BINARY_BASENAME=$(basename "$LINUX_BINARY_URL")
wget --quiet "$LINUX_BINARY_URL" "$LINUX_BINARY_URL.sig"
gpg --verify "$LINUX_BINARY_BASENAME.sig"

# build the installer for RPM
velociraptor --config client.config.yaml  rpm client --binary velociraptor-v0.6.4-2-linux-amd64
ls -lah velociraptor_*_client.rpm
