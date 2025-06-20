#!/bin/bash
# Tim H 2023

# https://kb.vmware.com/s/article/80469

# CLI tool for diagnosing and fixing vSphere issues
# should be run while in SSH session on the vSphere VM

# Had to do this stuff so I could migrate a vSphere 7 to 8

# all of the changes I made, not all listed here, seemed to fix it
# make sure NTP service is running and set to autostart, and is working
# I also manually deleted a few plugins like this: https://kb.vmware.com/s/article/1025360
# I removed the CyberPower one and a few others that were causing issues

# These 3 warnings remained on my last run but didn't cause any issues:
# Files that cannot be used with Lifecycle Manager 8.0.0 will not be copied from the source. These files
# include VM guest OS patch baselines, host upgrade baselines and files, and ESXi 6.5 and lower version
# host patches baselines.
#
#This ESXi host (//10.0.1.27:443] is managed by Center Server (10.0.1.31].
# Make sure the cluster where this ESXi host resides is not set to Fully Automated DRS for the duration of
# the upgrade process.

# Integrated Windows Authentication is deprecated. Learn more


mkdir ~/lsdoctor
cd ~/lsdoctor || exit 1
curl --output lsdoctor.zip \
    'https://kb.vmware.com/sfc/servlet.shepherd/version/download/0685G0000156OnnQAE' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'Referer: https://kb.vmware.com/s/article/80469' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Cookie: redacted' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' \
    -H 'TE: trailers'

unzip lsdoctor.zip

cd lsdoctor-master || exit 2
python lsdoctor.py --help

# 2023-02-15T02:07:38 ERROR generateReport: default-site\vsphere.int.butters.me (VC 7.0 or CGW) found Duplicates Found: Ignore if this is the PSC HA VIP.  Otherwise, you must unregister the extra endpoints.
# 2023-02-15T02:07:38 INFO generateReport: Report generated:  /var/log/vmware/lsdoctor/vsphere.int.butters.me-2023-02-15-020738.json

# cat /var/log/vmware/lsdoctor/*.json

python lsdoctor.py --stalefix
python lsdoctor.py --trustfix

# this can wreck things:
# I tried this:         2.  Replace all services with new services.
# You have selected a Rebuild function.  This is a potentially destructive operation!
# All external solutions and 3rd party plugins that register with the lookup service may
# have to be re-registered.  For example: SRM, vSphere Replication, NSX Manager, etc.

# this takes several minutes to run:
# this fixed the duplicate service names issue and removed some unused plugins
python lsdoctor.py --rebuild

# unrelated thing that needed to be changed too:
# https://kb.vmware.com/s/article/71083
/opt/likewise/bin/domainjoin-cli leave
# gotta also delete the AD listing in the GUI
reboot now && logout
