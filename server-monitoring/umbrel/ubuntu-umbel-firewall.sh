#!/bin/bash
# Tim H 2022

netstat -u
netstat -t

# let it do anything it wants on the LAN
# but only allow a few internet bound rules

# https://serverfault.com/questions/74023/ufw-on-ubuntu-to-allow-all-traffic-on-lan

sudo ufw enable
sudo ufw default deny outgoing
sudo ufw default deny incoming
sudo ufw allow in  ssh
sudo ufw allow in  http
sudo ufw allow in  8385
sudo ufw allow in  2000
sudo ufw allow out 53
sudo ufw allow out http
sudo ufw allow out https
sudo ufw allow out ldap


sudo ufw allow from 10.0.1.0/24
# sudo ufw allow to   10.0.1.0/24

sudo ufw status
