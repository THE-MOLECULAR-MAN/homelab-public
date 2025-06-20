#!/bin/bash
# Tim H 2022

# Set up Plex inside a docker container on an UBUNTU host, not Synology
# first sets up the Ubuntu host to have proper NFS mounts for persistent storage
#
# TODO:
#   1) add -v mount point for synology videos
#   2) switch this to a dockerfile?
#
# https://support.plex.tv/articles/201105343-advanced-hidden-server-settings/
# https://github.com/plexinc/pms-docker#intel-quick-sync-hardware-transcoding-support
# Important: https://www.reddit.com/r/PleX/comments/fb1wk3/comment/i6uhuay/
# https://maclookup.app/faq/how-do-i-identify-the-mac-address-of-a-docker-container-interface
#
#logs are stored here:
#/config/Library/Application Support/Plex Media Server/Logs
#ln -s "/config/Library/Application Support/Plex Media Server/Logs" /config/logs

# NFS Mounts
# follow directions here:
# ./honker-private-personal/linux/nfs-mount-for-backup.sh
# repeat for the media 

# Claim new code: https://www.plex.tv/claim/
# only good for FOUR minutes after creation
PLEX_CLAIM_CODE="REDACTED"

CONTAINER_IMAGE='plexinc/pms-docker:latest'
CONTAINER_NAME="plex"
FULL_PATH_TO_LOCALHOST_FOLDER="/nfs_synology_time_machine_central/container-host02.int.butters.me"
ALLOWED_NETWORKS="10.0.1.0/24"

CONTAINER_FQDN="$CONTAINER_NAME.int.butters.me"
PLEX_MOUNT_HOME="$FULL_PATH_TO_LOCALHOST_FOLDER/plex_docker_mounts"
DOCKER_NETWORK_NAME="host"
LAN_IP=$(ifconfig ens160 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

# stop and delete any old containers from previous tests
set +e
docker container stop "$CONTAINER_NAME" || echo "skipping stopping container since it isn't running or doesn't"
docker container rm   "$CONTAINER_NAME" || echo "skipping deleting container since it doesn't exist"
# delete any old persistent files from previous tests
cd "$PLEX_MOUNT_HOME" || exit 1
find "config" "data" "transcode" -mindepth 1 -delete
set -e

mkdir -p "$PLEX_MOUNT_HOME/config"
mkdir -p "$PLEX_MOUNT_HOME/transcode"
mkdir -p "$PLEX_MOUNT_HOME/data"

docker container create -i -t \
    --network="$DOCKER_NETWORK_NAME" \
    --hostname "$CONTAINER_FQDN" \
    -v "$PLEX_MOUNT_HOME/config":/config \
    -v "$PLEX_MOUNT_HOME/transcode":/transcode \
    -v "$PLEX_MOUNT_HOME/data":/data \
    -e TZ="America/New_York" \
    -e FRIENDLY_NAME="Plex-Condo2" \
    -e ADVERTISE_IP="https://$CONTAINER_FQDN:32400/,https://$LAN_IP:32400" \
    -e SECURE_CONNECTIONS=1 \
    -e LOG_DEBUG=1 \
    -e ALLOWED_NETWORKS="$ALLOWED_NETWORKS" \
    -e LAN_NETWORKS="$ALLOWED_NETWORKS" \
    -e PLEX_CLAIM="$PLEX_CLAIM_CODE" \
    --name "$CONTAINER_NAME" \
    --restart on-failure:3 \
    "$CONTAINER_IMAGE"
    
# start in non-interactive:
docker container start "$CONTAINER_NAME"

# view running containers
# docker container inspect "$CONTAINER_NAME"

# see the logs, add a "-f" to tail them in real time
docker logs "$CONTAINER_NAME"

# see what was created:
# tree "$FULL_PATH_TO_LOCALHOST_FOLDER"

# open the link IN PRIVATE BROWSING MODE, NOT WHERE YOU'VE ALREADY SIGNED IN
# if this is your SECOND Plex server, then create a NEW account, don't login
# note the http on first visit, can't do HTTPS until after config is complete
# also, don't try to go straight to the ...setup... URL, it won't work.
echo "visit Plex here in PRIVATE BROWSING MODE: http://$LAN_IP:32400/web/"


# nmap test:
# nmap -Pn -p32400,3005,8324,32469 "$LAN_IP"

#curl "http://10.0.1.38:32400/web"

