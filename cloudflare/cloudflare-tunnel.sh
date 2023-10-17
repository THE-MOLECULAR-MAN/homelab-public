#!/bin/bash
# Tim H 2022
#

# uninstall if already installed
sudo cloudflared service uninstall

curl -L --output cloudflared.deb \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

sudo dpkg -i cloudflared.deb

sudo cloudflared service install "redacted_unique_key"
