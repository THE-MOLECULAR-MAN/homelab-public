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

# don't try to migrate the "2.6" into the os variable. doesn't work.
product="splunk"       # values can be : splunk , splunkforwarder
version="9.0.0.1"      # Splunk product Version
hash="9e907cedecb1"    # hash of specific build, changes with every version.
arch="x86_64"          # values can be : x86_64 (redhat, tgz), amd64 (ubuntu), x64 (Windows)
os="linux"             # values can be : linux, windows
pkg="rpm"              # Values can be : tgz, rpm, deb, msi

filename="${product}-${version}-${hash}-${os}-2.6-${arch}.${pkg}"

# TODO: maybe replace with the curl URL that doesn't require the hash? See the help URL at the top for tips
wget "https://download.splunk.com/products/splunk/releases/${version}/${os}/${filename}"
wget "https://download.splunk.com/products/splunk/releases/${version}/${os}/${filename}.md5"

# example valid download URLs:
# https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-linux-2.6-x86_64.rpm
# https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-linux-2.6-x86_64.rpm

# verify the integrity of the downloaded Linux installer
md5sum --check "${filename}.md5"

# install/upgrade the service
#	this takes 1-2 minutes
#   it will automatically stop the service if needed, no need to manually
#   stop the splunk service
sudo yum install -y ./"${filename}"

# Triggers INTERACTIVE prompt to accept license agreement and perform migration
# Yes, the service status triggers it, not the install
sudo service splunk status

# start the service again if it wasn't already running
sudo service splunk start
