#!/bin/bash
# Tim H 2020
# renew-certbot-certificates.sh
#   Uses's certbot's automatic renewal feature to go and renew all certs.
#   This script assumes you've used my other scripts to make the certs and that your using Route 53 for DNS.
#   References:
#       https://certbot.eff.org/docs/using.html?highlight=renew#renewing-certificates

# bomb out immediately if any error occur
set -e

# a place to put the files so I don't have to "sudo" constantly to access them
READABLE_DESTINATION="$HOME/Documents/no_backup/letsencrypt_temp"

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
	echo -e "$(date_iso8601) [cert-renewer] \t $*"
}

check_public_ip () {
	PUBLIC_IP=$(curl -sSf ifconfig.co)
	UNDESIRED_PUBLIC_HOSTNAME="vpn.dyn.REDACTED.me"
	UNDESIRED_PUBLIC_IP=$(dig +short "$UNDESIRED_PUBLIC_HOSTNAME" | head -n 1)
	if [[ "$UNDESIRED_PUBLIC_IP" == "$PUBLIC_IP" ]]; then
		log "ERROR: Get on the VPN before running this script. They're going to track your public IP" 
		exit 2	
	else
		log "Public IP is fine"
	fi
}

################################################################################
#		MAIN
################################################################################
log "Starting script"

# check public IP to make sure I'm on VPN before continuing
check_public_ip

#back up files before renewing certs
#sudo ./backup-certbot.sh

# use this one for testing
#sudo certbot --dry-run renew

# use this for production
sudo certbot renew

# delete any old version
rm -Rf "$READABLE_DESTINATION"

# copy over the files and remove the symlinks
sudo cp -LR /etc/letsencrypt/live "$READABLE_DESTINATION"

# set the permissions so I can actually read them, I had to do this the hard way on OS X since it doesn't have the same flags for chmod/chown as Linux does.
sudo find "$READABLE_DESTINATION" -exec chmod 700 {} \;
sudo find "$READABLE_DESTINATION" -exec chown REDACTED_USERNAME {} \;

cd "$READABLE_DESTINATION"
ls -lah .

log "Successfully finished"
exit 0


# Cert types by host
######
#	Synology
#		Private key: privkey.pem
#		Certificate: cert.pem
#		Intermediate Certificate (optional): (blank)
#		that works fine!
#
#	Plex:
#	Settings / Network / Advanced
#		takes P12 files
#		https://support.plex.tv/articles/206225077-how-to-use-secure-server-connections/
#		path can be %plex%/file.p12

# stuff for Synology Plex cert
cd "$READABLE_DESTINATION/synology.int.REDACTED.me" || exit 99
ISO_DATE_NOW=$(date_iso8601)
P12_FILENAME="plex-letsencrypt-$ISO_DATE_NOW.p12"
openssl pkcs12 -export -out "$P12_FILENAME" -in cert.pem -inkey privkey.pem # TODO update it so it doesn't prompt for passphrase to protect PKCS12 file

# copy the file into the plex home directory
scp "$P12_FILENAME" synology.int.REDACTED.me:/volume1/Plex/
