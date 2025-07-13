# Redis Deployment Options

This directory contains configurations for deploying Redis on Kubernetes with two deployment options: **Standalone Redis** or **Redis Cluster with Sentinel**.

## Deployment Options

### 1. Standalone Redis

- **Use Case**: Development, testing, or simple applications
- **Features**: Single Redis instance with persistence
- **Configuration**: `values.yaml`

### 2. Redis Cluster with Sentinel

- **Use Case**: Production environments requiring high availability
- **Features**: Master-replica replication with Sentinel for failover
- **Configuration**: `redisClusterWithSentinelValues.yaml`

## Quick Start

### Option 1: Standalone Redis

```bash
# Deploy standalone Redis
helm install redis bitnami/redis -f values.yaml -n redis --create-namespace
```

**Features:**

- Single Redis instance
- 500Mi persistent storage
- NodePort service on port 30079
- 1Gi memory limit
- No authentication (for development)

### Option 2: Redis Cluster with Sentinel

```bash
# Deploy Redis cluster with Sentinel
helm install redis bitnami/redis -f redisClusterWithSentinelValues.yaml -n redis --create-namespace
```

**Features:**

- Master-replica replication (3 replicas)
- Sentinel for automatic failover
- 5Gi persistent storage per instance
- Authentication enabled
- High availability setup

## Configuration Details

### Standalone Configuration (`values.yaml`)

```yaml
architecture: "standalone"
auth:
  enabled: false
  sentinel: false

master:
  persistence:
    enabled: true
    size: "500Mi"
  service:
    type: "NodePort"
    nodePorts:
      redis: "30079"
  resources:
    limits:
      memory: "1Gi"
```

### Cluster Configuration (`redisClusterWithSentinelValues.yaml`)

```yaml
architecture: "replication"
auth:
  enabled: true

replica:
  replicaCount: 3
  persistence:
    enabled: true
    storageClass: "ebs-sc"
    size: 5Gi

sentinel:
  enabled: true
  replicas: 3
```

## Accessing Redis

### Standalone Redis

```bash
# Port forward to access Redis
kubectl port-forward -n redis svc/redis-master 6379:6379

# Connect using redis-cli
redis-cli -h localhost -p 6379
```

### Redis Cluster with Sentinel

```bash
# Port forward to master
kubectl port-forward -n redis svc/redis-master 6379:6379

# Connect with authentication
redis-cli -h localhost -p 6379 -a password
```

## Verification

```bash
# Check Redis pods
kubectl get pods -n redis

# Check Redis services
kubectl get svc -n redis

# Test Redis connection
kubectl exec -it -n redis deployment/redis-master -- redis-cli ping
```

## Customization

### Storage

- **Standalone**: 500Mi (adjust in `values.yaml`)
- **Cluster**: 5Gi per instance (adjust in `redisClusterWithSentinelValues.yaml`)

### Memory

- **Standalone**: 1Gi limit (adjust in `values.yaml`)
- **Cluster**: Default limits (adjust as needed)

### Authentication

- **Standalone**: Disabled by default
- **Cluster**: Enabled with password "password"

## Prerequisites

- Kubernetes cluster
- Helm installed
- Storage class configured (for cluster deployment)
- Bitnami Helm repository added

## Uninstall

```bash
# Remove Redis deployment
helm uninstall redis -n redis

# Delete namespace
kubectl delete namespace redis
```

## Use Cases

### Choose Standalone When:

- Development or testing environment
- Simple application requirements
- Limited resources
- No high availability needed

### Choose Cluster with Sentinel When:

- Production environment
- High availability required
- Automatic failover needed
- Multiple application instances
