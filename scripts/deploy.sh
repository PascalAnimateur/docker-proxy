#!/bin/bash


# Ensure the script is run from the root of the project
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

# Create logs directory and backup previous log file
mkdir -p logs
LOG_FILE="logs/deploy.log"
if [ -f "$LOG_FILE" ]; then
  LAST_TIMESTAMP=$(date -r "$LOG_FILE" +"%Y-%m-%d_%Hh%M")
  mv "$LOG_FILE" "logs/deploy-$LAST_TIMESTAMP.log"
fi

{
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
} 2>&1 | tee "$LOG_FILE"

# Exit with the same status as the last command
STATUS=${PIPESTATUS[0]}
exit $STATUS
