#!/bin/bash
# Tim H 2023

# https://github.com/JavDomGom/videostego
# only works on Linux, not MacOS
# Installs a tool from GitHub to write secret messages into MP4 files
# and writes a secret message into an example file, and then shows the secret
# message

cd "$HOME" || exit 1

# git the repo
git clone https://github.com/JavDomGom/videostego.git
cd videostego || exit 2

# build it:
sudo make install
make build

# test the executable
./videostego -h

# add a message to the file
./videostego -f "$HOME/file.mp4" -w -m "hidden message here"

# read the message back, verify it
./videostego -f "$HOME/file.mp4" -r
