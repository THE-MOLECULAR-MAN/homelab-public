#!/bin/bash
# Tim H 2022
# upgrade vSphere

# references:
# https://docs.vmware.com/en/VMware-vSphere/7.0/rn/vsphere-vcenter-server-70u3e-release-notes.html
# DO NOT do this directly over SSH, login through ESXi (not vSphere) and use the local console
# ssh into jump box
# open screen session
# ssh into ESXi console  - ssh root@vsphere.int.butters.me

# clear any pending updates, can cause issues if not done first
software-packages unstage

software-packages stage --url --acceptEulas
# this takes several minutes to download updates

software-packages list --staged

software-packages install --staged
# enter the "SSO" password
# this will take a while, so it's okay to disconnect from the screen session
# but don't kill the main ssh session

# I think a reboot is required after this
