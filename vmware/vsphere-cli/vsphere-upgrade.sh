#!/bin/bash
# Tim H 2022
# upgrade vSphere

# references:
# https://docs.vmware.com/en/VMware-vSphere/7.0/rn/vsphere-vcenter-server-70u3e-release-notes.html
# DO NOT do this over SSH, login through ESXi (not vSphere) and use the local console

software-packages stage --url --acceptEulas
# type "yes" twice

software-packages list --staged

software-packages install --staged

# I think a reboot is required after this
