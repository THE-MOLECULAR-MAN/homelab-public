#!/bin/bash
# Tim H 2021

# Enable DNS caching on CentOS 7
#
# References:
#   Better page for CentOS command line only server: https://www.golinuxcloud.com/configure-dns-caching-server-dnsmasq-centos-7/
#   not great: https://www.getpagespeed.com/server-setup/dns-caching-and-beyond-in-centos-rhel-7-and-8

yum -y install dnsmasq

cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/dns.conf 
[main]
dns=dnsmasq
EOF

# custom configuration, only listen locally (defaults to listening on ALL interfaces, will accept remote connections - BAD)
cat << 'EOF' | sudo tee /etc/dnsmasq.conf 
conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
listen-address=127.0.0.1
cache-size=1000
EOF

systemctl enable dnsmasq.service --now
systemctl start dnsmasq.service
systemctl status dnsmasq.service

#systemctl reload NetworkManager        # this doesn't work in CentOS 7 minimal server with no GUI like Gnome
systemctl restart network.service       # this works? not sure

# install dependencies for testing with nslookup
yum -y install bind-utils tcpdump

# required:
reboot now

# tail the TCP connections to port 53
tcpdump -i lo port 53       # listen only on loopback, otherwise it will list traffic outbound to the remote DNS server

# do it twice and verify the result came from localhost/127.0.0.1
nslookup google.com
nslookup google.com
