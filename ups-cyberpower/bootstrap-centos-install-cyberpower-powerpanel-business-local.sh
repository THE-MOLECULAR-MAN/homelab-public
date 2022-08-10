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
# CentOS only. Is already included in Ubuntu
# sudo yum install -y usbutils

# bash to make sure it is connected BEFORE installing the PowerPanel Business Local Module
lsusb | grep "Cyber Power System"

# requires ufw to be enabled and running
# GOTCHA: installer will make changes to firewall rule and force UFW
# system will reject future SSH connections if you don't do all this first
# gotta be just like this, no changes on next 2 lines:
sudo dpkg -P ufw iptables
# sudo apt-get -y reinstall ufw

# sudo ufw enable
# sudo systemctl start  ufw
# sudo systemctl enable ufw
# sudo ufw default deny incoming
# sudo ufw default allow outgoing
# sudo ufw allow ssh
# sudo ufw status verbose
sudo reboot now

# # make sure the service is running, active, and SSH is open after reboot
# sudo ufw status verbose
# sudo systemctl status ufw

##############################################################################
# DOWNLOAD AND INSTALL PowerPanel Business LOCAL
# For a virtual machine that has the USB device connected to the UPS
##############################################################################
# Turns out that the "global" edition is newer, less buggy
# different site for downloading
# https://www.cyberpower.com/global/en/product/sku/powerpanel_business_for_linux#downloads

PPB_LOCAL_INSTALLER_URL="https://www.cyberpower.com/global/en/File/GetFileSampleByType?fileId=SU-20040001-04&fileType=Download%20Center&fileSubType=FileOriginal"
PPB_LOCAL_INSTALLER_FILENAME="CyberPower_PPB_Linux_64bit_v4.8.1.sh"
PPB_LOCAL_INSTALLER_MD5="35E679BDC9751C8E829AAD1C7FADD146"

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
# don't forget the "-c" flag
# try being root, not just sudo on regular user?
sudo ./"$PPB_LOCAL_INSTALLER_FILENAME" -c

# Enter 9 times, Acccept the license (1), 
# Default install directory (Enter), 
# 1 (Local)

# list all the running services:
# sudo systemctl list-units --type service
 
# list all Cyberpower services:
# sudo systemctl list-units --type service | grep -i "Cyber\|UPS\|power\|ppb"

# list the newly installed service
systemctl status ppbed.service  # CyberPower UPS PowerPanel Business Edition
systemctl status ppbwd.service  # Monitor PowerPanel Business Service
#systemctl status ufw
#sudo ufw status


# searching for errors:
# dmesg | grep 'ppb\|cyber'
# IT may start ufw service in Ubuntu
# so it sets up UFW shit and closes SSH (22)
# find /var/log -type f -exec grep -i 'cyber\|ppb' {} \;
# from remote system:
# nmap -Pn -p22,3052,53568 ups-local02.int.butters.me

# list the processes that are listening and on which ports, java process should be listening on 3052 (default web app port)
sudo netstat -tunlp | grep 'java\|LISTEN\|ppb'

# test http connection
curl --insecure "http://$(hostname):3052/local/login"

# show version:
grep "To_PPB_version" /opt/PPB/log/PPBInfo.properties | cut -d '=' -f2

# now visit this site to verify it is recognizing the UPS
# http://centos-hostname:3052/
# GOTCHA: disable JavaScript blocker for this site, it's required to run
# default creds are: admin/admin ; note that you can't press Enter, have to click the red Log In button
# it should already recognize the UPS at this stage. If it does not, then do not continue

# modify the shared secret, enable HTTPS, lock it down since it is pretty insecure.

# test new https service after enabling in options menu
curl --insecure "http://$(hostname):53568/local/login"

# GOTCHA: make sure it comes back up after reboot:
sudo reboot now
# nmap -Pn -p22,3052,53568 ups-local02.int.butters.me
# after a few min SSH dies and becomes closed
