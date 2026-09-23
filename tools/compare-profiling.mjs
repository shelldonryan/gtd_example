import { readdir, readFile, writeFile } from "node:fs/promises";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import { join, resolve } from "node:path";

const root = fileURLToPath(new URL("..", import.meta.url));
const REQUIRED_HOTSPOTS = new Map([
  ["rendering", "frame_time_p95_ms"],
  ["image_scaling", "floor_band_builds"],
  ["per_frame_allocations", "allocations_per_frame"],
  ["transition_preview", "cache_invalidations"],
  ["asset_loading_and_cache", "load_time_ms"],
]);
const REQUIRED_PROFILES = ["core-i3-integrated", "reference"];
const REQUIRED_CADENCES = [15, 30, 60];
const REQUIRED_TEMPORAL_METRICS = [
  "callback_time_p95_ms", "simulation_time_p95_ms", "render_time_p95_ms",
  "draw_base_time_p95_ms", "draw_window_time_p95_ms", "audio_dispatch_time_p95_ms",
];
const REQUIRED_SAMPLES = new Set(["sample-01", "sample-02", "sample-03"]);
const REQUIRED_METRIC_FIELDS = [
  "sample_id", "duration_real_s", "frame_count", "frame_time_median_ms",
  "frame_time_p95_ms", "load_time_ms", "additional_memory_bytes", "icon_builds",
  "floor_band_builds", "cache_invalidations", "allocations_per_frame",
];
const COST_FIELDS = REQUIRED_METRIC_FIELDS.slice(3);
const INTEGER_METRIC_FIELDS = new Set([
  "frame_count", "additional_memory_bytes", "icon_builds", "floor_band_builds",
  "cache_invalidations",
]);
const NOMINAL_WINDOW_S = 30;
const DURATION_TOLERANCE_S = 0.5;
const MAX_REGRESSION_PERCENT = 10;
const MAX_ALLOCATION_NOISE_PERCENT = 1;
const MAX_FRAME_TIME_P95_MS = 33.3;
const PROFILING_TIMEOUT_MS = 60_000;
const METRICS_CONTRACT = "code/VERIFICATION.md#contrato-canônico-de-métricas";

class ProfilingError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

function fail(message) {
  return new ProfilingError("FAIL", message);
}

function inconclusive(message) {
  const diagnostic = message.startsWith("pré-requisito ausente")
    ? message : `pré-requisito ausente: ${message}`;
  return new ProfilingError("INCONCLUSIVO", diagnostic);
}

function parseCsv(source) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  for (let index = 0; index < source.length; index += 1) {
    const character = source[index];
    if (character === '"') {
      if (quoted && source[index + 1] === '"') {
        field += '"';
        index += 1;
      } else {
        quoted = !quoted;
      }
    } else if (character === "," && !quoted) {
      row.push(field);
      field = "";
    } else if ((character === "\n" || character === "\r") && !quoted) {
      if (character === "\r" && source[index + 1] === "\n") index += 1;
      row.push(field);
      if (row.some((value) => value.length > 0)) rows.push(row);
      row = [];
      field = "";
    } else {
      field += character;
    }
  }
  if (field.length > 0 || row.length > 0) {
    row.push(field);
    rows.push(row);
  }
  return rows;
}

function assertExactFields(actual, expected, label) {
  if (new Set(actual).size !== actual.length
    || actual.length !== expected.length
    || actual.some((field, index) => field !== expected[index])) {
    throw fail(`${label} deve usar o cabeçalho canônico: ${expected.join(",")}`);
  }
}

function numberField(record, field, label) {
  const value = Number(record[field]);
  if (!Number.isFinite(value)) throw fail(`${label}: valor inválido em ${field}`);
  if (INTEGER_METRIC_FIELDS.has(field) && !Number.isInteger(value)) {
    throw fail(`${label}: valor inteiro inválido em ${field}`);
  }
  if (value < 0) throw fail(`${label}: valor negativo em ${field}`);
  return value;
}

function median(values) {
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[middle - 1] + sorted[middle]) / 2
    : sorted[middle];
}

function percentChange(before, after) {
  if (before === 0) return after === 0 ? 0 : Number.POSITIVE_INFINITY;
  return ((after - before) / before) * 100;
}

function canonicalJson(value) {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value !== null && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) =>
      `${JSON.stringify(key)}:${canonicalJson(value[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}

function validateManifestEntry(entry, label) {
  if (entry === null || typeof entry !== "object" || Array.isArray(entry)) {
    throw fail(`manifesto de profiling incompatível: ${label} ausente ou inválido`);
  }
  if (typeof entry.kind !== "string" || entry.kind.length === 0
    || typeof entry.reference !== "string" || entry.reference.trim().length === 0
    || typeof entry.source !== "string" || entry.source.trim().length === 0
    || !/^[a-f0-9]{64}$/i.test(entry.digest ?? "")
    || !Array.isArray(entry.files) || entry.files.length === 0) {
    throw fail(`manifesto de profiling incompatível: identidade, digest ou arquivos inválidos em ${label}`);
  }

  const seenPaths = new Set();
  for (const file of entry.files) {
    if (file === null || typeof file !== "object" || Array.isArray(file)
      || typeof file.path !== "string" || file.path.length === 0
      || file.path.startsWith("/") || file.path.split(/[\\/]/).includes("..")
      || !/^[a-f0-9]{64}$/i.test(file.sha256 ?? "")
      || seenPaths.has(file.path)) {
      throw fail(`manifesto de profiling incompatível: inventário inválido em ${label}`);
    }
    seenPaths.add(file.path);
  }

  const { digest, ...payload } = entry;
  const calculatedDigest = createHash("sha256").update(JSON.stringify(payload)).digest("hex");
  if (calculatedDigest !== digest.toLowerCase()) {
    throw fail(`manifesto de profiling incompatível: digest divergente em ${label}`);
  }
  return entry;
}

async function readRunManifest(outputRoot, baselineVersion, revisedVersion) {
  const manifestPath = resolve(outputRoot, "profiling-run-manifest.json");
  let manifest;
  try {
    manifest = JSON.parse(await readFile(manifestPath, "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") {
      throw inconclusive(`pré-requisito ausente: manifesto de profiling (${manifestPath})`);
    }
    throw fail(`manifesto de profiling inválido: ${error.message}`);
  }
  if (manifest === null || typeof manifest !== "object" || Array.isArray(manifest)
    || manifest.schema !== "profiling-run-manifest-v1") {
    throw fail("manifesto de profiling incompatível: schema inválido");
  }

  const baselineIdentity = validateManifestEntry(manifest.baseline, "baseline");
  const revisedIdentity = validateManifestEntry(manifest.revised, "revised");
  if (baselineIdentity.reference === revisedIdentity.reference
    || baselineIdentity.digest === revisedIdentity.digest) {
    throw fail("manifesto de profiling incompatível: baseline e revisada compartilham identidade");
  }
  if ((process.env.BASELINE_REVISION && process.env.BASELINE_REVISION !== baselineIdentity.reference)
    || (process.env.REVISED_REVISION && process.env.REVISED_REVISION !== revisedIdentity.reference)) {
    throw fail("manifesto de profiling incompatível com as revisões solicitadas");
  }

  const fixture = manifest.fixture;
  if (fixture === null || typeof fixture !== "object" || Array.isArray(fixture)
    || fixture.scenario !== "command-day1" || fixture.nominalWindowSeconds !== NOMINAL_WINDOW_S
    || !Array.isArray(fixture.samples) || !Array.isArray(fixture.profiles)
    || fixture.samples.length !== REQUIRED_SAMPLES.size
    || new Set(fixture.samples).size !== fixture.samples.length
    || [...REQUIRED_SAMPLES].some((sample) => !fixture.samples.includes(sample))
    || fixture.profiles.length !== REQUIRED_PROFILES.length
    || new Set(fixture.profiles).size !== fixture.profiles.length
    || REQUIRED_PROFILES.some((profile) => !fixture.profiles.includes(profile))) {
    throw fail("manifesto de profiling incompatível: fixture, perfis, amostras ou janela divergentes");
  }
  if (fixture.processingRunner !== "tools/processing-cli.sh"
    || fixture.processingTimeoutMs !== 240_000
    || fixture.environment === null || typeof fixture.environment !== "object"
    || Array.isArray(fixture.environment)) {
    throw fail("manifesto de profiling incompatível: ambiente ou runner incompleto");
  }
  const environment = fixture.environment;
  if (typeof environment.environment !== "string" || environment.environment.length === 0
    || typeof environment.machine !== "string" || environment.machine.length === 0
    || typeof environment.gpu !== "string" || environment.gpu.length === 0
    || environment.host === null || typeof environment.host !== "object"
    || Array.isArray(environment.host)
    || typeof environment.host.operatingSystem !== "string" || environment.host.operatingSystem.length === 0
    || typeof environment.host.architecture !== "string" || environment.host.architecture.length === 0
    || environment.graphicalEnvironment === null
    || typeof environment.graphicalEnvironment !== "object"
    || Array.isArray(environment.graphicalEnvironment)
    || environment.graphicalEnvironment.mode !== "headless"
    || typeof environment.graphicalEnvironment.xvfbRunAvailable !== "boolean"
    || (environment.graphicalEnvironment.xvfbRunAvailable
      && typeof environment.graphicalEnvironment.xvfbRunPath !== "string")
    || environment.processing === null || typeof environment.processing !== "object"
    || Array.isArray(environment.processing)
    || typeof environment.processing.available !== "boolean"
    || environment.audio === null || typeof environment.audio !== "object"
    || Array.isArray(environment.audio)
    || (environment.audio.available !== true && environment.audio.available !== false
      && environment.audio.available !== null)) {
    throw fail("manifesto de profiling incompatível: metadados de ambiente incompletos");
  }

  const commandsExecuted = manifest.commandsExecuted;
  if (!Array.isArray(commandsExecuted) || commandsExecuted.length !== 1
    || commandsExecuted[0] === null || typeof commandsExecuted[0] !== "object") {
    throw inconclusive("pré-requisito ausente: manifesto sem resultado verificável da coleta");
  }
  const collectionCommand = commandsExecuted[0];
  if (typeof collectionCommand.command !== "string"
    || !collectionCommand.command.includes("tools/profile-runner.mjs")
    || typeof collectionCommand.startedAt !== "string"
    || !Number.isFinite(Date.parse(collectionCommand.startedAt))) {
    throw fail("manifesto de profiling incompatível: comando ou início da coleta inválido");
  }
  if (collectionCommand.status === "FAIL") {
    throw fail("coleta de profiling falhou conforme o manifesto de execução");
  }
  if (collectionCommand.status === "INCONCLUSIVO") {
    const diagnostics = collectionCommand.prerequisiteDiagnostics;
    if (!Array.isArray(diagnostics) || diagnostics.length === 0
      || diagnostics.some((diagnostic) => typeof diagnostic !== "string"
        || diagnostic.trim().length === 0 || !/pré-requisito ausente/i.test(diagnostic))) {
      throw fail("manifesto de profiling marca INCONCLUSIVO sem nomear pré-requisito ausente");
    }
    throw inconclusive(`pré-requisito ausente antes da coleta: ${diagnostics.join("; ")}`);
  }
  if (collectionCommand.status !== "PASS") {
    throw fail("manifesto de profiling tem status de coleta inválido");
  }

  const expectedRuns = new Set(REQUIRED_PROFILES.flatMap((profile) =>
    [baselineVersion, revisedVersion].map((version) => `${version}/${profile}/${fixture.scenario}`)));
  const results = manifest.results;
  if (!Array.isArray(results) || results.length !== expectedRuns.size) {
    throw inconclusive("pré-requisito ausente: manifesto sem os quatro resultados de coleta esperados");
  }
  const seenRuns = new Set();
  for (const result of results) {
    const runId = `${result?.version}/${result?.profile}/${result?.scenario}`;
    if (!expectedRuns.has(runId) || seenRuns.has(runId)) {
      throw fail(`manifesto de profiling incompatível: resultado duplicado ou inesperado (${runId})`);
    }
    seenRuns.add(runId);
    if (result.status === "FAIL") {
      throw fail(`coleta de profiling falhou em ${runId}`);
    }
    if (result.status === "INCONCLUSIVO") {
      const diagnostic = typeof result.diagnostic === "string" ? result.diagnostic.trim() : "";
      if (diagnostic.length === 0) {
        throw fail(`manifesto de profiling marca ${runId} INCONCLUSIVO sem diagnóstico`);
      }
      if (!/pré-requisito ausente/i.test(diagnostic)) {
        throw fail(`manifesto de profiling marca ${runId} INCONCLUSIVO sem pré-requisito nomeado`);
      }
      throw inconclusive(`pré-requisito ausente para ${runId}: ${diagnostic}`);
    }
    if (result.status !== "PASS"
      || result.artifacts !== "last_horizon/output/<versao>/<perfil>/<sample_id>.*"
      || result.historicalArtifactsRetained !== false) {
      throw fail(`manifesto de profiling não confirma artefatos completos em ${runId}`);
    }
  }
  return { manifest, fixture, baselineIdentity, revisedIdentity };
}

async function readMetric(csvPath, expectedSample, label) {
  let rows;
  try {
    rows = parseCsv(await readFile(csvPath, "utf8"));
  } catch (error) {
    throw fail(`${label}: CSV ausente ou ilegível: ${error.message}`);
  }
  if (rows.length !== 2) throw fail(`${label}: CSV deve conter cabeçalho e uma amostra`);
  assertExactFields(rows[0], REQUIRED_METRIC_FIELDS, label);
  if (rows[1].length !== REQUIRED_METRIC_FIELDS.length) {
    throw fail(`${label}: CSV tem quantidade de colunas inválida`);
  }
  const record = Object.fromEntries(REQUIRED_METRIC_FIELDS.map((field, index) => [field, rows[1][index]]));
  if (record.sample_id !== expectedSample) {
    throw fail(`${label}: sample_id ${record.sample_id} não corresponde a ${expectedSample}`);
  }
  const duration = numberField(record, "duration_real_s", label);
  if (duration < NOMINAL_WINDOW_S - DURATION_TOLERANCE_S
    || duration > NOMINAL_WINDOW_S + DURATION_TOLERANCE_S) {
    throw fail(`${label}: duração fora da janela nominal de 30s ±0,5s`);
  }
  if (numberField(record, "frame_count", label) <= 0) {
    throw fail(`${label}: frame_count deve ser positivo`);
  }
  const values = Object.fromEntries(COST_FIELDS.map((field) => [field, numberField(record, field, label)]));
  return { record, values };
}

async function readSidecar(sidecarPath, label) {
  let sidecar;
  try {
    sidecar = JSON.parse(await readFile(sidecarPath, "utf8"));
  } catch (error) {
    throw fail(`${label}: sidecar ausente ou inválido: ${error.message}`);
  }
  if (sidecar === null || Array.isArray(sidecar) || typeof sidecar !== "object") {
    throw fail(`${label}: sidecar deve ser um objeto JSON`);
  }
  const required = [
    "environment", "machine", "assets", "room", "state", "nominal_window_s",
    "processing", "hardware", "gpu", "os",
  ];
  assertExactFields(Object.keys(sidecar).sort(), [...required].sort(), `${label} sidecar`);
  for (const field of required) {
    if (sidecar[field] === null || sidecar[field] === undefined
      || (typeof sidecar[field] === "string" && sidecar[field].trim().length === 0)) {
      throw fail(`${label}: campo ausente no sidecar: ${field}`);
    }
  }
  if (typeof sidecar.nominal_window_s !== "number"
    || sidecar.nominal_window_s !== NOMINAL_WINDOW_S) {
    throw fail(`${label}: nominal_window_s deve ser 30`);
  }
  return sidecar;
}

async function readTemporalSidecar(temporalPath, label, expected, metric) {
  let temporal;
  try {
    temporal = JSON.parse(await readFile(temporalPath, "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") {
      throw inconclusive(`${label}: sidecar temporal ausente (${temporalPath})`);
    }
    throw fail(`${label}: sidecar temporal inválido: ${error.message}`);
  }
  if (temporal === null || Array.isArray(temporal) || typeof temporal !== "object") {
    throw fail(`${label}: sidecar temporal deve ser um objeto JSON`);
  }

  const requiredFields = [
    "schema", "version", "profile", "scenario", "sample_id", "cadence_fps",
    "duration_real_s", "callback_count", "callbacks", "delta_sequence_seconds",
    "step_sequence", "accepted_sequence_seconds", "remaining_sequence_seconds",
    "discarded_sequence_seconds", "distance_px", ...REQUIRED_TEMPORAL_METRICS,
    "statuses", "status",
  ];
  const missing = requiredFields.filter((field) => temporal[field] === undefined);
  if (missing.length > 0) {
    throw inconclusive(`${label}: métricas temporais ausentes (${missing.join(", ")})`);
  }
  if (temporal.schema !== "frame-temporal-profile-v1"
    || temporal.version !== expected.version || temporal.profile !== expected.profile
    || temporal.scenario !== expected.scenario || temporal.sample_id !== expected.sample) {
    throw fail(`${label}: identidade do sidecar temporal divergente`);
  }
  if (!REQUIRED_CADENCES.includes(temporal.cadence_fps)) {
    throw fail(`${label}: cadence_fps deve ser 15, 30 ou 60`);
  }
  const duration = temporal.duration_real_s;
  const csvDuration = Number(metric.record.duration_real_s);
  if (typeof duration !== "number" || !Number.isFinite(duration)
    || duration < NOMINAL_WINDOW_S - DURATION_TOLERANCE_S
    || duration > NOMINAL_WINDOW_S + DURATION_TOLERANCE_S
    || Math.abs(duration - csvDuration) > 0.05) {
    throw fail(`${label}: sidecar temporal não corresponde à janela do CSV`);
  }
  if (!Number.isInteger(temporal.callback_count) || temporal.callback_count <= 0
    || temporal.callback_count !== Number(metric.record.frame_count)
    || !Array.isArray(temporal.callbacks)
    || temporal.callbacks.length !== temporal.callback_count) {
    throw inconclusive(`${label}: callbacks temporais ausentes ou fora da janela do CSV`);
  }

  const sequences = [
    "delta_sequence_seconds", "step_sequence", "accepted_sequence_seconds",
    "remaining_sequence_seconds", "discarded_sequence_seconds",
  ];
  for (const field of sequences) {
    const values = temporal[field];
    if (!Array.isArray(values) || values.length !== temporal.callback_count
      || values.some((value) => typeof value !== "number"
        || !Number.isFinite(value) || value < 0)) {
      throw inconclusive(`${label}: sequência temporal ausente ou inválida em ${field}`);
    }
  }
  if (typeof temporal.distance_px !== "number"
    || !Number.isFinite(temporal.distance_px) || temporal.distance_px < 0) {
    throw inconclusive(`${label}: distância temporal ausente ou inválida`);
  }
  for (const field of REQUIRED_TEMPORAL_METRICS) {
    if (typeof temporal[field] !== "number"
      || !Number.isFinite(temporal[field]) || temporal[field] < 0) {
      throw inconclusive(`${label}: métrica temporal ausente ou inválida em ${field}`);
    }
  }
  const callbackFields = [
    "callback", "active_screen", "active_room", "ui_layer", "paused", "clock_origin",
    "harness_mode", "observed_delta_seconds", "steps_planned", "steps_executed",
    "last_executed_step", "accepted_seconds", "remaining_seconds", "discarded_seconds",
    "distance_delta_px", "jump_edge_consumed", "jump_edge_step", "interact_edge_consumed",
    "interact_edge_step", "door_transition_active", "door_transition_update_count",
    "confirmed_state_version", "logical_events", ...REQUIRED_TEMPORAL_METRICS.map((field) =>
      field.replace("_p95", "")),
  ];
  for (const [index, callback] of temporal.callbacks.entries()) {
    if (callback === null || typeof callback !== "object" || Array.isArray(callback)) {
      throw inconclusive(`${label}: callback temporal inválido no índice ${index}`);
    }
    const callbackMissing = callbackFields.filter((field) => callback[field] === undefined);
    if (callbackMissing.length > 0 || !Array.isArray(callback.logical_events)) {
      throw inconclusive(`${label}: FrameContext incompleto no callback ${index}`);
    }
    for (const field of callbackFields.filter((name) => name.endsWith("_ms"))) {
      if (typeof callback[field] !== "number" || !Number.isFinite(callback[field])
        || callback[field] < 0) {
        throw inconclusive(`${label}: métrica ausente no callback ${index}: ${field}`);
      }
    }
    if (callback.logical_events.some((event) => event === null
      || typeof event !== "object" || typeof event.family !== "string"
      || !Number.isInteger(event.variant) || typeof event.logical_timestamp_seconds !== "number"
      || !Number.isFinite(event.logical_timestamp_seconds)
      || !Number.isInteger(event.step_index))) {
      throw inconclusive(`${label}: evento lógico inválido no callback ${index}`);
    }
  }

  const validStatuses = new Set(["PASS", "FAIL", "INCONCLUSIVO"]);
  if (temporal.statuses === null || typeof temporal.statuses !== "object"
    || Array.isArray(temporal.statuses)) {
    throw inconclusive(`${label}: status de clock/audio/asset/cache ausente`);
  }
  if (Object.keys(temporal.statuses).sort().join(",") !== "asset,audio,cache,clock") {
    throw inconclusive(`${label}: categorias de status temporais incompletas ou divergentes`);
  }
  for (const category of ["clock", "audio", "asset", "cache"]) {
    if (!validStatuses.has(temporal.statuses[category])) {
      throw inconclusive(`${label}: status ausente ou inválido para ${category}`);
    }
    if (temporal.statuses[category] === "FAIL") {
      throw fail(`${label}: status temporal FAIL em ${category}`);
    }
    if (temporal.statuses[category] === "INCONCLUSIVO") {
      throw inconclusive(`${label}: status temporal INCONCLUSIVO em ${category}`);
    }
  }
  if (!validStatuses.has(temporal.status)) {
    throw inconclusive(`${label}: status geral temporal ausente ou inválido`);
  }
  if (temporal.status === "FAIL") throw fail(`${label}: status geral temporal FAIL`);
  if (temporal.status !== "PASS") {
    throw inconclusive(`${label}: status geral temporal ${temporal.status}`);
  }
  return temporal;
}

async function listJsonFiles(directory) {
  let entries;
  try {
    entries = await readdir(directory, { withFileTypes: true });
  } catch (error) {
    if (error.code === "ENOENT") {
      throw inconclusive(`pré-requisito ausente antes da comparação: amostras de profiling (${directory})`);
    }
    throw fail(`não foi possível ler o diretório de profiling: ${error.message}`);
  }
  const files = [];
  for (const entry of entries) {
    const entryPath = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...await listJsonFiles(entryPath));
    else if (entry.isFile() && entry.name.endsWith(".json")) files.push(entryPath);
  }
  return files;
}

function validateHotspots(artifact, metric, label) {
  if (!Array.isArray(artifact.hotspots)) throw fail(`${label}: hotspots deve ser uma lista`);
  const seen = new Set();
  for (const hotspot of artifact.hotspots) {
    if (hotspot === null || typeof hotspot !== "object"
      || typeof hotspot.hotspot !== "string" || typeof hotspot.metric !== "string"
      || !Number.isFinite(Number(hotspot.value))) {
      throw fail(`${label}: hotspot inválido`);
    }
    if (seen.has(hotspot.hotspot)) throw fail(`${label}: hotspot duplicado: ${hotspot.hotspot}`);
    seen.add(hotspot.hotspot);
    const expectedMetric = REQUIRED_HOTSPOTS.get(hotspot.hotspot);
    if (expectedMetric !== hotspot.metric) {
      throw fail(`${label}: métrica divergente no hotspot ${hotspot.hotspot}`);
    }
    const expectedValue = metric.values[expectedMetric];
    const actualValue = Number(hotspot.value);
    const tolerance = Math.max(0.001, Math.abs(expectedValue) * 0.001);
    if (Math.abs(actualValue - expectedValue) > tolerance) {
      throw fail(`${label}: valor do hotspot ${hotspot.hotspot} diverge do CSV`);
    }
  }
  for (const requiredHotspot of REQUIRED_HOTSPOTS.keys()) {
    if (!seen.has(requiredHotspot)) throw fail(`${label}: hotspot ausente: ${requiredHotspot}`);
  }
}

async function validateArtifact(path, outputRoot, version, profile) {
  let artifact;
  try {
    artifact = JSON.parse(await readFile(path, "utf8"));
  } catch (error) {
    throw fail(`profiling inválido em ${path}: ${error.message}`);
  }
  if (artifact === null || typeof artifact !== "object" || Array.isArray(artifact)) {
    throw inconclusive(`${path}: identidade de perfil, cenário ou amostra indisponível`);
  }
  const identityFields = ["profile", "version", "scenario", "sample"];
  const missingIdentity = identityFields.filter((field) =>
    typeof artifact[field] !== "string" || artifact[field].trim().length === 0);
  if (missingIdentity.length > 0) {
    throw inconclusive(`${path}: identidade incompleta (${missingIdentity.join(", ")})`);
  }
  const requiredFields = ["hotspots", "status", "metrics_contract", "metrics_csv", "sidecar_json"];
  const missing = requiredFields.filter((field) => artifact[field] === undefined || artifact[field] === "");
  if (missing.length > 0) throw fail(`${path}: campos ausentes: ${missing.join(", ")}`);
  if (typeof artifact.temporal_json !== "string" || artifact.temporal_json.length === 0) {
    throw inconclusive(`${path}: vínculo do sidecar temporal ausente`);
  }
  if (artifact.status !== "EXECUTED") {
    throw inconclusive(`${path}: amostra não executada (${artifact.status})`);
  }
  if (artifact.version !== version || artifact.profile !== profile
    || !/^[A-Za-z0-9._-]+$/.test(artifact.scenario)
    || !/^[A-Za-z0-9._-]+$/.test(artifact.sample)) {
    throw fail(`${path}: vínculo de versão, perfil, cenário ou amostra inconsistente`);
  }
  const expectedPath = resolve(outputRoot, "profiling", version, profile,
    artifact.scenario, `${artifact.sample}.json`);
  if (resolve(path) !== expectedPath) throw fail(`${path}: caminho não corresponde à identidade`);
  if (artifact.metrics_contract !== METRICS_CONTRACT) {
    throw fail(`${path}: contrato de métricas ausente ou divergente`);
  }
  const expectedCsv = `last_horizon/output/${version}/${profile}/${artifact.sample}.csv`;
  const expectedSidecar = `last_horizon/output/${version}/${profile}/${artifact.sample}.sidecar.json`;
  const expectedTemporal = `last_horizon/output/${version}/${profile}/${artifact.sample}.temporal.json`;
  if (artifact.metrics_csv !== expectedCsv || artifact.sidecar_json !== expectedSidecar) {
    throw fail(`${path}: CSV/sidecar não correspondem ao vínculo do profiling`);
  }
  if (artifact.temporal_json !== expectedTemporal) {
    throw fail(`${path}: sidecar temporal não corresponde ao vínculo do profiling`);
  }
  const metric = await readMetric(resolve(root, artifact.metrics_csv), artifact.sample, path);
  const sidecar = await readSidecar(resolve(root, artifact.sidecar_json), path);
  const temporal = await readTemporalSidecar(resolve(root, artifact.temporal_json), path, {
    version, profile, scenario: artifact.scenario, sample: artifact.sample,
  }, metric);
  validateHotspots(artifact, metric, path);
  return {
    path,
    artifact,
    metric,
    sidecar,
    temporal,
    identity: `${profile}/${artifact.scenario}/${artifact.sample}`,
  };
}

async function validateVersion(outputRoot, version) {
  const artifacts = [];
  for (const profile of REQUIRED_PROFILES) {
    const directory = resolve(outputRoot, "profiling", version, profile);
    const files = await listJsonFiles(directory);
    if (files.length !== 3) {
      throw inconclusive(`${version}/${profile}: esperadas três amostras, encontradas ${files.length}`);
    }
    const profileArtifacts = [];
    for (const file of files) profileArtifacts.push(await validateArtifact(file, outputRoot, version, profile));
    const samples = new Set(profileArtifacts.map((item) => item.artifact.sample));
    if (samples.size !== REQUIRED_SAMPLES.size
      || [...REQUIRED_SAMPLES].some((sample) => !samples.has(sample))) {
      throw fail(`${version}/${profile}: amostras devem ser sample-01, sample-02 e sample-03`);
    }
    const cadences = new Set(profileArtifacts.map((item) => item.temporal.cadence_fps));
    if (cadences.size !== REQUIRED_CADENCES.length
      || REQUIRED_CADENCES.some((cadence) => !cadences.has(cadence))) {
      throw inconclusive(`${version}/${profile}: sidecars devem cobrir as cadências 15, 30 e 60 FPS`);
    }
    artifacts.push(...profileArtifacts);
  }
  return artifacts;
}

function compareArtifacts(baseline, revised) {
  const baselineById = new Map(baseline.map((item) => [item.identity, item]));
  const revisedById = new Map(revised.map((item) => [item.identity, item]));
  if (baselineById.size !== revisedById.size
    || [...baselineById.keys()].some((id) => !revisedById.has(id))) {
    throw fail("baseline e versão revisada não têm os mesmos perfis, cenários e amostras");
  }
  for (const [identity, beforeItem] of baselineById) {
    if (beforeItem.temporal.cadence_fps !== revisedById.get(identity).temporal.cadence_fps) {
      throw fail(`baseline e versão revisada associam cadências diferentes à amostra ${identity}`);
    }
  }

  for (const profile of REQUIRED_PROFILES) {
    const beforeSidecars = baseline
      .filter((item) => item.artifact.profile === profile)
      .map((item) => canonicalJson(item.sidecar));
    const afterSidecars = revised
      .filter((item) => item.artifact.profile === profile)
      .map((item) => canonicalJson(item.sidecar));
    if (new Set(beforeSidecars).size !== 1 || new Set(afterSidecars).size !== 1
      || beforeSidecars[0] !== afterSidecars[0]) {
      throw fail(`baseline e versão revisada usam sidecars não comparáveis no perfil ${profile}`);
    }
  }

  const comparisons = [];
  let hasReproducibleReduction = false;
  let maximumRevisedP95 = 0;
  for (const profile of REQUIRED_PROFILES) {
    const profileBaseline = baseline.filter((item) => item.artifact.profile === profile);
    const profileRevised = revised.filter((item) => item.artifact.profile === profile);
    for (const field of COST_FIELDS) {
      const before = median(profileBaseline.map((item) => item.metric.values[field]));
      const after = median(profileRevised.map((item) => item.metric.values[field]));
      const pairwiseReductions = profileBaseline.filter((item) => {
        const revisedItem = revisedById.get(item.identity);
        return revisedItem.metric.values[field] < item.metric.values[field];
      }).length;
      comparisons.push({
        profile,
        scenario: profileBaseline[0].artifact.scenario,
        field,
        before,
        after,
        change: percentChange(before, after),
        pairwiseReductions,
        baselineArtifacts: profileBaseline.map((item) => item.path),
        revisedArtifacts: profileRevised.map((item) => item.path),
        baselineMetrics: profileBaseline.map((item) => resolve(root, item.artifact.metrics_csv)),
        revisedMetrics: profileRevised.map((item) => resolve(root, item.artifact.metrics_csv)),
        baselineSidecars: profileBaseline.map((item) => resolve(root, item.artifact.sidecar_json)),
        revisedSidecars: profileRevised.map((item) => resolve(root, item.artifact.sidecar_json)),
        baselineTemporalSidecars: profileBaseline.map((item) => resolve(root, item.artifact.temporal_json)),
        revisedTemporalSidecars: profileRevised.map((item) => resolve(root, item.artifact.temporal_json)),
      });
      if (after < before && pairwiseReductions >= 2) hasReproducibleReduction = true;
    }
    maximumRevisedP95 = Math.max(maximumRevisedP95,
      median(profileRevised.map((item) => item.metric.values.frame_time_p95_ms)));
  }

  const allocationComparisons = comparisons.filter((entry) =>
    entry.field === "allocations_per_frame");
  const allocationGrowth = allocationComparisons.filter((entry) => entry.after > entry.before);
  const allocationPersistentGrowth = allocationComparisons.length === REQUIRED_PROFILES.length
    && allocationComparisons.every((entry) => entry.change > MAX_ALLOCATION_NOISE_PERCENT);
  const temporalCadenceMetrics = [];
  for (const profile of REQUIRED_PROFILES) {
    for (const cadence of REQUIRED_CADENCES) {
      const beforeItems = baseline.filter((item) => item.artifact.profile === profile
        && item.temporal.cadence_fps === cadence);
      const afterItems = revised.filter((item) => item.artifact.profile === profile
        && item.temporal.cadence_fps === cadence);
      for (const field of REQUIRED_TEMPORAL_METRICS) {
        temporalCadenceMetrics.push({
          profile,
          cadence_fps: cadence,
          metric: field,
          baseline: median(beforeItems.map((item) => item.temporal[field])),
          revised: median(afterItems.map((item) => item.temporal[field])),
          baselineSamples: beforeItems.map((item) => item.artifact.sample),
          revisedSamples: afterItems.map((item) => item.artifact.sample),
        });
      }
    }
  }
  return {
    comparisons,
    temporalCadenceMetrics,
    hasReproducibleReduction,
    maximumRevisedP95,
    regressions: comparisons.filter((entry) => entry.change > MAX_REGRESSION_PERCENT),
    allocationGrowth,
    allocationPersistentGrowth,
    p95LimitExceeded: maximumRevisedP95 > MAX_FRAME_TIME_P95_MS,
  };
}

async function writeComparisonReport(path, report) {
  await writeFile(path, `${JSON.stringify(report, null, 2)}\n`, "utf8");
}

async function run() {
  const [outputRoot = "last_horizon/output", baselineVersion = "baseline", revisedVersion = "revised"] = process.argv.slice(2);
  const reportPath = resolve(outputRoot, "profiling-comparison.json");
  const results = await Promise.allSettled([
    readRunManifest(outputRoot, baselineVersion, revisedVersion),
    validateVersion(outputRoot, baselineVersion),
    validateVersion(outputRoot, revisedVersion),
  ]);
  const errors = results.filter((result) => result.status === "rejected").map((result) => result.reason);
  if (errors.length > 0) {
    const error = errors.find((item) => item instanceof ProfilingError && item.status === "FAIL") ?? errors[0];
    const status = error instanceof ProfilingError ? error.status : "FAIL";
    await writeComparisonReport(reportPath, {
      schema: "profiling-comparison-v1",
      generatedAt: new Date().toISOString(),
      baselineVersion,
      revisedVersion,
      status,
      gateDecision: status,
      diagnostic: error.message,
      comparisons: [],
      evidence: {
        manifest: "last_horizon/output/profiling-run-manifest.json",
        profilingPattern: "last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json",
        metricsPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.csv",
        sidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json",
        temporalSidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.temporal.json",
      },
    });
    throw error;
  }
  const [runManifest, baseline, revised] = results.map((result) => result.value);
  let comparison;
  try {
  for (const item of [...baseline, ...revised]) {
    if (item.artifact.scenario !== runManifest.fixture.scenario) {
      throw fail(`${item.path}: cenário não corresponde à fixture do manifesto de execução`);
    }
    const environment = runManifest.fixture.environment;
    if (item.sidecar.environment !== environment.environment
      || item.sidecar.machine !== environment.machine || item.sidecar.gpu !== environment.gpu) {
      throw fail(`${item.path}: identidade ambiental do sidecar diverge do manifesto de execução`);
    }
  }
    comparison = compareArtifacts(baseline, revised);
  } catch (error) {
    const status = error instanceof ProfilingError ? error.status : "FAIL";
    await writeComparisonReport(reportPath, {
      schema: "profiling-comparison-v1",
      generatedAt: new Date().toISOString(),
      baselineVersion,
      revisedVersion,
      status,
      gateDecision: status,
      diagnostic: error instanceof Error ? error.message : String(error),
      comparisons: [],
      evidence: {
        manifest: "last_horizon/output/profiling-run-manifest.json",
        profilingPattern: "last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json",
        metricsPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.csv",
        sidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json",
        temporalSidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.temporal.json",
      },
    });
    throw error;
  }
  for (const entry of comparison.comparisons) {
    console.log(`${entry.profile}/${entry.field}: antes=${entry.before.toFixed(3)} depois=${entry.after.toFixed(3)} variação=${entry.change.toFixed(2)}%`);
  }
  const constraintFailure = comparison.regressions.length > 0 || comparison.p95LimitExceeded
    || comparison.allocationPersistentGrowth;
  const status = constraintFailure ? "FAIL" : "PASS";
  const comparisonRows = comparison.comparisons.map((entry) => ({
    profile: entry.profile,
    scenario: entry.scenario,
    hotspot: [...REQUIRED_HOTSPOTS.entries()].find(([, metric]) => metric === entry.field)?.[0] ?? null,
    metric: entry.field,
    baseline: entry.before,
    revised: entry.after,
    variation_percent: entry.change,
    pairwise_reductions: entry.pairwiseReductions,
    status: entry.change > MAX_REGRESSION_PERCENT
      || (entry.field === "allocations_per_frame"
        && comparison.allocationPersistentGrowth
        && entry.after > entry.before)
      ? "FAIL" : "PASS",
    evidence: {
      baselineProfiling: entry.baselineArtifacts,
      revisedProfiling: entry.revisedArtifacts,
      baselineCsv: entry.baselineMetrics,
      revisedCsv: entry.revisedMetrics,
      baselineSidecars: entry.baselineSidecars,
      revisedSidecars: entry.revisedSidecars,
    },
  }));
  await writeComparisonReport(reportPath, {
    schema: "profiling-comparison-v1",
    generatedAt: new Date().toISOString(),
    baselineVersion,
    revisedVersion,
    status,
    gateDecision: status,
    maximumRevisedP95: comparison.maximumRevisedP95,
    maximumRevisedP95Limit: MAX_FRAME_TIME_P95_MS,
    hasReproducibleReduction: comparison.hasReproducibleReduction,
    allocationNoiseTolerancePercent: MAX_ALLOCATION_NOISE_PERCENT,
    allocationPersistentGrowth: comparison.allocationPersistentGrowth,
    allocationGrowthProfiles: comparison.allocationGrowth.map((entry) => entry.profile),
    runManifest: {
      path: "last_horizon/output/profiling-run-manifest.json",
      baselineReference: runManifest.baselineIdentity.reference,
      baselineDigest: runManifest.baselineIdentity.digest,
      revisedReference: runManifest.revisedIdentity.reference,
      revisedDigest: runManifest.revisedIdentity.digest,
      fixture: runManifest.fixture,
    },
    costTable: comparisonRows,
    temporalCadenceMetrics: comparison.temporalCadenceMetrics,
    hotspots: [...REQUIRED_HOTSPOTS.entries()].map(([hotspot, metric]) => ({ hotspot, metric })),
    evidence: {
      profilingPattern: "last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json",
      metricsPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.csv",
      sidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json",
      temporalSidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.temporal.json",
    },
  });
  if (status === "FAIL") {
    const reasons = [
      comparison.regressions.length > 0
        ? `regressão superior a 10%: ${comparison.regressions.map((entry) => `${entry.profile}/${entry.field}`).join(", ")}`
        : "",
      comparison.p95LimitExceeded ? `p95 mediano revisado acima de ${MAX_FRAME_TIME_P95_MS}ms` : "",
      comparison.allocationPersistentGrowth
        ? `allocations_per_frame aumentou acima de ${MAX_ALLOCATION_NOISE_PERCENT}% nos dois perfis` : "",
    ].filter(Boolean).join("; ");
    throw fail(`${reasons}; tabela de custos gravada em last_horizon/output/profiling-comparison.json`);
  }
  console.log(`PROFILING CHECK: PASS — ${baseline.length + revised.length} resultados válidos; p95 máximo revisado=${comparison.maximumRevisedP95.toFixed(3)}ms`);
}

const profilingTimeout = setTimeout(() => {
  console.log("PROFILING CHECK: FAIL");
  console.error("Diagnóstico: profiling excedeu o timeout fixo de 60s.");
  process.exit(124);
}, PROFILING_TIMEOUT_MS);

run().then(() => {
  clearTimeout(profilingTimeout);
}).catch((error) => {
  clearTimeout(profilingTimeout);
  const status = error instanceof ProfilingError ? error.status : "FAIL";
  console.log(`PROFILING CHECK: ${status}`);
  console.error(`Diagnóstico: ${error.message}`);
  process.exitCode = status === "INCONCLUSIVO" ? 2 : 1;
});
