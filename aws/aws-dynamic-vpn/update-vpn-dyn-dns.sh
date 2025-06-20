#!/bin/bash
# Tim H 2020
# script to call with a cron to update the dyndns for home
# dynamically updates the Route53 record for a hostname based on 
# this script's server's current public IP address
# designed to be used to run from a server at home on a schedule
# so that the home IP address always maps to a user owned domain

apiUrl="redacted.execute-api.us-east-1.amazonaws.com/prod"      # from CloudFormation outputs
apiKey="redacted"                                               # from CloudFormation outputs
hostname_to_set="vpn.redacted.redacted.me." 					# trailing . is required
shared_secret="redacted"                                        # from DynamoDB

# https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#item-explorer?initialTagKey=

# I think this was a third party script from another repo?
./route53-ddns-client.sh 		\
 --hostname "$hostname_to_set"  \
 --secret "$shared_secret"		\
 --api-key "$apiKey"			\
 --url "$apiUrl"				\
 --ip-source public

# wait for the changes to take effect
sleep 10

# test the Route53 DNS updates, you'll need to use the right DNS server for this nameserver
nslookup vpn.redacted.redacted.me ns-xxx.awsdns-xx.net


#MAILTO=root
#0 7 * * * cd /root/dynamic-dns/ && ./update-vpn-dyn-dns.sh
