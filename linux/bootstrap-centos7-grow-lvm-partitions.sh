#!/bin/bash
# Tim H 2020
# Increasing the size of LVM partitions in CentOS 7 virtual machines with XFS file system
# Prep steps:
#	1) Power off VM
#	2) Delete all snapshots
#	3) increase virtual HDD size
#	4) take a new snapshot
#	5) boot up the VM and run this script
#
# References:
#   https://stackoverflow.com/questions/26305376/resize2fs-bad-magic-number-in-super-block-while-trying-to-open
#   https://www.tecmint.com/extend-and-reduce-lvms-in-linux/
#   https://kb.vmware.com/s/article/1006371

# Clean up to save space, drive might be full:
sudo yum clean all
sudo yum autoremove

# install dependencies for commands called in this script
sudo yum install -y coreutils lvm2 xfsprogs cloud-utils-growpart

# check which Filessystem is used on /, should be EXT4 or XFS for this script
df -T /

sudo fdisk /dev/sda
# n p 3 [enter] [enter] [enter] w

# maybe I'll do it this way automated one day
#	https://serverfault.com/questions/258152/fdisk-partition-in-single-line/721878
#parted -a optimal /dev/sda mkpart primary 0% 4096MB

# mandatory reboot after resizing
sudo reboot

sudo pvcreate /dev/sda3
sudo vgextend centos_centos7std /dev/sda3

# check the free space available on virtual disk. There should be some free blocks to add.
#   In this example, there are 2048 free blocks to add
#   In this example, the outer container is named /dev/mapper/centos_centos7std-root
sudo vgdisplay centos_centos7std | grep "Free"

# extend the outer container by XXXX blocks

lvextend -l +XXXX /dev/mapper/centos_centos7std-root

# extend the inner partition for XFS systems
# automatically extends it to the maximum size
xfs_growfs /dev/mapper/centos_centos7std-root

# see final results
df -hT /

# different command used for EXT4 file systems: resize2fs
#resize2fs /dev/mapper/centos_centos7std-root
