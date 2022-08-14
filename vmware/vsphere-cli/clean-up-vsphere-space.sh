#!/bin/bash
# Tim H 2022
# frees up disk space on vSphere VM, usually caused by bugs that don't clean up old files

# references
# https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vcenter.configuration.doc/GUID-48BAF973-4FD3-4FF3-B1B6-5F7286C9B59A.html
# https://kb.vmware.com/s/article/68020
# https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.hostclient.doc/GUID-DD999601-2F41-498D-A577-DDC7C06648EE.html
# https://kb.vmware.com/servlet/rtaImage?eid=ka05G000001EuBq&feoid=00Nf400000Tyi5C&refid=0EM5G000005Vagm


# once fixed:
#https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vcenter.configuration.doc/GUID-467DA288-7844-48F5-BB44-99DE6F6160A4.html
#https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.hostclient.doc/GUID-DD999601-2F41-498D-A577-DDC7C06648EE.html


# show all partitions
df -h

# show partitions that are over 79% used
df -h |awk '0+$5 >= 78 {print}'

# check inode usage, never seen above 3%
df -ih

# delete old log files
find /storage/log                -iname 'catalina*log'      -type f -delete
find /storage/log                -iname 'localhost_access*' -type f -delete
find /var/log/vmware/vmware-sps  -iname 'sps-access*log'    -type f -delete
rm -f /var/mail/root

find /storage/log -iname '*.log' -mtime +7 -type f -exec truncate {} --size 0 \;
find /storage/log -type f -size +100M -mtime +28   -exec truncate {} --size 0 \;

# locate the log disk and partition for resizing
fdisk -l /dev/mapper/log_vg-log
# Disk /dev/mapper/log_vg-log: 10 GiB, 10729029632 bytes, 20955136 sectors
dmesg | grep log_vg-log


df -h

# these files prob shouldn't be there; was a bug with older version of vsphere
find /storage/core -type f -iname 'core.in*' -size +1M -ls
du -a /storage/core | sort -n -r | grep '/storage/core/core.in:imfile.' | head -n 20 | cut --delimiter=" " -f2
mkdir /storage/lifecycle/storage-core-backup/
#mv /storage/core/core.in:imfile.* /storage/lifecycle/storage-core-backup/
# move them immediately one at a time. Frees up space faster than mv but is slower
find /storage/core/  -maxdepth 1  -type f -name 'core.in:imfile.*' -exec mv {} /storage/lifecycle/storage-core-backup/ \;

# files being actively written to aren't released, may want to stop services before I do the above command
# can't be in that directory when using lsof
cd ~ && lsof -a +L1 /dev/mapper/core_vg-core /storage/core
cd ~ && lsof +D     /storage/core
