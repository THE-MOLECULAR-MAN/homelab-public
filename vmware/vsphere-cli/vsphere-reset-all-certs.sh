#!/bin/bash
# Tim H 2022
# resets ALL certificates in vSphere

# something to do with the certs
# for store in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list | grep -v TRUSTED_ROOT_CRLS); do echo "[*] Store :" $store; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $store --text | grep -ie "Alias" -ie "Not After";done;

/usr/lib/vmware-vmca/bin/certificate-manager
# option 8
# use the username that's for logging into the regular SSO vSphere page
# NOT the 5480 one: administrator@vsphere.int.butters.me
# THIS TAKE A VERY VERY LONG TIME, LIKE 45 MINUTES
