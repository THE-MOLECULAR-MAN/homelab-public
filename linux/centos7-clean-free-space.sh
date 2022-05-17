#!/bin/bash
# Tim H 2021
##############################################################################
# Clean up unused things to minimize disk usage
#   and shrink the future MicroSD card image
##############################################################################

# clean up the history of users
# https://www.linuxuprising.com/2019/10/how-to-clean-up-systemd-journal-logs.html
sudo journalctl --disk-usage
sudo journalctl --vacuum-size=1K
# not all versions of journalctl recognize the --rotate flag
sudo journalctl --disk-usage

# clean up yum caches
yum clean all

# remove unused Yum packages
package-cleanup --quiet --leaves 
package-cleanup --quiet --leaves | xargs yum remove -y

# remove old, unused Kernels, keep only the most recent 2 kernels
package-cleanup -y --oldkernels --count=2

# clear out logs but don't delete the files
find /var -name "*.log" -exec truncate {} --size 0 \;
find /var/log -type f -exec truncate {} --size 0 \;

# delete some cache files/directories
rm -rf /root/.composer/cache
rm -rf /home/*/.composer/cache
rm -rf /home/*/.cache/*/* /root/.cache/*/* 
rm -rf /var/cache/yum
rm -rf /var/tmp/yum-*

# begin the process of trimming the SSD (may take a long time in the background)
# the fstrim command should be after all the deletes and at the bottom
# of this script
fstrim --verbose --all
