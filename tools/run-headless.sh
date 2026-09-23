#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HEADLESS=1 exec "$ROOT_DIR/tools/processing-cli.sh" --run "$@"
