#!/bin/bash
# Tim H 2020
# Destroy all AWS S3 Glacier vaults recursively
# Warning, this will obliterate all data in AWS Glacier
# designed for OS X, but could be used on Linux if you just change the brew command
#
# References:
#   https://gist.github.com/veuncent/ac21ae8131f24d3971a621fac0d95be5
#   https://forums.aws.amazon.com/thread.jspa?messageID=441390
#   https://docs.aws.amazon.com/amazonglacier/latest/dev/deleting-an-archive-using-cli.html
#   https://docs.aws.amazon.com/cli/latest/reference/glacier/initiate-job.html

AWS_ACCOUNT_ID="-"   # use a '-' for all accounts

# dependencies
brew install jq

# gather the list of glacier vaults
VAULT_LIST=$(aws glacier list-vaults --account-id "$AWS_ACCOUNT_ID" | grep "VaultName" | cut -d \" -f 4)
#VAULT_LIST=$(aws glacier list-vaults --account-id "$AWS_ACCOUNT_ID"  | jq .VaultList[].VaultName)

# Loop through the list of vaults
for vault_name in $VAULT_LIST
do
    # Step 1 - inventory retreival, must trigger Glacier to re-index everything before you can trigger a delete
	JOB_ID=$(aws glacier initiate-job --account-id "$AWS_ACCOUNT_ID" --vault-name "$vault_name" --job-parameters '{"Type": "inventory-retrieval"}' | grep "jobId" | cut -d \" -f 4)
    #JOB_ID=$(aws glacier initiate-job --account-id "$AWS_ACCOUNT_ID" --vault-name "$vault_name" --job-parameters '{"Type": "inventory-retrieval"}' | jq .jobId)
    STATUS="false"

    # wait in a loop while the inventory retrieval is running, can take hours if lots of files
    while [ "$STATUS" = "false" ]
    do
        STATUS=$(aws glacier describe-job --account-id "$AWS_ACCOUNT_ID" --vault-name "$vault_name" --job-id "$JOB_ID"  | jq .Completed)
        echo "vault=$vault_name     STATUS=$STATUS    JOB_ID=$JOB_ID"
        sleep 30
    done

    OUTPUT_FILENAME="$AWS_ACCOUNT_ID.$vault_name.$JOB_ID.output.json"
    # store a JSON list of the archive IDs inside that one vault
    aws glacier get-job-output --vault-name "$vault_name" --account-id "$AWS_ACCOUNT_ID" --job-id "$JOB_ID" "$OUTPUT_FILENAME"
    
    # generate the list of just the Archive IDs, removing other stuff from the JSON
    archive_ids=$(jq .ArchiveList[].ArchiveId < "$OUTPUT_FILENAME")

    # loop through list of archives and trigger a delete on each archive ID inside the vault
    for archive_id in ${archive_ids}; do
        echo "Deleting Archive: ${archive_id}"
        aws glacier delete-archive --archive-id="$archive_id" --vault-name "$vault_name" --account-id "$AWS_ACCOUNT_ID"
    done
done

echo "script finished successfully"
