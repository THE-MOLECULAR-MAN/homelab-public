#!/bin/bash
# Tim H 2022

# Troubleshooting NXlog service issues in Linux

# see if service is running
systemctl status nxlog.service

# verify the config file has no syntax errors
# doesn't launch service, just validates the config file
/usr/bin/nxlog -v



ss -tulwn  | grep "7878"

# watch incoming traffic on the port to verify incoming syslog
tcpdump -i ens192 udp port "7878" -X

# view logs
tail -f /var/log/nxlog/nxlog.log 

ps aux | grep  /usr/bin/nxlog

/usr/bin/nxlog -f
ls -lah /run/nxlog/nxlog.pid && cat /run/nxlog/nxlog.pid
cat /etc/nxlog/nxlog.conf
tail -n5 /var/log/unifi.log

ls -lah /run/nxlog
mkdir  /run/nxlog/
touch  /run/nxlog/nxlog.pid