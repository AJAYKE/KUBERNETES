#!/bin/bash

namespace="redis"

if ! command -v helm &> /dev/null; then
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm
fi


helm repo list | grep -q 'bitnami' || helm repo add bitnami https://charts.bitnami.com/bitnami


helm install redis bitnami/redis -f values.yaml -n $namespace

