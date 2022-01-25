#!/bin/bash
# Tim H 2022

# commonly used functions in this repo
# This script is intended to be sourced by another script
# not run directly

friendlier_date () {
    # Looks like this: 2021-02-26 03:55:09 PM EST
	date +"%Y-%m-%d %I:%M:%S %p %Z"
}

log () {
	# formatted log output including timestamp
	# echo -e "[$THIS_SCRIPT_NAME] $(date)\t $@"
    echo -e "[$THIS_SCRIPT_NAME] $(friendlier_date)\t $*"
}

setup_logging_out_to_file () {
    # Set up logging to external file
    exec >> "$LOGFILE"
    exec 2>&1
}

#https://stackoverflow.com/questions/17029902/using-curl-post-with-variables-defined-in-bash-script-functions
generate_post_data_slack_notification()
{
  cat <<EOF
{
    "notification_description" : "[$THIS_SCRIPT_NAME] $(friendlier_date) $*"
}
EOF
}

# send a message to Slack
send_slack_notification() {
    # uses Rapid7's InsightConnect webhook, not Slack's direct webhook
    friendlier_output=$(generate_post_data_slack_notification $*)
    curl -X POST -H "Content-Type: application/json; charset=utf-8" \
        --data "$friendlier_output" \
        "$SLACK_NOTIFICATION_WEBHOOK_URL"
}
