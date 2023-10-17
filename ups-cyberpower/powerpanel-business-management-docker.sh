#!/bin/bash
# Tim H 2022
#
# Installs v4.7.0 (4a8ba38e) of PPBE Management, not the latest version
#
# References:
# https://github.com/MeCJay12/powerpanel-business-docker
# https://github.com/NathanVaughn/powerpanel-business-docker/issues/4#issuecomment-1011706061
# https://intellij-support.jetbrains.com/hc/en-us/articles/206544869-Configuring-JVM-options-and-platform-properties
#
# designed to be run on the Docker host, Synology
#
# https://www.networkworld.com/article/3602972/automating-responses-to-scripts-on-linux-using-expect-and-autoexpect.html
# recording the expect file:
# gotta do this inside the same Ubuntu docker image
# sudo autoexpect ./CyberPower_PowerPanel_Business_Linux_64bit_Management-v4.8.6.sh
# path: /usr/local/ppbe

# pull down repo
mkdir -p "$HOME/source_code"
cd "$HOME/source_code" || exit 1
rm -Rf powerpanel-business-docker
git clone https://github.com/THE-MOLECULAR-MAN/powerpanel-business-docker.git
cd powerpanel-business-docker || exit 2

# sudo is required
mv ~/.sh  ~/source_code/powerpanel-business-docker/
sudo ./build.mgmt.sh

# debconf: delaying package configuration, since apt-utils is not installed

# image should now be listed in docker, can launch it into a container

# volumes
# - app_data:/usr/local/ppbe/db_local/

# inside the docker container:
# apt-get update
# apt-get -y install vim

# can do this without tee since the container runs as root
echo "-Xmx512m" > /usr/local/ppbe/ppbed.vmoptions

# now visit the login page over HTTP
# default username and password are admin/admin
# http://redacted.int.butters.me:49163/management/login
