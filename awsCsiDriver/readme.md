# AWS EBS CSI Driver Setup

This directory contains resources for setting up AWS EBS CSI Driver to enable persistent storage using AWS EBS volumes in Kubernetes.

## What is AWS EBS CSI Driver?

The AWS EBS CSI Driver allows Kubernetes to create, attach, and mount AWS EBS volumes to pods. It's essential for persistent storage in AWS-based Kubernetes clusters.

## The DNS Resolution Problem

### Issue #214 Explained

The AWS EBS CSI Driver sometimes fails to resolve AWS EC2 endpoints due to DNS resolution issues within the cluster. This happens because:

1. **Network Configuration**: Some cluster configurations have DNS resolution problems
2. **AWS Endpoint Resolution**: The driver needs to reach `ec2.ap-south-1.amazonaws.com` to create/manage EBS volumes
3. **Container DNS**: Pods may not resolve AWS endpoints correctly

### Why We Patch the Driver

We patch the CSI driver deployment to add:

- **DNS Policy**: Ensures proper DNS resolution
- **Host Aliases**: Provides a direct IP mapping for AWS endpoints

## Quick Setup

### 1. Run the Installation Script

```bash
./aws_csi_driver.sh
```

This script will:

- Prompt for AWS credentials
- Install the CSI driver
- Apply the DNS patch automatically
- Verify the installation

### 2. Manual Installation (Alternative)

```bash
# Create AWS secret
kubectl create secret generic aws-secret \
  --namespace kube-system \
  --from-literal="key_id=YOUR_ACCESS_KEY" \
  --from-literal="access_key=YOUR_SECRET_KEY"

# Install CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.31"

# Wait for deployment
kubectl wait --for=condition=available deployment/ebs-csi-controller -n kube-system --timeout=120s
```

### 3. Apply DNS Patch (if needed)

```bash
# Check if DNS resolution works
nslookup ec2.ap-south-1.amazonaws.com

# If it fails, apply the patch
kubectl patch deployment ebs-csi-controller -n kube-system --type='merge' -p '{
  "spec": {
    "template": {
      "spec": {
        "dnsPolicy": "ClusterFirst",
        "hostAliases": [
          {
            "ip": "52.95.80.15",
            "hostnames": ["ec2.ap-south-1.amazonaws.com"]
          }
        ]
      }
    }
  }
}'
```

## Storage Class Configuration

### Create Storage Class

Create a file named `storageclass.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.ebs.csi.aws.com/zone
        values:
          - ap-south-1a # Change to your availability zone
```

### Apply Storage Class

```bash
kubectl apply -f storageclass.yaml
```

### Key Configuration Options

- **`type: gp2`**: General Purpose SSD (change to `io1` for high IOPS)
- **`volumeBindingMode: WaitForFirstConsumer`**: Volume created when pod is scheduled
- **`allowedTopologies`**: Restricts volumes to specific availability zones

## Verification

```bash
# Check CSI driver pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver

# Check storage class
kubectl get storageclass ebs-sc

# Test volume creation
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 1Gi
EOF
```

## Troubleshooting

### Common Issues

1. **CSI Driver Pods Not Ready**

   ```bash
   kubectl describe pod -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
   ```

2. **Volume Creation Fails**

   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
   ```

3. **DNS Resolution Issues**
   ```bash
   kubectl exec -n kube-system deployment/ebs-csi-controller -- nslookup ec2.ap-south-1.amazonaws.com
   ```

## Prerequisites

- AWS credentials with EBS permissions
- Kubernetes cluster running on AWS
- `kubectl` configured to access your cluster
