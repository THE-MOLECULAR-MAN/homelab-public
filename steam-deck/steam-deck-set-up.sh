#!/bin/bash
# Tim H 2022
# Setting up a Steam Deck

# first time only
# passwd

# almost always first command:
sudo steamos-readonly disable

sudo systemctl start sshd 
sudo systemctl enable sshd

# install and configure Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/deck/.bash_profile

# shellcheck disable=SC2016
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/deck/.bash_profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo pacman-key --init
sudo pacman -S base-devel
brew install gcc

cd ~/Desktop || exit 1
wget "https://www.emudeck.com/EmuDeck.desktop"
chmod +x EmuDeck.desktop

# prepping for VPN setup:
# https://wiki.archlinux.org/title/Openswan_L2TP/IPsec_VPN_client_setup
sudo pacman -S networkmanager-l2tp strongswan

# last:
sudo steamos-readonly enable
