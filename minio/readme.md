# MinIO Tenant Helm Deployment

This directory contains resources and instructions for deploying a MinIO tenant on Kubernetes using Helm.

## Prerequisites

- Kubernetes cluster (v1.19+)
- [Helm](https://helm.sh/) installed

## Quick Start

1. **Install the MinIO Operator**

   ```bash
   helm repo add minio-operator https://operator.min.io
   helm search repo minio-operator
   helm install \
     --namespace minio \
     minio-operator minio-operator/operator
   ```

2. **Download the MinIO Tenant values file**

   ```bash
   curl -sLo values.yaml https://raw.githubusercontent.com/minio/operator/master/helm/tenant/values.yaml
   ```

3. **Edit `values.yaml` as needed**

   - Example configuration is provided in this repo (`values.yaml`).
   - You can set the MinIO access key, secret key, storage size, and other options.

4. **Deploy the MinIO Tenant**

   ```bash
   helm upgrade --namespace minio --values values.yaml minio-tenant minio-operator/tenant
   ```

## Notes

- Default credentials and storage settings are in `values.yaml`.
- For more options, see the [MinIO Helm chart documentation](https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-minio-tenant-helm.html).
