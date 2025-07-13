# NGINX Ingress Controller

Two deployment options for NGINX Ingress Controller on Kubernetes.

## Option 1: Standard Ingress (LoadBalancer)

```bash
./ingress.sh
```

**Use for**: Cloud environments with LoadBalancer support

## Option 2: NodePort Ingress (Bare Metal)

```bash
./nginx_ingress_nodeport.sh
```

**Use for**: Bare metal clusters or environments without LoadBalancer

**Features**:

- NodePort service on port 443
- Scheduled on master node (srv09030)
- External traffic policy: Local
- Admission webhooks disabled

## Verification

```bash
kubectl get pods -n ingress
kubectl get svc -n ingress
```

## Access

- **LoadBalancer**: Use external IP
- **NodePort**: Access via `node-ip:443`

## Uninstall

```bash
helm uninstall ingress-nginx -n ingress
```
