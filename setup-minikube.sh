#!/bin/bash

# Exit immediately if a command fails
set -e

PROFILE="sbomer"

echo "--- Starting Minikube (Profile: sbomer)"
# 'start' will create the cluster if it doesn't exist, or start it if it's stopped.
minikube start -p $PROFILE --addons=ingress --driver=podman

# Ensure kubectl context is set to this cluster
minikube profile $PROFILE

echo "Waiting for Minikube to be ready..."
sleep 15

echo "--- Installing Tekton Pipelines & Dashboard ---"
# Install Pipelines
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
# Install Dashboard
kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/latest/release.yaml

echo "Waiting for Tekton to be ready..."
sleep 20

echo "--- Creating Dependencies (Secret & SA) ---"
# Create 'sbomer-storage-secret'
kubectl create secret generic sbomer-storage-secret \
    --from-literal=api-key="sbomer-secret-key" \
    --dry-run=client -o yaml | kubectl apply -f -

# Create 'sbomer-sa' Service Account
kubectl create sa sbomer-sa \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Waiting for resources to be created..."

sleep 10

bash ./tekton-tasks/apply-syft-taskrun-to-minikube.sh

echo "--- Minikube Setup Done! ---"

echo "Local setup is now complete. Please run ./hack/run-helm-with-local-build.sh from an SBOMer component in order to build and inject it into sbomer-platform and install the system as helm chart for testing.
