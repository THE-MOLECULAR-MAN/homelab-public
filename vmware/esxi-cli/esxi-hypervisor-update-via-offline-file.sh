#!/bin/bash
# Tim H 2021
# upgrade ESXi hypervisor version
# Update via offline updates manually downloaded onto a local datastore
# ESX CLI doesn't recognize comments, so can't put them on the same line as the command

# References:
#	https://kb.vmware.com/s/article/2008939
#	https://my.vmware.com/patch/#search		downloads
#	https://www.graysonadams.com/2020/07/shutdown-all-virtual-machines-gracefully-on-esxi-v6-x/

# SSH into the ESXi directly, not vSphere


# see current build number and version. The versions are confusing, so go by build number
vmware -v
#VMware ESXi 7.0.0 build-16324942

# List all running VMs, returns nothing if no VMs are running
esxcli vm process list

# stop all running VMs
#for i in $(esxcli vm process list | grep 'World ID:' | grep -o '[0-9]*'); do esxcli vm process kill --type=soft --world-id=$i; done;

# enter maintanance mode
vim-cmd /hostsvc/maintenance_mode_enter

# R7-3000 2U - 10.0.1.13
DATASTORE_NAME="r7-3000-raid10"

# HPE Microserver
#DATASTORE_NAME="hpe_nvme_ssd_FASTEST"

PATCH_FILENAME="VMware-ESXi-7.0b-16324942-depot.zip"
#[DependencyError]
# VIB VMW_bootbank_icen_1.0.0.9-1vmw.701.0.0.16850804 requires vmkapi_2_7_0_0, but the requirement cannot be satisfied within the ImageProfile.


PATH_TO_PATCHES="/vmfs/volumes/$DATASTORE_NAME/esx_modules_upload"

cd "$PATH_TO_PATCHES" || exit 1

# must be absolute path, not relative path
esxcli software vib install -d "$PATH_TO_PATCHES/$PATCH_FILENAME"
# it sits here for a few minutes with no  output  to  the screen, just wait...
# it will output a bunch of stuff to the screen, let you know if it was successful

# have to manually turn off maintanance mode, otherwise autostarted VMs won't start on boot
vim-cmd /hostsvc/maintenance_mode_exit

# reboot to apply updates
reboot

##############################################################################
#	POST REBOOT, SSH BACK IN. IT TAKES A *WHILE* BEFORE IT'S UP AND RUNNING AGAIN
#   MAY NOT HAVE SSH AUTOSTARTED AFTER REBOOT
##############################################################################

# see new build number and version. The versions are confusing, so go by build number
vmware -v 
