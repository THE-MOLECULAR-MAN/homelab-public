#!/bin/bash
# Tim H 2023

# set the ESXi Hypervisor web app timeout time
# it defaults to 900 seconds (15 minutes)
# max is 7200 seconds (2 hours)

# https://kb.vmware.com/s/article/1038578
# https://woshub.com/session-timeout-vmware-vsphere-esxi/

# UserVars.HostClientSessionTimeout in the GUI.

# show the existing value:
esxcli system settings advanced list -o "/UserVars/HostClientSessionTimeout"

# set the new value:
esxcli system settings advanced set  -o "/UserVars/HostClientSessionTimeout" --int-value=7199

# verify the change:
esxcli system settings advanced list -o "/UserVars/HostClientSessionTimeout"
