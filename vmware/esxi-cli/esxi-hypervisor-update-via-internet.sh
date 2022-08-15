#!/bin/bash
# Tim H 2022
# Update ESXi hypervisor via internet
# Use a screen session on a jump host

# references:
#   https://www.altaro.com/vmware/top-20-esxcli-commands/
#   https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/esx/vmw/vmw-esx-index.xml

#   list of versions and build numbers and release dates:
#       https://kb.vmware.com/s/article/2143832

# see current version
vmware -v
esxcli system version get

# list VIBs installed:
# esxcli software vib list

# list all virtual machines:
# vim-cmd vmsvc/getallvms

# enable maintenance mode, be sure to undo it before reboot or it will prevent VMs from auto-starting after reboot
esxcli system maintenanceMode set --enable true

# show running virtual machines:
esxcli vm process list

# list of WorldIDs of running VMs
# TODO: run this as a loop with a 30 sec sleep in between calls
# graceful shutdown of running VMs - use WorldID from previous command
for ITER_WORLD_ID in $(esxcli vm process list | grep "World ID" | cut -d ' ' -f6); do
    echo "Gracefully shutting down $ITER_WORLD_ID"
    #esxcli vm process kill --type=soft --world-id="$ITER_WORLD_ID"
    #sleep 30
done
echo "done shutting down VMs"

# list running tasks
vim-cmd vimsvc/task_list

# list depot packages, verify connection and URL
# takes about 40 seconds to run
# esxcli software sources profile list --depot=https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml
LATEST_PROFILE=$(esxcli software sources profile list --depot=https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml | grep '\-standard' | tail -n1 | cut -d ' ' -f1)

# this command takes a WHILE to run - 5-10 minutes
# maybe consider adding a beep afterward?
# TODO: consider addding && disable main && reboot, maybe some sleeps too
# the last item in the previous command is usually the latest, but go for
# the standard version, no the no-tools version.
# this command blocks until the update is done
esxcli software profile update --profile="$LATEST_PROFILE" --depot https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml

# the ESX equivalent of "top" to watch the most CPU-intensive processes
# https://kb.vmware.com/s/article/2001448
# gotta define that env variable first, otherwise it doesn't work
# TERM=xterm esxtop

# see if the update is still running:
ps -Tcgi | grep "esxcli software profile update"

# disable maintenance mode so VMs will come back up on reboot
esxcli system maintenanceMode set --enable false

# have to reboot, just use regular Linux command. No need for special ESX 
# command. it doesn't immediately logout, so do it manually
reboot now && logout

# check version after reboot
vmware -v
esxcli system version get
