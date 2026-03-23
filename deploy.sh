#!/bin/bash
set -euo pipefail
ENVIRONMENT="${1:-development}"
echo "🚀 Deploying to ${ENVIRONMENT}..."
docker-compose up -d
echo "✅ Done"
