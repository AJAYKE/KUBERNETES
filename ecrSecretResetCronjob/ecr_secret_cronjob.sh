#!/bin/bash

#reference: https://github.com/nabsul/k8s-ecr-login-renew/blob/main/README.md

namespace='ecr-secret-reset-cronjob' #namespace should match  the pods deployment ns as we are going to create secret there
helm repo add nabsul https://nabsul.github.io/helm

helm repo update

helm install k8s-ecr-login-renew nabsul/k8s-ecr-login-renew \
  --set awsRegion=ap-south-1 \
  --set awsAccessKeyId= \
  --set awsSecretAccessKey= \
  --set dockerSecretName=ecrscr-credentials \
  --set dockerRepositories=https://your-ecr-url.dkr.ecr.ap-south-1.amazonaws.com \
  --set targetNamespace=$namespace

#verify installation
kubectl get cronjob

#To immediately create a cronjob manually

kubectl create job --from=cronjob/k8s-ecr-login-renew-cron k8s-ecr-login-renew-cron-manual-1
