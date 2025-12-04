#!/usr/bin/env bash

# This script builds the schema, then tears down and rebuilds
# the local podman-compose development environment.

set -e

# --- Default Variables ---
PROFILE=sbomer
OVERRIDE_FILE_PATH=""

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -o|--override) OVERRIDE_FILE_PATH="$2"; shift ;;
        -h|--help) 
            echo "Usage: $0 [--override <path/to/my-override.yml>]" 
            exit 0 
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# If an override file is provided, we must get its Absolute Path.
# This is required because we change directories (pushd) later in the script.
if [[ -n "$OVERRIDE_FILE_PATH" ]]; then
    if [[ ! -f "$OVERRIDE_FILE_PATH" ]]; then
        echo "Error: Override file '$OVERRIDE_FILE_PATH' not found."
        exit 1
    fi
    # Get absolute path (works on Linux/macOS)
    ABS_OVERRIDE_PATH=$(cd "$(dirname "$OVERRIDE_FILE_PATH")" && pwd)/$(basename "$OVERRIDE_FILE_PATH")
    echo "--- using override file: $ABS_OVERRIDE_PATH ---"
fi

echo "--- Checking Minikube status (Profile: $PROFILE) ---"

if ! minikube -p "$PROFILE" status > /dev/null 2>&1; then
    echo "Error: Minikube cluster '$PROFILE' is NOT running."
    exit 1
fi

echo "--- Detecting Minikube Network Gateway ---"
MINIKUBE_IP=$(minikube -p $PROFILE ip)
GATEWAY_IP="${MINIKUBE_IP%.*}.1"
export SBOMER_STORAGE_URL="http://${GATEWAY_IP}:8085"
echo "Host Gateway: $GATEWAY_IP"

echo "--- Switching to podman folder ---"
pushd podman-compose > /dev/null

echo "--- Preparing Data Directories ---"
rm -rf kafka-data/
mkdir -p kafka-data
[ ! -d "./kafka-data" ] && mkdir ./kafka-data && podman unshare chown 1001:0 ./kafka-data
[ ! -d "./kafka-config" ] && mkdir ./kafka-config && podman unshare chown 1001:0 ./kafka-config

echo "--- Removing previous podman-compose and Kafka data --"
podman-compose down -v

echo "--- Starting podman-compose ---"

# Build the command dynamically
CMD="podman-compose -f podman-compose.yml"

if [[ -n "$ABS_OVERRIDE_PATH" ]]; then
    CMD="$CMD -f $ABS_OVERRIDE_PATH"
fi

CMD="$CMD up --build --force-recreate"

echo "Executing: $CMD"
eval $CMD

echo "--- Local podman-compose is now running ---"