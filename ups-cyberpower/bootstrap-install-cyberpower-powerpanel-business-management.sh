#!/bin/bash
# Tim H 2021
# Script to download and install CyberPower PowerPanel Business Management on
#   CentOS 7 Virtual Machine on vSphere/ESXi
# This should be done second, please read/do 
#   bootstrap-install-cyberpower-powerpanel-business-local.sh
#
# This script must be run on a DIFFERENT CentOS virtual machine than
#   bootstrap-install-cyberpower-powerpanel-business-local.sh
# 2 total CentOS VMs are required for this deployment,
# no way around that (except maybe containers)

##############################################################################
# DOWNLOAD AND INSTALL PowerPanel Business MANAGEMENT
##############################################################################
# Turns out that the "global" edition is newer, less buggy
# different site for downloading
# https://www.cyberpower.com/global/en/product/sku/powerpanel_business_for_linux#downloads

sudo apt-get update
sudo apt-get -y install expect \
    curl \
    ca-certificates \
    libgusb2 \
    libusb-1.0-0 \
    usb.ids \
    usbutils \
    --no-install-recommends

# URL for version: 4.8.6 - last updated Sept 30, 2022
PPB_INSTALLER_URL="https://www.cyberpower.com/global/en/File/GetFileSampleByType?fileId=SU-20040001-06&fileType=Download%20Center&fileSubType=FileOriginal"
PPB_INSTALLER_FILENAME="CyberPower_PowerPanel_Business_Linux_64bit_Management-v4.8.6.sh"
#PPB_INSTALLER_URL="http://installers.int.butters.me:8081/$PPB_INSTALLER_FILENAME"
PPB_INSTALLER_MD5="4D92C87C6FEC703464CA689D1A6F2999"

wget -O "$PPB_INSTALLER_FILENAME" "$PPB_INSTALLER_URL"

echo "$PPB_INSTALLER_MD5  $PPB_INSTALLER_FILENAME" > \
    "$PPB_INSTALLER_FILENAME.md5"

set -e
md5sum --check "$PPB_INSTALLER_FILENAME.md5"
set +e

# mark it as executable
chmod 500 "./$PPB_INSTALLER_FILENAME"

# It's an interactive install, not sure if there are flags that can be 
# passed or an answers file
autoexpect sudo ./$PPB_INSTALLER_FILENAME
# Enter 9 times, Acccept the license (1), 
#   Default install directory (Enter), 
#   1 (Management component)

# list the newly installed service
systemctl status ppbed.service
# at this point the service named pped should be installed and running

# list the processes that are listening and on which ports, java process
#   should be listening on 3052 (default web app port)
sudo netstat -tunlp | grep 'java\|LISTEN'

# test http connection
curl --insecure "http://$(hostname):3052/management/login"

# seems like it might cause issues if the CyberPower software is installed 
# on any of the ESXi hosts, needs to be on separate infrastructure, 
# like a laptop

# Now visit the login page and change the password, enable SSL instead
# Default login page after install (insecure): 
# http://centos-ups-management:3052/management/login
# Default credentials post-install: admin/admin
# Post install steps:
#	1) Change the admin password: top right click on admin, drop down to 
#       change password
#	2) set a new shared secret: Setting / Security
#	3) enable secure version over HTTPS: Setting / Network Configurations 
#       / Network Configurations - enable and port 53568

# test new https service after enabling in options menu
curl --insecure "http://$(hostname):53568/management/login"

# show version:
grep "To_PPB_version" /opt/PPB/log/PPBInfo.properties | cut -d '=' -f2

# integrating with vSphere:
# 1) Create a new service account inside vSphere (not AD)
# 2) Add it to the Administrators group to grant it permissions - it will have
#    none by default and fail to connect
# 3) Visit the Dashboards page in PPB Remote Management and click the + symbol
#       on the top left to add a vSphere integration
#		Username format: user@vsphere.int.REDACTED.me 
