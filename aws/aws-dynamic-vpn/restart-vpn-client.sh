#!/bin/bash
# Tim H 2020
#/usr/local/bin/restart-vpn.sh

# bomb out if any errors occur
set -e

LOGFILE="/root/cron-restartvpn.log"

# redirect all output to a logfile
exec >> "$LOGFILE"
exec 2>&1

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

################################################################################
#		FUNCTION DEFINITIONS
################################################################################

log () {
	# formatted log output including timestamp
	echo -e "[bootstrap] $(date)\t $*"
}

#log "starting vpn reconnection..."

/usr/local/bin/stop-vpn
log "finished stopping VPN..."

/usr/local/bin/start-vpn
log "finished starting VPN..."
