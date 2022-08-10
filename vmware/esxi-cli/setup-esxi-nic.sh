#!/bin/bash
# Tim H 2020
esxcli network nic list


vusb0_status=$(esxcli network nic get -n vusb0 | grep 'Link Status' | awk '{print $NF}')
count=0
while [[ $count -lt 20 && "${vusb0_status}" != "Up" ]]
do
    sleep 10
    count=$(( count + 1 ))
    vusb0_status=$(esxcli network nic get -n vusb0 | grep 'Link Status' | awk '{print $NF}')
done

if [ "${vusb0_status}" = "Up" ]; then
    esxcfg-vswitch -L vusb0 vSwitch0
    esxcfg-vswitch -M vusb0 -p "Management Network" vSwitch0
    esxcfg-vswitch -M vusb0 -p "VM Network" vSwitch0
fi
