#!/bin/bash
# Tim H 2022
# Validated this works on Ubuntu 20.04 on 2022-08-04
# Restore was successful with no issues.
#
# References:
#   https://docs.checkmk.com/latest/en/omd_basics.html#omd_backup_restore

# check version that is running. Verify it matches the backup.
sudo omd versions

# stop the service before running restore
sudo omd stop

# restore the backup
sudo omd restore ./check-mk-backup-free-edition-2.0.0p24.cfe-2022-08-03.tar.gz

# restart the service
sudo omd start

# check the status of the restored site (change to yours)
sudo omd status homelab2
