#!/bin/bash
# Tim H 2021, 2022
#
# Sync ROMS from remote file server to Raspberry Pi running RetroPie
# only syncs select game systems, not all since ROMS directories
# are often many hundreds of gigabytes and the sd card on the pi
# is much smaller
#
# uses rsync to avoid redownloading large amounts/sized files
# Script only does 1-way syncing, does not upload saved games or states
# to the network mount point

# local mount point for the remotely stored roms
REMOTE_POINT="/mnt/roms"

# local destination for the roms
LOCAL_POINT="/home/pi/RetroPie/roms"

# list of game systems to sync the roms for, don't do everything
declare -a LIST_OF_SYSTEMS=("nes" "snes" "n64" "genesis" "gb" "gba" \
    "gamegear" "mastersystem" "megadrive" "neogeo" "ngpc" "pcengine" \
    "sega32x" "segacd" "atarijaguar" "fba" "dreamcast" "psx" )

# immediately exit this script if anything returns an error
set -e

# Iterate the string array using for loop
# shellcheck disable=SC2068
for ITER_SYSTEM_NAME in ${LIST_OF_SYSTEMS[@]}; do
    echo "Copying $ITER_SYSTEM_NAME..."
    rsync -a --update --info=progress2 "$REMOTE_POINT/$ITER_SYSTEM_NAME" "$LOCAL_POINT/$ITER_SYSTEM_NAME"
done

# mark ownership of new files, assuming default username for RetroPie (pi)
sudo chown -R pi:pi "$LOCAL_POINT"

# display disk usage / free disk space on partition where roms are stored
df -h "$LOCAL_POINT"

echo "Script completed successfully."
