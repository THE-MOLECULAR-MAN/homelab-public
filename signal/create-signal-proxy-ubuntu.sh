#!/bin/bash
# Tim H 2022
# Create a proxy for Whisper Systems' Signal on Ubuntu
# https://signal.org/blog/run-a-proxy/
# t4g.micro
# t3a.micro

NEWFQDN="signal.digitalselfdefense.show"

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install systemd sudo net-tools geoip-bin

NEW_TIMEZONE="America/New_York"
sudo timedatectl set-timezone "$NEW_TIMEZONE"

sudo hostnamectl set-hostname "$NEWFQDN"
echo "127.0.0.1 localhost $NEWFQDN

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" | sudo tee /etc/hosts

sudo apt-get -y install docker docker-compose git
cd "$HOME" || exit 1
git clone https://github.com/signalapp/Signal-TLS-Proxy.git
cd Signal-TLS-Proxy
sudo ./init-certificate.sh
sudo docker-compose up --detach

sudo docker ps
htop

curl "https://signal.tube/#$NEWFQDN"
curl "https://$NEWFQDN"

# list connections:
netstat -tn src :80 or src :443
# geoiplookup 

# https://signal.tube/#signal.digitalselfdefense.show

#IRanASignalProxy https://signal.tube/#signal.digitalselfdefense.show https://signal.org/blog/run-a-proxy/