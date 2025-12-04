# SBOMer Local Development Environment

This repository contains the infrastructure code required to run a local instance of the SBOMer system using Podman, Minikube, and Tekton. It allows you to run the full upstream stack or inject your local code for development.

## Prerequisites

* **Podman** & **Podman Compose**
* **Minikube**
* **Kubectl**

---

## 1. Start the Cluster (Infrastructure)

First, initialize the Kubernetes cluster, install Tekton pipelines, and configure the necessary dummy secrets.

Run the setup script:

```bash
./setup-minikube.sh
```

> **⚠️ IMPORTANT:**
> This script ends by running a `kubectl proxy` process to expose the cluster on port `8001`.
> **Do not close this terminal.** Leave it running and open a new terminal for the next steps.

---

## 2. Run the Services

Once Minikube is running and the proxy is active, open a **new terminal** to start the application services (Kafka, Schema Registry, SBOMer components).

### Option A: Standalone Run (Upstream Images)
To run the environment using the latest official images from Quay:

```bash
./run-compose.sh
```

### Option B: Local Development (Inject Your Code)
If you are working on a specific component (e.g., `sbom-service`) in a separate repository, you can inject your local build without modifying this repository. (The parts below are already included within each respective component.)

1.  **Create an override file** in your component's repository root (e.g., `../sbom-service/dev.override.yml`).

    ```yaml
    # Example: ../sbom-service/dev.override.yml
    version: '3.8'
    services:
      sbom-service:
        # Use 'build' to trigger a local build from your source code
        build:
          context: .
          dockerfile: ./src/main/docker/Dockerfile.jvm
        environment:
          # Optional: Override env vars for local debugging
          LOG_LEVEL: DEBUG
    ```

2.  **Run the script** passing the override file:

    ```bash
    ./run-compose.sh --override ../sbom-service/dev.override.yml
    ```

This command will merge your local configuration with the main setup, build your container from source, and run it alongside the rest of the SBOMer stack.