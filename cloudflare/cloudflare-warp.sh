#!/bin/bash
# Tim H 2022
# Installs Warp on an Ubuntu system
#
# References:
# https://developers.cloudflare.com/warp-client/get-started/linux/
# https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/install-cloudflare-cert

set -e
# add the key and repo:
curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

# install it
sudo apt update
sudo apt install cloudflare-warp

# interactive registration and connection
warp-cli register
warp-cli connect

# make sure it responds with 'warp=on'
curl https://www.cloudflare.com/cdn-cgi/trace/

# warp-cli enable-always-on
