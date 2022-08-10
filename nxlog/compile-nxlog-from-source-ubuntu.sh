#!/bin/bash
# Tim H 2022
# this compiles the binary and the binary works, but 
# it doesn't install the service or setup the user.

# compile nxlog from source on Ubuntu 20.04
cd "$HOME" || exit 1
SRC_FULLPATH="$HOME/nxlog-ce-src.tar.gz"

sudo apt-get install -y libapr1-dev libaprutil1-dev libpcre3-dev

wget --output-document="$SRC_FULLPATH" "https://nxlog.co/system/files/products/files/348/nxlog-ce-3.0.2272.tar.gz"
tar -xzf "$SRC_FULLPATH"

cd nxlog-ce-3.0.14/ || exit 2
./configure
make
sudo make install


echo "
LogFile /var/log/nxlog/nxlog.log
LogLevel INFO
" | sudo tee -a /etc/nxlog/nxlog.conf

# see version:
nxlog --help

# test config file syntax:
nxlog -v

/usr/local/etc/nxlog/nxlog.conf
