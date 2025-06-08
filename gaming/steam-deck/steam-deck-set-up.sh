#!/bin/bash
# Tim H 2022
# Setting up a Steam Deck

# First time set up using Konsole
# passwd

# almost always first command:
sudo steamos-readonly disable

sudo systemctl start sshd 
sudo systemctl enable sshd

######### Can do over SSH now, preferably in a screen session

# install and configure Homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/deck/.bash_profile

# shellcheck disable=SC2016
#echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/deck/.bash_profile
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# Reinitialize and populate keyrings
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux holo

sudo pacman --noconfirm -S base-devel gcc screen

screen -S steamdeck
# brew install gcc

cd ~/Desktop || exit 1
wget "https://www.emudeck.com/EmuDeck.desktop"
chmod +x EmuDeck.desktop

# Use wire for VPN, not L2TP

# last:
sudo steamos-readonly enable
