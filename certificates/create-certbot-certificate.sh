#!/bin/bash
# Tim H 2020
# create-certbot-certificate.sh
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
#		https://hackernoon.com/easy-lets-encrypt-certificates-on-aws-79387767830b

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
	echo -e "[certbuilder] $(date_iso8601)\t $*"
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

################################################################################
#		MAIN
################################################################################
log "Starting script"

# pull in Bash parameters, required and will fail if they aren't specified
NEW_FQDN="$1"

check_public_ip

# check to see if this cert is already in the local database or on route53

certbot -d "$NEW_FQDN" --manual --preferred-challenges dns certonly
# need way to automatically approve the IP logging
# need way to pull output from this into variable for parsing
# need way to send key ENTER when done, maybe background this task and continue on for a minute, then resume it

# generate JSON file unique to this instance
JSON_FILE="$NEW_FQDN-dns-request.json"
SECRET="REDACTED"

# probably do lookup on this based off Hosted Zone
ZONE_ID="REDACTED"

cat <<EOF > "$JSON_FILE"
{
  "Comment": "optional comment about the changes in this change batch request",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "_acme-challenge.$NEW_FQDN",
        "Type": "TXT",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "\"$SECRET\""
          }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "file://$JSON_FILE"
sleep 10 # wait for changes to take effect before sending ENTER back to original tool

#
# copy the public and private keys to secure remote repository
# probably rsync or nfs

# probably have to tell user to disconnect from VPN
# then can backup the files to NAS over NFS

rm "$JSON_FILE"
# consider removing route53 changes after cert is generated, maybe wildcard delete on anything with _acme-challenge in it
# create cron to automatically renew certs, or just use bulk renewal
# probably want to move this to a dedicated VM on my home network?
# is there a cloudformation template that would aide in making this easier and focused on AWS?

log "Successfully finished"
