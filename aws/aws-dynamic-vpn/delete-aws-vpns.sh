#!/bin/bash
# Tim H 2019

# deletes all running stacks that these other scripts create
STACKS_RUNNING_LIST=$(aws cloudformation describe-stacks --output text | grep CREATE_COMPLETE | grep "pptp-vpn-" | cut -d$'\t' -f6)

for STACK_NAME_TO_TERMINATE in $STACKS_RUNNING_LIST
do
	echo "Deleting stack $STACK_NAME_TO_TERMINATE"
	aws cloudformation delete-stack --stack-name "$STACK_NAME_TO_TERMINATE"
done
