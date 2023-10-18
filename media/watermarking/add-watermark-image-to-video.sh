#!/bin/bash
# Tim H 2023
#
# Adds text into an MP4 video as a watermark
# You may need to adjust some of the numbers for the size of the PNG file
# and the location of where it is placed on the screen, depending on the
# length of your text
#
# References:
# https://stackoverflow.com/questions/26432463/ffmpeg-command-to-extract-first-two-minutes-of-a-video

set -e

TEXT_TO_OVERLAY="TEXT TO BE ADDED TO VIDEO"
WATERMARK_FILE="watermark.png"
INPUT_VIDEO_FILE="$HOME/Downloads/video.mp4"
OUTPUT_VIDEO_FILE="$HOME/Downloads/video-watermarked.mp4"

chmod -w "$INPUT_VIDEO_FILE"

# SAMPLE_LENGTH_IN_SECONDS=10
# SAMPLE_VIDEO_FILE="$INPUT_VIDEO_FILE-sample-before-watermark.mp4"
# rm -f "$SAMPLE_VIDEO_FILE" "$OUTPUT_VIDEO_FILE"
# create a short sample video of the original video
# ffmpeg -i "$INPUT_VIDEO_FILE" -ss 0 -t "$SAMPLE_LENGTH_IN_SECONDS" \
#   -c copy "$SAMPLE_VIDEO_FILE"

# generate the watermark image file as PNG
echo "text 15,30 \"$TEXT_TO_OVERLAY\"" > source_text.txt
convert -size 360x50 xc:white -font "PT-Mono-Bold" -pointsize 24 \
    -fill black -draw @source_text.txt "$WATERMARK_FILE"

# add the PNG watermark to the video in a sample video
ffmpeg -y -i "$INPUT_VIDEO_FILE" -i "$WATERMARK_FILE" -filter_complex \
    '[0:v][1:v]overlay=15:10[outv]' -map '[outv]' -map 0:a \
    -c:a copy -c:v libx264 -crf 22 -preset veryfast "$OUTPUT_VIDEO_FILE"

# play the sample without blocking CLI
# vlc "$OUTPUT_VIDEO_FILE" & 
