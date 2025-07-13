#!/bin/bash

helm repo update

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f values.yaml


### USE PORT FORWARDING TO ACCESS PROMETHEUS DASHBOARD

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki-stack -n monitoring \
  --set grafana.enabled=false \
  --set promtail.enabled=true \
  --set loki.persistence.enabled=true \
  # --set loki.persistence.storageClassName=your-storage-class \
  --set loki.persistence.size=10Gi \
  --set loki.config.table_manager.retention_deletes_enabled=true \
  --set loki.image.tag=2.9.3 \
  --set loki.config.table_manager.retention_period=168h  # 7 days
