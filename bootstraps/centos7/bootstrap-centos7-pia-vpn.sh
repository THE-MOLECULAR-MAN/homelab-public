#!/bin/bash
# Tim H 2021
#   Script to install and configure Private Internet Access via OpenVPN on CentOS 7
#   This also requires the example config file that will connect you to
#   TODO: configure kill switch so that ALL internet facing traffic must go through VPN.
#
#   References:
#       https://phoenixnap.com/kb/openvpn-centos
#       https://www.linode.com/docs/guides/vpn-firewall-killswitch-for-linux-and-macos-clients/
#       https://security.stackexchange.com/questions/183177/openvpn-kill-switch-on-linux
#       https://unix.stackexchange.com/questions/396218/block-wan-access-allow-lan-access-linux-hosts
#
#   !NON-EXECUTABLE!    not ready to run automatically yet, still requires rebooting and vim editing

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# bomb out in case of any errors
set -e

# pull latest repos
yum update -y

# install EPEL to get access to OpenVPN package and then update the repo list:
yum install epel-release -y
yum update -y

# install OpenVPN
yum install -y openvpn

# Antiquated stuff, don't need with CentOS 7
#mkdir $HOME/Downloads/
#cd $HOME/Downloads
#wget https://github.com/OpenVPN/easy-rsa/archive/v3.0.8.tar.gz
#tar -xf v3.0.8.tar.gz
#cd /etc/openvpn/
#mkdir /etc/openvpn/easy-rsa
#mv $HOME/Downloads/easy-rsa-3.0.8 /etc/openvpn/easy-rsa
#ls -lah /etc/openvpn/easy-rsa
#find /usr/share/doc/openvpn* -type f -name server.conf -exec cp {} /etc/openvpn/ \;

# downloaded while authenticated to PIA VPN, make sure to get the IP not the DNS version if using kill switch
cp "$HOME/mexico-aes-256-cbc-udp-ip.ovpn" /etc/openvpn/server.conf

# Start the openvpn service, it will ask you to manually enter your username and password via the keyboard.
# This is a test to make sure you have the right username/password.
# username starts with a "p" and then a bunch of numbers for Private Internet Access customers
systemctl -f start openvpn@server.service

# troubleshooting if necessary:
systemctl status -l openvpn@server.service
journalctl -xe

# Wait a moment after connecting for it to finish initializing
sleep 10

# Get the connection status
systemctl status openvpn@server.service

# list your new public IP
curl ifconfig.co

# store your working username and password in a text file that will be used.
# The first line is your username
# The second line is your password.
echo "p123456
password_here" > /etc/openvpn/private-internet-access-creds.txt

# Mark the file as read-only for the current user, protect it from snoops
# I know this is a bad idea, but this is the only way to have it autostart with PIA.
chmod 400 /etc/openvpn/private-internet-access-creds.txt

#systemctl stop openvpn@server.service

# Required: edit /etc/openvpn/server.conf and comment out the auth-user-pass line

# working manually
openvpn --auth-user-pass /etc/openvpn/private-internet-access-creds.txt --config /etc/openvpn/server.conf

# Edit this service definition to look like the above command
vim /usr/lib/systemd/system/openvpn@.service
## Original:
#ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf
## New one:
#ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/  --auth-user-pass /etc/openvpn/private-internet-access-creds.txt --config %i.conf

# enable the VPN to autostart on boot
systemctl enable openvpn@server.service

# testing 
reboot
# success!

# take a VM snapshot now

############### enabling the VPN kill switch    ##############################
# TODO: convert to firewalld commmands instead of iptables.
# groupadd -r openvpn

# Killswitch - must do from a VM console, NOT an SSH session since this will kill network access during setup.

# test internet connectivity before making changes:
sudo systemctl status openvpn@server.service
ifconfig tun0
route
ping -c 3 8.8.8.8
nslookup serverfault.com
curl ifconfig.co
curl https://captive.apple.com/

# install IPtables
sudo yum install -y iptables-services
sudo systemctl enable iptables
sudo systemctl enable ip6tables
sudo systemctl restart iptables

# backup the firewall rules before changing them
#iptables save > "$HOME/iptables-backup.ipv4"


sudo iptables --list-rules | sudo tee "$HOME/iptables-backup.ipv4"

#firewall-cmd

cat <<EOF > "$HOME/change-firewall.sh"
#!/bin/bash
LAN_NETWORK="10.0.1.0/24"
VPN_ENDPOINT_IP="77.81.142.104" # more or less static IP for Private Interenet Access service
NIC_ADAPTER_NAME="ens192"   # not the VPN adapter like tun0
VPN_ADAPTER_NAME="tun0"

# set firewall rules
sudo iptables --flush
sudo iptables --delete-chain
sudo iptables -t nat --flush
sudo iptables -t nat --delete-chain
sudo iptables -P OUTPUT DROP
sudo iptables -A INPUT -j ACCEPT -i lo
sudo iptables -A OUTPUT -j ACCEPT -o lo
sudo iptables -A INPUT --src $LAN_NETWORK -j ACCEPT -i $NIC_ADAPTER_NAME
sudo iptables -A OUTPUT -d $LAN_NETWORK -j ACCEPT -o $NIC_ADAPTER_NAME
sudo iptables -A OUTPUT -j ACCEPT -d $VPN_ENDPOINT_IP -o $NIC_ADAPTER_NAME -p udp -m udp --dport 1194
sudo iptables -A INPUT -j ACCEPT -s $VPN_ENDPOINT_IP -i $NIC_ADAPTER_NAME -p udp -m udp --sport 1194
sudo iptables -A INPUT -j ACCEPT -i $VPN_ADAPTER_NAME
sudo iptables -A OUTPUT -j ACCEPT -o $VPN_ADAPTER_NAME

# custom added: allows incoming and outgoing LAN traffic:
iptables -A OUTPUT -d 10.0.1.0/24 -j ACCEPT
iptables -A INPUT  -d 10.0.1.0/24 -j ACCEPT

sudo service iptables save
sudo iptables --list-rules > "$HOME/iptables-new.ipv4"

EOF

chmod u+x change-firewall.sh
# gotta do this in a screen session:
screen
./change-firewall.sh
reboot now


# test if the killswitch works by stopping the VPN service:
# verify working first:
sudo systemctl status openvpn@server.service
ifconfig -a
ifconfig tun0
route
ping -c 3 8.8.8.8
nslookup serverfault.com
curl ifconfig.co
curl https://captive.apple.com/




sudo systemctl stop openvpn@server.service
