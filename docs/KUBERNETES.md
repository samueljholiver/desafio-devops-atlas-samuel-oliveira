# Kubernetes Documentation

This document details the Kubernetes orchestration and deployment strategy for the `orders-api`.

## 🏗️ Architecture

The deployment follows a **Kustomize**-based structure to handle environment-specific configurations while sharing a common base.

### 📁 Directory Structure
- `.k8s/base/`: Contains the core manifests (Deployment, Service, HPA, etc.).
- `.k8s/dev/`: Development environment overlays.
- `.k8s/prod/`: Production environment overlays (includes PDB).

## 📄 Manifest Details

### 1. Deployment (`deployment.yaml`)
- **Replicas:** Defaults to 2 for high availability.
- **Strategy:** RollingUpdate.
- **Containers:** Runs the `orders-api` image on port 8080.
- **Health Probes:**
  - `livenessProbe`: Restarts the container if the app becomes unresponsive.
  - `readinessProbe`: Ensures the app is ready to receive traffic before joining the LoadBalancer.
  - `startupProbe`: Handles slow start times without triggering premature restarts.
- **Resources:**
  - Requests: `100m CPU / 128Mi Memory`.
  - Limits: `500m CPU / 256Mi Memory`.

### 2. Networking
- **Service (`service.yaml`):** Exposes the deployment internally via ClusterIP.
- **Ingress (`ingress.yaml`):** Provides external access via NGINX Ingress Controller. Configured for SSL redirection and path-based routing.

### 3. Scalability
- **HPA (`hpa.yaml`):** Automatically scales pods between 2 and 5 replicas based on CPU (70%) and Memory (80%) utilization.
- **PDB (`pdb.yaml`):** (Prod only) Ensures a minimum availability of 1 pod during voluntary disruptions (e.g., node maintenance).

### 4. Configuration & Secrets
- **ConfigMap:** Stores non-sensitive application settings.
- **Secret:** Stores connection strings and keys. 
  - *Recommendation:* Transition to Azure Key Vault CSI Driver for production.

## 🚀 Deployment Workflow

The deployment is managed via the Azure DevOps Pipeline:

1.  **Tagging:** The image tag in `kustomization.yaml` is dynamically updated using the `kustomize edit set image` command during the pipeline.
2.  **Application:** `kustomize build . | kubectl apply -f -` is used to merge the base with the environment overlay and apply it to the cluster.

## 🔍 Verification
After deployment, verify the state using:
```bash
kubectl get pods -n orders-prod
kubectl get hpa -n orders-prod
kubectl get ingress -n orders-prod
```
