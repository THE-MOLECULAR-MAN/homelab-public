#!/bin/bash
# Tim H 2021
#
# Wake gaming desktop
# https://superuser.com/questions/411213/how-to-send-a-magic-packet-from-os-x-in-order-to-wake-a-pc-on-the-lan-wol

# install dependency before first run
# brew install wakeonlan

# MAC address of target network adapter on LAN
TARGET_MAC_ADDRESS="fc:34:97:a8:d6:14"

# Broadcast address where target is located. Must end in .255
# Not the CIDR notation
TARGET_BROADCAST_IP_ADDRESS="10.0.1.255"

wakeonlan -i "$TARGET_BROADCAST_IP_ADDRESS" "$TARGET_MAC_ADDRESS"

# optional - verify it is up and running after wake
# echo "arping requires sudo..."
# sudo /usr/local/sbin/arping -i en0 -c 3 "$TARGET_MAC_ADDRESS"

TARGET_IP="10.0.1.81"
ping -c 10 "$TARGET_IP"

# nmap "$TARGET_IP"

