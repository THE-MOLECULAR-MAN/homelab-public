#!/bin/bash
# Tim H 2022
# Installs the Check-MK server Free Enterprise edition on Ubuntu 20.04
# https://checkmk.com/download?method=cmk&edition=cre&version=2.1.0p9&platform=ubuntu&os=focal&type=cmk
# https://docs.checkmk.com/latest/en/install_packages_debian.html#signed
# https://checkmk.com/download/archive#checkmk-2.0.0

cd "$HOME" || exit 1

# GOTCHAs: version and type must exactly match.
# "Raw" is not the same as "Free"
CMK_VERSION="2.0.0p24"
CMK_EDITION="free" # free, raw, etc.
CMK_HASHES_URL="https://download.checkmk.com/checkmk/$CMK_VERSION/HASHES"
CMK_INSTALLER_FILENAME="check-mk-$CMK_EDITION-${CMK_VERSION}_0.focal_amd64.deb"

# download installer:
wget "https://download.checkmk.com/checkmk/$CMK_VERSION/$CMK_INSTALLER_FILENAME"

# download all the hashes for that version:
wget "$CMK_HASHES_URL"

# verify SHA256 hashsum for integrity check of installer
sha256sum --ignore-missing --check ./HASHES

# verify GPG signature of installer
sudo apt-get update
sudo apt-get -y install dpkg-sig
wget https://download.checkmk.com/checkmk/Check_MK-pubkey.gpg
gpg --import Check_MK-pubkey.gpg
dpkg-sig --verify "$CMK_INSTALLER_FILENAME"

# Install the debian package.
# It has a lot of dependencies and takes 1-2 min to run
# the ./ is required
sudo apt -y install "./$CMK_INSTALLER_FILENAME"

# verify install, check version:
omd version

# now go and create a site and follow their setup instructions
