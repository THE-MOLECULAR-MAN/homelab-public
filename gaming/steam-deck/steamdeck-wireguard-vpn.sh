#!/bin/bash
# Tim H 2023

# Ubiquiti WireGuard VPN working on Steam Deck (Arch) Linux

# from my laptop:
scp ~/Downloads/wireguard_vpn_steamdeck.conf deck@10.0.1.61:~/

#####################################################################
# on the steam deck via SSH:
ssh deck@10.0.1.61
# start a screen session for all this:
screen

sudo steamos-readonly disable

# install updates, interactive
sudo pacman -Syyu

sudo pacman -S --needed wireguard-tools 

sudo cp ~/wireguard_vpn_steamdeck.conf /etc/wireguard/wg0.conf

# edit the config file and replace the static public IP with the DDNS:
sudo vim /etc/wireguard/wg0.conf

# workaround for Arch
sudo ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf

# start the VPN, test it
sudo wg-quick up wg0

sudo steamos-readonly enable
