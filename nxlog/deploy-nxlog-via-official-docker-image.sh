#!/bin/bash
# Tim H 2022
# MOVE_TO_GRAVEYARD
# Didn't work, was replaced by my custom Docker image

# Deploy and configure nxlog-ce via official docker container image
# https://docs.nxlog.co/userguide/integrate/docker.html
# https://docs.nxlog.co/userguide/troubleshoot/common-issues.html

set -e

CONTAINER_NAME="nxlog-official-"
CONTAINER_IMAGE='nxlog/nxlog-ce'
NXLOG_HOST_CONFIG_FILE_PATH="$HOME/nxlog_container_config/$CONTAINER_NAME/nxlog.conf"
NXLOG_HOST_LOG_DIR="$HOME/nxlog_container_config/$CONTAINER_NAME/log"

# destroy all old test versions:
for ITER_CONTAINER_ID in $(sudo docker container list --all --filter name=nxlog-official --quiet); do
    echo "Stopping and rm'ing $ITER_CONTAINER_ID"
    sudo docker container stop "$ITER_CONTAINER_ID"
    sudo docker container rm "$ITER_CONTAINER_ID"
done

mkdir -p "$(dirname "$NXLOG_HOST_CONFIG_FILE_PATH")"

# Synology version:
mkdir -p "$NXLOG_HOST_LOG_DIR/nxlog"

echo "new file created" > "$NXLOG_HOST_LOG_DIR/nxlog/nxlog.log"

# OS X version:
#mkdir -p "$NXLOG_HOST_LOG_DIR"

echo "
# parent directories must already exist
LogFile /var/log/nxlog/nxlog.log
LogLevel DEBUG
" > "$NXLOG_HOST_CONFIG_FILE_PATH"

cat "$NXLOG_HOST_CONFIG_FILE_PATH"

# using find instead of tree since Synology doesn't have tree
find "$HOME/nxlog_container_config/$CONTAINER_NAME/"

# create new container
# synology version for Docker version 20.10.3, build 55f0773
sudo docker container create -i -t \
    -v "$NXLOG_HOST_LOG_DIR":/var/log \
    -v "$NXLOG_HOST_CONFIG_FILE_PATH":/etc/nxlog.conf \
    -v "/volume1/PlexMediaServer/AppData/Plex Media Server/Logs":/plex_logs \
    --name "$CONTAINER_NAME" \
    "$CONTAINER_IMAGE"

# OS X test version for Docker version 20.10.17, build 100c701
# 

# test if log directory is accessible
sudo docker logs "$CONTAINER_NAME"


# testing basic without any mounts:
sudo docker container create -i -t \
   --name "$CONTAINER_NAME" \
   "$CONTAINER_IMAGE"

# start and attach
# detach with Ctrl+P then Ctrl+Q
sudo docker container start --attach -i "$CONTAINER_NAME"
#
# 2022-08-24 20:43:33 ERROR couldn't open logfile '/var/log/nxlog/nxlog.log' for writing;Permission denied



cat "$NXLOG_HOST_LOG_DIR/nxlog.log"

tree "$HOME/nxlog_container_config/$CONTAINER_NAME/"

echo "script finished successfully."
