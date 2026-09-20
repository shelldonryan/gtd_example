import { readFile } from "node:fs/promises";

/**
 * Parse the quoted CSV subset used by the performance report.
 *
 * @param {string} source - CSV source.
 * @returns {string[][]} Rows including the header.
 */
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

/**
 * Read a metrics file.
 *
 * @param {string} path - CSV path.
 * @returns {Promise<Array<Record<string, string>>>} Parsed rows.
 * @throws {Error} If the file is missing or has no data rows.
 */
async function readMetrics(path) {
  const rows = parseCsv(await readFile(path, "utf8"));
  if (rows.length < 2) throw new Error(`CSV sem amostras: ${path}`);
  const [header, ...values] = rows;
  return values.map((row) => Object.fromEntries(
    header.map((field, index) => [field, row[index] ?? ""]),
  ));
}

/**
 * Calculate the median of numeric values.
 *
 * @param {number[]} values - Values to rank.
 * @returns {number} Median value.
 * @throws {Error} If no numeric values are available.
 */
function median(values) {
  const sorted = values.filter(Number.isFinite).sort((left, right) => left - right);
  if (sorted.length === 0) throw new Error("Nenhum valor numérico disponível");
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[middle - 1] + sorted[middle]) / 2
    : sorted[middle];
}

/**
 * Assert that a phase has the expected comparable sample shape.
 *
 * @param {Array<Record<string, string>>} rows - Phase rows.
 * @param {string} label - Phase label for diagnostics.
 * @returns {void}
 */
function validatePhase(rows, label) {
  if (rows.length !== 3) throw new Error(`${label} precisa de três amostras`);
  if (!rows.every((row) => Number(row.duration_s) === 30)) {
    throw new Error(`${label} precisa de janelas de 30 segundos`);
  }
}

/**
 * Compare the median frame time and p95 from before/after samples.
 *
 * @returns {Promise<void>} Resolves after reporting the comparison.
 */
async function run() {
  const [baselinePath, finalPath] = process.argv.slice(2);
  if (!baselinePath || !finalPath) {
    throw new Error("Uso: node tools/compare-metrics.mjs <baseline.csv> <final.csv>");
  }

  const [baseline, final] = await Promise.all([
    readMetrics(baselinePath),
    readMetrics(finalPath),
  ]);
  validatePhase(baseline, "baseline");
  validatePhase(final, "final");

  const environmentFields = ["environment", "machine", "assets", "room", "state", "window", "processing"];
  for (const field of environmentFields) {
    const values = [...baseline, ...final].map((row) => row[field]);
    if (new Set(values).size !== 1) {
      throw new Error(`Ambiente não comparável no campo ${field}`);
    }
  }

  const beforeMedian = median(baseline.map((row) => Number(row.frame_median_ms)));
  const afterMedian = median(final.map((row) => Number(row.frame_median_ms)));
  const beforeP95 = median(baseline.map((row) => Number(row.frame_p95_ms)));
  const afterP95 = median(final.map((row) => Number(row.frame_p95_ms)));
  const medianChange = ((afterMedian - beforeMedian) / beforeMedian) * 100;
  const p95Change = ((afterP95 - beforeP95) / beforeP95) * 100;

  console.log(`frame_median_ms: antes=${beforeMedian.toFixed(3)} ms depois=${afterMedian.toFixed(3)} ms variação=${medianChange.toFixed(2)}%`);
  console.log(`frame_p95_ms: antes=${beforeP95.toFixed(3)} ms depois=${afterP95.toFixed(3)} ms variação=${p95Change.toFixed(2)}%`);
  if (p95Change > 10) {
    console.error("METRICS CHECK: INVESTIGATE — regressão consistente superior a 10% no p95");
    process.exitCode = 1;
    return;
  }
  console.log("METRICS CHECK: PASS — ambiente equivalente e nenhuma regressão superior a 10% no p95");
}

run().catch((error) => {
  console.error(`METRICS CHECK: ERROR ${error.message}`);
  process.exitCode = 1;
});
