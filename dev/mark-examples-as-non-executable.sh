#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
#   
#   Script to find any .sh files that contain my keyphrase "!NON-EXECUTABLE!" 
#   and chmod them to -x to prevent direct execution
#       Except this script
# bomb out if any errors

set -e

THIS_SCRIPT_NAME=$(basename "$0")

#KEYPHRASE="!NON-EXECUTABLE!"

# files that have "sudo su" in them probably should not be executable
#find .. -type f  -iname '*.sh' ! -name "$THIS_SCRIPT_NAME" \
#     -exec grep --with-filename "sudo su" {} \;

find .. -type f -iname '*.sh' ! -name "$THIS_SCRIPT_NAME" -print0 \
	 -perm +111 \
     -exec grep --files-with-matches "NON-EXECUTABLE" {} \; | xargs chmod -x
