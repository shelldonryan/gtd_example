#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$ROOT_DIR/tools/run-headless.sh"
CLEANUP="$ROOT_DIR/tools/cleanup-verification-artifacts.mjs"

cleanup() {
  node "$CLEANUP"
}

trap cleanup EXIT
cleanup

"$RUNNER" --capture
"$RUNNER" --hit-test
"$RUNNER" --ladder-test
"$RUNNER" --asset-pipeline-test
