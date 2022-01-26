#!/bin/bash
# Tim H 2020
# set an existing Docker host (VM) running CentOS 7 as a worker node on an existing Kubernetes cluster
# Make sure there is PLENTY of RAM on the container host since swap has to be disabled

# have to add the kubernetes CentOS repository in order to install kubeadm
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# update the repo list
yum makecache -y

# have to disable swap :-( as required by Kubernetes
sed -i '/swap/d' /etc/fstab
swapoff -a

# reboot to finish disabling swap
reboot

# install dependencies, set it to autostart
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet
systemctl start kubelet

# worker node firewall rules
# sudo firewall-cmd --permanent --add-port=10248/tcp # added
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

# set up network bridging so it all works
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# apply those changes
sysctl --system

# clear the settings from previous install or failed attempt
rm -Rf /etc/kubernetes

# join the cluster, may have issues
# [kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get "http://localhost:10248/healthz": dial tcp [::1]:10248: connect: connection refused.
kubeadm join 10.0.1.32:6443 --token REDACTED \
	--discovery-token-ca-cert-hash sha256:REDACTED

# view logs for debugging if needed
docker info | grep -i cgroup
journalctl -xeu kubelet

# view the health page if needed
curl -sSL http://localhost:10248/healthz
