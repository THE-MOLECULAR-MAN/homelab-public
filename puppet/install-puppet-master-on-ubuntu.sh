#!/bin/bash
# Tim H 2022

# Install and configure Puppet Master on Ubuntu 20.04 64bit
# https://computingforgeeks.com/install-puppet-server-and-agent-on-centos-rhel/

# install the repository on UBUNTU 20.04, NOT SAME FOR 18.04
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb

# my homelab only:
sudo rm -f /etc/apt/sources.list.d/us_archive_ubuntu_com_ubuntu.list

sudo apt-get update

# must install AGENT FIRST with Ubuntu 20.04
# i think the agent needs to be installed first, contrary to the documentation
sudo apt-get -y install puppet-agent

# install the puppet server:
sudo apt-get -y install puppetserver 

# reload PATH variable
bash -l

# this seems to still be required for some reason
sudo ln -s /opt/puppetlabs/bin/puppet       /usr/local/bin/puppet
sudo ln -s /opt/puppetlabs/bin/puppetserver /usr/local/bin/puppetserver

# start the server service, set to autostart
sudo systemctl start  puppetserver
sudo systemctl enable puppetserver

# validate install and path variable:
puppetserver -v

# make sure post-install directories exist:
ls -lah /opt/puppetlabs /etc/profile.d/puppet-agent.sh /etc/puppetlabs/code/environments/production/manifests/

# check for listening ports if service is running:
sudo netstat -anpl | grep 8140

cd /etc/puppetlabs/code/environments/production/manifests/ || exit 2
sudo bash -c "cat > hellopuppet.pp" <<EOF
class file_creator {
  # Now create media.txt under /opt/sysops
  file { '/opt/sysops/media.txt':
    ensure => 'present',
  }
}
 node 'stapp01.stratos.xfusioncorp.com' {
  include file_creator
}
EOF

sudo bash -c "cat > init.pp" <<EOF
class basicwebserver {
  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure  => true,
    enable  => true,
    require => Package['apache2'],
  }
}
EOF

sudo bash -c "cat > site.pp" <<EOF
node 'puppet-node1.int.butters.me' {
   include basicwebserver
}
EOF

# change perms on new files
sudo chmod ugo+rx /etc/puppetlabs/code/environments/production/manifests/*.pp

# check the syntax 
sudo puppet parser validate --verbose *.pp
# output is blank, everything is fine.


###############################################################################
# stop and take powered off snapshot here
###############################################################################

# can only do this after the first time the service starts
sudo puppet config set dns_alt_names 'puppet,puppet.int.butters.me,puppet-master,puppet-master.int.butters.me' --section main
sudo puppet config set certname      'puppet.int.butters.me' --section main
sudo puppet config set server        'puppet.int.butters.me' --section main

# Install Puppet Dev Kit for Ubuntu 20
# https://puppet-vscode.github.io/docs/getting-started/#prerequisites
# curl -JLO 'https://pm.puppet.com/cgi-bin/pdk_download.cgi?dist=ubuntu&rel=20.04&arch=amd64&ver=latest'
# sudo dpkg -i pdk_2.5.0.0-1focal_amd64.deb

# install the agent on the node

# should see the agent listed
sudo puppetserver ca list

# sign the agent's cert
sudo puppetserver ca sign --certname puppet-node1.int.butters.me

# test open ports on newly configured asset, should have TCP 80 open
# nmap -Pn -p22,80,443,8140 puppet-node1.int.butters.me puppet.int.butters.me
