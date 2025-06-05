#!/bin/bash
#
# ESXi v7 Disk Minimization Script for All VMs
#
# For each VM on the host, this script will:
#  1. Check if powered on; if so, gracefully shut it down and wait until it is powered off.
#  2. Disconnect any attached datastore ISO (CD-ROM) devices.
#  3. Delete all snapshots.
#  4. Consolidate disks (i.e., run “snapshot.consolidate”).
#  5. Punch zeroes on each VMDK to reclaim unused space.
#
# Usage: Copy this to a file on the ESXi shell (e.g. /root/minimize_all_vms.sh), then:
#   scp ~/source_code/homelab-public/vmware/esxi-cli/shrink_all_ESXi_VMs.sh root@10.0.1.13:/
#   chmod +x /root/minimize_all_vms.sh
#   /root/minimize_all_vms.sh
#
# Run as root or with equivalent privileges on the ESXi host.

set -euo pipefail

# ------------- Helper Functions -------------

# Wait until the given VM is powered off
wait_for_poweroff() {
  local vmid=$1
  local state
  while true; do
    state=$(vim-cmd vmsvc/power.getstate "$vmid" 2>/dev/null | tail -1)
    if [[ "$state" == "Powered off" ]]; then
      echo "    VM $vmid is now powered off."
      break
    fi
    echo "    Waiting for VM $vmid to power off (current state: $state)..."
    sleep 5
  done
}

# Disconnect all CD-ROM (ISO) devices from a VM
disconnect_iso_devices() {
  local vmid=$1
  # Get device list, look for VirtualCdrom entries and extract their keys
  local dev_list
  dev_list=$(vim-cmd vmsvc/device.getdevices "$vmid" 2>/dev/null)

  # Parse out lines that identify the key for each VirtualCdrom.
  # We look for a block containing "VirtualCdrom" and find the preceding "key = <num>"
  local cd_keys=()
  while read -r line; do
    if [[ $line =~ key[[:space:]]*=[[:space:]]*([0-9]+) ]]; then
      key="${BASH_REMATCH[1]}"
      # Peek ahead a few lines to see if this block contains "VirtualCdrom"
      # We capture the next 5 lines from the device.getdevices output to check for type.
      block=$(echo "$dev_list" | sed -n "/key = $key/,/^\s*key = /p" | head -n 5)
      if echo "$block" | grep -q "VirtualCdrom"; then
        cd_keys+=("$key")
      fi
    fi
  done <<< "$(echo "$dev_list")"

  # For each CD-ROM device key, disconnect it (set connected to false)
  for key in "${cd_keys[@]}"; do
    echo "    Disconnecting CD-ROM device (key=$key) from VM $vmid..."
    vim-cmd vmsvc/device.connection "$vmid" "$key" 0 0 2>/dev/null || {
      echo "      ✖ Failed to disconnect device key $key. Continuing."
    }
  done

  if [ "${#cd_keys[@]}" -eq 0 ]; then
    echo "    No CD-ROM devices found for VM $vmid."
  fi
}

# Delete all snapshots for a VM
delete_snapshots() {
  local vmid=$1
  echo "    Deleting all snapshots for VM $vmid..."
  vim-cmd vmsvc/snapshot.removeall "$vmid" 2>/dev/null || {
    echo "      ✖ Snapshot deletion failed or no snapshots existed."
  }
}

# Consolidate snapshots/disks for a VM
consolidate_disks() {
  local vmid=$1
  echo "    Consolidating disks for VM $vmid..."
  vim-cmd vmsvc/snapshot.consolidate "$vmid" 2>/dev/null || {
    echo "      ✖ Consolidation failed or no consolidation needed."
  }
}

# Punch zeroes on all VMDKs of a VM
punch_zero_vmdks() {
  local vmid=$1
  echo "    Identifying VMDK files for VM $vmid..."

  # Retrieve the VM’s file layout, which lists all files used by the VM.
  # We filter for .vmdk lines.
  local file_layout
  file_layout=$(vim-cmd vmsvc/get.filelayout "$vmid" 2>/dev/null)

  # Extract lines containing “.vmdk” and isolate the full datastore path, e.g. "[datastore1] VMname/VMname.vmdk"
  # Then translate that into an absolute ESXi path: /vmfs/volumes/datastore1/VMname/VMname.vmdk
  # The layout output usually shows lines like:
  #   "    [datastore1] VMname/VMname.vmdk"
  # We strip the leading spaces and brackets.
  while read -r line; do
    # Trim whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    if [[ "$line" =~ \[(.+)\][[:space:]]+(.+\.vmdk) ]]; then
      ds="${BASH_REMATCH[1]}"
      vmdkpath="${BASH_REMATCH[2]}"
      # Construct absolute path
      abs_path="/vmfs/volumes/$ds/$vmdkpath"
      # Confirm that the file exists
      if [ -f "$abs_path" ]; then
        echo "      Punching zeroes on $abs_path ..."
        vmkfstools --punchzero "$abs_path" 2>/dev/null || {
          echo "        ✖ vmkfstools --punchzero failed on $abs_path. Continuing."
        }
      else
        echo "      Skipping missing file $abs_path"
      fi
    fi
  done <<< "$(echo "$file_layout")"
}

# ------------- Main Loop -------------

echo "=============================================================="
echo "Starting ESXi VM disk-minimization process at $(date)"
echo "=============================================================="

# 1. Get a list of all VM IDs
all_vm_ids=()
while read -r id; do
  all_vm_ids+=("$id")
done < <(vim-cmd vmsvc/getallvms | awk 'NR>1 { print $1 }')

# If no VMs found, exit
if [ ${#all_vm_ids[@]} -eq 0 ]; then
  echo "No VMs found on this ESXi host. Exiting."
  exit 0
fi

# Iterate through each VM
for vmid in "${all_vm_ids[@]}"; do
  echo
  echo "--------------------------------------------------------------"
  vm_name=$(vim-cmd vmsvc/get.summary "$vmid" | grep "name =" | head -1 | awk -F\" '{print $2}')
  echo "Processing VM ID: $vmid  (Name: $vm_name)"

  # 2. Check power state
  state=$(vim-cmd vmsvc/power.getstate "$vmid" 2>/dev/null | tail -1)
  echo "  Power state: $state"

  # If the VM is powered on, issue a guest shutdown and wait
  if [[ "$state" == "Powered on" ]]; then
    echo "  → Shutting down VM $vmid gracefully..."
    vim-cmd vmsvc/power.shutdown "$vmid" 2>/dev/null || {
      echo "    ✖ Failed to issue shutdown for VM $vmid (maybe VMware Tools not running). Forcing power off..."
      vim-cmd vmsvc/power.off "$vmid" 2>/dev/null || {
        echo "      ✖ Forced power-off also failed. Skipping this VM."
        continue
      }
    }
    # Wait until it is powered off
    wait_for_poweroff "$vmid"
  else
    echo "  → VM $vmid is already powered off."
  fi

  # 3. Disconnect any ISO/CD-ROM devices
  disconnect_iso_devices "$vmid"

  # 4. Delete all snapshots
  # delete_snapshots "$vmid"

  # 5. Consolidate disks
  consolidate_disks "$vmid"

  # 6. Punch zeroes on each VMDK
  # punch_zero_vmdks "$vmid"

  echo "Completed processing VM $vmid (Name: $vm_name)."
done

echo
echo "=============================================================="
echo "All VMs processed. Completed at $(date)"
echo "=============================================================="
