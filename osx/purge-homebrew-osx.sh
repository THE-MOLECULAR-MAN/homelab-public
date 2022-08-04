#!/bin/bash
# Tim H 2022

# https://github.com/homebrew/install#uninstall-homebrew
# Homebrew's official uninstall script, but it leaves stuff behind
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# delete some directories that are known to be left behind after uninstall script
sudo rm -Rf /usr/local/Caskroom     \
            /usr/local/Homebrew/    \
            /usr/local/Cellar       \
            /usr/local/var/homebrew \
            /usr/local/share/doc/homebrew \
            /System/Volumes/Data/usr/local/var/homebrew \
            /System/Volumes/Data/usr/local/share/doc/homebrew

# this is a system provided theme, don't delete it.
# doesn't seem to have anything to do with actual Homebrew package manager
# /System/Applications/Utilities/Terminal.app/Contents/Resources/Initial Settings/Homebrew.terminal


# search current user's home directory - most of the leftover stuff is here.
# done very quickly
find "$HOME"  -iname '*homebrew*' 2>/dev/null

# search the whole local file system for other files
# the -mount keeps it from scanning remote file systems, only local ones
find / -mount -iname '*homebrew*' 2>/dev/null
