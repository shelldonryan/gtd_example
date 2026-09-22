import { spawnSync } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const outputRoot = resolve(root, "last_horizon/output");
const evidenceRoot = resolve(outputRoot, "integrated");
const reportPath = resolve(outputRoot, "integrated-verification-report.json");
const profilingManifestPath = resolve(outputRoot, "profiling-run-manifest.json");
const profilingCollectionReportPath = resolve(outputRoot, "profiling-collection-report.json");
const profilingComparisonReportPath = resolve(outputRoot, "profiling-comparison.json");
const STATUS_ORDER = ["FAIL", "INCONCLUSIVO", "PASS"];
const COMMANDS = [
  {
    id: "typecheck",
    command: process.platform === "win32" ? "npm.cmd" : "npm",
    args: ["run", "typecheck"],
    timeout: 60_000,
  },
  {
    id: "build",
    command: process.platform === "win32" ? "npm.cmd" : "npm",
    args: ["run", "build"],
    timeout: 300_000,
  },
  { id: "capture", command: "bash", args: ["tools/run-headless.sh", "--capture"], timeout: 300_000 },
  { id: "hit-test", command: "bash", args: ["tools/run-headless.sh", "--hit-test"], timeout: 60_000 },
  { id: "ladder-test", command: "bash", args: ["tools/run-headless.sh", "--ladder-test"], timeout: 60_000 },
  {
    id: "asset-pipeline-test",
    command: "bash",
    args: ["tools/run-headless.sh", "--asset-pipeline-test"],
    timeout: 60_000,
  },
  {
    id: "optional-module-matrix",
    command: process.execPath,
    args: ["tools/optional-modules.mjs"],
    timeout: 300_000,
  },
  {
    id: "balance-simulation",
    command: process.execPath,
    args: ["prototype/balance-model.mjs", "--simulate"],
    timeout: 120_000,
  },
  {
    id: "windows-regression",
    command: process.execPath,
    args: ["tools/regression-windows.mjs"],
    timeout: 300_000,
  },
  {
    id: "profiling-collection",
    command: process.execPath,
    args: ["tools/profile-runner.mjs"],
    timeout: 1_500_000,
  },
  {
    id: "profiling-gate",
    command: process.execPath,
    args: ["tools/compare-profiling.mjs"],
    timeout: 60_000,
  },
  {
    id: "cleanup",
    command: process.execPath,
    args: ["tools/cleanup-verification-artifacts.mjs"],
    timeout: 60_000,
  },
  {
    id: "final-snapshot",
    command: process.execPath,
    args: ["tools/snapshot-entrega.mjs"],
    timeout: 300_000,
  },
];

function statusFromResult(result) {
  if (result.error?.code === "ENOENT") return "INCONCLUSIVO";
  if (result.error?.code === "ETIMEDOUT" || result.signal) return "FAIL";
  if (result.status === 0) return "PASS";
  if (result.status === 2) return "INCONCLUSIVO";
  return "FAIL";
}

function diagnosticFromResult(result) {
  if (result.error?.code === "ENOENT") return "pré-requisito ausente antes do início: comando não encontrado";
  if (result.error?.code === "ETIMEDOUT" || result.signal) return "execução iniciada e excedeu o timeout fixo";
  if (result.error) return result.error.message;
  return `processo terminou com código ${result.status}`;
}

async function runCommand(spec) {
  const startedAt = new Date().toISOString();
  const result = spawnSync(spec.command, spec.args, {
    cwd: root,
    encoding: "utf8",
    env: process.env,
    maxBuffer: 64 * 1024 * 1024,
    timeout: spec.timeout,
  });
  const stdout = result.stdout ?? "";
  const stderr = result.stderr ?? "";
  const status = statusFromResult(result);
  const diagnostic = status === "PASS" ? "" : diagnosticFromResult(result);
  const logPath = resolve(evidenceRoot, `${spec.id}.log`);
  await writeFile(logPath, [
    `command=${spec.command} ${spec.args.join(" ")}`,
    `started_at=${startedAt}`,
    `status=${status}`,
    `exit_code=${result.status ?? "null"}`,
    "[stdout]",
    stdout,
    "[stderr]",
    stderr,
    diagnostic.length > 0 ? `[diagnostic]\n${diagnostic}` : "",
  ].join("\n"), "utf8");
  if (stdout.length > 0) process.stdout.write(stdout);
  if (stderr.length > 0) process.stderr.write(stderr);
  console.log(`DELIVERY CHECK ${spec.id}: ${status}`);
  if (diagnostic.length > 0) console.error(`Diagnóstico: ${spec.id}: ${diagnostic}`);
  return {
    id: spec.id,
    status,
    exitCode: result.status,
    timeoutMs: spec.timeout,
    log: `last_horizon/output/integrated/${spec.id}.log`,
    diagnostic,
  };
}

async function validateIdentity() {
  let manifest;
  try {
    manifest = JSON.parse(await readFile(profilingManifestPath, "utf8"));
  } catch (error) {
    const status = error.code === "ENOENT" ? "INCONCLUSIVO" : "FAIL";
    return {
      id: "identity",
      status,
      diagnostic: `manifesto de profiling indisponível: ${error.message}`,
    };
  }
  const identityFor = (version, referenceOverride, manifestOverride) => {
    const entry = manifest?.[version];
    if (!entry || typeof entry.reference !== "string" || entry.reference.length === 0
      || typeof entry.digest !== "string" || entry.digest.length === 0
      || !Array.isArray(entry.files) || entry.files.length === 0) {
      return null;
    }
    return {
      reference: referenceOverride || entry.reference,
      manifest: manifestOverride || `${"last_horizon/output/profiling-run-manifest.json"}#${version}.digest=${entry.digest}`,
      manifestDigest: entry.digest,
      fileCount: entry.files.length,
    };
  };
  const baseline = identityFor(
    "baseline",
    process.env.BASELINE_REVISION ?? "",
    process.env.BASELINE_MANIFEST ?? "",
  );
  const revised = identityFor(
    "revised",
    process.env.REVISED_REVISION ?? "",
    process.env.REVISED_MANIFEST ?? "",
  );
  if (!baseline || !revised) {
    return {
      id: "identity",
      status: "INCONCLUSIVO",
      diagnostic: "manifesto de profiling não contém referências e manifestos exatos para baseline e versão revisada",
      baseline,
      revised,
    };
  }
  return {
    id: "identity",
    status: "PASS",
    diagnostic: "baseline e versão revisada possuem referências, digest e lista exata de arquivos no manifesto",
    baseline,
    revised,
  };
}

async function validateProfilingEvidence() {
  let collection;
  let comparison;
  try {
    collection = JSON.parse(await readFile(profilingCollectionReportPath, "utf8"));
    comparison = JSON.parse(await readFile(profilingComparisonReportPath, "utf8"));
  } catch (error) {
    return {
      id: "profiling-evidence",
      status: error.code === "ENOENT" ? "INCONCLUSIVO" : "FAIL",
      diagnostic: `relatório de profiling ausente ou inválido: ${error.message}`,
    };
  }
  const collectionResults = Array.isArray(collection.results) ? collection.results : [];
  const requiredLogPaths = [];
  for (const version of ["baseline", "revised"]) {
    for (const profile of ["core-i3-integrated", "reference"]) {
      for (const sample of ["sample-01", "sample-02", "sample-03"]) {
        requiredLogPaths.push(resolve(outputRoot, version, profile, "command-day1", `${sample}.log`));
      }
    }
  }
  let logsComplete = true;
  try {
    await Promise.all(requiredLogPaths.map((path) => readFile(path, "utf8")));
  } catch {
    logsComplete = false;
  }
  const collectionComplete = collection.schema === "profiling-collection-report-v1"
    && collection.status === "PASS"
    && collectionResults.length === 4
    && collectionResults.every((entry) => entry.status === "PASS")
    && logsComplete;
  const comparisonComplete = comparison.schema === "profiling-comparison-v1"
    && comparison.status === "PASS"
    && comparison.gateDecision === "PASS"
    && Array.isArray(comparison.costTable)
    && comparison.costTable.length === 16
    && comparison.costTable.every((entry) => entry.status === "PASS");
  if (!collectionComplete || !comparisonComplete) {
    return {
      id: "profiling-evidence",
      status: collection.status === "FAIL" || comparison.status === "FAIL" ? "FAIL" : "INCONCLUSIVO",
      diagnostic: "a coleta deve conter quatro combinações PASS com 12 artefatos e logs, e a comparação deve conter 16 custos PASS",
      collection: "last_horizon/output/profiling-collection-report.json",
      comparison: "last_horizon/output/profiling-comparison.json",
    };
  }
  return {
    id: "profiling-evidence",
    status: "PASS",
    diagnostic: "12 coletas PASS e 16 linhas de custo PASS cobrem os dois perfis, três amostras e cinco hotspots",
    collection: "last_horizon/output/profiling-collection-report.json",
    comparison: "last_horizon/output/profiling-comparison.json",
    manifest: "last_horizon/output/profiling-run-manifest.json",
  };
}

async function validateSnapshotManifest() {
  try {
    const manifest = JSON.parse(await readFile(resolve(root, "output/snapshot-entrega-manifest.json"), "utf8"));
    if (manifest.schema !== "snapshot-entrega-v1" || manifest.status !== "final" || manifest.final !== true) {
      return { id: "final-snapshot", status: "FAIL", diagnostic: "manifesto não representa um snapshot final" };
    }
    if (manifest.result === "fail") {
      return { id: "final-snapshot", status: "FAIL", diagnostic: "snapshot final contém falhas" };
    }
    if (manifest.result !== "pass") {
      return { id: "final-snapshot", status: "INCONCLUSIVO", diagnostic: "snapshot final não foi compilado integralmente" };
    }
    return {
      id: "final-snapshot",
      status: "PASS",
      diagnostic: "manifesto final e cópia compilada representam o estado pós-limpeza",
      manifest: "output/snapshot-entrega-manifest.json",
    };
  } catch (error) {
    return {
      id: "final-snapshot",
      status: error.code === "ENOENT" ? "INCONCLUSIVO" : "FAIL",
      diagnostic: `manifesto final ausente ou inválido: ${error.message}`,
    };
  }
}

async function validateEquivalenceReport() {
  let report;
  try {
    report = JSON.parse(await readFile(resolve(outputRoot, "equivalence-report.json"), "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") {
      return { id: "equivalence-report", status: "INCONCLUSIVO", diagnostic: "relatório canônico ausente antes da validação" };
    }
    return { id: "equivalence-report", status: "FAIL", diagnostic: `relatório canônico inválido: ${error.message}` };
  }
  if (report === null || typeof report !== "object" || Array.isArray(report)) {
    return { id: "equivalence-report", status: "FAIL", diagnostic: "relatório canônico não é um objeto" };
  }
  const expectedEntries = 22 * 34;
  if (report.schema !== "night-equivalence-v1" || report.quest_count !== 22
    || report.state_count !== 34 || report.expected_entries !== expectedEntries
    || !Array.isArray(report.entries) || report.entries.length !== expectedEntries) {
    return { id: "equivalence-report", status: "FAIL", diagnostic: "contrato de 22 quests × 34 estados inválido" };
  }
  const identifiers = new Set();
  const quests = new Set();
  const states = new Set();
  for (const entry of report.entries) {
    const identityValid = entry && typeof entry.identifier === "string"
      && typeof entry.quest_id === "string" && typeof entry.state_id === "string"
      && Number.isInteger(entry.day) && typeof entry.stage === "string"
      && (entry.status === "PASS" || entry.status === "FAIL")
      && Array.isArray(entry.differences) && typeof entry.application_valid === "boolean"
      && entry.reference && typeof entry.reference === "object"
      && entry.revised && typeof entry.revised === "object"
      && entry.fields && typeof entry.fields === "object";
    if (!identityValid || identifiers.has(entry.identifier) || entry.identifier !== `${entry.quest_id}::${entry.state_id}`) {
      return { id: "equivalence-report", status: "FAIL", diagnostic: "identificador ou estado inválido no relatório" };
    }
    if (entry.status === "PASS" && entry.differences.length !== 0) {
      return { id: "equivalence-report", status: "FAIL", diagnostic: `diferença omitida em ${entry.identifier}` };
    }
    if (entry.status === "FAIL" && entry.differences.length === 0) {
      return { id: "equivalence-report", status: "FAIL", diagnostic: `falha sem diferença em ${entry.identifier}` };
    }
    identifiers.add(entry.identifier);
    quests.add(entry.quest_id);
    states.add(entry.state_id);
  }
  if (quests.size !== 22 || states.size !== 34) {
    return { id: "equivalence-report", status: "FAIL", diagnostic: "o relatório não cobre todas as quests ou estados esperados" };
  }
  if (report.status === "FAIL") {
    return { id: "equivalence-report", status: "FAIL", diagnostic: "o relatório canônico contém diferenças" };
  }
  if (report.status !== "PASS") {
    return { id: "equivalence-report", status: "FAIL", diagnostic: "status inválido no relatório canônico" };
  }
  return { id: "equivalence-report", status: "PASS", diagnostic: "748 entradas comparadas campo a campo" };
}

function overallStatus(results) {
  return STATUS_ORDER.find((status) => results.some((result) => result.status === status)) ?? "INCONCLUSIVO";
}

async function main() {
  await mkdir(evidenceRoot, { recursive: true });
  const results = [];
  const initialCleanup = await runCommand({
    id: "cleanup-before",
    command: process.execPath,
    args: ["tools/cleanup-verification-artifacts.mjs"],
    timeout: 60_000,
  });
  results.push(initialCleanup);
  for (const command of COMMANDS) results.push(await runCommand(command));
  results.push(await validateIdentity());
  results.push(await validateProfilingEvidence());
  results.push(await validateSnapshotManifest());
  const equivalence = await validateEquivalenceReport();
  results.push(equivalence);
  const status = overallStatus(results);
  const identity = results.find((result) => result.id === "identity");
  const report = {
    schema: "integrated-delivery-verification-v1",
    generatedAt: new Date().toISOString(),
    baseline: identity?.baseline ?? { reference: "not provided", manifest: "not provided" },
    revised: identity?.revised ?? { reference: "not provided", manifest: "not provided" },
    evidence: {
      profilingManifest: "last_horizon/output/profiling-run-manifest.json",
      profilingCollection: "last_horizon/output/profiling-collection-report.json",
      profilingComparison: "last_horizon/output/profiling-comparison.json",
      equivalence: "last_horizon/output/equivalence-report.json",
      fallbackDiagnostics: "last_horizon/output/fallback-diagnostics.jsonl",
      finalSnapshotManifest: "output/snapshot-entrega-manifest.json",
    },
    results,
    status,
    decision: status === "PASS"
      ? "all required checks have valid evidence"
      : "delivery cannot be declared complete while a required check is FAIL or INCONCLUSIVO",
  };
  await writeFile(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(`INTEGRATED DELIVERY: ${status}`);
  if (status === "FAIL") process.exitCode = 1;
  else if (status === "INCONCLUSIVO") process.exitCode = 2;
}

main().catch((error) => {
  console.log("INTEGRATED DELIVERY: FAIL");
  console.error(`Diagnóstico: ${error.message}`);
  process.exitCode = 1;
});
