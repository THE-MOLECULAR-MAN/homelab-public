#!/bin/bash
# Tim H 2022
# MOVE_TO_GRAVEYARD 
# Configures a Docker container that uses Ubuntu on Synology DSM 7.x
# Installs nxlog inside the Docker container

# on the DSM, enable experimental mode to allow container checkpoints
# /var/packages/Docker/etc/dockerd.json
# add this line:
# "experimental": true
# restart daemon, takes 2+ minutes
# sudo synopkgctl stop Docker && sudo synopkgctl start Docker


##############################################################################
# CREATE A NEW CONTAINER
# works on Synology command line and OS X
##############################################################################
CONTAINER_NAME="nxlog-ubuntu-pkg-1"
sudo docker pull ubuntu
# on Synology:
sudo docker container create -v "/volume1/PlexMediaServer/AppData/Plex Media Server/Logs":/plex_logs -i -t --name "$CONTAINER_NAME" ubuntu
# on OS X:
sudo docker container create -i -t --name "$CONTAINER_NAME" ubuntu

# sudo docker container list --all
sudo docker container start --attach -i "$CONTAINER_NAME"


##############################################################################
# INSIDE THAT CONTAINER
##############################################################################
# verify the mount point exists:
ls /plex_logs

apt-get update # 4 seconds on MacBook Pro
apt-get upgrade -y # 3 seconds on Macbook Pro

# now go run the compile-nxlog-from-source-ubuntu.sh script inside the container

##############################################################################
# TAKE A SNAPSHOT/checkpoint
##############################################################################

sudo docker checkpoint create "$CONTAINER_NAME" readyforinstall
