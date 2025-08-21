#!/usr/bin/env bash
set -euo pipefail
cd worker

export DB_HOST=localhost
export REDIS_HOST=localhost

echo "[+] Restoring & building .NET worker"
dotnet restore
dotnet build

echo "[+] Running worker (Ctrl+C to stop)"
dotnet run
