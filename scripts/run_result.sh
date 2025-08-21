#!/usr/bin/env bash
set -euo pipefail
cd result

export PG_HOST=localhost
export PORT=8081

echo "[+] Installing npm dependencies"
npm i

echo "[+] Starting Result app on http://localhost:8081"
node server.js
