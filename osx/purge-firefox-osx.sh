#!/bin/bash
# Tim H 2020
# Purges all local Firefox data on OS X after uninstall
# fixes corrupted Firefox installations where normal uninstall/reinstall won't
#   work
# Step 1: uninstall Firefox
# Step 2: run this script
# Step 3: reboot and reinstall Firefox

# delete the directories
rm -Rf "$HOME/Library/Caches/Firefox"
rm -Rf "$HOME/Library/Caches/Mozilla/updates/Applications/Firefox"
rm -Rf "$HOME/Library/Saved Application State/org.mozilla.firefox.savedState"
rm -Rf "$HOME/Library/Application Support/Firefox"

# Delete this file:
rm -f "$HOME/Library/Preferences/org.mozilla.firefox.plist"

# deleting these directories requires sudo powers:
sudo rm -Rf "/Library/Logs/DiagnosticReports/firefox_*.diag" "/System/Volumes/Data/Library/Logs/DiagnosticReports/firefox_*.diag"
sudo rm -Rf "/System/Volumes/Data/private/var/folders/4w/hys77ptx1756jjyx9qgf1dv8lk3v4w/C/org.mozilla.firefox"
