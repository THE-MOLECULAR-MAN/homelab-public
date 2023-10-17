#!/bin/bash
# Tim H 2022

##############################################################################
#   STEP 2 - IF VELOCIRAPTOR SERVER IS GOING TO BE HOSTED ON UBUNTU
#   INSTALLING THE VELOCIRAPTOR SERVER VIA DEB PACKAGE IN UBUNTU LINUX
##############################################################################

# def create the 1 GB safety file since disk may fill up
# a bunch of the documentation talks about how the server could fill up the
# disk space
fallocate -l 1G space_saver_safe_to_delete

# this is slow:
# installs it and starts the process, creates an autostarting process on next
# reboot too
sudo dpkg -i velociraptor*server*.deb

# check to see if the service is running
service velociraptor_server status

# turn off the firewall:
#sudo service ufw stop

# show the files and permissions:
tree -apu /opt/velociraptor

# test the env path, verify it can run
# needs to be sudo to read the config file
sudo velociraptor version

# check for listening ports:
# needs to be sudo or run as root user:
sudo ss -antpl | grep velociraptor

# open the firewall:
# firewall is disabled by default on Ubuntu 20.04 EC2 instances
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04
# sudo /bin/systemctl start firewalld.service
# sudo firewall-cmd --zone=public --add-port=8889/tcp --permanent
# sudo firewall-cmd --zone=public --add-port=8000/tcp --permanent
# sudo firewall-cmd --zone=public --add-port=8001/tcp --permanent
# sudo firewall-cmd --zone=public --add-port=8003/tcp --permanent
# sudo firewall-cmd --reload

# test the HTTP server
# curl command must use FQDN, not just localhost:
curl --insecure -v -u "admin:admin" "https://$(hostname):8889/app/index.html"

# generate the client config file:
sudo /usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml \
    config client | sudo tee /etc/velociraptor/client.config.yaml
sudo chmod +r /etc/velociraptor/client.config.yaml

# get that file back onto your laptop, you'll need it for anywhere
# you want to install the agent

# now visit this page in a web browser, replacing the host with your hostname
# https://velociraptor.local:8889/app/index.html?#/search/all
