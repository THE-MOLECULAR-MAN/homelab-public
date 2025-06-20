#!/bin/sh
# Tim H 2025

# Troubleshooting NVMe storage issues on ESXi v7

# list storage adapters, like RAID controllers
esxcli storage core adapter list

# list VMware kernel modules loaded
vmkload_mod -l | grep nvme

# list NVMe devices
esxcli nvme device list

esxcli hardware pci list | grep -i nvme


# list storage devices
esxcli storage core device list

# list all nvme devices listed in PCI connections
lspci | grep -i nvme
