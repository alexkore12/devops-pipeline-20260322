#!/bin/bash
# Setup script - Configure environment

set -euo pipefail

if [ -f .env.example ]; then
    if [ ! -f .env ]; then
        cp .env.example .env
        echo "✅ Environment file created from .env.example"
    fi
fi

echo "✅ Setup complete!"
