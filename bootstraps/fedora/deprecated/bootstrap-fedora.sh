#!/bin/bash
# Tim H 2021
# Boostrap for Fedora 33, desktop
# 
# References:
#	https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt/
#

#  !NON-EXECUTABLE!
echo "this script should not be run directly. It is either notes or in progress. Exiting"
exit 1

# bomb out if any errors occur
set -e

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 2
fi

################################################################################
#		FUNCTION DEFINITIONS
################################################################################

friendlier_date () {
    #Looks like this: 2021-02-26 03:55:09 PM EST
	date +"%Y-%m-%d %I:%M:%S %p %Z"
}

log () {
	# formatted log output including timestamp
	#echo -e "[$THIS_SCRIPT_NAME] $(date)\t $@"
    echo -e "[$THIS_SCRIPT_NAME] $(friendlier_date)\t $*"
}

# need a "configure-logging" function to call once
configure_logging () {
	THIS_SCRIPT_NAME=$(basename --suffix=".sh" "$0")

	# check to see if THIS_SCRIPT_NAME is blank or whatever, happens during AWS User Data runs

	if [ "$THIS_SCRIPT_NAME" == "" ]; then
		THIS_SCRIPT_NAME="bootstrap_blank"
	fi

	# configure $HOME as /root if it is not defined
	if [ "$HOME" == "" ]; then
		HOME="/root"
		# or maybe source the profile files
	fi
	
	LOGFILE="$HOME/history-$THIS_SCRIPT_NAME.log"                           # filename of file that this script will log to. Keeps history between runs.

	# Set up logging to external file
	exec >> "$LOGFILE"
	exec 2>&1

	# start a log so I know it ran
	log "========= START ============="
}


################################################################################
#		MAIN PROGRAM
################################################################################

configure_logging

# Make directory and change directory if needed
mkdir "$HOME/Downloads"
cd "$HOME/Downloads/" 

# bomb out if any errors, don't move any higher in this.
set -e

# set up local DNS
resolvectl dns
systemd-resolve --flush-caches
resolvectl dns wlp3s0 10.0.1.11 8.8.8.8 4.4.4.4
resolvectl dns

# updates
dnf -qy update

# install common tools from repos
dnf install -qy autoconf automake awscli bind-utils ca-certificates chromium \
	curl dkms dnsutils elfutils-libelf-devel gcc glibc-common grep htop \
	iotop kernel-devel kernel-headers libtool lsof make mlocate nc net-tools nload \
	nmap npm ntpdate open-vm-tools openldap-devel openssh-server openssl \
	openssl-devel pam-devel python3-pip qt5-qtx11extras rdesktop screen \
	sublime-text sysstat tar tcpdump tcpflow telnet traceroute unzip vim \
	vim-enhanced wget yum-utils zlib-devel \
	iftop atop glances
#	acpi

# dependencies for VirtualBox later
dnf -qy install @development-tools

log "installed DNF tools from repos"

# shellcheck disable=SC1001
echo "
####### added by bootstrap
export EDITOR='vim'
export VISUAL='vim'
PS1="\u@\h:\w\$ "
" >> "$HOME/.bashrc"

# shellcheck disable=SC1091
source "$HOME/.bashrc"

#set openssh server to autostart, fedora automatically takes care of the firewall opening
systemctl enable sshd
systemctl start sshd

# Add Docker, too bad there's no Docker Desktop for Linux
dnf -qy remove docker \
	  docker-client \
	  docker-client-latest \
	  docker-common \
	  docker-latest \
	  docker-latest-logrotate \
	  docker-logrotate \
	  docker-selinux \
	  docker-engine-selinux \
	  docker-engine
dnf -qy install dnf-plugins-core
dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
dnf -qy install docker-ce docker-ce-cli containerd.io docker-compose
systemctl start docker
docker run hello-world

log "installed docker stuff."

# Install NodeJS modules
cd "$HOME" || exit 3
npm install -y jsonlint swagger-codegen swagger-cli -g
log "installed NodeJS stuff"

# VirtualBox prep
wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -P /etc/yum.repos.d/
#vim /etc/yum.repos.d/virtualbox.repo
dnf -y update
#dnf install VirtualBox-6.1
#https://www.if-not-true-then-false.com/2010/install-virtualbox-with-yum-on-fedora-centos-red-hat-rhel/
log "prepped for VirtualBox install."

# Join domain
DOMAIN_TO_JOIN="INT.REDACTED.ME"                 #INT.CONTOSO.COM    must be in ALL CAPS
DOMAIN_ADMIN_USERNAME="REDACTED_USERNAME"          #jdoe.adm
dnf install -qy realmd sssd krb5-workstation krb5-libs oddjob oddjob-mkhomedir samba-common-tools adcli
realm discover "$DOMAIN_TO_JOIN"
kinit "$DOMAIN_ADMIN_USERNAME"@"$DOMAIN_TO_JOIN"
realm join --verbose "$DOMAIN_TO_JOIN" -U "$DOMAIN_ADMIN_USERNAME@$DOMAIN_TO_JOIN"
realm list
# Give domain admins sudo priv on system
echo "%Domain\ Admins@$DOMAIN_TO_JOIN ALL=(ALL) NOPASSWD:ALL" | tee --append /etc/sudoers
tail /etc/sudoers

# reboot?


# space saver
dd if=/dev/zero of="$HOME/.space_saver" count=1024 bs=1048576

# install Snap package manager for third party stuff
dnf -y install snapd
ln -s /var/lib/snapd/snap /snap

# install other GUI tools via Snap:
snap refresh
snap install code   --classic
snap install slack  --classic
snap install spotify
snap install signal-desktop
snap install vlc
snap install postman
snap install notepad-plus-plus

# RPM sphere - works
dnf -y install \
	https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-32-1.noarch.rpm


# EPEL not working
#https://fedora.pkgs.org/32/rpm-sphere-x86_64/veracrypt-1.24.4-1.x86_64.rpm.html
#https://docs.fedoraproject.org/en-US/quick-docs/setup_rpmfusion/
#rpm -Uvh https://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Fedora Fusion repo
dnf -y install \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
dnf -y install \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
dnf -y update
dnf -y groupupdate core

# Install Burp Suite Community
wget -O burp_installer.sh "https://portswigger.net/burp/releases/download?product=community&type=Linux"
chmod u+x ./burp_installer.sh

# Veracrypt
wget -O rpmsphere-release-32-1.noarch.rpm "https://github.com/rpmsphere/noarch/blob/master/r/rpmsphere-release-32-1.noarch.rpm?raw=true"
rpm -Uvh rpmsphere-release*rpm
dnf -y install veracrypt

# Wipe the hard disk free space
dnf -y install bleachbit
bleachbit -v
screen -d -m "bleachbit --wipe-free-space / && df -h"

# pull github repos
su - REDACTEDUSERNAME -c "mkdir $HOME/source_code/ && cd $HOME/source_code/ && git init"

# R7 agent download and install
systemctl disable auditd
service auditd stop
# open firewall for R7 agent
firewall-cmd --zone=public --add-port=31400/udp --permanent
firewall-cmd --reload

# pen testing tools
snap install sqlmap

# shell check
snap install shellcheck

#ls -lah ~/.ssh


# check battery status:
upower -i /org/freedesktop/UPower/devices/battery_BAT0

# SMART data for drives
dnf -y install smartmontools
smartctl -H /dev/sda
smartctl -H /dev/sdb
smartctl --test=short /dev/sda
smartctl --test=short /dev/sdb
sleep 150
smartctl -a /dev/sda
smartctl -a /dev/sdb

# clean up
dnf -y autoremove

log "== SCRIPT ENDED SUCCESSFULLY =="
