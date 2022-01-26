#!/bin/bash
# Tim H 2021
# Script to download and install CyberPower PowerPanel Business Management on CentOS 7 Virtual Machine on vSphere/ESXi
# This should be done second, please read/do bootstrap-install-cyberpower-powerpanel-business-local.sh
#
# This script must be run on a DIFFERENT CentOS virtual machine than bootstrap-install-cyberpower-powerpanel-business-local.sh
# 2 total CentOS VMs are required for this deployment, no way around that (except maybe containers)

##############################################################################
# DOWNLOAD AND INSTALL PowerPanel Business MANAGEMENT
##############################################################################
# Turns out that the "global" edition is newer, less buggy
# different site for downloading
# As of the time of this writing, the regular download site shows v4.4.0
# and the "global" site shows 4.7.0
# https://www.cyberpower.com/global/en/product/sku/powerpanel%C2%AE_business_for_linux#downloads
PPB_MANAGEMENT_INSTALLER_URL="https://www.cyberpower.com/global/en/File/GetFileSampleByType?fileId=SU-20040001-06&fileType=Download%20Center&fileSubType=FileOriginal"
PPB_MANAGEMENT_INSTALLER_FILENAME="CyberPower_PPB+Mgt_Linux+64bit_v4.7.0.sh"
PPB_MANAGEMENT_INSTALLER_MD5="7F94FBE93F581AA3679699E9A0FC1199"

wget -O "$PPB_MANAGEMENT_INSTALLER_FILENAME" "$PPB_MANAGEMENT_INSTALLER_URL"

echo "$PPB_MANAGEMENT_INSTALLER_MD5  $PPB_MANAGEMENT_INSTALLER_FILENAME" > "$PPB_MANAGEMENT_INSTALLER_FILENAME.md5"

set -e
md5sum --check "$PPB_MANAGEMENT_INSTALLER_FILENAME.md5"
set +e

# mark it as executable
chmod 500 "./$PPB_MANAGEMENT_INSTALLER_FILENAME"

# It's an interactive install, not sure if there are flags that can be passed or an answers file
./$PPB_MANAGEMENT_INSTALLER_FILENAME
# Enter 9 times, Acccept the license (1), Default install directory (Enter), 1 (Management component)

# list the newly installed service
systemctl status ppbed.service
# at this point the service named pped should be installed and running

# list the processes that are listening and on which ports, java process should be listening on 3052 (default web app port)
netstat -tunlp | grep LISTEN

# seems like it might cause issues if the CyberPower software is installed on any of the ESXi hosts, needs to be on separate infrastructure, like a laptop

# Now visit the login page and change the password, enable SSL instead
# Default login page after install (insecure): http://centos-ups-management:3052/management/login
# Default credentials post-install: admin/admin
# Post install steps:
#	1) Change the admin password: top right click on admin, drop down to change password
#	2) set a new shared secret: Setting / Security
#	3) enable secure version over HTTPS: Setting / Network Configurations.

# integrating with vSphere:
# 1) Create a new service account inside vSphere (not AD)
# 2) Add it to the Administrators group to grant it permissions - it will have none by default and fail to connect
# 3) Visit the Dashboards page in PPB Remote Management and click the + symbol on the top left to add a vSphere integration
#		Username format: user@vsphere.int.REDACTED.me 
