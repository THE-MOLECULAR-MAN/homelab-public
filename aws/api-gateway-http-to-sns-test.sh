#!/bin/bash
# Tim H 2021
# Testing the Deloyment of this cloud formation template:
# https://jens.dev/2017/09/13/integrate-api-gateway-with-sns-using-cloudformation.html
# was originally doing this for some HTTP post testing with CyberPower UPS software

# Lots of info has been redacted, stored in LastPass

# TODO: load these from from .env file
AWS_REGION="us-east-1"
AWS_ARN="arn:aws:sns:$AWS_REGION:REDACTED:REDACTED"
API_ID="REDACTED"                   # sensitive since no auth
#API_GATEWAY_KEY="REDACTED"         # This cloud formation stack disables the requirement for the API key, not sure how to reenable it after the stack has been deployed

# URL as defined by API gateway in this CloudFormation Stack
BASE_URL="https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/Prod/stats?topic=$AWS_ARN"

curl --location --request POST "$BASE_URL" \
    --header 'Content-Type: text/plain' \
    --data-raw 'Curl test 1'

# Posting to InsightConnect WebHook API
curl -vv -X POST -H "Content-Type: application/json; charset=utf-8" \
    -d '{"notification_description":"test2"}' \
    "https://us.platform.insight.rapid7.com/1/webhooks/REDACTED"
