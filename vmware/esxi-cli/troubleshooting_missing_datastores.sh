#!/bin/bash
# Tim H 2025

# I had accidentally enabled PCI passthrough on a hardware device, that was screwing everything up

vmware -v
# VMware ESXi 7.0.3 build-20842708

vim-cmd /hostsvc/maintenance_mode_enter

esxcli storage filesystem list
esxcli storage core device list
esxcli storage core device partition list
esxcli storage core device partition showguid
esxcli storage vmfs extent list

esxcfg-scsidevs -l   
esxcfg-mpath -b
esxcfg-scsidevs -c
esxcfg-volume --list

ls -ltrh /vmfs/devices/disks/

# where the VMs usually are located: 
ls -lah /vmfs/volumes
# /vmfs/volumes/63ef8353-2c948b36-a6c8-08f1ea9284c8/
# no Adapters, no devices listed inside ESXi
# but they are listed in iLO?

# https://10.0.1.14/provision/
# everything was fine in iLO

# back up ESXi v6-8 config:
vim-cmd hostsvc/firmware/sync_config

