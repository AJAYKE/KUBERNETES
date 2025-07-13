# MetalLB Setup

MetalLB provides load balancing for bare metal Kubernetes clusters.

## Prerequisites

Enable strict ARP in kube-proxy:

```bash
kubectl edit configmap -n kube-system kube-proxy
# Set strictARP: true
```

## Installation

```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml

# Wait for pods
kubectl -n metallb-system get pods
```

## Configuration

```bash
# Apply IP pool (10.0.0.120-10.0.0.130)
kubectl -n metallb-system apply -f pool-1.yaml

# Apply L2 advertisement
kubectl -n metallb-system apply -f l2advertisement.yaml
```

## Verification

```bash
# Check MetalLB resources
kubectl api-resources | grep metallb

# Check IP pool
kubectl get ipaddresspools -n metallb-system

# Check L2 advertisement
kubectl get l2advertisements -n metallb-system
```

## Usage

Set service type to LoadBalancer:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
```

## Uninstall

```bash
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
```
