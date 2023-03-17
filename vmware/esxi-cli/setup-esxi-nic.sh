#!/bin/bash
# Tim H 2020

# I think this script was for an old laptop running ESXi 7 that needed 
# a second ethernet adapter that was on USB. That adapter needed to be
# configured

# Comments were added in 2023, guessing what this script did.

# list the network adapters
esxcli network nic list

# get a list of the status of the virtual USB adapter
vusb0_status=$(esxcli network nic get -n vusb0 | grep 'Link Status' | awk '{print $NF}')

count=0
# iterate through a loop of up to 20 attempts (each 10 seconds)
# wait for the virtual USB adapter's status to be "Up" instead of something else
while [[ $count -lt 20 && "${vusb0_status}" != "Up" ]]
do
    sleep 10
    count=$(( count + 1 ))
    vusb0_status=$(esxcli network nic get -n vusb0 | grep 'Link Status' | awk '{print $NF}')
done

# if it does come up, then configure it
if [ "${vusb0_status}" = "Up" ]; then
    # assign the vUSB adapter to switch0 and some other stuff
    esxcfg-vswitch -L vusb0 vSwitch0
    esxcfg-vswitch -M vusb0 -p "Management Network" vSwitch0
    esxcfg-vswitch -M vusb0 -p "VM Network" vSwitch0
fi
