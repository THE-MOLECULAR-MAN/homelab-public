#!/bin/bash
# Tim H 2022
# BitDefender can do webhooks, but they aren't supported in the web app
# you can only create/manage webhooks using the API
# This script creates a trigger that contacts Rapid7's InsightConnect
# via webhook if an event happens
# https://www.bitdefender.com/business/support/en/77209-125280-getting-started.html#UUID-e6befdd4-3eb1-4b6e-cc6c-19bdd16847b4_section-idm4640170076361632655245645786
# https://www.bitdefender.com/business/support/en/77209-141188-api-usage-examples.html

# Test BitDefender API
API_KEY="REDACTED"

API_KEY_BASIC_AUTH=$(echo -n "$API_KEY:" | base64 )

###############################################################################
# PART ONE
#   CREATE A PUSH/TRIGGER IN BITDEFENDER TO TELL IT TO CONTACT 
#   INSIGHTCONNECT VIA WEBHOOK IF *ANY* SORT OF EVENT IS DETECTED
###############################################################################

# API endpoint for pushes
apiEndpoint_Url="https://cloud.gravityzone.bitdefender.com/api/v1.0/jsonrpc/push"

# generates the POST data body info replace the webhook URL
# with whatever yours is
generate_post_data_body_icon()
{
  cat <<EOF
{
    "params": {
        "status": 1,
        "serviceType": "jsonRPC",
        "serviceSettings": {
            "url": "https://us.platform.insight.rapid7.com/1/webhooks/REDACTED",
            "authorization": "basic asdf",
            "requireValidSslCertificate": true
        },
        "subscribeToEventTypes": {
            "modules": true,
            "sva": true,
            "registration": true,
            "supa-update-status": true,
            "av": true,
            "aph": true,
            "fw": true,
            "avc": true,
            "uc": true,
            "dp": true,
            "sva-load": true,
            "task-status": true,
            "exchange-malware": true,
            "network-sandboxing": true,
            "adcloud": true,
            "exchange-user-credentials": true,
            "endpoint-moved-out": true, 
            "endpoint-moved-in": true,
            "troubleshooting-activity": true,
            "uninstall": true,
            "install": true,
            "hwid-change": true,
            "new-incident": true,
            "antiexploit": true,
            "network-monitor": true,
            "ransomware-mitigation": true,
            "security-container-update-available": true
        }
    },
    "jsonrpc": "2.0",
    "method": "setPushEventSettings",
    "id": "does-not-matter"
}
EOF
}

generate_post_data_body_icon > test.json
jsonlint --quiet test.json || echo "JSON WAS NOT VALID"

curl -i \
    -H "Authorization: Basic $API_KEY_BASIC_AUTH" \
    -H "Content-Type: application/json" \
    --data "$(generate_post_data_body_icon)" \
    -X POST "$apiEndpoint_Url"


###############################################################################
# PART TWO
#   CREATE A FAKE INCIDENT TO TEST THE TRIGGER MADE IN PART 1
###############################################################################

# function to create a fake malware incident to trigger webhook
generate_post_data_body2()
{
  cat <<EOF
{
       "params": {
           "eventType": "av",
           "data": {
               "malware_name": "Push test from cURL - not real malware"
           }
       },
       "jsonrpc": "2.0",
       "method": "sendTestPushEvent",
       "id": "ad12cb61-52b3-4209-a87a-93a8530d91cb"
  }  

EOF
}

generate_post_data_body > test2.json
jsonlint --quiet test2.json || echo "JSON WAS NOT VALID"

curl -i \
    -H "Authorization: Basic $API_KEY_BASIC_AUTH" \
    -H "Content-Type: application/json" \
    --data "$(generate_post_data_body2)" \
    -X POST "$apiEndpoint_Url"


###############################################################################
# PART THREE
#   CREATE A PUSH/TRIGGER IN BITDEFENDER TO NOTIFY SLACK OF ANY EVENT
###############################################################################

generate_post_data_body_slack()
{
  cat <<EOF
{
    "params": {
        "status": 1,
        "serviceType": "jsonRPC",
        "serviceSettings": {
            "url": "https://hooks.slack.com/services/REDACTED",
            "authorization": "basic asdf",
            "requireValidSslCertificate": true
        },
        "subscribeToEventTypes": {
            "modules": true,
            "sva": true,
            "registration": true,
            "supa-update-status": true,
            "av": true,
            "aph": true,
            "fw": true,
            "avc": true,
            "uc": true,
            "dp": true,
            "sva-load": true,
            "task-status": true,
            "exchange-malware": true,
            "network-sandboxing": true,
            "adcloud": true,
            "exchange-user-credentials": true,
            "endpoint-moved-out": true, 
            "endpoint-moved-in": true,
            "troubleshooting-activity": true,
            "uninstall": true,
            "install": true,
            "hwid-change": true,
            "new-incident": true,
            "antiexploit": true,
            "network-monitor": true,
            "ransomware-mitigation": true,
            "security-container-update-available": true
        }
    },
    "jsonrpc": "2.0",
    "method": "setPushEventSettings",
    "id": "does-not-matter"
}
EOF
}

generate_post_data_body_slack > test3.json
jsonlint --quiet test.json || echo "JSON WAS NOT VALID"

curl -i \
    -H "Authorization: Basic $API_KEY_BASIC_AUTH" \
    -H "Content-Type: application/json" \
    --data "$(generate_post_data_body_slack)" \
    -X POST "$apiEndpoint_Url"
