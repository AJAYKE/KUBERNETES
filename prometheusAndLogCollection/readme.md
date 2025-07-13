# Prometheus Stack Deployment

This directory contains resources for deploying a complete monitoring stack on Kubernetes using Helm, including Prometheus, Grafana, AlertManager, and Loki for log aggregation.

## Prerequisites

- Kubernetes cluster (v1.19+)
- [Helm](https://helm.sh/) installed
- Storage class configured for persistent volumes

## Quick Start

1. **Deploy the Monitoring Stack**

   ```bash
   # Run the installation script
   ./prometheus_stack.sh
   ```

   This will install:

   - **Prometheus** - Metrics collection and storage
   - **Grafana** - Visualization and dashboards
   - **AlertManager** - Alert routing and notification
   - **Loki** - Log aggregation (with Promtail)

2. **Verify Installation**

   ```bash
   kubectl get pods -n monitoring
   kubectl get services -n monitoring
   ```

## Accessing the Dashboards

### Grafana Dashboard

```bash
# Port forward to access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: Get it with:
  ```bash
  kubectl -n monitoring get secret prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
  ```

### Prometheus Dashboard

```bash
# Port forward to access Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

- **URL**: http://localhost:9090

### AlertManager

```bash
# Port forward to access AlertManager
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

- **URL**: http://localhost:9093

## Configuration

The `values.yaml` file configures:

- **Prometheus**: 10Gi storage, 10-day retention
- **AlertManager**: 2Gi storage
- **Services**: All set to ClusterIP (use port-forwarding for access)
- **Grafana**: Default configuration with persistent storage

## Components

- **Prometheus**: Collects and stores metrics from Kubernetes and applications
- **Grafana**: Provides dashboards and visualization for metrics and logs
- **AlertManager**: Handles alert routing and notifications
- **Loki**: Log aggregation system with 7-day retention
- **Promtail**: Log collection agent

## Troubleshooting

```bash
# Check all components
kubectl get pods -n monitoring

# View Prometheus logs
kubectl logs -n monitoring deployment/prometheus-kube-prometheus-prometheus

# View Grafana logs
kubectl logs -n monitoring deployment/prometheus-grafana

# Check persistent volumes
kubectl get pvc -n monitoring
```

## Uninstall

```bash
# Remove Loki stack
helm uninstall loki -n monitoring

# Remove Prometheus stack
helm uninstall prometheus -n monitoring

# Delete namespace
kubectl delete namespace monitoring
```
