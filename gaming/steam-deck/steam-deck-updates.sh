#!/bin/bash
# Tim H 2023

# Steam Deck updates

# start a screen session for all this:
screen

sudo steamos-readonly disable

sudo pacman -Syyu

# brew update && brew upgrade
# brew doctor

sudo flatpak update --noninteractive --assumeyes
# flatpak update com.heroicgameslauncher.hgl

# sudo flatpak install tv.plex.PlexHTPC tv.plex.PlexDesktop

# interactive only, doesn't take parameters, I looked thru all the src
# exits on error but returns 0, seems to be fine, maybe doesn't clean up
# "$HOME/.config/EmuDeck/backend/installCLI.sh"

sudo steamos-update
# sudo steamos-update-os after-reboot

sudo steamos-readonly enable

sudo reboot now && logout
