#!/bin/bash
# Tim H 2022

# Installing Ubuntu's MicroK8s on Ubuntu 20.04
# https://microk8s.io/#install-microk8s

# Install it
sudo snap install microk8s --classic

# change perms so current user doesn't need to use sudo with microk8s commands
sudo usermod -a -G microk8s $(whoami)
sudo chown -f -R $(whoami) ~/.kube
newgrp microk8s

# wait for service to start
microk8s status --wait-ready

# install additional roles
microk8s enable dashboard dns registry istio
# microk8s enable --help
microk8s kubectl get all --all-namespaces
microk8s dashboard-proxy
microk8s start

# https://kubernetes2.int.butters.me:10443/#/login

# install the web application /dashboard
microk8s kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

# troubleshooting:
# microk8s kubectl get no       # list all nodes on master
# microk8s leave            # on the worker
# microk8s remove-node --force container-host02.int.butters.me  # on the master
