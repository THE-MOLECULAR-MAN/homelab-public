#!/bin/bash
# Tim H 2022

# join existing docker host to existing K8 Cluster master node
# this
# https://microk8s.io/docs/clustering

# RUN FROM THE NEW DOCKER HOST THAT WILL JOIN:
# install K8:
# v1.23 has fewer bugs than 1.24: 
#   https://github.com/canonical/microk8s/issues/3225
sudo snap install microk8s --classic --channel=1.23/stable
sudo usermod -a -G microk8s $(whoami)
sudo chown -f -R $(whoami) ~/.kube
newgrp microk8s
microk8s status --wait-ready    # wait for service to start

##############################################################################
# RUN FROM THE MASTER, generates tokens valid for 1 hour
microk8s add-node --token-ttl 3600
##############################################################################

# BACK ON THE NEW ASSET:
# copy and paste the commands that the Master node provided

# Contacting cluster  Connection failed. Invalid token 500

# debugging:
# view logs on master node:
journalctl -u snap.microk8s.daemon-cluster-agent

# checking master node from the worker node:
curl --insecure -0 https://kubernetes2.int.butters.me:25000

