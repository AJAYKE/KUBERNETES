# ECR Secret Reset Cronjob

Automatically refreshes ECR login tokens to prevent authentication failures.

## Usage

```bash
# Edit script with your AWS credentials
vim ecr_secret_cronjob.sh

# Run installation
./ecr_secret_cronjob.sh
```

## Configuration

Update these values in the script:

- `awsRegion`: Your AWS region
- `awsAccessKeyId`: AWS access key
- `awsSecretAccessKey`: AWS secret key
- `dockerRepositories`: Your ECR repository URL

## Verification

```bash
# Check cronjob
kubectl get cronjob

# Run manually
kubectl create job --from=cronjob/k8s-ecr-login-renew-cron k8s-ecr-login-renew-cron-manual-1
```

## What it does

- Creates a cronjob that runs every 12 hours
- Refreshes ECR login tokens
- Updates the `ecrscr-credentials` secret
- Prevents "unauthorized" errors when pulling images

## Uninstall

```bash
helm uninstall k8s-ecr-login-renew -n ecr-secret-reset-cronjob
```
