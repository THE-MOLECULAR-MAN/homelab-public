#!/bin/bash
# Tim H 2022

# DOES NOT WORK WITH APPLE M1

# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!
# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!
# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!

# function definition
get_file_check_hash_extract_zip() {
    URL="$1"
    HASH="$2"
    ORIG_FILENAME=$(basename "$URL")
    NEW_DIR_NAME="${ORIG_FILENAME%.*}"

    cd "$HOME/Library/Android/sdk/platform-tools"
    wget --no-clobber "$URL"
    echo "$HASH $ORIG_FILENAME" > "$ORIG_FILENAME.sha256"
    sha256sum --check "$ORIG_FILENAME.sha256"
    unzip -n -d "$NEW_DIR_NAME" "$ORIG_FILENAME"
}



# Install Android Debug Bridge on OSX
# https://brismuth.com/installing-adb-on-mac-os-x-f34b39ff0dd1
brew install --cask android-platform-tools
brew install --cask android-studio
# you must now launch Android Studio to finish the setup, otherwise certain directories required below won't be created.
# installing it in the GUI takes 2-3 min, you can close it when it's done, no need to launch anything else


# should see the device listed here
adb devices

# https://www.xda-developers.com/install-adb-windows-macos-linux/
# verify the shell is working first:
# adb shell
# find / -type d -iname '*platform-tools*' 2>/dev/null

# see CPU info, record it for later.
adb shell getprop ro.product.cpu.abi
# old Nexus 6P: arm64-v8a

# reboot the Android into bootload mode to check some things:
adb reboot bootloader

# while in bootloader mode:
fastboot devices
# fastboot oem device-info        # this command doesn't work for some reason?

# unlock the bootloader, use volume buttons to select and power as Enter
# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!
# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!
# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!
# must unlock before you can do a fastboot erase system
fastboot flashing unlock

# Download Android 13 Oct 2022 edition for AMD64+Google Store stuff:
# wget "https://dl.google.com/developers/android/tm/images/gsi/aosp_arm64-exp-T1B3.221003.003-9173718-7eba5aba.zip"
# unzip aosp_arm64-exp-T1B3.221003.003-9173718-7eba5aba.zip
# rm aosp_arm64-exp-T1B3.221003.003-9173718-7eba5aba.zip

# this next line is IMPORTANT, don't skip it:
cd "$HOME/Library/Android/sdk/platform-tools"


# Android 13 GSIs
# Date: August 15, 2022
# Build: TP1A.220624.014
# Security patch level: August 2022
# Google Play Services: 22.18.21

# ARM64+GMS
get_file_check_hash_extract_zip "https://dl.google.com/developers/android/tm/images/gsi/gsi_gms_arm64-exp-TP1A.220624.014-8819323-8a77fef1.zip" "8a77fef1842da4a4cff68e36802f779d65e52ae0cfce024a33901d5dc48d47d0"

# ARM64 without GMS
get_file_check_hash_extract_zip "https://dl.google.com/developers/android/tm/images/gsi/aosp_arm64-exp-TP1A.220624.014-8819323-996da050.zip"    "996da050f44a6f08299eecf2b254de4fe42a3a883cca27faf119ac9224e65a66"

# https://www.getdroidtips.com/download-android-13-gsi/#Steps-to-Install-Android-13-GSI-on-Any-Project-Treble-Device
adb reboot bootloader
fastboot devices

# Next, you’ll have to disable Android Verified Boot (AVB) by running the command below:
# fastboot flash vbmeta vbmeta.img

# erase everything, again
fastboot erase system

# flash new Android version onto it - sent it to the phone
fastboot flash system system.img

fastboot -w

fastboot reboot

# the Pixel XL wouldn't boot until I did this, but then it just reverted to Android 10
# relock the bootloader and flash the phone AGAIN
# !!!!!!! THIS DOES A FACTORY RESET ON THE PHONE!!!!!!
# fastboot flashing lock

# try next: the version of the flash command that disables the check, the one with 1-2 flags

# something wrong about this: https://source.android.com/docs/setup/create/gsi#changes-in-q-gsis



# https://forum.xda-developers.com/t/how-to-flash-a-b-treble-gsi-roms-without-twrp.4115009/
ls -lah *.img


# https://technastic.com/fastboot-commands-list/

# https://developer.android.com/topic/generic-system-image/releases

# https://flash.android.com/release/12.0.0


# https://developers.google.com/android/images
# https://developers.google.com/android/ota#blueline
# 11.0.0 (RP1A.201005.004.A1, Dec 2020)
get_file_check_hash_extract_zip "https://dl.google.com/dl/android/aosp/taimen-ota-rp1a.201005.004.a1-9de3b962.zip"      "9de3b96223cf14e8afd69ed9b21b801a15a96990781a7058ac8418ffd78e0dd7"

# this reboots into a slightly different space: fastbootD
fastboot reboot fastboot

# fastboot --slot=other flash bootloader taimen-ota-rp1a.201005.004.a1-9de3b962/payload.bin
fastboot flash system taimen-ota-rp1a.201005.004.a1-9de3b962/payload.bin


# https://source.android.com/docs/core/architecture/bootloader/fastbootd
fastboot getvar is-userspace

# what at least came close to working
# Whole process takes about 5 minutes to start booting into Android OS
# boot device into Fastboot mode (not fastbootd) - do a fresh boot into the bootloader, don't do this after issuing other commands
# visit this page in CHROME: https://flash.android.com/release/12.0.0
# Click ADD DEVICE and pick the Pixel 3, it shouldn't already say "paired" next to it.
# it does a LOT of steps and reboots the phone several times automatically
# This tool only does Android versions that are OFFICIALLY supported by Google, so for example on the Pixel 3 it does Android 12, but does NOT support Android 13 for the Pixel 3
# late in the process you will have to touch buttons on the phone to approve locking the bootloader



####
brew install simg2img

# fails:
cd taimen-ota-rp1a.201005.004.a1-9de3b962 || exit 1
simg2img payload.bin system_raw.img


cd gsi_gms_arm64-exp-TP1A.220624.014-8819323-8a77fef1 || exit 1
simg2img system.img system_raw.img

./imgtool <path-to-factory-image>/system.img extract


wget "http://newandroidbook.com/tools/imjtool.tgz"
# xattr -d com.apple.quarantine ./imjtool
cd gsi_gms_arm64-exp-TP1A.220624.014-8819323-8a77fef1
../imjtool system.img extract # extracted empty file

cd taimen-ota-rp1a.201005.004.a1-9de3b962
../imjtool payload.bin extract      # extracted successfully?
# but this just extracts it, doesn't do anything for the phone

# Unfortunately, you can't do this operation on your M1 device. Because, Android doesn't officially support the ARM version of SDK Platform tools. Only the intel version of Apple devices could be used to flash roms.
# https://developer.android.com/tools/releases/platform-tools



## attempting on Ubuntu:
sudo apt install android-sdk    # so many unneeded "suggested" packages
# android-sdk-build-tools
sudo fastboot devices

sudo fastboot flash system taimen-ota-rp1a.201005.004.a1-9de3b962/payload.bin
