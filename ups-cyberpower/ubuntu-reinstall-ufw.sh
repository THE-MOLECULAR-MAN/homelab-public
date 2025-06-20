#!/bin/bash
# Tim H 2022

# purge and reinstall UFW/iptables in Ubuntu 20.04
sudo apt-get remove ufw iptables
sudo rm - Rf /etc/ufw

sudo apt-get -y install ufw

sudo reboot now

# this fixed the problem that PPB local caused

