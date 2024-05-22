#!/bin/bash
# Tim H 2022

# https://www.reddit.com/r/SteamDeck/comments/t6w9at/how_to_get_rid_of_read_only_filesystem_folders/

sudo steamos-readonly disable

# https://www.windowscentral.com/gaming/pc-gaming/how-to-install-epic-games-on-steam-deck

# https://flatpak.org/setup/Arch
sudo pacman --noconfirm -S flatpak

# added sudo to avoid the 7+ prompts for password
sudo flatpak install flathub com.heroicgameslauncher.hgl

# create symbolic link to sdcard in user's home directory
# SD card mount point: /dev/mmcblk0p1
cd /run/media/mmcblk0p1 || exit 1
ln -s /run/media/mmcblk0p1 "$HOME/sd_card"
mkdir "$HOME/sd_card/heroic_games"

# for some reason, the Heroic Games launcher needs the symbolic link here?
ln -s /run/media/mmcblk0p1/heroic_games "$HOME/Documents/heroic_games"

sudo steamos-readonly enable

# 1) go to Steam in DESKTOP mode, the old school desktop interface
# 2) add the Heroic Games launcher as a non-steam game
# 3) launch it
# 4) login to Epic Games
