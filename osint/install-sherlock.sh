#!/bin/bash
# Tim H 2023
#
# OSINT tool for social media
#
# References:
#   https://github.com/sherlock-project/sherlock

cd "$HOME/source_code/third_party" || exit 1
git clone https://github.com/sherlock-project/sherlock.git
cd sherlock || exit 2
python3 -m pip install -r requirements.txt

# run a scan for a single person with a bunch of usernames
python3 sherlock --nsfw --csv --folderoutput sherlock-theirname  \
   username1 username2 username3
