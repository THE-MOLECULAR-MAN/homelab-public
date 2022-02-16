#!/bin/bash
# Tim H 2021
#
# Install script for CentOS7 or Ubuntu 18.04 vanilla
# 4 GB RAM, 2 CPU cores, 200 GB HDD
# install this on a Linux VM
#	https://docs.securityonion.net/en/2.3/installation.html
#	https://docs.securityonion.net/en/2.3/hardware.html#hardware
#
#   !NON-EXECUTABLE! not ready to be fully automated yet, still is copy and paste

# install dependencies
sudo yum -y install git

# download code for SecurityOnion from GitHub
mkdir ~/source-installers
cd ~/source-installers || exit 1
git clone https://github.com/Security-Onion-Solutions/securityonion

# Total run time:  (~28 min) 1675.932 s, NOT including post-install scripts
screen

# start the setup
# have a few questions, then like 1 min of install then more questions before long install
# want: Wazuh, Strelka
cd ~/source-installers/securityonion || exit 2
sudo bash so-setup-network

# set up syslog:
# download epel and install the repo
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh epel-release-latest-7.noarch.rpm
cd /etc/yum.repos.d/ || exit 3
wget https://copr.fedorainfracloud.org/coprs/czanik/syslog-ng331/repo/epel-7/czanik-syslog-ng331-epel-7.repo

# install syslog-ng, start it, and have it autostart
sudo yum install -y syslog-ng
sudo systemctl enable syslog-ng
sudo systemctl start syslog-ng

# edit the config file:
sudo vim /etc/syslog-ng/syslog-ng.conf

# change this file to include this without the leading #
# destination d_net { udp("syslog-target-hostname.int.REDACTED.me" port(7788)); };
# log { source(s_syslog); destination(d_net); };

sudo reboot
# noticed that firewalld was running, might have been blocking outbound logs
# check for incoming traffic on the collector using tcpflow or whatever
# try changing hostname to IP - tried moving the second line to lower down
# service won't restart

# open the firewall
sudo so-allow
# 10.0.1.0/24
