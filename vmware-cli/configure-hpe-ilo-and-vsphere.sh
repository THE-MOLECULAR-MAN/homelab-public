#!/bin/bash
# Tim H 2022

# Setting up and troubleshooting IPMI connections from vSphere to
# HPE's iLO. Be sure to set the iLO dedicated IP to a static IP.
# Allows VMware vSphere to control the hardware settings (like power)
# and poll it for serial numbers, etc.
# vSphere will attempt to connect to the listed IP on UDP port 623, 
# this port is not configurable in vSphere but is configurable in iLO.
# Host OS (ESXi Hypervisor) must be rebooted after making changes to Power 
# settings in iLO
# Common issues with config and toubleshooting - make sure you're using 
# the iLO DEDICATED IP and not the host OS IP
# setting power settings in vSphere:
# 	ESXi Host / Configure / Hardware:Overview - SCROLL TO THE BOTTOM / Edit Power Policy
# Must enable the following setting in iLO:
# 	IPMI/DCMI over LAN: Enabled

# References:
# 	https://docs.oracle.com/cd/E19464-01/820-6850-11/IPMItool.html
# 	https://kb.vmware.com/s/article/2009169
# 	https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.resmgmt.doc/GUID-D247EC2C-92C5-4B9B-9305-39099F30D3B5.html
# 	https://medium.com/@what_if/automate-enabling-of-ipmi-over-lan-access-on-hpe-ilo-7d9d8c55b83e



# Settings for the HPE iLO NIC:
DEDICATED_ILO_IP="10.0.1.x"
ILO_USERNAME="administrator" # default username
ILO_PASSWORD="REDACTED"		 # available on sticker on outside of server


##############################################################################
# Test a basic connection to iLO's IPMI (UDP 623) with authentication. 
##############################################################################
# install the pre-req tool in OSX
brew install ipmitool

# the -I lanplus is required to prevent the "Authentication type NONE not supported" error
ipmitool -I lanplus -H "$DEDICATED_ILO_IP" -U "$ILO_USERNAME" -P "$ILO_PASSWORD" chassis status

# add the -vvvv flag for debugging info:
# ipmitool -I lanplus -vvvv -H "$DEDICATED_ILO_IP" -U "$ILO_USERNAME" -P "$ILO_PASSWORD" chassis status


##############################################################################
# Test UNauthenticated API call to iLO's RESTful API (TCP 443/https)
##############################################################################
curl --insecure "https://$DEDICATED_ILO_IP/xmldata?item=All" #| xmllint --format



##############################################################################
# Test a basic authenticated API call to iLO's RESTful API (TCP 443/https)
##############################################################################
# dependency, optional
brew install jq

# pass results to jq to make it pretty and readable
# The RESTful API uses HTTP basic auth
# add a -v for debugging. You shouldn't get a 4xx HTTP return code
curl --insecure --location \
	 --request GET "https://$DEDICATED_ILO_IP/redfish/v1/Managers/1/NetworkProtocol/" \
	 -u "$ILO_USERNAME:$ILO_PASSWORD" \
   	 --header 'Content-Type: application/json' | jq


##############################################################################
# Port scan iLO dedicated IP for open TCP ports
##############################################################################
# dependency:
brew install nmap

# IPMI not included since it is UDP
# default TCP ports for iLO services
nmap -Pn -p17990,22,162,17988,80,443 "$DEDICATED_ILO_IP"
