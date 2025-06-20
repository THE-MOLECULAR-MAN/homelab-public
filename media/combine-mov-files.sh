#!/bin/bash
# Tim H 2022
#
# combine multiple MOV files into a single MOV file
# works extremely quickly if the files are all the same format

set -e

cd "$HOME/Downloads/Photos-001" || exit 1

echo "file ./IMG_4870.MOV
file ./IMG_4871.MOV
file ./IMG_4872.MOV" > files_to_combine.txt

ffmpeg -safe 0 -f concat -i files_to_combine.txt -vcodec copy \
    -acodec copy merged.MOV
