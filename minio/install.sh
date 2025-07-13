
#!/bin/bash

# src:https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-minio-tenant-helm.html
set -euxo pipefail

ns='minio'

helm repo add minio-operator https://operator.min.io
helm search repo minio-operator
helm install \
  --namespace $ns \
  minio-operator minio-operator/operator


curl -sLo values.yaml https://raw.githubusercontent.com/minio/operator/master/helm/tenant/values.yaml


helm upgrade --namespace $ns --values values.yaml minio-tenant minio-operator/tenant
