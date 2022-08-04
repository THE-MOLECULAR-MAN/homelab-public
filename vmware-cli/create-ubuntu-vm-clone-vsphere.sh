#!/bin/bash
# Tim H 2022
# script for automating VM cloning via the vSphere API.
# Clones an existing VM and outputs the new one's MAC address.
# Just a proof of concept run before writing InsightConnect plugin
#
# Setup steps:
#   1) create a service account on vSphere and plugin the username in this script
#        store the password (no new line) in the text file named "vsphere_password.txt"
#   2) get the vm name for the device you want to clone. In this example it is
#       "golden-ubuntu". Change that in the get_vm_id function below.
#   3) run this script. Example:
#       ./create-ubuntu-vm-clone-vsphere.sh newclonenamehere
#
# References:
#   https://app.swaggerhub.com/apis/dmilov/script-runtime-service-for-vsphere/1.0#/script_executions/create.script.execution
#   https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/vcenter/VM/
#   https://developer.vmware.com/apis/vsphere-automation/latest/

set -e

VSPHERE_FQDN="vsphere.int.redacted.me"
VSPHERE_USERNAME="svc-redacted-username@vsphere.int.redacted.me"

VSPHERE_PASSWORD=$(cat vsphere_password.txt)
NEW_VM_HOSTNAME="$1 (new ubuntu clone)"

VSPHERE_BASE_URL="https://{$VSPHERE_FQDN}/api"
SESSION_HEADER_NAME="vmware-api-session-id"

vsphere_auth() {
    SESSION_ID=$(curl --silent --insecure -X POST "$VSPHERE_BASE_URL/session" -u "$VSPHERE_USERNAME:$VSPHERE_PASSWORD" | awk -F'"' '{print $2}' )
    export SESSION_ID
}

vsphere_list_vms() {
    curl --output vmlist.json --silent --insecure -X GET \
        -H "$SESSION_HEADER_NAME: $SESSION_ID" \
        "$VSPHERE_BASE_URL/vcenter/vm"
}

get_vm_id() {
    # gets the ID for the VM to clone
    ORIGINAL_VM_ID=$(jq --raw-output '.[] | select(.name=="golden-ubuntu") | .vm' vmlist.json)
    # ICON version:
    # jq --raw-output '.body_object.object[] | select(.name=="golden-ubuntu") | .vm' ~/Desktop/get-list-of-vms-output.json
    export ORIGINAL_VM_ID
}

generate_clone_post_data()
{
  cat <<EOF
{ 
    "name": "$NEW_VM_HOSTNAME", 
    "source": "$ORIGINAL_VM_ID"
}
EOF
}

clone_vm() {
    # https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/vmactioninstant-clone/post/
    # instant_clone only works on powered on VMs, not powered off ones
    echo "cloning golden-ubuntu into $NEW_VM_HOSTNAME..."

    curl  --insecure -X POST \
    --trace-ascii vsphere-debug.log \
    --output new-clone-id.json \
    -H "$SESSION_HEADER_NAME: $SESSION_ID" \
    -H "Content-Type: application/json" \
    --data-raw "$(generate_clone_post_data)" \
    "$VSPHERE_BASE_URL/vcenter/vm?action=clone"

    echo "new-clone-id.json contents:"
    cat new-clone-id.json

    NEW_VM_ID=$(cat new-clone-id.json)
    export NEW_VM_ID
}

get_vm_mac_address() {
    # https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/vm/vm/get/
    curl --output getvm-response.json --insecure -X GET \
        -H "$SESSION_HEADER_NAME: $SESSION_ID" \
        "$VSPHERE_BASE_URL/vcenter/vm/$NEW_VM_ID"

    NEW_MAC=$(jq --raw-output '.nics[].mac_address' getvm-response.json)
    export NEW_MAC
}

####### MAIN
vsphere_auth
vsphere_list_vms 
get_vm_id
clone_vm
get_vm_mac_address

echo "New hostname: $NEW_HOSTNAME  New MAC: $NEW_MAC"

echo "script finished successfully"
