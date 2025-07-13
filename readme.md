# Kubernetes Infrastructure Setup

Complete Kubernetes infrastructure setup with monitoring, storage, messaging, and deployment tools.

## Cluster Setup

- **[Cluster Setup](clusterSetup/)** - AWS cluster initialization and configuration

## Storage & Persistence

- **[AWS CSI Driver](awsCsiDriver/)** - EBS storage for Kubernetes
- **[Longhorn](longhorn/)** - Distributed block storage
- **[MinIO](minio/)** - Object storage solution

## Networking & Load Balancing

- **[MetalLB](metallb/)** - Load balancer for bare metal clusters
- **[NGINX Ingress](nginxIngress/)** - Ingress controller (LoadBalancer/NodePort)
- **[Update NodePort Range](updateNodePortRange/)** - Customize NodePort range

## Monitoring & Observability

- **[Prometheus & Log Collection](prometheusAndLogCollection/)** - Metrics and logging stack
- **[Metrics Server](metrics_server/)** - Kubernetes metrics API

## Messaging & Communication

- **[MQTT](mqtt/)** - Message queuing telemetry transport
- **[RabbitMQ](rabbitmq/)** - Message broker
- **[Kafka](kafka/)** - Distributed streaming platform
- **[Redis](redis/)** - In-memory data store (standalone/cluster)

## Deployment & CI/CD

- **[ArgoCD](argocd/)** - GitOps continuous delivery
- **[Microservices Deployment](microServicesDeployment/)** - Multi-service Helm chart
- **[ECR Secret Reset Cronjob](ecrSecretResetCronjob/)** - Auto-refresh ECR tokens

## Development Tools

- **[Helm](helm/)** - Kubernetes package manager

## Quick Start

1. **Setup Cluster**: Start with [Cluster Setup](clusterSetup/)
2. **Configure Storage**: Install [AWS CSI Driver](awsCsiDriver/) or [Longhorn](longhorn/)
3. **Setup Networking**: Deploy [MetalLB](metallb/) and [NGINX Ingress](nginxIngress/)
4. **Add Monitoring**: Install [Prometheus](prometheusAndLogCollection/) and [Metrics Server](metrics_server/)
5. **Deploy Applications**: Use [Microservices Deployment](microServicesDeployment/) or individual services

## Prerequisites

- Kubernetes cluster
- Helm installed
- kubectl configured
- AWS credentials (for AWS services)
