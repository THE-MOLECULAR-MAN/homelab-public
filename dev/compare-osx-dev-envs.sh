#!/bin/bash
# Tim H 2022
#
# compare two OS X dev environments
# creates a series of text files that describe a developer's config on MacOS
# then diffs those files to compare them.
# used for troubleshooting why some of my things worked on one laptop
# but not another

OUTPUT_FILENAME_SUFFIX="$(hostname -s).txt"

# clean up any issues first
brew doctor
pip3 check

brew list -1 --formula > "state-brew_formula.$OUTPUT_FILENAME_SUFFIX"
brew list -1 --casks   > "state-brew_casks.$OUTPUT_FILENAME_SUFFIX"
pip3 list > "state-pip3.$OUTPUT_FILENAME_SUFFIX"
cd /Applications && find . -type d -maxdepth 1 -mindepth 1 | \
     sort --unique > "state-allOSXapps.$OUTPUT_FILENAME_SUFFIX"
find /Applications -path '*Contents/_MASReceipt/receipt' -maxdepth 4 -print | \
    sed 's#.app/Contents/_MASReceipt/receipt#.app#g; s#/Applications/##' | \
    sort --unique > "state-appstore.$OUTPUT_FILENAME_SUFFIX"

npm list --global --depth=0 --parseable | awk '(NR>1)' | xargs basename | \
    sort --unique > "state-npm.$OUTPUT_FILENAME_SUFFIX"

echo "NEW                          STANDARD"
colordiff --side-by-side state-pip3.RMT-MBP-10361.txt         state-pip3.bespin.txt
colordiff --side-by-side state-allOSXapps.RMT-MBP-10361.txt   state-allOSXapps.bespin.txt
colordiff --side-by-side state-brew_casks.RMT-MBP-10361.txt   state-brew_casks.bespin.txt
colordiff --side-by-side state-brew_formula.RMT-MBP-10361.txt state-brew_formula.bespin.txt
colordiff --side-by-side state-npm.RMT-MBP-10361.txt          state-npm.bespin.txt
