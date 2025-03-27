#!/bin/bash
set -euxo pipefail

echo "🚀 Deploying infrastructure..."

echo "🌐 Creating default network..."
docker network inspect proxy >/dev/null 2>&1 || docker network create \
  --driver=bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  proxy

echo "⬇️ Pulling latest changes from Git..."
git fetch origin
git checkout production
git reset --hard origin/production

echo "🛠 Recreating containers..."
docker compose pull
docker compose up -d --force-recreate

echo "✅ Deployment completed!"
