#!/bin/bash

set -euxo pipefail

read -p "Enter your AWS Access Key: " AwsAccessKey
export AwsAccessKey
read -p "Enter your AWS Secret Key: " AwsSecertKey
export AwsSecertKey

# Create AWS secret
kubectl create secret generic aws-secret \
  --namespace kube-system \
  --from-literal="key_id=$AwsAccessKey" \
  --from-literal="access_key=$AwsSecertKey"

# Deploy AWS EBS CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.31"

# Wait for the controller pod to be ready
echo "Waiting for ebs-csi-controller pod to be ready..."
kubectl wait --for=condition=available deployment/ebs-csi-controller \
  -n kube-system --timeout=120s

# (Optional) Check pod status
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver

# Check DNS resolution
nslookup ec2.ap-south-1.amazonaws.com || echo "nslookup failed, continuing..."

# Patch the deployment with dnsPolicy and hostAliases
echo "Patching ebs-csi-controller deployment..."
kubectl patch deployment ebs-csi-controller \
  -n kube-system \
  --type='merge' \
  -p '{
    "spec": {
      "template": {
        "spec": {
          "dnsPolicy": "ClusterFirst",
          "hostAliases": [
            {
              "ip": "52.95.80.15",
              "hostnames": [
                "ec2.ap-south-1.amazonaws.com"
              ]
            }
          ]
        }
      }
    }
  }'

echo "✅ Patch applied successfully."
