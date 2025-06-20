#!/bin/bash
# Tim H 2020
# create-certbot-certificates.sh
#	References:
#		https://aws.amazon.com/premiumsupport/knowledge-center/simple-resource-record-route53-cli/
#		https://certbot.eff.org/docs/using.html
#		https://unix.stackexchange.com/questions/20784/how-can-i-resolve-a-hostname-to-an-ip-address-in-a-bash-script
#		https://tools.ietf.org/html/draft-ietf-acme-acme-03#section-7.4
#		https://stackoverflow.com/questions/40731295/amazon-cli-route-53-txt-error
#
#	More AWS automation:
#		https://medium.com/@stefanroman/automated-letsencrypt-certificates-on-aws-dce4146acad0
#		https://medium.com/swlh/free-ssl-certificates-with-certbot-in-aws-lambda-991eb24ac1f3
#		Most important: https://hackernoon.com/easy-lets-encrypt-certificates-on-aws-79387767830b
#		https://sslmate.com/caa/

# bomb out immediately if any error occur
set -e

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

################################################################################
#		FUNCTION DEFINITIONS
################################################################################
date_iso8601 () {
	# you should install homebrew before, designed for OS X
	# OS X version of date doesn't offer a way to do milliseconds
	# brew install coreutils
	gdate -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
}

log () {
	# formatted log output including timestamp
	echo -e "$(date_iso8601) [certbuilder] \t $*"
}

check_public_ip () {
	PUBLIC_IP=$(curl -sSf ifconfig.co)
	UNDESIRED_PUBLIC_HOSTNAME="vpn.dyn.REDACTED.me"
	UNDESIRED_PUBLIC_IP=$(dig +short "$UNDESIRED_PUBLIC_HOSTNAME" | head -n 1)
	#log "
	#UNDESIRED PUBLIC HOSTNAME: $UNDESIRED_PUBLIC_HOSTNAME
	#Public IP:                 $PUBLIC_IP
	#UNDESIRED PUBLIC IP:       $UNDESIRED_PUBLIC_IP"
	if [[ "$UNDESIRED_PUBLIC_IP" == "$PUBLIC_IP" ]]; then
		log "ERROR: Get on the VPN before running this script. They're going to track your public IP" 
		exit 2	
	else
		log "Public IP is fine"
	fi
}

fqdn_to_tld () {
	#converts a n-depth FQDN to a top level domain
	# example: fqdn_to_tld "vpn.dyn.REDACTED.me"
	#	will return "REDACTED.me"
	echo "$1" | grep -o "[^.]*\.[^.]*$"
}

################################################################################
#		MAIN
################################################################################
log "Starting script"

# pull in Bash parameters, required and will fail if they aren't specified
if [ -z "$1" ]; then
	log "FQDN must be provided. Exiting."
	exit 4
else
	NEW_FQDN="$1"
	TLD=$(fqdn_to_tld "$NEW_FQDN")
fi

check_public_ip

# check to see if this cert is already in the local database or on route53

log "checking to see if certificate already locally exists"

if certbot certificates | grep -q "Certificate Name: $NEW_FQDN" ; then
	log "certificate was already locally found for $NEW_FQDN:
	$(certbot certificates)

	Existing since cert already exists"
	exit 3
else
	log "certificate was not locally found, okay to proceed."
fi

# download the necessary hook script into current directory
log "downloading hook script..."
wget --no-verbose https://gist.githubusercontent.com/li0nel/4563f8d909e808169c91a5521569ff10/raw/cb1396d07eb91700642b27a4cd92e335498c03ca/auth-hook.sh -O ./auth-hook.sh
chmod +x auth-hook.sh
log "hook script finished downloading"

#verify the download
if test -f "auth-hook.sh"; then
    log "auth-hook.sh exists."
else
	log "auth-hook.sh failed to download. Exiting."
	exit 10
fi

# logging for debugging purposes
log "
FQDN = $NEW_FQDN
TLD =  $TLD"

# create the new certificate
certbot certonly --non-interactive --manual \
	--manual-auth-hook "./auth-hook.sh UPSERT $TLD" \
	--manual-cleanup-hook "./auth-hook.sh DELETE $TLD" \
	--preferred-challenge dns \
	--agree-tos \
	--manual-public-ip-logging-ok \
	--domains "$NEW_FQDN" \
	--email "security@REDACTED.me"

# copy the public and private keys to secure remote repository
# probably rsync or nfs to synology

# probably have to tell user to disconnect from VPN
# then can backup the files to NAS over NFS

# maybe just make the letsencrypt directories mount to NFS so they're never stored locally anyway
# have to verify they're mounted before running, might have permissions problems with multiple users accessing tho and same usernames

# create cron to automatically renew certs, or just use bulk renewal
# probably want to move this to a dedicated VM on my home network?

log "Successfully finished"
