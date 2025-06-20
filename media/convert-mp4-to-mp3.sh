#!/bin/bash
# Tim H 2022
#
# Convert an .MP4 video file into an MP3
#
# https://askubuntu.com/questions/84584/converting-mp4-to-mp3

ORIGINAL_VIDEO="$HOME/Downloads/redacted.mp4"
AUDIO_FILE="$HOME/Documents/no_backup/redacted.mp3"

# remove previous run, if the file exists
rm -f "$AUDIO_FILE"

# install dependencies - this takes a WHILE
# brew install ffmpeg  

ffmpeg -i "$ORIGINAL_VIDEO" -vn \
    -acodec libmp3lame -ac 2 -ab 160k -ar 48000 \
    "$AUDIO_FILE"

# took 2.5 min to do 2.5 hours of video on MacBook Pro
