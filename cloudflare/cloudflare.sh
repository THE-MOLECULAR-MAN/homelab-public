#!/bin/bash
# Tim H 2022

# installing CloudFlare agent on Ubuntu 20.04
# https://developers.cloudflare.com/cloudflare-one/tutorials/ssh/
# https://dash.cloudflare.com/
# https://dash.teams.cloudflare.com

sudo wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo apt-get update
sudo dpkg -i ./cloudflared-linux-amd64.deb

# must have at least one ACTIVE domain that uses CloudFlare to manage 
# its DNS. Must have finished transferring NS record to CloudFlare
cloudflared tunnel login

# CloudFlare research
# proxy services - want "Secure Web Gateway"
# sudo apt-get purge dnsmasq-base

# echo "search int.butters.me
# # nameserver 10.0.1.1
# nameserver 10.0.1.11
# nameserver 10.0.1.1" | sudo tee /etc/resolv.conf
