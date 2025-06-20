#!/bin/bash
# Tim H 2021

# This whole script is completely unecesssary when using the HPE provided ESXi ISO to install ESXi
#       https://customerconnect.vmware.com/en/downloads/details?downloadGroup=OEM-ESXI70U2-HPE&productId=974
#
# installing the ABS agent on ESX 7.0.1
# GOTCHA: iLO version must exactly match the ESXi version. Ex: iLO version for 7.0.0 will not work with 7.0.1
#
# References:
#	https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_521550eda2644e46af366f9a9b#tab2

# must install ILO drivers before AMS: https://10.0.1.14/lang/en/help/help.html?topic=ref-ams#

# enable SSH access to the ESXi hypervisor first
# make sure it is in maintenence mode and all VMs are powered off

# see if it the "package" is installed.
esxcli software component list | grep amsdComponent

# note: the absolute path is required, not relative path
# cd /tmp
# wget "https://downloads.hpe.com/pub/softlib2/software1/pubsw-windows/p1937760539/v185907/amsdComponent_700.11.6.10.4-1_17206321.zip"
# wget command exists and does DNS resolution but doesn't seem to work, firewall?
# scp amsdComponent_700.11.6.10.4-1_17206321.zip 10.0.1.27:/vmfs/volumes/hpe_nvme_ssd_FASTEST/esx_modules_upload/

# on my Microserver
ls -lah /vmfs/volumes/hpe_nvme_ssd_FASTEST/esx_modules_upload/amsdComponent_700.11.6.10.4-1_17206321.zip
esxcli software component apply -d /vmfs/volumes/hpe_nvme_ssd_FASTEST/esx_modules_upload/amsdComponent_700.11.6.10.4-1_17206321.zip

# on my 2U R7-3000 server:
# esxcli software component apply -d /vmfs/volumes/r7-3000-raid10/esx_modules_upload/amsdComponent_700.11.6.10.4-1_17206321.zip

# reboot ESXi hypervisor to apply changes
# This will make the R7-3000 VERY LOUD for a few minutes
# reboot

esxcli software component list | grep amsdComponent # should list "amsdComponent"

# amsdComponent_701.11.7.2.4-1_17974261
# https://community.hpe.com/t5/ProLiant-Servers-ML-DL-SL/iLO-did-not-detect-the-Agentless-Management-Service-when-this/td-p/7138228
# https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_4eee0f5a257e4c01a489046663#tab3
# restarting AMS on ESXi: 
# /etc/init.d/ams.sh restart # doesn't work, no script there named that
# test if the service is running. For some reason it is NOT listed in the GUI.
/etc/init.d/amsd status
# it wasn't running after reboot, i had to manually start it. it wouldn't start
# amsd-smarev is not running 1626381697 1
# amsd-ahsd is not running 1626381687 1
# amsd-amsd is not running 1626381677 1
# amsd-smad is not running 1626381667 1
# Service is not ilsted in the ESXi host's list of services in the GUI

# https://community.hpe.com/t5/ProLiant-Servers-ML-DL-SL/ESXi7-0-0b-Agentless-Management-Service-on-DL20-GEN10-doesn-t/m-p/7099765

# recommendations are 1) maintenence mode 2) stop the AMS service 3) uninstall the AMS service 4) reboot

# wget "https://downloads.hpe.com/pub/softlib2/software1/pubsw-windows/p1937760539/v192153/amsdComponent_701.11.7.1.3-1_17671487.zip"
# scp amsdComponent*.zip 10.0.1.27:/vmfs/volumes/hpe_nvme_ssd_FASTEST/esx_modules_upload/
esxcli software component apply -d /vmfs/volumes/hpe_nvme_ssd_FASTEST/esx_modules_upload/amsdComponent_701.11.7.1.3-1_17671487.zip
