#!/bin/bash
# Tim H 2022
# Builds and runs a docker image for plex logging via nxlog on a synology server
# https://nxlog.co/question/3678/problem-nxlog-ce
# https://docs.nxlog.co/userguide/troubleshoot/common-issues.html#linux-permission-error
#
# scp "$HOME/source_code/homelab-public/nxlog/docker_image1/"* synology.int.butters.me:~/tmp_docker_nxlog/ 
# sudo su

IMAGE_NAME="nxlog-custom1-image"
CONTAINER_NAME="nxlog-custom1-live"
sudo docker build -t "$IMAGE_NAME" .

sudo docker container stop "$CONTAINER_NAME"
sudo docker container rm "$CONTAINER_NAME"

sudo docker container create -i -t \
   -v "/volume1/PlexMediaServer/AppData/Plex Media Server/Logs":/plex_logs \
   --name "$CONTAINER_NAME" \
   "$IMAGE_NAME"

sudo docker container start --attach -i "$CONTAINER_NAME"
