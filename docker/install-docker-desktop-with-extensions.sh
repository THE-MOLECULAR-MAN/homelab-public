#!/bin/bash
# Tim H 2023
#
# This is for virtualized Ubuntu Desktop instances
#
# 1) Power off virtual machine - required
# 2) Open VM's settings in vSphere/etc
# 3) Enable:  Expose hardware assisted virtualization to the guest OS
# 4) Power the VM back on, IGNORE THE ERROR
# 5) Make sure that the /etc/hosts file has the short and FQDN of the host
#       defined
#
# Installing Docker Desktop on Gnome Ubuntu plus some extensions
# https://docs.docker.com/desktop/install/linux-install/

# check to make sure nested virtualization is working:
sudo kvm-ok

# remove any previous version
sudo apt remove docker-desktop
rm -r "$HOME/.docker/desktop"
sudo rm /usr/local/bin/com.docker.cli
sudo apt purge docker-desktop

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
# shellcheck disable=SC1091
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# sudo apt-get install docker-ce docker-ce-cli containerd.io \
#   docker-buildx-plugin docker-compose-plugin

wget -O docker-desktop-4.24.2-amd64.deb \
  "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.24.2-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"

sudo apt -qy install ./docker-desktop-4.24.2-amd64.deb

# in Gnome - launch Docker Desktop

# must be done in Gnome Terminal, not via SSH:
sudo systemctl --user enable docker-desktop

# volumes backup and share
# https://www.docker.com/blog/back-up-and-share-docker-volumes-with-this-extension/
# https://hub.docker.com/extensions/docker/volumes-backup-extension

# generate gpg key, required.
gpg --generate-key
pass init 

# install the volume backup extension
docker extension install volumes-backup-extension

# INFO: Your CPU does not support KVM extensions
# KVM acceleration can NOT be used
