#!/bin/bash
# Tim H 2018

# install dependencies
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Using yum-config-manager, add the CentOS-specific Docker repo:
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker:
sudo yum -y install docker-ce

# Enable the Docker Daemon
sudo systemctl enable --now docker

# Configure User Permissions
# Add the new user to the docker group:
sudo usermod -aG docker cloud_user
# Note: You will need to exit the server for the change to take effect.
# logout and then login again

# Run a Test Image
# Using docker, run the hello-world image to verify that the environment is set up properly:
docker run hello-world
docker ps
