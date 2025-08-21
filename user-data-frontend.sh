#!/bin/bash
set -euxo pipefail

# --- Basics ---
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

# --- Docker install (Ubuntu) ---
install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi
ARCH="$(dpkg --print-architecture)"
. /etc/os-release
echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# --- App env ---
REDIS_HOST="${REDIS_HOST:-10.0.2.20}"
PG_HOST="${PG_HOST:-10.0.3.70}"

# --- Cleanup previous runs (idempotent) ---
docker rm -f vote-app result-app >/dev/null 2>&1 || true

# --- Vote (Flask) on port 80 (container) → host port 80 ---
docker run -d --name vote-app \
  -e REDIS_HOST="$REDIS_HOST" \
  -e REDIS_PORT=6379 \
  -e PORT=80 \
  -p 80:80 \
  docker.io/fmtorres/vote:latest

# --- Result (Node/Express) on container port 8081 → host port 8081 ---
docker run -d --name result-app \
  -e PG_HOST="$PG_HOST" \
  -e PG_PORT=5432 \
  -e PG_USER=postgres \
  -e PG_PASSWORD=postgres \
  -e PORT=8081 \
  -p 8081:8081 \
  docker.io/fmtorres/result:latest

# Optional: basic health wait loop
for i in {1..20}; do
  if curl -fsS http://127.0.0.1/ >/dev/null; then break; fi
  sleep 3
done
