#!/bin/bash
# Tim H 2021
# To be done on CentOS 7 golden image before snapshot/shutdown/cloning


# Reset the SSH server host keys before cloning
# Do this first since it relies on Yum caches to run faster
#https://serverfault.com/questions/471327/how-to-change-a-ssh-host-key
sudo rm -f /etc/ssh/ssh_host_*
sudo yum reinstall -y openssh-server
sudo systemctl restart sshd.service

yum clean all

package-cleanup --quiet --leaves 
package-cleanup --quiet --leaves | xargs yum remove -y

# CentOS 7 and earlier:
package-cleanup -y --oldkernels --count=2

# clear out logs but don't delete the files
find /var -name "*.log" -exec truncate {} --size 0 \;

# delete some cache files/directories
rm -rf /root/.composer/cache
rm -rf /home/*/.composer/cache
rm -rf /home/*/.cache/*/* /root/.cache/*/* 
rm -rf /var/cache/yum
rm -rf /var/tmp/yum-*

history -c

# add a TRIM command for SSDs and VMs? - see the raspbery pi stuff I wrote in another file
fstrim --all --verbose
