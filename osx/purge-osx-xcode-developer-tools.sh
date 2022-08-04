#!/bin/bash
# Tim H 2022
# uninstalls and purges XCODE developer plugins for OS X
# References:
#   https://mac.install.guide/commandlinetools/6.html
#   https://dzone.com/articles/how-to-completely-uninstall-xcode-from-mac

# disable developer mode first
# do NOT use sudo here, it switches user:
/usr/sbin/DevToolsSecurity -disable
/usr/sbin/DevToolsSecurity -status -verbose

# reset all the xcode settings
# this does require sudo:
sudo xcode-select --reset

# remove XCode from two locations
sudo rm -rf /Library/Developer/CommandLineTools
sudo rm -rf ~/Library/Developer/

# see where xcode is installed:
xcode-select --print-path
xcode-select --version

# seearch for any other leftovers:
# may need to open new window for new path varibles to take effect
whereis xcode-select
mdfind -name "xcode"
mdfind -name devtools

# these directories don't exist on my system, but an article claims they should be deleted
rm -Rf ~/Library/MobileDevice \
    ~/Library/Developer \
    ~/Library/Preferences/com.apple.dt.Xcode.plist \
    ~/Library/Caches/com.apple.dt.Xcode \
    /Applications/Xcode.app \
    /System/Library/Receipts/com.apple.pkg.XcodeSystemResources.plist  \
    /System/Library/Receipts/com.apple.pkg.XcodeExtensionSupport.plist \
    /System/Library/Receipts/com.apple.pkg.XcodeSystemResources.bom    \
    /System/Library/Receipts/com.apple.pkg.XcodeExtensionSupport.bom   \
    /Library/Preferences/com.apple.dt.Xcode.plist
