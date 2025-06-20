#!/bin/bash
# Tim H 2021

# sets up remote testing for the validate-ip-hostname-dns-list.sh script

REMOTE_HOST="redacted@kali.int.redacred.me"
INVENTORY_FILE="definitive-list-of-mac-ip-hostname.csv"

if [ ! -f "$INVENTORY_FILE" ]
then
    echo "Validation file does not exist. Exiting."
    exit 2
fi

shellcheck "validate-ip-hostname-dns-list.sh"

scp  "$INVENTORY_FILE"                       "$REMOTE_HOST:~/"
scp ./validate-ip-hostname-dns-list.sh       "$REMOTE_HOST:~/"
