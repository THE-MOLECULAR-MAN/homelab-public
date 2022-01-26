#!/bin/bash
# Tim H 2021

# Test script for Clickatell SMS API

setopt interactivecomments

# API keys may include various characters you want interpreted literally
# shellsheck ignore SC2016
CLICKATELL_API_KEY='REDACTED'   # API key provided by Clickatell
TARGET_PHONE_NUMBER="1555REDACTED"               # US phone numbers must start with 1, ex: "12175551234"
MESSAGE_TO_SEND="Clickatell+API+test+at+$(date)"             # use + not spaces
#MESSAGE_TO_SEND="Clickatell+API+Test4"             # use + not spaces

echo "$MESSAGE_TO_SEND"

##############################################################################
#   "ONE API"
##############################################################################
curl -i \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Authorization: REDACTED" \
    -d '{"messages": [{ "channel": "sms", "to": "1555REDACTED", "content": "ONE API SMS Message Text" }]}' \
    -s https://platform.clickatell.com/v1/message


##############################################################################
#   "HTTP API"
##############################################################################
curl "https://platform.clickatell.com/messages/http/send?apiKey=REDACTED&to=1555REDACTED&content=HTTP+API+Test1"


#https://stackoverflow.com/questions/17029902/using-curl-post-with-variables-defined-in-bash-script-functions
generate_post_data()
{
  cat <<EOF
{
    "messages":[
        {
            "channel":"sms",
            "to":"$TARGET_PHONE_NUMBER",
            "content":"$MESSAGE_TO_SEND"
        }
    ]
}
EOF
}

#https://app.clickatell.com/my-workspace/sms/sms-setup-details/redacted/HTTPAPI
#curl -v "https://platform.clickatell.com/messages/http/send?apiKey=$CLICKATELL_API_KEY&to=$TARGET_PHONE_NUMBER&content=$MESSAGE_TO_SEND"

#https://portal.clickatell.com/#/integrations/omni/edit/redacted
curl -i \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Authorization: $CLICKATELL_API_KEY" \
    --data "$(generate_post_data)" \
    -s https://platform.clickatell.com/v1/message
