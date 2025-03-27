#!/bin/bash
set -e

# Ensure the script is run from the root of the project
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

# Ensure the logs directory exists
mkdir -p logs
LOG_FILE="logs/deploy.log"
touch "$LOG_FILE"

# Redirect stdout and stderr to the log file
{
  echo "🚀 Deploying infrastructure..."
  
  # Default network
  echo "🌐 Creating default network..."
  docker network inspect proxy >/dev/null 2>&1 || docker network create \
    --driver=bridge \
    --subnet=172.20.0.0/16 \
    --gateway=172.20.0.1 \
    proxy
  
  echo "⬇️ Pulling latest changes from Git..."
  git pull origin production
  
  echo "🛠 (Re)create and start containers..."
  docker compose pull
  docker compose up -d
  
  echo "✅ Deployment completed!"
} | tee -a "$LOG_FILE"
