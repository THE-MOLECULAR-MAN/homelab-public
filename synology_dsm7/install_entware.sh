#!/bin/bash
# Tim H 2022
#
# Installing opkg (EntWare) package manager on Synology DSM v7
# works fine with over-installs too
#
# There's one more step that's necessary in the GUI, see directions in link
#
# References:
#   https://github.com/Entware/Entware/wiki/Install-on-Synology-NAS

sudo su -

mkdir -p /volume1/@Entware/opt
rm -rf /opt/*
mkdir -p /opt
mount -o bind "/volume1/@Entware/opt" /opt
wget -O - https://bin.entware.net/x64-k3.2/installer/generic.sh | /bin/sh

# follow GUI instructions
# finish with reboot

sudo opkg update
sudo opkg upgrade
sudo opkg list-installed

sudo opkg install whereis
