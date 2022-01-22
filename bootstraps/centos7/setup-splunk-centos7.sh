#!/bin/bash
# Tim H 2021
# Installs/upgrades Splunk on CentOS Linux 7 64-bit
# Unfortunately, you must provide the version and hash strings from a download URL
# Where to see the latest version numbers or example URLs:
#    https://www.splunk.com/en_us/download/splunk-enterprise.html
#
# Since this requires knowing the version and hash, and the Splunk
#	installer/upgrade requires interactive input, it cannot be run automatically
#	or on cron.

# https://community.splunk.com/t5/Installation/Where-did-the-download-links-for-wget-go-on-splunk-com/m-p/196867

set -e

product="splunk"       # values can be : splunk , splunkforwarder
version="8.2.4"        # Splunk product Version
hash="87e2dda940d1"    # specific per Version
arch="x86_64"          # values can be : x86_64 (redhat, tgz), amd64 (ubuntu), x64 (Windows)
os="linux"             # values can be : linux, windows
pkg="rpm"              # Values can be : tgz, rpm, deb, msi

filename="${product}-${version}-${hash}-${os}-2.6-${arch}.${pkg}"

# TODO: maybe replace with the curl URL that doesn't require the hash? See the help URL at the top for tips
wget "https://download.splunk.com/products/splunk/releases/${version}/${os}/${filename}"
wget "https://download.splunk.com/products/splunk/releases/${version}/${os}/${filename}.md5"

# example valid download URL:
# https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-linux-2.6-x86_64.rpm

# verify the integrity of the downloaded Linux installer
md5sum --check "${filename}.md5"

# Stop the splunk service (if running) before upgrading; this takes 30 seconds
#	or more before it returns control to the command line
# Unneccesary since the yum upgrade command will stop the service if it
#	is running
#sudo service splunk stop

# install/upgrade the service
#	this takes 1-2 minutes
sudo yum install -y ./"${filename}"

# this prompts an INTERACTIVE prompt to accept license agreement and perform migration
sudo service splunk status

# start the service again if it wasn't already running
sudo service splunk start
