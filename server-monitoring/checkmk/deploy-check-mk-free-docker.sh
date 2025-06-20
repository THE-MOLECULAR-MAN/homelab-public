#!/bin/bash
# Tim 2022
# Deploy the Check MK Free Enterprise edition via Docker

# References:
# https://hub.docker.com/r/checkmk/check-mk-free

CONTAINER_NAME="check-mk"

docker pull checkmk/check-mk-free

sudo docker container create -i -t \
    -v "/volume1/docker/check-mk-free/backups":/backups \
    -v "/volume1/docker/check-mk-free/cmk":/TBD \
    --name "$CONTAINER_NAME" \
    -e CMK_PASSWORD=password \
    -e MAIL_RELAY_HOST=10.0.1.35 \
    -e CMK_CONTAINERIZED=TRUE \
    -e CMK_SITE_ID=cmk \
    -e CMK_LIVESTATUS_TCP=on \
    -p 5050:5000 \
    -p 6050:6557 \
    --restart always \
    --tmpfs /opt/omd/sites/cmk/tmp:uid=1000,gid=1000 \
    checkmk/check-mk-free:2.1.0-latest
    




#/omd/sites