#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_SKETCH="${SKETCH_SOURCE:-$ROOT_DIR/last_horizon}"
PROCESSING_BIN="${PROCESSING_BIN:-}"
HEADLESS="${HEADLESS:-0}"
TIMEOUT_SECONDS=300
METRICS_MODE=0
MODULE_SET="complete"
METRICS_SCENARIO="command-day1"
PROCESSING_USER_ARGS=()

for argument in "$@"; do
  case "$argument" in
    --module-set=*)
      MODULE_SET="${argument#*=}"
      ;;
    *)
      PROCESSING_USER_ARGS+=("$argument")
      ;;
  esac
done

case "$MODULE_SET" in
  base|capture|manual|complete)
    ;;
  *)
    echo "PROCESSING REGRESSION: FAIL — módulo opcional desconhecido: $MODULE_SET"
    echo "Diagnóstico: use base, capture, manual ou complete. Impacto: nenhuma compilação foi iniciada." >&2
    exit 1
    ;;
esac

report_inconclusive() {
  local reason="$1"
  local impact="$2"
  echo "PROCESSING REGRESSION: INCONCLUSIVO — $reason"
  echo "Diagnóstico: $reason Impacto: $impact" >&2
  exit 2
}

if printf '%s\n' "${PROCESSING_USER_ARGS[@]}" | grep -Fxq -- "--metrics"; then
  TIMEOUT_SECONDS=180
elif printf '%s\n' "${PROCESSING_USER_ARGS[@]}" | grep -Fxq -- "--build"; then
  TIMEOUT_SECONDS=300
elif printf '%s\n' "${PROCESSING_USER_ARGS[@]}" | grep -Fxq -- "--run"; then
  TIMEOUT_SECONDS=60
  for argument in "${PROCESSING_USER_ARGS[@]}"; do
    if [[ "$argument" == "--capture" ]]; then
      TIMEOUT_SECONDS=300
      break
    fi
  done
fi

if printf '%s\n' "${PROCESSING_USER_ARGS[@]}" | grep -Fxq -- "--metrics"; then
  METRICS_MODE=1
fi

require_metrics_metadata() {
  local variable_name="$1"
  local impact="$2"
  if [[ -z "${!variable_name:-}" ]]; then
    report_inconclusive \
      "pré-requisito ausente antes do início: $variable_name" \
      "$impact"
  fi
}

if [[ "$METRICS_MODE" == "1" ]]; then
  require_metrics_metadata "METRICS_VERSION" \
    "a captura não foi iniciada porque a versão da referência não foi identificada"
  require_metrics_metadata "METRICS_PROFILE" \
    "a captura não foi iniciada porque o perfil de hardware não foi identificado"
  require_metrics_metadata "METRICS_ENVIRONMENT" \
    "a captura não foi iniciada porque o ambiente não foi identificado"
  require_metrics_metadata "METRICS_MACHINE" \
    "a captura não foi iniciada porque a máquina não foi identificada"
  require_metrics_metadata "METRICS_GPU" \
    "a captura não foi iniciada porque a GPU não foi identificada"
fi

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
  report_inconclusive \
    "pré-requisito ausente antes do início: Processing 4.5.6 CLI" \
    "nenhum cenário foi iniciado e a execução não pode servir como evidência"
fi

if [[ ! -x "$PROCESSING_BIN" ]]; then
  report_inconclusive \
    "pré-requisito ausente antes do início: PROCESSING_BIN não é executável" \
    "nenhum cenário foi iniciado e a execução não pode servir como evidência"
fi

NEEDS_XVFB=0
if [[ "$HEADLESS" == "1" || -z "${DISPLAY:-}" ]]; then
  NEEDS_XVFB=1
  if ! command -v xvfb-run >/dev/null 2>&1; then
    report_inconclusive \
      "pré-requisito ausente antes do início: xvfb-run" \
      "a captura headless não foi iniciada e nenhuma métrica ou regressão foi validada"
  fi
fi

if ! command -v timeout >/dev/null 2>&1; then
  report_inconclusive \
    "pré-requisito ausente antes do início: timeout" \
    "o limite operacional não pode ser aplicado e a execução não foi iniciada"
fi

if [[ "$METRICS_MODE" == "1" && -z "${METRICS_PROCESSING_VERSION:-}" ]]; then
  PROCESSING_HELP="$("$PROCESSING_BIN" cli --help 2>&1)" || report_inconclusive \
    "pré-requisito ausente antes do início: versão do Processing" \
    "a captura não foi iniciada porque o runtime não informou sua versão"
  PROCESSING_VERSION_LINE="$(printf '%s\n' "$PROCESSING_HELP" | grep -m1 'Command line edition for Processing' || true)"
  METRICS_PROCESSING_VERSION="${PROCESSING_VERSION_LINE#*Processing }"
  METRICS_PROCESSING_VERSION="${METRICS_PROCESSING_VERSION%% *}"
  if [[ -z "$METRICS_PROCESSING_VERSION" || "$METRICS_PROCESSING_VERSION" == "$PROCESSING_VERSION_LINE" ]]; then
    report_inconclusive \
      "pré-requisito ausente antes do início: versão do Processing" \
      "a captura não foi iniciada porque o runtime não informou sua versão"
  fi
  export METRICS_PROCESSING_VERSION
fi

if [[ ! -f "$SOURCE_SKETCH/last_horizon.pde" ]]; then
  report_inconclusive \
    "pré-requisito ausente antes do início: sketch $SOURCE_SKETCH/last_horizon.pde" \
    "nenhum cenário foi iniciado porque a entrada do Processing não existe"
fi

if [[ "$MODULE_SET" == "capture" || "$MODULE_SET" == "complete" ]] \
  && [[ ! -f "$SOURCE_SKETCH/capture.pde" ]]; then
  report_inconclusive \
    "pré-requisito ausente antes do início: capture.pde" \
    "a combinação $MODULE_SET não foi compilada porque o módulo de captura não existe"
fi

if [[ "$MODULE_SET" == "manual" || "$MODULE_SET" == "complete" ]] \
  && [[ ! -f "$SOURCE_SKETCH/test_mode.pde" ]]; then
  report_inconclusive \
    "pré-requisito ausente antes do início: test_mode.pde" \
    "a combinação $MODULE_SET não foi compilada porque o módulo manual não existe"
fi

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/last-horizon-processing.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT

cp -a "$SOURCE_SKETCH" "$TEMP_ROOT/last_horizon"

if [[ "$MODULE_SET" == "base" || "$MODULE_SET" == "capture" ]]; then
  rm -f "$TEMP_ROOT/last_horizon/test_mode.pde"
fi
if [[ "$MODULE_SET" == "base" || "$MODULE_SET" == "manual" ]]; then
  rm -f "$TEMP_ROOT/last_horizon/capture.pde"
fi

if printf '%s\n' "${PROCESSING_USER_ARGS[@]}" | grep -Fxq -- "--asset-pipeline-test"; then
  if ! command -v node >/dev/null 2>&1; then
    report_inconclusive \
      "pré-requisito ausente antes do início: Node.js para a fixture do pipeline" \
      "a fixture não foi preparada e o cenário de pipeline não foi iniciado"
  fi
  mkdir -p "$TEMP_ROOT/last_horizon/data"
  if ! node --input-type=module -e '
    import { readFileSync, writeFileSync } from "node:fs";
    const [sourcePath, targetPath] = process.argv.slice(1);
    const source = readFileSync(sourcePath, "utf8");
    const match = source.match(/const pipelineProbePng = "([^"]+)"/);
    if (!match) throw new Error("Fixture PNG do pipeline não encontrada");
    writeFileSync(targetPath, Buffer.from(match[1], "base64"));
  ' "$ROOT_DIR/tools/regression-windows.mjs" \
    "$TEMP_ROOT/last_horizon/data/pipeline_probe_frame_1.png"; then
    echo "PROCESSING REGRESSION: FAIL — não foi possível preparar a fixture do pipeline"
    echo "Diagnóstico: a fixture PNG não pôde ser preparada. Impacto: o cenário de pipeline não é evidência de PASS." >&2
    exit 1
  fi
fi

PROCESSING_ARGS=(
  cli
  "--sketch=$TEMP_ROOT/last_horizon"
  "--output=$TEMP_ROOT/build"
)

PROCESSING_OPERATION_SET=0
for argument in "${PROCESSING_USER_ARGS[@]}"; do
  case "$argument" in
    --build|--run|--present|--export)
      PROCESSING_OPERATION_SET=1
      ;;
  esac
done
if [[ "$PROCESSING_OPERATION_SET" == "0" ]]; then
  PROCESSING_ARGS+=(--run)
fi

cd "$TEMP_ROOT/last_horizon"

set +e
if [[ "$NEEDS_XVFB" == "1" ]]; then
  timeout --signal=TERM "${TIMEOUT_SECONDS}s" xvfb-run -a -s "-screen 0 1280x720x24" \
    "$PROCESSING_BIN" "${PROCESSING_ARGS[@]}" "${PROCESSING_USER_ARGS[@]}" \
    >"$TEMP_ROOT/processing.stdout" 2>"$TEMP_ROOT/processing.stderr"
  PROCESSING_STATUS=$?
else
  timeout --signal=TERM "${TIMEOUT_SECONDS}s" \
    "$PROCESSING_BIN" "${PROCESSING_ARGS[@]}" "${PROCESSING_USER_ARGS[@]}" \
    >"$TEMP_ROOT/processing.stdout" 2>"$TEMP_ROOT/processing.stderr"
  PROCESSING_STATUS=$?
fi
set -e

if [[ -f "$TEMP_ROOT/processing.stdout" ]]; then
  cat "$TEMP_ROOT/processing.stdout"
fi
if [[ -f "$TEMP_ROOT/processing.stderr" ]]; then
  cat "$TEMP_ROOT/processing.stderr" >&2
fi

if [[ -d "$TEMP_ROOT/last_horizon/output" ]]; then
  mkdir -p "$SOURCE_SKETCH/output"
  cp -a "$TEMP_ROOT/last_horizon/output/." "$SOURCE_SKETCH/output/"
fi

if [[ "$METRICS_MODE" == "1" ]]; then
  METRICS_OUTPUT_DIR="$SOURCE_SKETCH/output/$METRICS_VERSION/$METRICS_PROFILE"
  METRICS_LOG_DIR="$METRICS_OUTPUT_DIR/$METRICS_SCENARIO"
  mkdir -p "$METRICS_LOG_DIR"
  for sample_id in sample-01 sample-02 sample-03; do
    {
      printf 'version=%s\nprofile=%s\nscenario=%s\nsample=%s\nexit_code=%s\n' \
        "$METRICS_VERSION" "$METRICS_PROFILE" "$METRICS_SCENARIO" "$sample_id" "$PROCESSING_STATUS"
      printf '%s\n' "[stdout]"
      cat "$TEMP_ROOT/processing.stdout"
      printf '%s\n' "[stderr]"
      cat "$TEMP_ROOT/processing.stderr"
    } >"$METRICS_LOG_DIR/$sample_id.log"
  done
fi

if [[ "$PROCESSING_STATUS" -ne 0 ]]; then
  if [[ "$PROCESSING_STATUS" -eq 124 || "$PROCESSING_STATUS" -eq 143 ]]; then
    echo "PROCESSING REGRESSION: FAIL — timeout de ${TIMEOUT_SECONDS}s excedido"
    echo "Processing excedeu o timeout de ${TIMEOUT_SECONDS}s." >&2
    exit 124
  fi
  if [[ "$PROCESSING_STATUS" -eq 2 ]]; then
    echo "PROCESSING REGRESSION: INCONCLUSIVO — o Processing não iniciou uma evidência válida"
    echo "Diagnóstico: o Processing encerrou com código 2 antes de produzir uma evidência completa. Impacto: o resultado não é evidência de PASS." >&2
    exit 2
  fi
  echo "PROCESSING REGRESSION: FAIL — Processing terminou com código ${PROCESSING_STATUS}"
  echo "Diagnóstico: a operação foi iniciada e terminou com código ${PROCESSING_STATUS}. Impacto: esta execução não é evidência de PASS." >&2
  exit 1
fi

if grep -Eiq \
  '(^|[^[:alpha:]])FALHOU([^[:alpha:]]|$)|QUEST CHECK: FAIL|CAPTURE CHECK: FAIL|METRICS CHECK: (FAIL|INVESTIGATE)|java\.lang\.[A-Za-z0-9.$]+Exception' \
  "$TEMP_ROOT/processing.stdout" "$TEMP_ROOT/processing.stderr" 2>/dev/null; then
  echo "PROCESSING REGRESSION: FAIL — o harness reportou falha"
  echo "Diagnóstico: o harness reportou falha. Impacto: esta execução não é evidência de PASS." >&2
  exit 1
fi

if [[ "$METRICS_MODE" == "1" ]] \
  && ! grep -Eq 'METRICS CHECK: PASS' "$TEMP_ROOT/processing.stdout" "$TEMP_ROOT/processing.stderr" 2>/dev/null; then
  echo "PROCESSING REGRESSION: FAIL — a captura não confirmou três amostras canônicas"
  echo "Diagnóstico: o Processing terminou sem emitir METRICS CHECK: PASS. Impacto: CSVs ou sidecars incompletos não são evidência de PASS." >&2
  exit 1
fi

echo "PROCESSING REGRESSION: PASS"
