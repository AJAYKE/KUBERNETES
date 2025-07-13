# Microservices Deployment Helm Chart

This directory contains a Helm chart for deploying multiple microservices on Kubernetes. This is a sample codebase that demonstrates a structured approach to microservices deployment.

## Structure

```
microservicesdeployment/
├── Chart.yaml          # Helm chart metadata
├── values.yaml         # Configuration values
├── templates/          # Kubernetes manifests
│   ├── 01_configmap.yaml
│   ├── 02_secret.yaml
│   ├── 03_pvc.yaml
│   ├── 04_deployment.yaml
│   ├── 05_service.yaml
│   ├── 06_ingress.yaml
│   ├── 07_hpa.yaml
│   ├── 08_websocket_ingress.yaml
│   └── 09_path_ingress.yaml
└── charts/             # Sub-charts (if any)
```

## Quick Start

1. **Update Configuration**

   ```bash
   # Edit values.yaml with your service details
   vim values.yaml
   ```

2. **Deploy Services**

   ```bash
   helm install my-services . -n main --create-namespace
   ```

3. **Upgrade Deployment**
   ```bash
   helm upgrade my-services . -n main
   ```

## Configuration

The `values.yaml` file defines:

- **Services**: Multiple microservices with their configurations
- **Resources**: CPU and memory limits/requests
- **Secrets**: Database, Redis, RabbitMQ credentials
- **ConfigMaps**: Environment-specific configurations
- **Ingress**: Routing and TLS settings
- **HPA**: Horizontal Pod Autoscaling

## Features

- **Multi-service Support**: Deploy multiple services from single chart
- **Resource Management**: CPU/memory limits and requests
- **Auto-scaling**: HPA configuration for each service
- **Ingress Support**: Path-based and WebSocket routing
- **Persistent Storage**: PVC configuration
- **Secret Management**: Centralized secret handling

## Uninstall

```bash
helm uninstall my-services -n main
```

## Notes

- This is a sample structure for reference
- Update image repositories and tags in `values.yaml`
- Configure secrets and configMaps for your environment
- Adjust resource limits based on your requirements
