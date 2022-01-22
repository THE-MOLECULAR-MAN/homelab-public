#!/bin/bash
# Tim H 2021
# Testing SMTP container connection to gmail
#
#   References
#       * https://netcorecloud.com/tutorials/smtp-connection-from-command-line/
#       * https://mailtrap.io/blog/test-smtp-relay/
#       * container used: #https://registry.hub.docker.com/r/tecnativa/postfix-relay/

# define variables for test
SMTP_OPEN_RELAY_HOSTNAME="10.0.1.35"
SMTP_OPEN_RELAY_PORT="25"
FROM_EMAIL="REDACTED@gmail.com"
TO_EMAIL="REDACTED@gmail.com"

#  !NON-EXECUTABLE!
echo "this script should not be run directly. It is either notes or in progress. Exiting"
exit 1

# check to see if the port is open first
nmap -Pn -p$SMTP_OPEN_RELAY_PORT "$SMTP_OPEN_RELAY_HOSTNAME"

# manually connect to it, see if protocol is presented
telnet "$SMTP_OPEN_RELAY_HOSTNAME" "$SMTP_OPEN_RELAY_PORT"

# view SSL info, test SMTP connection
openssl s_client -connect "$SMTP_OPEN_RELAY_HOSTNAME:$SMTP_OPEN_RELAY_PORT" -starttls smtp 

# install a dependency
sudo yum install -y swaks

# send a test email with unique identifiers for each test
# works, validated on CenOS 7 9/14/2021 on the tecnativa/postfix-relay container
swaks --to "$TO_EMAIL" --from="$FROM_EMAIL" --header "Subject: Swaks CLI test email: $(date) from $(hostname)" --server "$SMTP_OPEN_RELAY_HOSTNAME"
