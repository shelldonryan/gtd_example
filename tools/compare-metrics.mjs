import { readFile, readdir, stat } from "node:fs/promises";
import { basename, extname, join, resolve } from "node:path";

const REQUIRED_SIDECAR_FIELDS = [
  "environment", "machine", "assets", "room", "state", "nominal_window_s",
  "processing", "hardware", "gpu", "os",
];
const REQUIRED_METRIC_FIELDS = [
  "sample_id", "duration_real_s", "frame_count", "frame_time_median_ms",
  "frame_time_p95_ms", "load_time_ms", "additional_memory_bytes", "icon_builds",
  "floor_band_builds", "cache_invalidations", "allocations_per_frame",
];
const COST_FIELDS = REQUIRED_METRIC_FIELDS.slice(3);
const NOMINAL_WINDOW_S = 30;
const DURATION_TOLERANCE_S = 0.5;
const MAX_REGRESSION_PERCENT = 10;
const MAX_FRAME_TIME_P95_MS = 33.3;
const ALLOCATION_METRIC = "allocations_per_frame";
const COMPARISON_TIMEOUT_MS = 60_000;
const LEGACY_NAMES = new Set(["performance__metricas.csv", "metrics.csv"]);
const INTEGER_METRIC_FIELDS = new Set([
  "frame_count", "additional_memory_bytes", "icon_builds", "floor_band_builds",
  "cache_invalidations",
]);
const SIDECAR_STRING_FIELDS = REQUIRED_SIDECAR_FIELDS.filter((field) =>
  field !== "nominal_window_s");

class MetricsError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

function fail(message) {
  return new MetricsError("FAIL", message);
}

function inconclusive(message) {
  return new MetricsError("INCONCLUSIVO", message);
}

function parseCsv(source) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;

  for (let index = 0; index < source.length; index += 1) {
    const character = source[index];
    const next = source[index + 1];
    if (character === '"' && quoted && next === '"') {
      field += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === "," && !quoted) {
      row.push(field);
      field = "";
    } else if ((character === "\n" || character === "\r") && !quoted) {
      if (character === "\r" && next === "\n") index += 1;
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

function assertUniqueFields(fields, label) {
  if (new Set(fields).size !== fields.length) {
    throw fail(`${label} contém campos duplicados`);
  }
}

function assertExactFields(actual, expected, label) {
  assertUniqueFields(actual, label);
  if (actual.length !== expected.length || actual.some((field, index) => field !== expected[index])) {
    throw fail(`${label} deve usar o cabeçalho canônico: ${expected.join(",")}`);
  }
}

function finiteNumber(record, field, label) {
  const rawValue = record[field];
  if (typeof rawValue !== "string" || rawValue.trim().length === 0) {
    throw fail(`${label}: métrica ausente em ${field}`);
  }
  const value = Number(rawValue);
  if (!Number.isFinite(value)) throw fail(`${label}: métrica inválida em ${field}`);
  if (INTEGER_METRIC_FIELDS.has(field) && !Number.isInteger(value)) {
    throw fail(`${label}: métrica inteira inválida em ${field}`);
  }
  return value;
}

function canonicalJson(value) {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value !== null && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) =>
      `${JSON.stringify(key)}:${canonicalJson(value[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}

async function resolveSamplePaths(input, label) {
  const absolute = resolve(input);
  let inputStat;
  try {
    inputStat = await stat(absolute);
  } catch (error) {
    if (error.code === "ENOENT") {
      throw inconclusive(`${label}: pré-requisito ausente antes do início: ${input}`);
    }
    throw fail(`${label}: não foi possível inspecionar ${input}: ${error.message}`);
  }

  if (inputStat.isDirectory()) {
    const entries = await readdir(absolute, { withFileTypes: true });
    const csvPaths = entries
      .filter((entry) => entry.isFile() && extname(entry.name) === ".csv")
      .map((entry) => join(absolute, entry.name))
      .sort();
    if (csvPaths.length < 3) {
      throw inconclusive(`${label} precisa de três CSVs canônicos; encontrados ${csvPaths.length}`);
    }
    if (csvPaths.length > 3) {
      throw fail(`${label} precisa de exatamente três CSVs canônicos; encontrados ${csvPaths.length}`);
    }
    return csvPaths;
  }

  if (!inputStat.isFile()) throw fail(`${label}: caminho não é arquivo nem diretório: ${input}`);
  if (LEGACY_NAMES.has(basename(absolute))) {
    throw fail(`${label}: nome legado ${basename(absolute)} rejeitado; use amostras canônicas ou conversão explícita`);
  }
  return [absolute];
}

async function readSample(csvPath, label) {
  const csvName = basename(csvPath);
  if (LEGACY_NAMES.has(csvName)) {
    throw fail(`${label}: nome legado ${csvName} rejeitado sem conversão explícita`);
  }

  const rows = parseCsv(await readFile(csvPath, "utf8"));
  if (rows.length !== 2) throw fail(`${label}: ${csvName} deve conter cabeçalho e uma amostra`);
  assertExactFields(rows[0], REQUIRED_METRIC_FIELDS, `${label} ${csvName}`);
  const [values] = rows.slice(1);
  if (values.length !== REQUIRED_METRIC_FIELDS.length) {
    throw fail(`${label}: ${csvName} tem quantidade de colunas inválida`);
  }
  const record = Object.fromEntries(REQUIRED_METRIC_FIELDS.map((field, index) => [field, values[index] ?? ""]));
  const expectedSampleId = csvName.slice(0, -".csv".length);
  if (!/^[A-Za-z0-9._-]+$/.test(record.sample_id) || record.sample_id !== expectedSampleId) {
    throw fail(`${label}: sample_id ${record.sample_id} não corresponde ao arquivo ${csvName}`);
  }

  const duration = finiteNumber(record, "duration_real_s", label);
  if (duration < NOMINAL_WINDOW_S - DURATION_TOLERANCE_S
    || duration > NOMINAL_WINDOW_S + DURATION_TOLERANCE_S) {
    throw fail(`${label}: ${csvName} tem duração ${duration}s fora da tolerância de ±${DURATION_TOLERANCE_S}s`);
  }
  const frameCount = finiteNumber(record, "frame_count", label);
  if (frameCount <= 0) {
    throw fail(`${label}: ${csvName} tem frame_count inválido`);
  }
  for (const field of COST_FIELDS) {
    const value = finiteNumber(record, field, label);
    if (value < 0) throw fail(`${label}: ${csvName} tem valor negativo em ${field}`);
  }

  const sidecarPath = `${csvPath.slice(0, -".csv".length)}.sidecar.json`;
  let sidecar;
  try {
    sidecar = JSON.parse(await readFile(sidecarPath, "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") throw fail(`${label}: sidecar ausente para ${csvName}`);
    throw fail(`${label}: sidecar inválido para ${csvName}: ${error.message}`);
  }
  if (sidecar === null || Array.isArray(sidecar) || typeof sidecar !== "object") {
    throw fail(`${label}: sidecar não é um objeto JSON`);
  }
  assertExactFields(Object.keys(sidecar).sort(), [...REQUIRED_SIDECAR_FIELDS].sort(), `${label} ${csvName} sidecar`);
  for (const field of REQUIRED_SIDECAR_FIELDS) {
    if (sidecar[field] === null || sidecar[field] === undefined
      || (typeof sidecar[field] === "string" && sidecar[field].trim().length === 0)) {
      throw fail(`${label}: campo ausente no sidecar ${csvName}: ${field}`);
    }
  }
  for (const field of SIDECAR_STRING_FIELDS) {
    if (typeof sidecar[field] !== "string" || sidecar[field].trim().length === 0) {
      throw fail(`${label}: campo de texto inválido no sidecar ${csvName}: ${field}`);
    }
  }
  if (typeof sidecar.nominal_window_s !== "number" || !Number.isFinite(sidecar.nominal_window_s)
    || sidecar.nominal_window_s !== NOMINAL_WINDOW_S) {
    throw fail(`${label}: nominal_window_s deve ser o número ${NOMINAL_WINDOW_S} em ${csvName}`);
  }

  return { csvPath, sidecarPath, record, sidecar };
}

async function readPhase(input, label) {
  const paths = await resolveSamplePaths(input, label);
  const samples = await Promise.all(paths.map((path) => readSample(path, label)));
  if (samples.length < 3) throw inconclusive(`${label} precisa de três amostras`);
  if (samples.length > 3) throw fail(`${label} precisa de exatamente três amostras`);
  const ids = samples.map((sample) => sample.record.sample_id);
  if (new Set(ids).size !== ids.length) throw fail(`${label} possui sample_id duplicado`);
  return samples;
}

function validateComparableManifests(baseline, revised) {
  const all = [...baseline, ...revised];
  const first = canonicalJson(all[0].sidecar);
  if (all.some((sample) => canonicalJson(sample.sidecar) !== first)) {
    throw fail("manifestos sidecar divergentes; baseline e versão revisada não são comparáveis");
  }
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

function comparePhases(baseline, revised) {
  const baselineById = new Map(baseline.map((sample) => [sample.record.sample_id, sample]));
  const revisedById = new Map(revised.map((sample) => [sample.record.sample_id, sample]));
  if (baselineById.size !== revisedById.size
    || [...baselineById.keys()].some((id) => !revisedById.has(id))) {
    throw fail("baseline e versão revisada precisam usar os mesmos três sample_id");
  }

  const comparison = COST_FIELDS.map((field) => {
    const before = median(baseline.map((sample) => Number(sample.record[field])));
    const after = median(revised.map((sample) => Number(sample.record[field])));
    const change = percentChange(before, after);
    const pairwiseReductions = [...baselineById.entries()].filter(([id, sample]) =>
      Number(revisedById.get(id).record[field]) < Number(sample.record[field])).length;
    return { field, before, after, change, pairwiseReductions };
  });
  const regressions = comparison.filter((entry) => entry.change > MAX_REGRESSION_PERCENT);
  const reproducibleReductions = comparison.filter((entry) =>
    entry.after < entry.before && entry.pairwiseReductions >= 2);
  const frameTimeP95 = comparison.find((entry) => entry.field === "frame_time_p95_ms");
  const allocationMetric = comparison.find((entry) => entry.field === ALLOCATION_METRIC);
  return {
    comparison,
    regressions,
    reproducibleReductions,
    frameTimeP95,
    allocationGrowth: allocationMetric.after > allocationMetric.before,
  };
}

function printComparison(result) {
  for (const entry of result.comparison) {
    console.log(`${entry.field}: antes=${entry.before.toFixed(3)} depois=${entry.after.toFixed(3)} variação=${entry.change.toFixed(2)}%`);
  }
}

async function run() {
  const [baselineInput, revisedInput] = process.argv.slice(2);
  if (!baselineInput || !revisedInput) {
    throw inconclusive("Uso: node tools/compare-metrics.mjs <baseline-dir> <revised-dir>");
  }

  const phaseResults = await Promise.allSettled([
    readPhase(baselineInput, "baseline"),
    readPhase(revisedInput, "versão revisada"),
  ]);
  const phaseErrors = phaseResults
    .filter((result) => result.status === "rejected")
    .map((result) => result.reason);
  if (phaseErrors.length > 0) {
    const prioritizedError = phaseErrors.find((error) => error instanceof MetricsError
      && error.status === "FAIL") ?? phaseErrors[0];
    throw prioritizedError;
  }
  const [baseline, revised] = phaseResults.map((result) => result.value);
  validateComparableManifests(baseline, revised);
  const result = comparePhases(baseline, revised);
  printComparison(result);

  if (result.regressions.length > 0) {
    const fields = result.regressions.map((entry) => entry.field).join(", ");
    console.log(`METRICS CHECK: FAIL — regressão superior a ${MAX_REGRESSION_PERCENT}% em ${fields}`);
    console.error(`Diagnóstico: os custos ${fields} excederam o limite de regressão.`);
    return "FAIL";
  }
  if (result.frameTimeP95.after > MAX_FRAME_TIME_P95_MS) {
    console.log(`METRICS CHECK: FAIL — p95 agregado acima de ${MAX_FRAME_TIME_P95_MS} ms`);
    console.error(`Diagnóstico: o p95 agregado revisado foi ${result.frameTimeP95.after.toFixed(3)} ms; o limite obrigatório é ${MAX_FRAME_TIME_P95_MS} ms.`);
    return "FAIL";
  }
  if (result.allocationGrowth) {
    const allocation = result.comparison.find((entry) => entry.field === ALLOCATION_METRIC);
    console.log("METRICS CHECK: FAIL — allocations_per_frame cresceu");
    console.error(`Diagnóstico: allocations_per_frame passou de ${allocation.before.toFixed(3)} para ${allocation.after.toFixed(3)} na mediana das três amostras.`);
    return "FAIL";
  }
  if (result.reproducibleReductions.length === 0) {
    console.log("METRICS CHECK: INCONCLUSIVO — nenhuma redução mensurável e reproduzível");
    console.error("Diagnóstico: PASS exige redução na mediana e em pelo menos duas das três amostras.");
    return "INCONCLUSIVO";
  }

  const fields = result.reproducibleReductions.map((entry) => entry.field).join(", ");
  console.log(`METRICS CHECK: PASS — redução reproduzível em ${fields}; sem regressão superior a ${MAX_REGRESSION_PERCENT}%`);
  return "PASS";
}

const comparisonTimeout = setTimeout(() => {
  console.log("METRICS CHECK: FAIL");
  console.error("Diagnóstico: comparação excedeu o timeout fixo de 60s.");
  process.exit(124);
}, COMPARISON_TIMEOUT_MS);

run().then((status) => {
  clearTimeout(comparisonTimeout);
  if (status === "FAIL") process.exitCode = 1;
  if (status === "INCONCLUSIVO") process.exitCode = 2;
}).catch((error) => {
  clearTimeout(comparisonTimeout);
  const status = error instanceof MetricsError ? error.status : "FAIL";
  console.log(`METRICS CHECK: ${status}`);
  console.error(`Diagnóstico: ${error.message}`);
  process.exitCode = status === "INCONCLUSIVO" ? 2 : 1;
});
