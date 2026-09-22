#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$ROOT_DIR/tools/run-headless.sh"
CLEANUP="$ROOT_DIR/tools/cleanup-verification-artifacts.mjs"
REGRESSION_TIMEOUT_SECONDS=300
EVIDENCE_ROOT="$ROOT_DIR/last_horizon/output/regression"
REGRESSION_FAILURE=0
REGRESSION_INCONCLUSIVE=0

cleanup() {
  node "$CLEANUP"
}

trap cleanup EXIT
cleanup
REGRESSION_STARTED_AT=$SECONDS
mkdir -p "$EVIDENCE_ROOT"

check_regression_timeout() {
  if (( SECONDS - REGRESSION_STARTED_AT >= REGRESSION_TIMEOUT_SECONDS )); then
    echo "PROCESSING REGRESSION: FAIL — timeout fixo de 300s excedido."
    echo "Diagnóstico: a regressão foi iniciada e excedeu o timeout fixo de 300s; o resultado não é evidência de PASS." >&2
    exit 124
  fi
}

run_scenario() {
  check_regression_timeout
  local scenario="$1"
  local scenario_name="${scenario#--}"
  local scenario_log="$EVIDENCE_ROOT/${scenario_name}.log"
  local scenario_status=0
  set +e
  "$RUNNER" "$scenario" >"$scenario_log" 2>&1
  scenario_status=$?
  set -e
  cat "$scenario_log"
  check_regression_timeout
  if (( scenario_status == 0 )); then
    echo "SCENARIO $scenario: PASS"
  elif (( scenario_status == 2 )); then
    echo "SCENARIO $scenario: INCONCLUSIVO"
    REGRESSION_INCONCLUSIVE=1
  else
    echo "SCENARIO $scenario: FAIL"
    REGRESSION_FAILURE=1
  fi
}

run_scenario --capture
run_scenario --hit-test
run_scenario --ladder-test
run_scenario --asset-pipeline-test

if (( REGRESSION_FAILURE == 1 )); then
  echo "PROCESSING REGRESSION: FAIL"
  exit 1
fi
if (( REGRESSION_INCONCLUSIVE == 1 )); then
  echo "PROCESSING REGRESSION: INCONCLUSIVO"
  exit 2
fi
echo "PROCESSING REGRESSION: PASS"
