#!/bin/bash
# Tim H 2022

# references:
#   https://www.altaro.com/vmware/top-20-esxcli-commands/

# list of versions and build numbers and release dates:
# https://kb.vmware.com/s/article/2143832

# see current version
vmware -v
esxcli system version get

# list VIBs installed:
esxcli software vib list

# list all virtual machines:
vim-cmd vmsvc/getallvms

# show running virtual machines:
esxcli vm process list

# enable maintenance mode, be sure to undo it before reboot or it will prevent VMs from auto-starting after reboot
esxcli system maintenanceMode set --enable true

# list of WorldIDs of running VMs
# TODO: run this as a loop with a 30 sec sleep in between calls
#esxcli vm process list | grep "World ID" | cut -d ' ' -f6

# graceful shutdown of running VMs - use WorldID from previous command
esxcli vm process kill --type=soft --world-id=1084026

# list running tasks
vim-cmd vimsvc/task_list

# at the time of this writing, the latest is below, dated 2022/03/29
# this command takes a WHILE to run
# maybe consider adding a beep afterward?
# TODO: consider addding && disable main && reboot, maybe some sleeps too
esxcli software profile update --profile=ESXi-7.0U3d-19482537-standard --depot https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml

# the ESX equivalent of "top" to watch the most CPU-intensive processes
# https://kb.vmware.com/s/article/2001448
# gotta define that env variable first, otherwise it doesn't work
TERM=xterm esxtop

# see if the update is still running:
ps -Tcgi | grep "esxcli software profile update"

# disable maintenance mode so VMs will come back up on reboot
esxcli system maintenanceMode set --enable false

# have to reboot, just use regular Linux command. No need for special ESX command
reboot now

# check version after reboot
vmware -v
esxcli system version get
