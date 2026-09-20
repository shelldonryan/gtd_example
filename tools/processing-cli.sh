#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_SKETCH="$ROOT_DIR/last_horizon"
PROCESSING_BIN="${PROCESSING_BIN:-}"
HEADLESS="${HEADLESS:-0}"

if [[ -z "${PULSE_SERVER:-}" ]]; then
  for pulse_socket in \
    "${XDG_RUNTIME_DIR:-}/pulse/native" \
    "/tmp/gtd-pulse-runtime/pulse/native"; do
    if [[ -S "$pulse_socket" ]]; then
      export PULSE_SERVER="unix:$pulse_socket"
      break
    fi
  done
fi

if [[ -z "$PROCESSING_BIN" ]]; then
  for candidate in /opt/processing/bin/Processing "$(command -v Processing 2>/dev/null || true)" "$(command -v processing 2>/dev/null || true)"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      PROCESSING_BIN="$candidate"
      break
    fi
  done
fi

if [[ -z "$PROCESSING_BIN" ]]; then
  echo "Processing 4.5.6 CLI não encontrado. Defina PROCESSING_BIN." >&2
  exit 127
fi

if [[ ! -f "$SOURCE_SKETCH/last_horizon.pde" ]]; then
  echo "Sketch ausente: $SOURCE_SKETCH/last_horizon.pde" >&2
  exit 1
fi

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/last-horizon-processing.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT

# O CLI exige que o nome da pasta do sketch coincida com o arquivo PDE.
cp -a "$SOURCE_SKETCH" "$TEMP_ROOT/last_horizon"

PROCESSING_ARGS=(
  cli
  "--sketch=$TEMP_ROOT/last_horizon"
  "--output=$TEMP_ROOT/build"
)

cd "$TEMP_ROOT/last_horizon"

if [[ "$HEADLESS" == "1" || -z "${DISPLAY:-}" ]]; then
  if ! command -v xvfb-run >/dev/null 2>&1; then
    echo "DISPLAY ausente e xvfb-run não está instalado." >&2
    exit 127
  fi
  xvfb-run -a -s "-screen 0 1280x720x24" \
    "$PROCESSING_BIN" "${PROCESSING_ARGS[@]}" "$@"
else
  "$PROCESSING_BIN" "${PROCESSING_ARGS[@]}" "$@"
fi

if [[ -d "$TEMP_ROOT/last_horizon/output" ]]; then
  mkdir -p "$SOURCE_SKETCH/output"
  cp -a "$TEMP_ROOT/last_horizon/output/." "$SOURCE_SKETCH/output/"
fi
