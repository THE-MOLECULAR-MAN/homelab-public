#!/bin/bash
# Tim H 2023

# Steam Deck updates

# start a tmux session for all this:
tmux

sudo steamos-readonly disable

sudo steamosctl reload-config
# sudo steamosctl set-max-charge-level 80

# sudo pacman-key --init && sudo pacman-key --populate archlinux holo
# installs all base OS updates
sudo pacman -Syyu

# brew update && brew upgrade
# brew doctor

# includes Plex, Chrome, Heroic Games Launcher, etc.
sudo flatpak update --noninteractive --assumeyes
flatpak update --assumeyes --noninteractive com.heroicgameslauncher.hgl io.github.streetpea.Chiaki4deck

# sudo flatpak install --noninteractive --assumeyes tv.plex.PlexHTPC tv.plex.PlexDesktop

# interactive only, doesn't take parameters, I looked thru all the src
# exits on error but returns 0, seems to be fine, maybe doesn't clean up
# "$HOME/.config/EmuDeck/backend/installCLI.sh"

sudo steamos-update
# sudo steamos-update-os after-reboot

sync

sudo steamos-readonly enable

sudo reboot now && logout
