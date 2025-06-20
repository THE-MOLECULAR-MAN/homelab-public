#!/bin/bash
# Tim H 2022

# Install and configure Docker on Ubuntu server 20.04, no GUI
# https://docs.docker.com/engine/install/ubuntu/
# https://sematext.com/blog/docker-logs-location/#toc-how-to-find-the-logs-3

set -e

# do not run this as root, run it as the user you'll be interacting w/ docker
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg


echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER
# add current user to docker group
sudo usermod -aG docker "$USER"

# reload to apply permissions to current user
newgrp docker

# verify install:
#sudo docker run hello-world

# this already exists after install, will exit with error code if run:
# sudo groupadd docker

# verify I can issue docker commands without sudo
docker run hello-world

# set to autostart:
# sudo systemctl enable docker.service
# sudo systemctl enable containerd.service

# enable log rotation, prevent logging from filling up disk:
# this file doesn't exist by default.
sudo mkdir /etc/docker/
sudo vim /etc/docker/daemon.json

# add this as the contents but remove the comments
# {
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "10m",
#     "max-file": "3" 
#   },
#   "dns": ["10.0.1.11","10.0.1.1","8.8.8.8"],
#   "dns-search": ["int.butters.me"],
#   "experimental": true
# }

# validate the syntax of the config file
jsonlint /etc/docker/daemon.json

# restart the service to apply changes:
sudo systemctl restart docker.service
sudo systemctl restart containerd.service

# launch something to generate logs:
docker run hello-world

# test LAN dns and network connectivity:
# starts Ubuntu container in interactive mode
docker run -it ubuntu
# can use "unminimize" command to reinstall all the user tools
# cat /etc/resolv.conf
# apt-get update
# apt-get -y -qq install dnsutils iputils-ping curl > /dev/null
# nslookup dc02.int.butters.me
# ping -c2 dc02.int.butters.me
# ping -c2 8.8.8.8
# curl -I https://www.google.com

# can't CD into directory since current user doesn't have perms
# show which log files exist:
sudo find "/var/lib/docker/containers/" -type f -name '*.log' -exec ls -lah {} \;

# show the contents of the log files:
sudo find "/var/lib/docker/containers/" -type f -name '*.log' -exec cat {} \;
