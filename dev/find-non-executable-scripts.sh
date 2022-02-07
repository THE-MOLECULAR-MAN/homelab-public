#!/bin/bash
# Tim H 2019
# READY_FOR_PUBLIC_REPO
#   
#   Script to find any .sh files that are NOT executable in repo
#
#   References:
#       https://stackoverflow.com/questions/4458120/search-for-executable-files-using-find-command


# bomb out if any errors
set -e

find .. -type f -iname '*.sh' ! -perm +111
