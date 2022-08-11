#!/bin/bash
# Tim H 2018
# Flushes the OS's DNS Cache on OS X.
# Warning: Google Chrome has its own separate DNS cache

sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
