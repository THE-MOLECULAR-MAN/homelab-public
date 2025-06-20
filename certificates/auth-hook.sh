#!/bin/bash
# shellcheck disable=SC2086,SC2046
# Tim H 2020
# This is used by another script, be very careful modifying it.

aws route53 wait resource-record-sets-changed --id \
    $(aws route53 change-resource-record-sets --hosted-zone-id \
        "$(aws route53 list-hosted-zones-by-name --dns-name $2. \
        --query HostedZones[0].Id --output text)" \
      --query ChangeInfo.Id \
      --output text \
      --change-batch "{ \
        \"Changes\": [{ \
          \"Action\": \"$1\", \
          \"ResourceRecordSet\": { \
            \"Name\": \"_acme-challenge.${CERTBOT_DOMAIN}.\", \
            \"ResourceRecords\": [{\"Value\": \"\\\"${CERTBOT_VALIDATION}\\\"\"}], \
            \"Type\": \"TXT\", \
            \"TTL\": 30 \
          } \
        }] \
      }" \
    )