#!/bin/bash
# Tim H 2022
# simple test for my new .env and common-functions files before 
#   adding it to all my other files


################################################################################
#	TEMPLATE & DEFINITIONS
################################################################################
# bomb out if any errors
set -e

THIS_SCRIPT_NAME=$(basename "$0")                 # can't use the --suffix since it isn't supported in OS X like it is in Linux

# source must come after the variable definitions?
# can't combine into one line, only one file per source
# shellcheck disable=SC1091
source .env
# shellcheck disable=SC1091
source common-functions.sh

################################################################################
#		MAIN PROGRAM
################################################################################

send_slack_notification "test"

echo "$THIS_SCRIPT_NAME ended succcessfully"
