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
LOGFILE="$HOME/history-$THIS_SCRIPT_NAME.log"         # filename of file that this script will log to. Keeps history between runs.

# source must come after the variable definitions?
# can't combine into one line, only one file per source
source .env
source common-functions.sh

# output to the log file instead of the screen
setup_logging_out_to_file

################################################################################
#		MAIN PROGRAM
################################################################################


# start a log so I know it ran
log "========= START ============="
echo "CLICKATELL API KEY: $CLICKATELL_API_KEY"

# list all environment variables
printenv

# list all SHELL variables, not the same as environment variables
( set -o posix ; set )

log "========= SCRIPT FINISHED SUCCESSFULLY ============="
