CHART_VERSION="4.10.1"
namespace='ingress'

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx


helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace $namespace \
  --version "$CHART_VERSION" \
  --create-namespace \
  --set controller.publishService.enabled=false \
  --set controller.admissionWebhooks.enabled=false