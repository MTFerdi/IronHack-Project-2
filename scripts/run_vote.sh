#!/usr/bin/env bash
set -euo pipefail
cd vote

export REDIS_HOST=localhost
export PORT=8080

# Create venv only if missing
if [ ! -d "venv" ]; then
  echo "[+] Creating Python venv"
  python3 -m venv venv
fi

echo "[+] Activating venv and installing requirements"
source ./venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "[+] Starting Vote app on http://localhost:8080"
python3 app.py
