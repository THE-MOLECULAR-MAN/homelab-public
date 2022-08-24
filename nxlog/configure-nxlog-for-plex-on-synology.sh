#!/bin/bash
# Tim H 2022
#PLEX_MEDIA_SERVER_USE_SYSLOG=true

#"/var/packages/Plex Media Server/scripts/start-stop-status"
#"/volume1/PlexMediaServer/AppData/Plex Media Server/Preferences.xml"

/var/packages/Docker/etc/dockerd.json
#"experimental": true
# restart daemon, takes 2+ minutes
sudo synopkgctl stop Docker && sudo synopkgctl start Docker

#Logs: 
#mount "/volume1/PlexMediaServer/AppData/Plex Media Server/Logs" as /plex_logs

docker pull ubuntu
docker container start nxlog-ubuntu1
#docker checkpoint create nxlog-ubuntu1 checkpoint1
docker attach nxlog-ubuntu1

# verify the mount point exists:
ls /plex_logs

apt-get update
apt-get upgrade

# now go run the compile-nxlog-from-source-ubuntu.sh script inside the container

# The following packages have unmet dependencies:
#  nxlog-ce : Depends: libperl5.30 (>= 5.30.0) but it is not installable
#             Depends: libpython3.8 (>= 3.8.2) but it is not installable
#             Depends: libssl1.1 (>= 1.1.0) but it is not installable
# E: Unable to correct problems, you have held broken packages.

