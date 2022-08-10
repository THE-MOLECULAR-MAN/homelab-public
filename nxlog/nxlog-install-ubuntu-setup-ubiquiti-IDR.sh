#!/bin/bash
# Tim H 2022
# Better than the CentOS version of this script. Includes stuff from
# nxlog-fix.sh

# install and configure NXLog for Ubuntu 20.04
# add an adapter to recieve incoming Ubiquiti UniFi syslogs
# and convert them to JSON and forward them to a Rapid7 InsightIDR
# collector
# References:
#   https://docs.nxlog.co/userguide/integrate/unifi.html
#   https://docs.nxlog.co/userguide/deploy/debian.html
#   https://docs.nxlog.co/userguide/deploy/signature-verification.html#deb
#   https://nxlog.co/products/all/download?field_pf_product_nid=348

# define the UDP port where the NX Log system should be listening
# this is the port where UniFi is sending the logs to.
# Unfortunately, UniFi syslog only supports sending UDP, not TCP
INCOMING_UDP_PORT_FROM_UNIFI_SYSLOG="7878"
IDR_COLLECTOR_IP="10.0.1.40"
IDR_COLLECTOR_LISTENING_PORT="7879"

# set the path to the latest version of the NX Log package for this distro:
PACKAGE_INSTALLER_URL="https://nxlog.co/system/files/products/files/348/nxlog-ce_3.0.2272_ubuntu_focal_amd64.deb"

# install dependencies:
sudo apt-get update
sudo apt-get -y install debsig-verify

cd "$HOME" || exit 1
git clone https://gitlab.com/nxlog-public/contrib.git

# download the installer package
wget --no-clobber --output-document="$HOME/nxlog-ce.deb" "$PACKAGE_INSTALLER_URL"

# validate it:
dpkg-deb --info "$HOME/nxlog-ce.deb"
cd "$HOME/contrib/deb-verify" || exit 2
sudo cp -vR ./policies/* /etc/debsig/policies/
sudo cp -vR ./keyrings/* /usr/share/debsig/keyrings/
debsig-verify --policies-dir /etc/debsig/policies/ --keyrings-dir $/usr/share/debsig/keyrings/ "$HOME/nxlog-ce.deb"
#./deb-verify.sh "$HOME/nxlog-ce.deb"

# install NXLog community edition
sudo apt-get install "$HOME/nxlog-ce.deb"

# autorun
sudo systemctl enable nxlog.service

cp /etc/nxlog/nxlog.conf /etc/nxlog/nxlog.conf.backup

cat << EOF > /etc/nxlog/nxlog.conf
LogFile /var/log/nxlog/nxlog.log
LogLevel INFO

<Extension _syslog>
    Module  xm_syslog
</Extension>

<Extension _json>
    Module  xm_json
</Extension>

<Input incoming_unifi_syslog_over_udp>
    Module  im_udp
    Host    0.0.0.0
    Port    $INCOMING_UDP_PORT_FROM_UNIFI_SYSLOG
    Exec    parse_syslog();
</Input>

<Output outgoing_idr_collector_as_json_over_udp>
    Module  om_udp
    Host    $IDR_COLLECTOR_IP
    Port    $IDR_COLLECTOR_LISTENING_PORT
    Exec    to_json();
</Output>

<Route r>
    Path    incoming_unifi_syslog_over_udp => outgoing_idr_collector_as_json_over_udp
</Route>
EOF

sudo mkdir /var/run/nxlog
sudo chown root:$(whoami) /etc/nxlog

# check config file syntax
sudo /usr/bin/nxlog -v

# stop and disable the firewall to simplify testing
service firewalld stop

# restart service to apply changes to config file
service nxlog restart

service nxlog status
cat /var/log/nxlog/nxlog.log

# see if server is listening on UDP port where traffic from UniFi should be
# coming:
# gotta wait a sec for service to finish starting up, otherwise
# it won't be listed
sleep 1
ss -tulwn  | grep "$INCOMING_UDP_PORT_FROM_UNIFI_SYSLOG"

# watch incoming traffic on the port to verify incoming syslog
tcpdump -i ens160 udp port "$IDR_COLLECTOR_LISTENING_PORT" -X

# now you have to BE PATIENT AND WAIT
# it could take 5-10 min before you see the first logs in the Log Search
# in IDR
