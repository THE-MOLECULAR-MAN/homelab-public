#!/bin/bash
# Tim H 2022
# MOVE_TO_GRAVEYARD
# fixing NXLog issues


sudo yum reinstall nxlog-ce.rpm
sudo systemctl enable nxlog.service
sudo systemctl start nxlog.service
sudo systemctl status nxlog.service

echo "
LogFile /var/log/nxlog/nxlog.log
LogLevel INFO
" | sudo tee -a /etc/nxlog/nxlog.conf

sudo systemctl restart nxlog.service

# check firewall rules too

# NXLog fixes on CentOS 7
sudo mkdir /var/run/nxlog
sudo chown nxlog:nxlog /var/run/nxlog
sudo systemctl start nxlog.service
tail /var/log/nxlog/nxlog.log

# see ports in use:
cat /etc/nxlog/nxlog.conf

# verify incoming data over UDP port 7878
sudo tcpdump -i ens192 udp port 7878 -X

# verify outgoing data: to remote UDP 7879
sudo tcpdump -i ens192 udp port 7879 -X
