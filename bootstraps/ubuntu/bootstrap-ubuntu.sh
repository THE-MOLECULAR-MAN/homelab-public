#!/bin/bash
# Tim H 2022

NEW_HOSTNAME="new-appliance"
DOMAIN_TO_JOIN="INT.REDACTED.ME" # must be in all caps
DOMAIN_ADMIN_USERNAME="jdoe.adm"    # domain admin used to join the domain

NEW_FQDN="$NEW_HOSTNAME.$DOMAIN_TO_JOIN"

NEW_TIMEZONE="America/New_York"

# see current Ubuntu version
lsb_release -a 

sudo do-release-upgrade --check-dist-upgrade-only

timedatectl set-timezone "$NEW_TIMEZONE"

sudo apt-get update
sudo apt-get -y upgrade

echo "127.0.0.1 localhost $NEW_FQDN $NEW_HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
" | sudo tee /etc/hosts

sudo hostnamectl set-hostname "$NEW_HOSTNAME.$DOMAIN_TO_JOIN"

sudo apt-get install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

# THIS IS an interactive prompt
# type in the full domain in all caps: ex: "INT.REDACTED.ME"
# this does not join the asset to the domain
sudo apt-get install -y krb5-user

sudo apt-get install -y open-vm-tools

sudo apt-get install -y apt-file apt-transport-https arping autoconf automake \
		ca-certificates curl dnsutils gcc gnupg-agent grep libtool lsof make \
		mlocate net-tools netcat nmap npm ntpdate openssh-server openssl \
		python3-pip screen software-properties-common sysstat tar tcpdump \
		tcpflow telnet traceroute unzip vim wget

sudo ntpdate pool.ntp.org

sudo apt autoremove -y
sudo apt-get clean
