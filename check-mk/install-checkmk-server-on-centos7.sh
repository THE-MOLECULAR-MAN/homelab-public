#!/bin/bash
# Tim H 2022
# install checkmk on CentOS 7
#
# References: 
#   https://aventistech.com/kb/checkmk-raw-to-enterprise-free-edition/
#   https://docs.checkmk.com/latest/en/intro_setup_monitor.html#install_agent
#   https://docs.checkmk.com/latest/en/install_packages_redhat.html

# enable extra repositories to allow install dependencies
sudo yum-config-manager --enable rhel-7-server-optional-rpms
sudo yum-config-manager --enable rhel-7-server-extras-rpms

# add HTTP web server to firewall rules
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --reload

# open firewall for agents to dial into console
sudo firewall-cmd --zone=public --add-port=6557/tcp --permanent
sudo firewall-cmd --reload

# download their GPG key
wget https://download.checkmk.com/checkmk/Check_MK-pubkey.gpg
rpm --import Check_MK-pubkey.gpg

# download the installer
wget "https://download.checkmk.com/checkmk/2.0.0p24/check-mk-free-2.0.0p24-el7-38.x86_64.rpm"

# install it from local RPM file
sudo rpm --install ./check-mk-free-2.0.0p24-el7-38.x86_64.rpm

# start the related services
sudo service omd start
sudo service httpd start

# check service and version
omd version
