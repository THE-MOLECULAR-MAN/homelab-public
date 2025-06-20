#!/bin/bash
# Tim H 2022
# clean up, free up space
# SAFE_FOR_PUBLIC_RELEASE

sudo yum -y autoremove
sudo yum clean all

sudo journalctl --vacuum-time=1h
sudo journalctl --vacuum-size 1M

# shrink the disk, def the best option - super fast compared to writing zeros
fstrim -v --all
