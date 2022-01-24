#!/bin/bash
# Tim H 2021

# Create a test web server for debugging web traffic in Linux or OS X CLI
# Starts a python web server in a screen session named webserver
# Starts a second screen session named portmonitor that watches all TCP
# traffic to/from the port indicated
#
# Careful running these commands on your corporate system
# They look similar to an attacker and may trigger an alert

# Wrote this for debugging some CyberPower UPS issues
# https://www.reddit.com/r/homelab/comments/d7k2sn/anyone_here_got_clickatell_or_other_sms_working/

# show the current server's active network adapters and IP addresses
# ifconfig -a

# the high port number to be used to listen
export TCP_PORT_NUMBER="8000"

# start listening on port 8000 via HTTP (not HTTPS),
# listen on all interfaces (8000 and bind on all are default, 
#   are NOT required to be specified)
screen -S webserver   -dm bash -c "python3 -m http.server  $TCP_PORT_NUMBER"

# watching the TCP stream
screen -S portmonitor -dm bash -c "tcpdump -vv -i any port $TCP_PORT_NUMBER"
