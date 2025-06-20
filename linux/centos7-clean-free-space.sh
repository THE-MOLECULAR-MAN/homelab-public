#!/bin/bash
# Tim H 2021
##############################################################################
# Clean up unused things to minimize disk usage
#   and shrink the future MicroSD card image
##############################################################################

# clean up the history of users
# https://www.linuxuprising.com/2019/10/how-to-clean-up-systemd-journal-logs.html
journalctl --rotate
journalctl --flush
journalctl --sync 
journalctl --vacuum-size=1

# clean up yum caches
yum clean all

# remove unused Yum packages
sudo package-cleanup --quiet --leaves | xargs yum remove -y

# remove old, unused Kernels, keep only the most recent 2 kernels
sudo package-cleanup -y --oldkernels --count=2

# clear out logs but don't delete the files
find /var/log -type f -name "*log" -exec truncate "{}" --size 0 \;
find /var/log -type f -name "*.gz" -delete
find /var/log -type f \( -name "*.log.[0-9]" -o -name "*.[0-9].log" -o -name "*.[0-9]" \) -delete

# delete some cache files/directories
rm -rf /root/.composer/cache
rm -rf /home/*/.composer/cache
rm -rf /home/*/.cache/*/* /root/.cache/*/* 
rm -rf /var/cache/yum
rm -rf /var/tmp/yum-*
rm -rf /tmp/* /var/tmp/*

# for VMware ESXi virtual machines, shrink the VMDK
dd if=/dev/zero of=/zerofile bs=1M status=progress || true
sync
rm -f /zerofile
sync
echo
echo "=== Cleanup complete at $(date) ==="
shutdown -h now


# for MicroSD cards, we need to trim the SSD
# begin the process of trimming the SSD (may take a long time in the background)
# the fstrim command should be after all the deletes and at the bottom
# of this script
fstrim --verbose --all
