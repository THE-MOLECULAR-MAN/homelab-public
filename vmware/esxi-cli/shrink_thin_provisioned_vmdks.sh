#!/bin/sh
# Tim H 2025
# for shrinking virtual disks in VMware ESXi v7 command line that have thin provisioned disks

# ssh root@10.0.1.13
# ssh root@10.0.1.27

# esxcli does not have screen
# screen -S shrink_vmdks -d -m -L -Logfile /var/log/shrink_vmdks.log

# set -euo pipefail

cd /vmfs/volumes

# find /vmfs/volumes/r7-3000-raid10/ -type f -name 'vmware*.log' -exec rm -f "{}" \;

find . -type f -name '*.vmdk' ! -name '*-flat.vmdk' -exec sh -c '
  for virtual_disk_filepath in "$@"; do
    vmkfstools --punchzero "$virtual_disk_filepath" || continue
    thin_temp_filename="${virtual_disk_filepath%.vmdk}-thin.vmdk"
    vmkfstools -i "$virtual_disk_filepath" -d thin "$thin_temp_filename" || continue
    thick_filename="${virtual_disk_filepath%.vmdk}-orig.vmdk"
    mv "$virtual_disk_filepath" "$thick_filename" || continue
    mv "$thin_temp_filename" "$virtual_disk_filepath" || continue
  done ' sh {} +

echo "Finished shrinking all VMDKs."
