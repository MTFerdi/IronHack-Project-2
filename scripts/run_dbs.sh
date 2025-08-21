#!/usr/bin/env bash
set -euo pipefail

# Optional: clean up any old containers with the same names
docker rm -f redis db >/dev/null 2>&1 || true

echo "[+] Starting Redis on localhost:6379"
docker run -d --name redis -p 6379:6379 redis:latest

echo "[+] Starting Postgres on localhost:5432 (user=postgres, password=postgres)"
docker run -d --name db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:latest

echo "[+] Checking ports (you may need: sudo apt -y install netcat)"
nc -vz 127.0.0.1 6379 || true
nc -vz 127.0.0.1 5432 || true

echo "[✓] Databases are starting. Use: docker logs -f redis | docker logs -f db"
