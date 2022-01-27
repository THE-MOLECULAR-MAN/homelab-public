#!/bin/bash
# Tim H 2020
# Description:
#   This script will create a new AWS EC2 instance for short term testing.
#   EC2 instances can be easily terminated with the terminate_lab.sh script
#   Servers will be an Amazon Linux 2 web server that deliver a static webpage
#     with details about the server.
#
#	References:
#	  https://stackoverflow.com/questions/9904980/variable-in-bash-script-that-keeps-it-value-from-the-last-time-running
#	  https://marcelog.github.io/articles/aws_get_tags_from_inside_instance_ec2.html
#

##############################################################################
BOOTSTRAP_SCRIPT_FILENAME="file://$1"

#AWS_REGION="us-east-1"
#INSTANCE_TYPE="t2.large"					# size so InsightVM will pick it up (large and above)
#AMI="ami-09d95fab7fff3776c"					# Amazon Linux 2 64bit
#KEYPAIR="aws-marketplace-testing1"			# SSH Keypair to be used

#SECURITY_GROUP="sg-xxxxxxxxxxxxxxxx"		# My default one, only from home and work
#SUBNET_ID="subnet-xxxxxxxxxxxxxxxxx"		# Default VPC, us-east-1a (use1-az4)
#COUNTER_FILE="$HOME/.counter.dat"
#ROUTE_53_DNS_RECORD_TO_USE="redacted.com" # a domain that is registered with AWS ROUTE 53
#ROUTE_53_DNS_SERVER="ns-XXX.awsdns-XX.net"  # FQDN of the AWS Route 53 DNS server used for $ROUTE_53_DNS_RECORD_TO_USE

# if we don't have a file, start at zero
if [ ! -f "$COUNTER_FILE" ] ; then
  AWS_INSTANCE_COUNTER=0
# otherwise read the value from the file
else
  AWS_INSTANCE_COUNTER=$(cat "$COUNTER_FILE")
fi
# increment the value
AWS_INSTANCE_COUNTER=$(( AWS_INSTANCE_COUNTER + 1))
# and save it for next time
echo "${AWS_INSTANCE_COUNTER}" > "$COUNTER_FILE"

INSTANCE_NAME="AutoServer$AWS_INSTANCE_COUNTER"

#	Launching an instance that uses the bootstrap script:
aws ec2 run-instances \
  --region "$AWS_REGION" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --image-id "$AMI" \
  --key-name "$KEYPAIR" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME},{Key=Route53FQDN,Value=$INSTANCE_NAME.$ROUTE_53_DNS_RECORD_TO_USE},{Key=Billing,Value=Rapid7Testing},{Key=GeneratedBy,Value=create_new_ec2_bootstrapped_server}]"  \
  --iam-instance-profile Name=EC2-DescribeAllInstanceTagsOnly  \
  --security-group-ids "$SECURITY_GROUP"  \
  --subnet-id "$SUBNET_ID" \
  --user-data "$BOOTSTRAP_SCRIPT_FILENAME"

echo "$INSTANCE_NAME"

echo "waiting for DNS..."
sleep 50
nslookup "$INSTANCE_NAME.$ROUTE_53_DNS_RECORD_TO_USE" "$ROUTE_53_DNS_SERVER"
