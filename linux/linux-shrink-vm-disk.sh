#!/bin/bash
# Tim H 2021
# Shrinking thin provisioned virtual disks in ESXi/vSphere
#https://www.nakivo.com/blog/thick-and-thin-provisioning-difference/
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/fs-discard-unused-blocks
# Not Possible in ESXi/vSphere, only desktop versions: https://serverfault.com/questions/398162/disk-shrink-does-not-work-on-esxi-guests

# WARNING: this will only work for VMware Workstation and Fusion VMs, not vSphere/ESXi VMs

# show file systems including types. My CentOS 7 is xfs 
df -Th

# wipe free space as zeros using basic dd command
#dd bs=1M count=10240 if=/dev/zero of=zero

# other options that aren't as good
#yum install -y zerofree
#zerofree
#secure-delete
#nwipe
#shred - bleachbit
#fstrim

# install dependencies
yum install -y util-linux

# shrink the disk, def the best option - super fast compared to writing zeros
fstrim -v --all

# view the disks
vmware-toolbox-cmd disk list 

# shrink the root file system
vmware-toolbox-cmd disk shrink / 
