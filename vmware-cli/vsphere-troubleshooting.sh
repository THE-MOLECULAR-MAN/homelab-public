#!/bin/bash
# Tim H 2022
# vSphere troubleshooting
#https://kb.vmware.com/s/article/2109887#listing_vCenter_server_appliance_services

/bin/service-control --list | grep -i 'web\|proxy'

/bin/service-control --start vmware-rhttpproxy
#/bin/service-control --start vsphere-client
/bin/service-control --start vsphere-ui

/bin/service-control --stop --all
/bin/service-control --start --all

# check if disk space full - reboot?
# check if expired certs- "Expires: Monday, August 15, 2022 at 3:56:04 AM Eastern Daylight Time"
# time sync problems - date was fine
# try Chrome instead of firefox

# tailing logs for errors
tail -f /storage/log/vmware/vsphere-ui/logs/vsphere_client_virgo.log /storage/log/vmware/vpxd/vpxd.log
tail -f /storage/log/vmware/vsphere-ui/logs/vsphere_client_virgo.log /storage/log/vmware/vpxd/vpxd.log | grep -i error
rm -f /storage/log/vmware/vsphere-ui/logs/vsphere_client_virgo.log
grep '\[ERROR\]' /storage/log/vmware/vsphere-ui/logs/vsphere_client_virgo.log
grep -i error /storage/log/vmware/vpxd/vpxd.log

#https://kb.vmware.com/s/article/82332
/bin/service-control --status --all
/bin/service-control --start  --all


# some sort of integrity checker, never seen it pass, always fails
#/etc/profile.d/VMware-visl-integration.sh; /usr/lib/vmware/site-packages/cis/integrity_checker.py -f check
