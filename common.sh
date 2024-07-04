#!/bin/bash

set -euxo pipefail

sudo apt-get update

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# disable swap
swapoff -a

# Apply sysctl params without reboot
sudo sysctl --system

#download kubectl binary with curl on Linux
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

#Download the kubectl checksum file
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

#Validate the kubectl binary against the checksum file
sudo echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

#Install kubectl
sudo sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# to ensure the you installation is up-to-date detailed view of version:
sudo kubectl version --client --output=yaml


sudo apt-get update
sudo apt-get install -y software-properties-common curl

#Define the Kubernetes version and used CRI-O stream
KUBERNETES_VERSION=v1.29 #if it fails change it to v1.30.1
PROJECT_PATH=prerelease:/main

#Add the Kubernetes repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list
#Add the CRI-O repository
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list
    
#Install the packages
sudo apt-get update
sudo apt-get install -y cri-o

sudo systemctl daemon-reload #instructs systemd to re-read all unit files
sudo systemctl enable crio --now
sudo systemctl start crio.service

#Overriding the sandbox (pause) image


#Installing kubeadm, kubelet and kubectl 

sudo apt-get update
# install packages needed to use the Kubernetes apt repository
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

#Download the public signing key for the Kubernetes package repositories
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update the apt package index, install kubelet, kubeadm and kubectl
sudo apt-get update
KUBEADM_VERSION=1.30.1-1.1
sudo apt-get install -y kubelet=$KUBEADM_VERSION kubectl=$KUBEADM_VERSION kubeadm=$KUBEADM_VERSION


# pin their version:
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet


