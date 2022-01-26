#!/bin/bash
# Tim H 2021
# Script to download and install CyberPower PowerPanel Business Local (Agent) on CentOS 7 Virtual Machine on vSphere/ESXi
# This is the management software that will eventually integrate with vSphere and trigger shutdowns on VMs and then ESXi hosts
# Therefore this software must be installed somehwere OUTSIDE of the virtual machines
# The CyberPower software ONLY runs on 32 and 64 bit OSes, not ARM- so you can't install this on a Raspberry Pi
#
# CyberPower's documentation is very confusing, but here's a basic overview:
#   * The term "Local Module" refers to a software agent installed on an asset with an Operating System. 
#       This "Local Module" runs as a service and communicates directly over USB or Serial with the UPS. 
#	    Install the Local Client software on the system that has the USB port connected
#       This software has VERY limited capabilities and can only communicate with the OS it is installed it. 
#       It cannot talk to Hypervisors or other networked systems.
#       The Local Module software acts like an agent that is remote controlled using separate Management software
#       It defaults to listening on TCP 3052 in HTTP (insecure)
#       The shared secret must match for the Local Module and the Management module. It defaults to a very insecure static string, so change it.
#
#   * The term "Management Module" refers to a totally separate piece of software that initiates a connection to the Local Module software running on endpoints. 
#       The Management module is the one that has all the features for integrating w/ vSphere and ESXi. 
#       It establishes policies for shutting down a fleet of UPSes and has a lot more features.
#       The Management Module can scan networks to look for Local Modules, but you cannot specify a port, so it might only look on TCP 3052, but I'm not sure.
#	* The Client and Management software cannot be installed on the same system!!! There is no work-around since they use the same path, filenames, ports, and service name
#
# Beware: if you put these 2 CentOS VMs (one for Local, one for Management) on the vSphere/ESXi environment that is being powered down, then it may not work well.

# References:
#   https://www.cyberpowersystems.com/products/software/power-panel-business/

# Prerequisites:
# 	1) Connect the physical USB cable from the UPS to a USB port on the ESXi host where the PPB Client will be installed.
#   2) The CentOS 7 VM that will be used for the Local Module must be powered off (won't work if on)
#   3) In ESXi (not vSphere), edit the CentOS virtual machine and add the CyberPower USB device
#
#   TODO: add architecture check, make sure it's 64 bit, not 32 or ARM; won't work on Raspberry Pi since it's ARM

cd "$HOME"

##############################################################################
# Set up - see pre-reqs above.
##############################################################################
# the web app should now update and show the UPS specs, it should recognize it.

# this server should be a static IP or have a DHCP reservation

# follow the logs to watch for USB device connect if having issues:
#tail -f /var/log/{messages,kernel,dmesg,syslog}

# optional, provide the lsusb command for debugging and validation
yum install -y usbutils

# bash to make sure it is connected BEFORE installing the PowerPanel Business Local Module
lsusb | grep "Cyber Power System"


##############################################################################
# DOWNLOAD AND INSTALL PowerPanel Business LOCAL
# For a virtual machine that has the USB device connected to the UPS
##############################################################################
# Turns out that the "global" edition is newer, less buggy
# different site for downloading
# As of the time of this writing, the regular download site shows v4.4.0
# and the "global" site shows 4.7.0
# https://www.cyberpower.com/global/en/product/sku/powerpanel%C2%AE_business_for_linux#downloads
PPB_LOCAL_INSTALLER_URL="https://www.cyberpower.com/global/en/File/GetFileSampleByType?fileId=SU-20040001-04&fileType=Download%20Center&fileSubType=FileOriginal"
PPB_LOCAL_INSTALLER_FILENAME="CyberPower_PPB_Linux+64bit_v4.7.0.sh"
PPB_LOCAL_INSTALLER_MD5="2DCD9DB2525D727EBA200B19B7828FDA"

# download the file, set the filename like the site
wget -O "$PPB_LOCAL_INSTALLER_FILENAME" "$PPB_LOCAL_INSTALLER_URL"

# create a hashsum file using the known MD5
echo "$PPB_LOCAL_INSTALLER_MD5  $PPB_LOCAL_INSTALLER_FILENAME" > "$PPB_LOCAL_INSTALLER_FILENAME.md5"

# check the hashsum to verify integrity of the download, bail if it doesn't match
set -e
md5sum --check "$PPB_LOCAL_INSTALLER_FILENAME.md5"
set +e

# mark it as executable
chmod 500 "./$PPB_LOCAL_INSTALLER_FILENAME"

# It's an interactive install, not sure if there are flags that can be passed or an answers file
./$PPB_LOCAL_INSTALLER_FILENAME
# Enter 9 times, Acccept the license (1), Default install directory (Enter), 1 (Management component)

# list all the running services:
#systemctl list-units --type service
 
# list all Cyberpower services:
#systemctl list-units --type service | grep -i "Cyber\|UPS\|power"

# list the newly installed service
systemctl status ppbed.service
# at this point the service named pped should be installed and running

# list the processes that are listening and on which ports, java process should be listening on 3052 (default web app port)
netstat -tunlp | grep LISTEN

# now visit this site to verify it is recognizing the UPS
# http://centos-hostname:3052/
# default creds are: admin/admin ; note that you can't press Enter, have to click the red Log In button
# it should already recognize the UPS at this stage. If it does not, then do not continue

# modify the shared secret, enable HTTPS, lock it down since it is pretty insecure.
