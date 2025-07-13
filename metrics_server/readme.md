## METRICS SERVER SETUP

### IN TESTING ENV

#### Verified Absence:

```bash
kubectl get pods -n kube-system | grep metrics-server  # No output
kubectl top nodes  # Failed with "Metrics API not available"
```

#### Installed Metrics Server:

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml
```

Added `--kubelet-insecure-tls` to args in `metrics-server.yaml` Deployment:

```bash
containers:
- args:
  - --cert-dir=/tmp
  - --secure-port=4443
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --kubelet-insecure-tls  # Add this line
  image: registry.k8s.io/metrics-server/metrics-server:v0.7.1
  name: metrics-server
```

```bash
kubectl apply -f metrics-server.yaml
```

#### Verified Installation

```bash
kubectl get pods -n kube-system | grep metrics-server
kubectl get apiservices | grep metrics
kubectl top nodes
```
