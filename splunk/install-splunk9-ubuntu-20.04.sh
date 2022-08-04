#!/bin/bash
# Tim H 2022
# backup is just tar up /opt/splunk  lol
# https://lantern.splunk.com/Splunk_Success_Framework/Platform_Management/Managing_backup_and_restore_processes
# https://docs.splunk.com/Documentation/Splunk/8.0.2/Admin/Backupconfigurations
# https://www.splunk.com/en_us/download/splunk-enterprise/thank-you-enterprise.html
# https://www.splunk.com/en_us/download.html
# https://www.splunk.com/en_us/download/splunk-enterprise.html
# https://jasonmurray.org/posts/2021/installsplunk/

cd "$HOME" || exit 1

wget "https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb"
wget "https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb.md5"

md5sum --check splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb.md5

sudo apt-get update
# installs the Ubuntu package "splunk"
sudo apt -y install "./splunk-9.0.0.1-9e907cedecb1-linux-2.6-amd64.deb"

cd /opt/splunk/bin || exit 2
# interactive :-(
sudo ./splunk start
# press 'q' then 'y'
# now enter initial creds

# not secure portal:
# http://splunk.local:8000/

# visit the License page, switch to free, has to restart the service
