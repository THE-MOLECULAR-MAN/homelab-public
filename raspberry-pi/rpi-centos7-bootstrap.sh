#!/bin/bash
# Tim H 2021
# SAFE_FOR_PUBLIC_RELEASE

NEW_HOSTNAME="rpi-01"
NEW_FQDN="$NEW_HOSTNAME.REDACTED.int.REDACTED.me"

# TODO: install screen and launch a screen session for upcoming commands

# download the list of the latest yum packages in case it has been a while
yum makecache

# install screen, useful for running this in the background
yum install -y screen 

# auto expand the drive to fill the disk
/usr/bin/rootfs-expand

# install all updates
yum update -y

# install common tools
yum install -y atop autoconf automake awscli bind-utils ca-certificates \
    cloud-utils-growpart coreutils curl dkms  elfutils-libelf-devel \
    epel-release gcc glances glibc-common grep htop iftop initscripts iotop \
    java-11-openjdk-devel kernel-devel kernel-headers libtool lsof lvm2 make \
    mlocate nc net-tools nfs-utils nload nmap npm ntpdate open-vm-tools \
    openldap-devel openssh-server openssl openssl-devel pam-devel \
    python3 python3-pip screen sudo sysstat tar tcpdump tcpflow \
    telnet traceroute tree unzip vim vim-enhanced wget which \
    xfsprogs yum-cron yum-utils zlib-devel

# clean up and remove unnecessary/unused packages
yum autoremove -y

# create a blank file that occupies 1 GB of space, can easily delete in case 
#   drive fills up
# which did indeed happen to me when copying ROMs onto the sdcard
dd if=/dev/zero of="$HOME/space_saver.delete_me" bs=1 count=0 seek=1G

# set the hostname and hosts file
hostnamectl set-hostname "$NEW_FQDN"                    # immediate and permanent
echo "127.0.0.1   localhost $NEW_FQDN $NEW_HOSTNAME
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" > /etc/hosts

echo "[main]
enabled=0" > /etc/yum/pluginconf.d/subscription-manager.conf

# adding risky and unofficial, unsupported EPEL repo to CentOS "Userland" 7
# see more here: https://wiki.centos.org/SpecialInterestGroup/AltArch/armhfp
# required for some packages in other Ansible scripts like installing htop
cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Epel rebuild for armhfp
baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/
enabled=1
gpgcheck=0

EOF

# caching the Yum catalog, make sure that the new EPEL is working
sudo yum makecache
