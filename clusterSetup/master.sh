#!/bin/bash


sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Install the Tigera Calico operator and custom resource definitions.
#The operator provides lifecycle management for Calico exposed via the Kubernetes API defined as a custom resource definition
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml


#Install Calico by creating the necessary custom resource
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml

sudo apt install awscli # to connect with aws ecr registry

kubeadm token create --print-join-command
