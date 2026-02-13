#!/bin/bash
# Tim H 2026
# Create a proxy for Whisper Systems' Signal on Ubuntu 24.04 ARM64 EC2 instance
# This creates the proxy, but doesn't publish it anywhere. It won't be used unless others are notified of it.
#
# https://signal.org/blog/run-a-proxy/
# t4g.nano (ARM64)	us-east-1
# ubuntu/images/hvm-ssd/ubuntu-*-22.04-arm64-server-*

##############################################################################
# On laptop:
##############################################################################
aws ssm get-parameters \
    --names /aws/service/canonical/ubuntu/server/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id \
    --region us-east-1 \
    --query 'Parameters[0].Value' --output text

aws ec2 run-instances \
    --image-id ami-00cdb36f35bd8af7d \
    --count 1 \
    --no-cli-pager \
    --instance-type t4g.nano \
    --region us-east-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Route53FQDN,Value=signal-proxy1},{Key=Name,Value=SignalProxy1}]' \
    --key-name aws-thonker-may-2023 \
    --security-group-ids sg-081ffecd8597f5736 sg-0338d104836ccd813 \
    --subnet-id subnet-0c1fcfd14bc1aa8df

ssh -i ~/.ssh/aws-thonker-may-2023.pem ubuntu@signal-proxy1


##############################################################################
# On the EC2 instance:
##############################################################################
NEWFQDN="signal-proxy1"
NEW_TIMEZONE="America/New_York"

sudo apt-get -qq update
sudo apt-get -qq -y upgrade
sudo apt-get -qq -y install systemd sudo net-tools geoip-bin ca-certificates curl

sudo timedatectl set-timezone "$NEW_TIMEZONE"

sudo hostnamectl set-hostname "$NEWFQDN"
echo "127.0.0.1 localhost $NEWFQDN

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" | sudo tee /etc/hosts

# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Docker
# sudo apt-get -y install docker docker-compose git
cd "$HOME" || exit 1
git clone https://github.com/signalapp/Signal-TLS-Proxy.git
cd Signal-TLS-Proxy || exit 1
sudo ./init-certificate.sh
sudo docker compose up --detach

sudo docker ps
htop

curl "https://signal.tube/#$NEWFQDN"
curl "https://$NEWFQDN"

# list connections:
netstat -tn src :80 or src :443
# geoiplookup 
