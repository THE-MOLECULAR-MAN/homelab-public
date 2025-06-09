#!/bin/bash
# Tim H 2025
# Script to fix non-unique UUIDs in a VMDK descriptor file on ESXi
# WARNING: This modifies VMDK descriptor files in-place. Use with care.

# Fixing non-unique UUIDs in FreeNAS VMDK files

##############################################################################
# MACOS SIDE
##############################################################################
NEW_UUID=$(uuidgen | sed 's/-//g' | cut -c1-32)
NEW_DDB_UUID=$(echo "$NEW_UUID" | sed 's/../& /g; s/ $//' | cut -c1-23)
NEW_LONG_CONTENT_ID="$NEW_UUID"

echo ""
echo "Paste this into the ESXi CLI:"
echo ""
echo "export NEW_UUID=\"${NEW_UUID}\""
echo "export NEW_LONG_CONTENT_ID=\"${NEW_LONG_CONTENT_ID}\""
echo "export NEW_DDB_UUID=\"${NEW_DDB_UUID}\""
echo ""


##############################################################################
# ESXI SIDE
##############################################################################
# paste the output from the MacOS section above into the ESXi CLI before 
# running this script

VM_NAME="truenas_test1"
DATASTORE="r7-3000-raid10"

# verify that the variables are set
if [ -z "${NEW_UUID}" ] || [ -z "${NEW_LONG_CONTENT_ID}" ] || [ -z "${NEW_DDB_UUID}" ] ; then
  echo "NEW_UUID or NEW_LONG_CONTENT_ID is not set. Please set them before running this script."
  exit 1
fi  

VMDK_FILE="${VM_NAME}_1.vmdk"
VMX_PATH="/vmfs/volumes/${DATASTORE}/${VM_NAME}"
VMDK_PATH="${VMX_PATH}/${VMDK_FILE}"
VM_ID=$(vim-cmd vmsvc/getallvms | grep "${VM_NAME}" | awk '{print $1}')

if [ ! -f "${VMDK_PATH}" ]; then
  echo "VMDK descriptor not found at ${VMDK_PATH}"
  exit 1
fi

# Check if the VM is powered off
VM_POWER_STATE=$(vim-cmd vmsvc/power.getstate "${VM_ID}" | tail -n1)
if [ "${VM_POWER_STATE}" != "Powered off" ]; then
    echo "VM ${VM_NAME} (ID ${VM_ID}) is not powered off. Gracefully powering off the VM..."

    # gracefully power off the VM
    vim-cmd vmsvc/power.off "${VM_ID}"
    printf "Waiting for VM ${VM_NAME} (ID ${VM_ID}) to power off."

    # wait for the VM to power off
    while true; do
        VM_POWER_STATE=$(vim-cmd vmsvc/power.getstate "${VM_ID}" | tail -n1)
        if [ "${VM_POWER_STATE}" == "Powered off" ]; then
            echo "VM ${VM_NAME} (ID ${VM_ID}) is now powered off."
            break
        fi
        printf "."
        sleep 1
    done
fi

echo "Backing up original VMDK descriptor..."
if [ -f "${VMDK_PATH}.bak" ]; then
    echo "Backup file already exists. Not overwriting."
else  
    cp -i "${VMDK_PATH}" "${VMDK_PATH}.bak"
    chmod -w "${VMDK_PATH}.bak"
fi

# current UUIDs
CURRENT_UUID=$(grep '^uuid\.location' "${VMDK_PATH}" | awk -F'"' '{print $2}')
CURRENT_DDB_UUID=$(grep '^ddb\.uuid' "${VMDK_PATH}" | awk -F'"' '{print $2}')
CURRENT_LONG_CONTENT_ID=$(grep '^ddb\.longContentID' "${VMDK_PATH}" | awk -F'"' '{print $2}')
echo "Current UUID: ${CURRENT_UUID}"
echo "Current ddb.uuid: ${CURRENT_DDB_UUID}"
echo "Current ddb.longContentID: ${CURRENT_LONG_CONTENT_ID}"    

echo "Updating descriptor file..."
sed -i "s/^ddb.uuid = .*/ddb.uuid = \"${NEW_DDB_UUID}\"/" "${VMDK_PATH}"
sed -i "s/^ddb.longContentID = .*/ddb.longContentID = \"${NEW_LONG_CONTENT_ID}\"/" "${VMDK_PATH}"

cat "$VMDK_PATH"

echo "Reloading VM ${VM_NAME} (ID ${VM_ID})..."
vim-cmd vmsvc/reload "${VM_ID}"

echo "Done. UUIDs updated and VM reloaded."

# powering on the VM
echo "Powering on the VM ${VM_NAME} (ID ${VM_ID})..."
vim-cmd vmsvc/power.on "${VM_ID}"
