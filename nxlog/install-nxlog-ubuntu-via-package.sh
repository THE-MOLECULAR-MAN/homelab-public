#!/bin/bash
# Tim H 2022

# Installs but does not configure NXLog for Ubuntu 20.04
# set the path to the latest version of the NX Log package for this distro:
# last updated: Aug 23 2022
PACKAGE_INSTALLER_URL="https://nxlog.co/system/files/products/files/348/nxlog-ce_3.0.2272_ubuntu_focal_amd64.deb"

# install dependencies:
sudo apt-get update
sudo apt-get -y install debsig-verify

cd "$HOME" || exit 1
git clone https://gitlab.com/nxlog-public/contrib.git

# download the installer package
wget --no-clobber --output-document="$HOME/nxlog-ce.deb" "$PACKAGE_INSTALLER_URL"

# validate it:
dpkg-deb --info "$HOME/nxlog-ce.deb"
cd "$HOME/contrib/deb-verify" || exit 2
sudo cp -vR ./policies/* /etc/debsig/policies/
sudo cp -vR ./keyrings/* /usr/share/debsig/keyrings/
debsig-verify --policies-dir /etc/debsig/policies/ --keyrings-dir $/usr/share/debsig/keyrings/ "$HOME/nxlog-ce.deb"
#./deb-verify.sh "$HOME/nxlog-ce.deb"

# install NXLog community edition
sudo apt-get install "$HOME/nxlog-ce.deb"
#sudo dpkg -i "$HOME/nxlog-ce.deb"
# Docker container: The following packages have unmet dependencies:
#  nxlog-ce : Depends: libperl5.30 (>= 5.30.0) but it is not installable
#             Depends: libpython3.8 (>= 3.8.2) but it is not installable
#             Depends: libssl1.1 (>= 1.1.0) but it is not installable
# E: Unable to correct problems, you have held broken packages.

# autorun
sudo systemctl enable nxlog.service

cp /etc/nxlog/nxlog.conf /etc/nxlog/nxlog.conf.backup
