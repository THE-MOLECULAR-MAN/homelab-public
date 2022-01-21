#!/bin/bash
# Tim H 2021
# Boostrap for CentOS 7 server
#   You're probably better off using the Ansible scripts than this basic script
#   installs all my common CLI tools, no GUI

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# TODO: install screen and launch a screen session for upcoming commands
yum install -y screen

# install latest updates first
yum update -y

# install dependencies and tools
yum install -y atop autoconf automake awscli bind-utils ca-certificates \
    cloud-utils-growpart coreutils curl dkms  elfutils-libelf-devel \
    epel-release gcc glances glibc-common grep htop iftop initscripts iotop \
    java-11-openjdk-devel kernel-devel kernel-headers libtool lsof lvm2 make \
    mlocate nc net-tools nfs-utils nload nmap npm ntpdate open-vm-tools \
    openldap-devel openssh-server openssl openssl-devel pam-devel \
    python3 python3-pip screen sudo sysstat tar tcpdump tcpflow \
    telnet traceroute tree unzip vim vim-enhanced wget which \
    xfsprogs yum-cron yum-utils zlib-devel

# prep for Rapid7 Insight agent
firewall-cmd --zone=public --add-port=31400/udp --permanent
firewall-cmd --reload

# clean up and remove unnecessary/unused packages
yum autoremove -y

# CIS Benchmarking stuff
#systemctl status firewalld
#  unix-user-home-dir-mode - nfsnobody
#chmod 750 $(eval echo "~nfsnobody")

#echo "install udf /bin/true" >> /etc/modprobe.d/udf.conf
#rmmod udf

#set nodev for /boot /var/lib/nfs/rpc_pipefs
