#!/usr/bin/env bash

set -Eeuo pipefail

#########################################
# Emby Watch Party Development Builder
# Version 1.0
#########################################

#########################################
# Load development environment
#########################################

if [ ! -f ".env.dev" ]; then
    echo
    echo "ERROR: .env.dev not found."
    echo
    exit 1
fi

set -a
source .env.dev
set +a

#########################################
# Variables
#########################################

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEV_DIR="${PROJECT_DIR}/dev"

#########################################
# Create development folders
#########################################

mkdir -p "${DEV_DIR}"
mkdir -p "${DEV_DIR}/avatars"
mkdir -p "${DEV_DIR}/logs"

#########################################
# Create config.json on first run
#########################################

if [ ! -f "${DEV_DIR}/config.json" ]; then
    echo "{}" > "${DEV_DIR}/config.json"
fi

#########################################
# Header
#########################################

echo
echo "==============================================="
echo "   Emby WatchParty Development Builder"
echo "==============================================="
echo

#########################################
# Git Information
#########################################

echo "Branch : $(git branch --show-current)"
echo "Commit : $(git rev-parse --short HEAD)"
echo

#########################################
# Build Image
#########################################

echo "[1/4] Building Docker image..."
echo

docker build -t "${IMAGE_NAME}" .

echo
echo "Image successfully built."

IMAGE_ID=$(docker image inspect "${IMAGE_NAME}" --format='{{.Id}}')

echo "Image ID:"
echo "${IMAGE_ID}"
echo

#########################################
# Remove previous container
#########################################

echo "[2/4] Recreating development container..."
echo

docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true

#########################################
# Create Development Container
#########################################

docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p "${HOST_PORT}:${WATCH_PARTY_PORT}" \
    -e WATCH_PARTY_BIND="${WATCH_PARTY_BIND}" \
    -e WATCH_PARTY_PORT="${WATCH_PARTY_PORT}" \
    -e APP_PREFIX="${APP_PREFIX}" \
    -e SESSION_EXPIRY="${SESSION_EXPIRY}" \
    -e EMBY_SERVER_URL="${EMBY_SERVER_URL}" \
    -e EMBY_API_KEY="${EMBY_API_KEY}" \
    -v "${DEV_DIR}/config.json:/app/config.json" \
    -v "${DEV_DIR}/avatars:/app/backend/avatars" \
    -v "${DEV_DIR}/logs:/app/logs" \
    "${IMAGE_NAME}"

#########################################
# Verify
#########################################

echo
echo "[3/4] Verifying container..."
echo

docker ps --filter "name=${CONTAINER_NAME}"

CONTAINER_IMAGE_ID=$(docker inspect "${CONTAINER_NAME}" --format='{{.Image}}')

echo
echo "Container Image ID:"
echo "${CONTAINER_IMAGE_ID}"
echo

if [ "${IMAGE_ID}" = "${CONTAINER_IMAGE_ID}" ]; then
    echo "✓ Container is running the latest image."
else
    echo "✗ WARNING: Container is NOT running the latest image!"
fi

#########################################
# Finished
#########################################

echo
echo "[4/4] Development environment ready."
echo
echo "URL:"
echo "http://10.10.0.50:${HOST_PORT}"
echo
echo "Container:"
echo "${CONTAINER_NAME}"
echo
echo "Happy coding!"
echo