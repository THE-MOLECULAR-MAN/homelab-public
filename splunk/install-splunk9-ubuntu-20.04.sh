#!/bin/bash
# Tim H 2022
# Installs Splunk v9.0.0.1 on Ubuntu 20.04
# References:
# https://www.splunk.com/en_us/download/splunk-enterprise/thank-you-enterprise.html
# https://www.splunk.com/en_us/download.html
# https://www.splunk.com/en_us/download/splunk-enterprise.html
# https://jasonmurray.org/posts/2021/installsplunk/

cd "$HOME" || exit 1

# download installer and checksum files
wget "https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb"
wget "https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb.md5"

# verify integrity of installer
md5sum --check splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb.md5

# update package list before using apt
sudo apt-get update
# installs the Ubuntu package "splunk"
sudo apt -y install "./splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb"

# verify path exists
cd /opt/splunk/bin || exit 2

# INTERACTIVE first launch
sudo ./splunk start
# press 'q' then 'y'
# now enter initial creds

# not secure portal:
# http://splunk.local:8000/

# visit the License page, switch to free, has to restart the service
