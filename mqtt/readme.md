# MQTT (Mosquitto) Helm Deployment

This directory contains resources and instructions for deploying an MQTT broker (Eclipse Mosquitto) on Kubernetes using Helm.

## Prerequisites

- Kubernetes cluster (v1.19+)
- [Helm](https://helm.sh/) installed
- Storage class configured (update `values.yaml` with your storage class name)

## Quick Start

1. **Install Mosquitto MQTT Broker**

   ```bash
   # Run the installation script
   ./install.sh
   ```

   Or manually:

   ```bash
   # Add the Helm repository
   helm repo add eclipse-mosquitto https://k8s-at-home.com/charts/
   helm repo update

   # Install Mosquitto
   helm install mosquitto eclipse-mosquitto/mosquitto -f values.yaml -n mqtt --create-namespace
   ```

2. **Verify Installation**

   ```bash
   kubectl get pods -n mqtt
   kubectl get services -n mqtt
   ```

## Configuration

The `values.yaml` file contains the following key configurations:

- **Image**: Eclipse Mosquitto 2.0.18
- **Service**: NodePort on port 1883
- **Persistence**: 1Gi storage with ReadWriteOnce access mode
- **Security**: Anonymous access enabled (configure authentication as needed)
- **WebSocket**: Disabled by default (can be enabled for MQTT over WebSockets)

## Usage

### Connect to MQTT Broker

The MQTT broker will be accessible on:

- **Port**: 1883 (NodePort)
- **Protocol**: MQTT
- **Authentication**: Anonymous (configure as needed)

### Test Connection

```bash
# Using mosquitto_pub (install mosquitto-clients package)
mosquitto_pub -h <node-ip> -p 1883 -t "test/topic" -m "Hello MQTT!"

# Using mosquitto_sub
mosquitto_sub -h <node-ip> -p 1883 -t "test/topic"
```

## Customization

Edit `values.yaml` to customize:

- **Storage**: Change storage class and size
- **Service Type**: Switch between ClusterIP, NodePort, or LoadBalancer
- **Authentication**: Configure user/password authentication
- **WebSocket**: Enable MQTT over WebSockets
- **Logging**: Adjust log levels and destinations

## Security Notes

- Default configuration allows anonymous access
- For production, configure proper authentication
- Consider using TLS/SSL for encrypted connections
- Review and adjust security context settings

## Troubleshooting

```bash
# Check pod status
kubectl get pods -n mqtt

# View logs
kubectl logs -n mqtt deployment/mosquitto

# Check service
kubectl get svc -n mqtt

# Describe pod for issues
kubectl describe pod -n mqtt <pod-name>
```

## Uninstall

```bash
helm uninstall mosquitto -n mqtt
kubectl delete namespace mqtt
```
