#!/bin/sh
#
# ESXi v7 Disk Minimization Script for All VMs (POSIX-sh syntax)
#
# For each VM on the host, this script will:
#  1. Check if powered on; if so, gracefully shut it down and wait until it is powered off.
#  2. Disconnect any attached datastore ISO (CD-ROM) devices.
#  3. Delete all snapshots.
#  4. Consolidate disks (i.e., run “snapshot.consolidate”).
#  5. Punch zeroes on each VMDK to reclaim unused space.
#
# Usage:
#   scp shrink_all_ESXi_VMs.sh root@<esxi-host>:/root/
#   ssh root@<esxi-host>
#   chmod +x /root/shrink_all_ESXi_VMs.sh
#   /root/shrink_all_ESXi_VMs.sh
#
# Must be run as root (or equivalent) on the ESXi host.

set -e  # Exit immediately if any command fails

# ------------- Helper Functions -------------

# Wait until the given VM is powered off
wait_for_poweroff() {
  vmid=$1
  while true; do
    state=$(vim-cmd vmsvc/power.getstate "$vmid" 2>/dev/null | tail -1)
    if [ "$state" = "Powered off" ]; then
      echo "    VM $vmid is now powered off."
      break
    fi
    echo "    Waiting for VM $vmid to power off (current state: $state)..."
    sleep 5
  done
}

# Disconnect all CD-ROM (ISO) devices from a VM
disconnect_iso_devices() {
  vmid=$1
  echo "  Disconnecting ISO/CD-ROM devices for VM $vmid..."

  # Get the raw device list for this VM
  dev_list=$(vim-cmd vmsvc/device.getdevices "$vmid" 2>/dev/null)

  # For each line containing "key = X", check whether that device block is a VirtualCdrom
  echo "$dev_list" | while IFS= read -r line; do
    # If the line matches "key = some_number", capture that number
    echo "$line" | grep -q '^[[:space:]]*key[[:space:]]*=' || continue
    key=$(echo "$line" | awk -F'=' '{ print $2 }' | sed 's/[[:space:]]//g')
    if [ -z "$key" ]; then
      continue
    fi

    # Now extract the block of ~5 lines after "key = X" and see if "VirtualCdrom" appears
    block=$(echo "$dev_list" | sed -n "/key = $key/,/^ *key = /p" | head -n 5)
    echo "$block" | grep -q "VirtualCdrom"
    if [ $? -eq 0 ]; then
      echo "    Disconnecting CD-ROM device (key=$key) from VM $vmid..."
      vim-cmd vmsvc/device.connection "$vmid" "$key" 0 0 2>/dev/null \
        || echo "      ✖ Failed to disconnect device key $key. Continuing."
    fi
  done
}

# Delete all snapshots for a VM
delete_snapshots() {
  vmid=$1
  echo "    Deleting all snapshots for VM $vmid..."
  vim-cmd vmsvc/snapshot.removeall "$vmid" 2>/dev/null \
    || echo "      ✖ Snapshot deletion failed or no snapshots existed."
}

# Consolidate snapshots/disks for a VM
consolidate_disks() {
  vmid=$1
  echo "    Consolidating disks for VM $vmid..."
  vim-cmd vmsvc/snapshot.consolidate "$vmid" 2>/dev/null \
    || echo "      ✖ Consolidation failed or no consolidation needed."
}

# Punch zeroes on all VMDKs of a VM
punch_zero_vmdks() {
  vmid=$1
  echo "    Identifying VMDK files for VM $vmid..."

  # Retrieve the VM’s file layout, which lists every file used by the VM
  file_layout=$(vim-cmd vmsvc/get.filelayout "$vmid" 2>/dev/null)

  echo "    Processing VMDK files for VM $vmid..."

  # For each line that looks like "[datastoreName] Path/To/VM.vmdk", construct absolute path
  echo "$file_layout" | while IFS= read -r line; do

    echo "Starting to process line $line"
    # Trim leading whitespace
    trimmed=$(echo "$line" | sed 's/^[[:space:]]*//')
    # If this line contains “[something] ... .vmdk”
    echo "$trimmed" | grep -q '^\[.*\].*\.vmdk'
    if [ $? -ne 0 ]; then
      continue
    fi

    # Extract the datastore name inside brackets and the relative path
    # Format:    [datastore1] VMfolder/VMname.vmdk
    ds=$(echo "$trimmed" | sed -n 's/^\[\([^]]*\)\].*$/\1/p')
    vmdkpath=$(echo "$trimmed" | sed -n 's/^\[.*\][[:space:]]*//;s/ //g;p')

    # Construct the absolute ESXi path: /vmfs/volumes/<datastore>/<vmdkpath>
    abs_path="/vmfs/volumes/$ds/$vmdkpath"

    if [ -f "$abs_path" ]; then
      echo "      Punching zeroes on $abs_path ..."
      vmkfstools --punchzero "$abs_path" 2>/dev/null \
        || echo "        ✖ vmkfstools --punchzero failed on $abs_path. Continuing."
    else
      echo "      Skipping missing file $abs_path"
    fi
  done
}

# ------------- Main Loop -------------

echo "=============================================================="
echo "Starting ESXi VM disk-minimization process at $(date)"
echo "=============================================================="

# 1. Get a list of all VM IDs (vim-cmd vmsvc/getallvms -> skip header)
vmid_list=$(vim-cmd vmsvc/getallvms | awk 'NR>1 { print $1 }')

# If no VMs found, exit
echo "$vmid_list" | grep -q '[0-9]'
if [ $? -ne 0 ]; then
  echo "No VMs found on this ESXi host. Exiting."
  exit 0
fi

# 2. Iterate through each VM ID
echo "$vmid_list" | while IFS= read -r vmid; do
  # Skip empty lines (if any)
  [ -z "$vmid" ] && continue

  echo
  echo "--------------------------------------------------------------"
  vm_name=$(vim-cmd vmsvc/get.summary "$vmid" | grep 'name =' | head -1 | awk -F\" '{ print $2 }')
  echo "Processing VM ID: $vmid  (Name: $vm_name)"

  # 3. Check power state
  state=$(vim-cmd vmsvc/power.getstate "$vmid" 2>/dev/null | tail -1)
  echo "  Power state: $state"

  # If the VM is powered on, issue a guest shutdown (or force off if needed)
  if [ "$state" = "Powered on" ]; then
    echo "  → Attempting graceful shutdown of VM $vmid..."
    vim-cmd vmsvc/power.shutdown "$vmid" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "    ✖ Guest shutdown failed (perhaps VMware Tools not running). Forcing power off..."
      vim-cmd vmsvc/power.off "$vmid" 2>/dev/null \
        || { echo "      ✖ Forced power-off also failed. Skipping this VM."; continue; }
    fi

    # Wait until it is powered off
    wait_for_poweroff "$vmid"
  else
    echo "  → VM $vmid is already powered off."
  fi

  # 4. Disconnect any ISO/CD-ROM devices
  # disconnect_iso_devices "$vmid"

  # 5. Delete all snapshots
  delete_snapshots "$vmid"

  # 6. Consolidate disks
  consolidate_disks "$vmid"

  # 7. Punch zeroes on each VMDK
  # punch_zero_vmdks "$vmid"

  echo "Completed processing VM $vmid (Name: $vm_name)."
done

echo
echo "=============================================================="
echo "All VMs processed. Completed at $(date)"
echo "=============================================================="
