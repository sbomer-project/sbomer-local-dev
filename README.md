# SBOMer Local Development Environment

This repository contains the infrastructure code required to run a local instance of the SBOMer system using Minikube, Tekton, and Kueue. It allows you to run the full upstream stack or inject your local code for development.

## Prerequisites

* **Minikube** - Local Kubernetes cluster
* **Kubectl** - Kubernetes command-line tool

---

## 1. Start the Cluster (Infrastructure)

First, initialize the Kubernetes cluster, install Tekton pipelines, Kueue job queuing system, and configure the necessary dummy secrets.

Run the setup script:

```bash
./setup-minikube.sh
```

This sets up the infrastructure to run SBOMer services, however without the actual components.

Based on the components developed, use scripts usually found in the `hack` directory to build and deploy them.

More details and full helm charts can be found in the [SBOMer Platform repository](https://github.com/sbomer-project/sbomer-platform).

---