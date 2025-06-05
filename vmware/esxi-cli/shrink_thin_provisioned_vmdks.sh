#!/bin/bash
# Tim H 2025



# for shrinking virtual disks in VMware ESXi v7 that have thin provisioned disks

ssh root@10.0.1.13

screen -S shrink_vmdks -d -m -L -Logfile /var/log/shrink_vmdks.log

# 1.4 TB used before shrinking

set -euo pipefail

find . -type f -name '*.vmdk' -exec sh -c '
  for vmdk; do
    echo "Shrinking $vmdk ..."
    vmkfstools --punchzero "$vmdk"
    echo "Finished shrinking $vmdk ."
  done ' sh {} +

echo "Finished shrinking all VMDKs."

# vmkfstools --punchzero "/vmfs/volumes/datastore1/MyVM/MyVM.vmdk"
# [r7-3000-raid10] dss2/dss2.vmdk
