#!/bin/bash
# Tim H 2021
#   Checking availability of a domain on DropCatch.com
#   Also does WhoIs lookup on them to check domain status
#   You must have a validated account and generated an API key first
#   put the API key and username in drop-catch-creds.json. See example file in repo
#
#   Example usage:
#   ./drop-catch-search.sh FlatulenceIsFunny.net
#
#   example crontab for daily at 1 AM
#   1 0 * * * $HOME/bin/drop-catch-search.sh FlatulenceIsFunny.net
#
# References:
#   * https://www.dropcatch.com/hiw/dropcatch-api
#   * https://stackoverflow.com/questions/15912924/how-to-send-file-contents-as-body-entity-using-curl
#   * https://stackoverflow.com/questions/44656515/how-to-remove-double-quotes-in-jq-output-for-parsing-json-files-in-bash

# bomb out if any errors
set -e

################################################################################
# Defining variables for your specific environment
################################################################################
PATH_TO_CREDS="./drop-catch-creds.json"

# You shouldn't need to modify anything below this line
DOMAIN_PREFIX="$1"                  # query, like "google.com" or "fitness", don't have to include full Top Level Domain (TLD) like google.com

## ONE TIME SETUP:
## install WhoIs in CentOS 7
# yum install -q -y whois
## install whois on OS X with brew
# brew install whois

################################################################################
#		MAIN PROGRAM
################################################################################

# make sure that the github user list file exists, bail if not.
if [[ ! -f "$PATH_TO_CREDS" ]]; then
    echo "Credentials file $PATH_TO_CREDS does not exist. Exiting"
    exit 4
fi

# show the current timestamp for future reference
echo "Current runtime: $(date)"

# look up who the authorative WHOIS server to get the full details, limit to one result in case more than one is returned
# OS X version of cut doesn't work with --delimiter, must use -d instead
WHOIS_SERVER=$(whois "$DOMAIN_PREFIX" | grep "Registrar WHOIS Server" | head -n1 | cut -d ":" -f2 | xargs)

# do a targeted whois on the authorative server, display the status of that domain to get current info
whois "$DOMAIN_PREFIX" --host "$WHOIS_SERVER" | grep -e "Domain Status\|Registry Expiry Date"
#whois "$DOMAIN_PREFIX" --host "$WHOIS_SERVER" | grep -e "Domain Status" | awk '{$1=$1;print}' | cut -d " " -f1-3 | sort --unique

# authenticate with a single endpoint to grab a token for future API calls
AUTH_RESPONSE=$(curl -s -X POST "https://api.dropcatch.com/Authorize" \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json" \
    -d "@${PATH_TO_CREDS}")  # @ symbol is required

if [[ "$AUTH_RESPONSE" == "\"An error occured trying to process this request\"" ]]; then
    echo "DropCatch API failed. Exiting."
    exit 2
fi

# extract the token from the initial auth
TOKEN=$(echo "$AUTH_RESPONSE" |  jq --raw-output '.token')

# search for auctions, display results in pretty JSON to make easier to read
curl -s -X GET "https://api.dropcatch.com/v2/auctions?searchTerm=$DOMAIN_PREFIX&size=10&showAllActive=true" \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json" \
    -H  "Authorization: Bearer $TOKEN" \
    | jq

sleep 5s

# search for backorders too
curl -s -X GET "https://api.dropcatch.com/v2/backorders?searchTerm=$DOMAIN_PREFIX&size=10&showAllActive=true" \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json" \
    -H  "Authorization: Bearer $TOKEN" \
    | jq
