#!/bin/bash
# Tim H 2020
# set up Kubernetes in CentOS 7
#   https://phoenixnap.com/kb/how-to-install-kubernetes-on-centos
# must be 2 cores minimum

# add repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# install packages
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet
systemctl start kubelet

systemctl stop firewalld
systemctl disable firewalld

#set up firewall rules
#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --reload

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

#sudo sed -i '/swap/d' /etc/fstab
#sudo swapoff -a

yum install -y docker
systemctl enable docker
systemctl start docker


#kubeadm config images pull     #optional
# stop here and take snapshot

# don't change the network in the next line. It is tied to the kube-flannel.yml file below
# do NOT use your LAN CIDR range in the next line. Use a totally separate network.
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

sleep 5m

## Stop here, don't procede as root anymore:

mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
#sudo chown $(id -u):$(id -g) "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# froze the whole server with the above command ^ 

# wait a 5 minutes for everything to initialize? def required after reboot
sleep 5m

kubectl get nodes
# froze the whole server once with the above command ^ 
# I think it is running out of RAM since swap is disabled, make sure it has a TON of RAM; at least 9 GB RAM

kubectl get pods --all-namespaces

kubeadm token list
kubeadm token list REDACTED --print-join-command --ttl=0

#TODO: add other Docker host to this cluster using token

#kubeadm join --discovery-token ... (CUSTOM)
