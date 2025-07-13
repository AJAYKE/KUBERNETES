# Update NodePort Range

This script modifies the Kubernetes API server to change the default NodePort range from `30000-32767` to `443-32767`.

## What is NodePort Range?

NodePort services in Kubernetes use ports in a specific range (default: 30000-32767). This script expands the range to start from port 443, allowing you to use lower port numbers.

## Why Change the Range?

- **Lower Port Numbers**: Use ports like 443, 80, 8080 instead of 30000+
- **Firewall Rules**: Easier to configure with existing firewall policies
- **Load Balancer Integration**: Better compatibility with external load balancers
- **Standard Ports**: Use common web ports (80, 443, 8080, etc.)

## Usage

```bash
# Run the script with sudo
sudo ./update_node_port_range.sh
```

## What the Script Does

1. **Checks Permissions**: Ensures script runs as root
2. **Backs Up**: Creates backup of kube-apiserver manifest
3. **Modifies**: Adds `--service-node-port-range=443-32767` flag
4. **Restarts**: API server restarts automatically with new configuration

## Verification

```bash
# Check if the flag was added
grep "service-node-port-range" /etc/kubernetes/manifests/kube-apiserver.yaml

# Verify API server is running
kubectl get nodes
```

## Prerequisites

- Root/sudo access
- `yq` tool installed
- Kubernetes cluster with kube-apiserver in static pod mode

## Notes

- The API server will restart automatically after the change
- Backup file is created as `kube-apiserver.yaml.bak`
- New range: 443-32767 (includes standard web ports)
