#!/bin/bash
# Tim H 2022
# This is known to be working as of 3/28/22
# https://www.bitdefender.com/business/support/en/77209-125280-getting-started.html#UUID-e6befdd4-3eb1-4b6e-cc6c-19bdd16847b4_section-idm4640170076361632655245645786
# https://www.bitdefender.com/business/support/en/77209-141188-api-usage-examples.html

# Test BitDefender API
# set the API key gathered from GUI
API_KEY="REDACTED"

# generate the value for the header, encoded in base64
API_KEY_BASIC_AUTH=$(echo -n "$API_KEY:" | base64 )

# define a single API endpoint, just aa basic GET licensing one
apiEndpoint_Url="https://cloud.gravityzone.bitdefender.com/api/v1.0/jsonrpc/licensing"

# define a function that gets license information, prove it works
generate_post_data_body()
{
  cat <<EOF
{
    "id": "does-not-matter",
    "jsonrpc": "2.0", 
    "method": "getLicenseInfo", 
    "params": 
    {
          "returnAllProducts": true
    }
}
EOF
}

# make an API call that ties it all together
curl -i \
    -H "Authorization: Basic $API_KEY_BASIC_AUTH" \
    -H "Content-Type: application/json" \
    --data "$(generate_post_data_body)" \
    -X POST "$apiEndpoint_Url"
