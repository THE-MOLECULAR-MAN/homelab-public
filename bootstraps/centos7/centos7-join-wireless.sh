#!/bin/bash
# Tim H 2021

# SAFE_FOR_PUBLIC_RELEASE

# Join a command line CentOS system to a wireless network
# https://unix.stackexchange.com/questions/370318/how-to-connect-to-wifi-in-centos-7clino-gui

# install the dependency. May screw with custom DNS or network settings
sudo yum install -y NetworkManager-tui

# INTERACTIVE method for selecting Wifi network and entering password
sudo nmtui
