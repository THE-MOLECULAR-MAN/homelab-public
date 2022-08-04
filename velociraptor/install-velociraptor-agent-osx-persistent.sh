#!/bin/bash
# Tim H 2022

##############################################################################
#   STEP 4:
#       INSTALLING THE VELOCIRAPTOR AGENT ON OS X AND MAKING IT AUTOSTART
##############################################################################
# OS X - sudo is required

# install it
sudo velociraptor --config client.config.yaml service install

# see if process is running:
pgrep --list-full "velociraptor"

# test if it is set to autostart in OS X
sudo launchctl list | grep velociraptor
