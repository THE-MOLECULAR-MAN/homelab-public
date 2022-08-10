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

PPB_MANAGEMENT_INSTALLER_URL="https://www.cyberpower.com/global/en/File/GetFileSampleByType?fileId=SU-20040001-06&fileType=Download%20Center&fileSubType=FileOriginal"
PPB_MANAGEMENT_INSTALLER_FILENAME="CyberPower_PPB_Mgt_Linux_64bit_v4.7.0.sh"
PPB_MANAGEMENT_INSTALLER_MD5="F29FEA0F78A5C62905896F0BE23D578C"

wget -O "$PPB_MANAGEMENT_INSTALLER_FILENAME" "$PPB_MANAGEMENT_INSTALLER_URL"

echo "$PPB_MANAGEMENT_INSTALLER_MD5  $PPB_MANAGEMENT_INSTALLER_FILENAME" > \
    "$PPB_MANAGEMENT_INSTALLER_FILENAME.md5"

set -e
md5sum --check "$PPB_MANAGEMENT_INSTALLER_FILENAME.md5"
set +e

# mark it as executable
chmod 500 "./$PPB_MANAGEMENT_INSTALLER_FILENAME"

# It's an interactive install, not sure if there are flags that can be 
# passed or an answers file
sudo ./$PPB_MANAGEMENT_INSTALLER_FILENAME
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
