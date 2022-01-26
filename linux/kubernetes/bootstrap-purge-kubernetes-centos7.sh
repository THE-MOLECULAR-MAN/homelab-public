#!/bin/bash
# Tim H 2021
# Removing Kubernetes in CentOS 7
# requires multiple reboots

##############################################################################
# PURGING Kubernetes and Docker
##############################################################################

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# uninstall the packages via the package manager
yum remove -y kubelet kubeadm kubectl docker
yum autoremove -y
yum clean all

# manually delete everything related to Kubernetes
sudo rm -Rf /etc/yum.repos.d/kubernetes.repo /etc/kubernetes /etc/sysctl.d/k8s.conf /usr/lib/systemd/system/kubelet.service.d /etc/systemd/system/multi-user.target.wants/kubelet.service  /var/lib/docker /var/lib/yum/repos/x86_64/7/kubernetes /var/lib/kubelet "/var/log/pods/kube-*" /var/cache/yum/x86_64/7/kubernetes /var/cache/yum/x86_64/7/kubernetes /root/.kube /root/kubernetes-monitor.yml "/var/lib/etcd/*" "/home/$USER@int.butters.me/.kube"

# reboot since you can't delete all the files until a reboot
reboot now

exit 0
##############################################################################
# Post reboot
##############################################################################


# delete stuff that couldn't be deleted until a reboot
# the next line's path will be different every time
sudo rm -Rf /var/lib/kubelet /usr/libexec/kubernetes #"/var/tmp/yum-$USER-dr1ETf/x86_64/7/kubernetes"
find /var/tmp/yum-* -type d -name 'kubernetes' -exec sudo rm -Rf {} \;
sudo rm -Rf /etc/sysconfig/docker-storage.rpmsave /etc/docker /var/lib/systemd/timers/stamp-docker-cleanup.timer /var/lib/dockershim

reboot now

##############################################################################
# Post reboot
##############################################################################

# update repo package list in case of restorng a VM snapshot
yum makecache

# tests to make sure everything is gone
yum list installed | grep -i 'docker\|kube'
sudo find /  \( -iname "*kube*" -o -iname "*docker*" \)

# install any outstanding updates before snapshot, save time later.
yum update -y

# shut down and take a snapshot
shutdown -h now
