#!/bin/bash
# Tim H 2022
#
# Turns out this doesn't work at all b/c it's not a standard HTTP request and some of them use UDP instead
# can't rely on basic CURL commands, each protocol is different
# 
# TRACKER_LIST_FILE_PATH="$HOME/Desktop/trackers2.txt"

TRACKER_LIST_FILE_PATH="./trackers_list_https.txt"

# TODO: replace with while read loop
for url in $(cat "$TRACKER_LIST_FILE_PATH")
do 
  echo "Testing: $url ..."
  if curl --output /dev/null --connect-timeout 5 --silent --head --fail "$url"; then
    echo "URL exists: $url"
  else
    echo "URL does not exist: $url"
  fi
done
