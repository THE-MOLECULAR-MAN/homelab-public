#!/bin/bash
# Tim H 2022

# Set up directories and permissions for back

mkdir --mode=770 /opt/omd/backups
chgrp omd /opt/omd/backups

# checkmk Failed to start the job: The backup target path is configured to 
# be a mountpoint, but nothing is mounted. 
