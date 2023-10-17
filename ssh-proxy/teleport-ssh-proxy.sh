#!/bin/bash
# Tim H 2022
# https://goteleport.com/blog/how-to-record-ssh-sessions/

set -e

#INSTALLER_URL="https://get.gravitational.com/teleport_10.1.2_amd64.deb"
#INSTALLER_HASHSUM="06d03ec3b1b65c20123c1600047c56d5a4b076c1e520859c0ba667c66e70b0f8"

#INSTALLER_FILENAME=$(basename "$INSTALLER_URL")
#INSTALLER_HASHSUM_FILENAME="$INSTALLER_FILENAME.hashsum"

# download the file
#wget "$INSTALLER_URL"

sudo curl https://deb.releases.teleport.dev/teleport-pubkey.asc \
  -o /usr/share/keyrings/teleport-archive-keyring.asc

source "/etc/os-release"

echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
  https://apt.releases.teleport.dev/${ID?} ${VERSION_CODENAME?} stable/v10" \
| sudo tee /etc/apt/sources.list.d/teleport.list > /dev/null

sudo apt-get update

sudo apt-get install teleport

# create a hashsum file
#echo "$INSTALLER_HASHSUM  $INSTALLER_FILENAME" > \
 #   "$INSTALLER_HASHSUM_FILENAME"

# check the hashsum to verify integrity of the download,
# bail if it doesn't match
#sha256sum --check "$INSTALLER_HASHSUM_FILENAME" || exit 2

#sudo apt-get update
#sudo dpkg -i "$INSTALLER_FILENAME"


# proper way to sudo EOF:
sudo bash -c 'cat << EOF > /etc/teleport.yaml
auth_service:
   # IMPORTANT: this line enables the proxy recording / OpenSSH mode:
   session_recording: "proxy"

   # For better security its recommended to enable host checking as well,
   # this is when the Teleport proxy will verify the identity of the
   # nodes. Teleport documentation covers how to issue host certificates,
   # but for simplicity of this tutorial we are disabling strict host
   # checking here
   proxy_checks_host_keys: no

   # turn 2FA off to make the tutorial easier to follow
   authentication:
      second_factor: off
EOF'

# blocking logging, consider adding &
# sudo is required.
#sudo teleport start --roles=auth,proxy

# check versions
tctl version
tsh version

sudo service teleport start


#### on the endpoint
SSH_PROXY_HOSTNAME="ssh-proxy.int.butters.me"
SSH_PROXY_PORT="3023"
END_HOST="nxlog02.int.butters.me"
END_USERNAME="thrawn"

nmap -Pn -p22,"$SSH_PROXY_PORT" "$SSH_PROXY_HOSTNAME"

# check the local version of OpenSSH, it needs to be at least version 6.9
# Ubuntu 20.04 comes with OpenSSH_7.4p1
ssh -V

# non-proxy test:
nslookup "$END_HOST"
nmap -Pn -p22 "$END_HOST"
ssh "$END_USERNAME@$END_HOST"

# proxy test:
ssh -o "ForwardAgent yes" \
    -o "ProxyCommand ssh -o 'ForwardAgent yes' -p $SSH_PROXY_PORT %r@$SSH_PROXY_HOSTNAME -s proxy:%h:%p" \
    -o PreferredAuthentications=password -o PubkeyAuthentication=no \
    "$END_USERNAME@$END_HOST"
