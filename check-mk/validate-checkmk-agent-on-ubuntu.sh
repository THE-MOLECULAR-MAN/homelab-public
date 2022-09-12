#!/bin/bash
# Tim H 2022

# validate checkmk agent on Ubuntu

sudo ufw status

# verify binary exists and can run:
/usr/bin/check_mk_agent --version

# port 6556

# scan it from the checkmk server:

TARGET_IN_PROGRESS="REDACTED.int.REDACTED.me"

nmap -Pn -p22,6556 "$TARGET_IN_PROGRESS"
echo | nc "$TARGET_IN_PROGRESS" 6556

# working on Ubuntu:
# sudo systemctl list-units --all --type=service --no-pager
sudo service check-mk-agent-async       status

# show the network config:
sudo cat /etc/systemd/system/check-mk-agent.socket
sudo vim /etc/systemd/system/check-mk-agent.socket


sudo netstat -tulpn | grep -i '6556\|mk\|LISTEN'

ss -tulpn | grep 6556

check_mk_agent


# fix the daemon file to remove any incoming IP filters
# must reload the daemon list, not the config file
echo "# systemd socket definition file
[Unit]
Description=Checkmk agent socket

[Socket]
ListenStream=6556
Accept=true
MaxConnectionsPerSource=3
IPAddressDeny=none
IPAddressAllow=any

[Install]
WantedBy=sockets.target" | sudo tee /etc/systemd/system/check-mk-agent.socket && sudo systemctl daemon-reload


