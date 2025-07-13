## Argo CD Installation and Setup

1. **Install Argo CD**

You can install Argo CD by running the provided `install.sh` script. This will set up Argo CD in your Kubernetes cluster.

2. **Accessing the Argo CD UI (Optional)**

If you want to use the Argo CD web UI, you can port-forward the Argo CD service (which runs on port 80) to your local machine.

3. **Configure GitHub Access**

Create a Kubernetes Secret to provide Argo CD with access to your GitHub repository. This allows Argo CD to pull your application manifests.

4. **Create an Application**

Apply the Application YAML to Argo CD. This will configure Argo CD to monitor your repository and automatically apply changes when values are updated.
