#!/bin/bash
# Tim H 2022
# Cisco Umbrella Dynamic DNS agent installation for Linux
# https://support.opendns.com/hc/en-us/articles/227987727-Linux-IP-Updater-for-Dynamic-Networks

sudo apt-get update
sudo apt-get -y install ddclient


/etc/ddclient.conf

##
## OpenDNS.com account-configuration
##
protocol=dyndns2
use=web, web=myip.dnsomatic.com
ssl=yes
server=updates.opendns.com
login=opendns_username
password='opendns_password'
opendns_network_label

