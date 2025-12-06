# BotForge Helm Chart

This Helm chart deploys the BotForge application, including the Backend, RAG service, Redis, and PostgreSQL.

## Prerequisites

- Kubernetes cluster (e.g., k3s, minikube, EKS, GKE)
- Helm installed
- Docker images for `botforge-backend` and `botforge-rag` available in your cluster or registry.

## Installation

1.  **Build Images** (if running locally/custom):
    ```bash
    # Example for local k3s/minikube
    docker build -t botforge-backend:latest ../botforge-backend
    docker build -t botforge-rag:latest ../botforge-rag
    # Import to cluster if needed (e.g., k3s)
    k3s ctr images import botforge-backend.tar
    ```

2.  **Configure Secrets**:
    Edit `values.yaml` to set your actual secrets, or pass them via `--set`.
    - `rag.env.OPENAI_API_KEY`
    - `rag.env.UPSTASH_TOKEN`
    - `backend.config.jwtSecret`
    - `backend.config.firebase.apiKey`

3.  **Install Chart**:
    ```bash
    helm install botforge ./botforge-helm --namespace botforge --create-namespace
    ```

## Configuration

The `values.yaml` file contains the default configuration.

### Services
- **Backend**: NodePort 30080 (default). Access at `http://<node-ip>:30080`.
- **RAG**: ClusterIP. Internal communication only.
- **Redis**: ClusterIP. Internal.
- **Postgres**: ClusterIP. Internal.

### Persistence
- **Postgres**: Uses `emptyDir` by default. For production, configure a PVC in `deployment-postgres.yaml`.
- **Redis**: Uses `emptyDir` by default.
- **Uploads**: Uses `emptyDir` by default.

## Environment Variables

The chart is pre-configured with the environment variables provided for the RAG service, including:
- `OPENAI_API_KEY`
- `UPSTASH_URL` / `UPSTASH_TOKEN`
- `POSTGRES_*` (configured to use the internal Postgres)
- `REDIS_*` (configured to use the internal Redis)
