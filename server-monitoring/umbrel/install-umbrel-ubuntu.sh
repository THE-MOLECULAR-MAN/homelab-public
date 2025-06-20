#!/bin/bash
# Tim H 2022
# https://github.com/getumbrel/umbrel

# installs Docker
# install it
# skipping the optional directory parameter since I don't have perms outside
# home directory

curl -L https://umbrel.sh | bash

sudo apt-get install -y uidmap
dockerd-rootless-setuptool.sh install

export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/1000/docker.sock

# http://umbrel.int.butters.me.local
################################################################################
# blocking the outbound TOR network connections:
################################################################################
sudo service umbrel-startup stop

sudo ufw enable
sudo ufw status
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow 6556/tcp


