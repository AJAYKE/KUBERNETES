#!/bin/bash

CHART_VERSION="4.10.1"
namespace='ingress'

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

### nodename is important for bare metal deployments
## since we are using nodeport and not LoadBalancer
## it is important to set the nodeSelector and tolerations
## so that the ingress controller pods can be scheduled on the master node
## this is because the master node is not tainted by default
## and we want the ingress controller to run on the master node

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace $namespace \
  --version "$CHART_VERSION" \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.https=443 \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.config.use-forwarded-headers="true" \
  --set controller.nodeSelector."kubernetes\.io/hostname"=srv09030 \ 
  --set controller.tolerations[0].key="node-role.kubernetes.io/master" \
  --set controller.tolerations[0].operator="Exists" \
  --set controller.tolerations[0].effect="NoSchedule" \
  --set controller.publishService.enabled=false \
  --set controller.admissionWebhooks.enabled=false