#!/bin/bash
# Tim H 2022

# https://puppet.com/docs/puppet/7/install_agents.html#install_nix_agents

# install puppet agent on Ubuntu 20/18
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb

# my homelab only:
sudo rm -f /etc/apt/sources.list.d/us_archive_ubuntu_com_ubuntu.list

sudo apt-get update

sudo apt-get -y install puppet-agent

# add a symlink to avoid changing the PATH variable
sudo ln -s /opt/puppetlabs/bin/puppet /usr/local/bin/puppet
# bash -l

###############################################################################
# stop and take powered off snapshot here
###############################################################################
# the agent does NOT autostart after install, but it does automatically start
# on the next reboot!

# configure the hostname for the pupper master
# it defaults to "puppet"
# this command does not start the service
sudo puppet config set server 'puppet.int.butters.me' --section main

# start the service, reload the config
sudo puppet resource service puppet ensure=running enable=true
sudo systemctl restart puppet

# test the configuration, connection to the puppet master
sudo puppet agent --test

# go run the cert approval on the server

# run this again to pull cert
sudo puppet agent --test

# everything should work now with no errors



# debugging:
# show agent config:
# sudo /opt/puppetlabs/bin/puppet config print
# stop the service, starts automatically on reboot but not after install
# sudo kill $(cat /var/run/puppetlabs/agent.pid)
