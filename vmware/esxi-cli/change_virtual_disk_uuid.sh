#!/bin/bash
# Tim H 2025

# Fixing 

cd /vmfs/volumes/r7-3000-raid10/FreeNAS1
vi FreeNAS1_1.vmdk

vim-cmd vmsvc/getallvms
vim-cmd vmsvc/reload 12
