import { readdir, readFile, writeFile } from "node:fs/promises";
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
  return new ProfilingError("INCONCLUSIVO", message);
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

async function listJsonFiles(directory) {
  let entries;
  try {
    entries = await readdir(directory, { withFileTypes: true });
  } catch (error) {
    if (error.code === "ENOENT") throw inconclusive(`diretório de profiling ausente: ${directory}`);
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
  if (artifact.metrics_csv !== expectedCsv || artifact.sidecar_json !== expectedSidecar) {
    throw fail(`${path}: CSV/sidecar não correspondem ao vínculo do profiling`);
  }
  const metric = await readMetric(resolve(root, artifact.metrics_csv), artifact.sample, path);
  const sidecar = await readSidecar(resolve(root, artifact.sidecar_json), path);
  validateHotspots(artifact, metric, path);
  return {
    path,
    artifact,
    metric,
    sidecar,
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
  return {
    comparisons,
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
        profilingPattern: "last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json",
        metricsPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.csv",
        sidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json",
      },
    });
    throw error;
  }
  const [baseline, revised] = results.map((result) => result.value);
  const comparison = compareArtifacts(baseline, revised);
  for (const entry of comparison.comparisons) {
    console.log(`${entry.profile}/${entry.field}: antes=${entry.before.toFixed(3)} depois=${entry.after.toFixed(3)} variação=${entry.change.toFixed(2)}%`);
  }
  const constraintFailure = comparison.regressions.length > 0 || comparison.p95LimitExceeded
    || comparison.allocationPersistentGrowth;
  const status = constraintFailure ? "FAIL" : comparison.hasReproducibleReduction ? "PASS" : "INCONCLUSIVO";
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
    costTable: comparisonRows,
    hotspots: [...REQUIRED_HOTSPOTS.entries()].map(([hotspot, metric]) => ({ hotspot, metric })),
    evidence: {
      profilingPattern: "last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json",
      metricsPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.csv",
      sidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json",
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
  if (status === "INCONCLUSIVO") throw inconclusive("nenhuma redução mensurável e reproduzível em pelo menos um custo");
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
