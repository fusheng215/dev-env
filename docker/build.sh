#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-dev-env-ci:latest}"
cd "$REPO_ROOT"
docker build -f docker/Dockerfile -t "$TAG" .
echo "Built $TAG"
