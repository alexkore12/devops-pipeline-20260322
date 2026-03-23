#!/bin/bash
set -euo pipefail
echo "🔍 Monitoring..."
docker ps --format '{{.Names}}: {{.Status}}'
echo "✅ Done"
