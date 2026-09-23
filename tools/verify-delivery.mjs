import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
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
  { id: "temporal-test", command: "bash", args: ["tools/run-headless.sh", "--temporal-test"], timeout: 300_000 },
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
const FEATURE_CRITERIA = [
  {
    feature: "feat-026",
    criteria: [
      {
        id: "feat-026-c1",
        criterion: "Cada amostra identifica versão, perfil, cenário, sample_id, cadence_fps, sequência de deltas, passos, tempo aceito, remanescente, descartado, distância e eventos lógicos.",
        checks: ["profiling-evidence"],
        evidence: ["last_horizon/output/<version>/<profile>/<sample_id>.temporal.json"],
      },
      {
        id: "feat-026-c2",
        criterion: "O sidecar contém callback_time_p95_ms, simulation_time_p95_ms, render_time_p95_ms, draw_base_time_p95_ms, draw_window_time_p95_ms e audio_dispatch_time_p95_ms.",
        checks: ["profiling-evidence"],
        evidence: ["last_horizon/output/<version>/<profile>/<sample_id>.temporal.json"],
      },
      {
        id: "feat-026-c3",
        criterion: "As métricas adicionais usam as mesmas amostras e a mesma janela do frame_time_p95_ms, com fronteiras de medição distintas.",
        checks: ["profiling-evidence"],
        evidence: ["last_horizon/output/profiling-comparison.json#temporalCadenceMetrics"],
      },
      {
        id: "feat-026-c4",
        criterion: "Status de relógio, áudio, asset e cache são registrados consistentemente; métrica ausente torna o artefato INCONCLUSIVO.",
        checks: ["profiling-evidence", "profiling-gate"],
        evidence: ["last_horizon/output/<version>/<profile>/<sample_id>.temporal.json#statuses", "last_horizon/output/profiling-comparison.json"],
      },
      {
        id: "feat-026-c5",
        criterion: "O sidecar registra por amostra os campos mínimos do FrameContext, incluindo sala, UI, pausa, relógio, harness, callback, passos, bordas, porta e versão confirmada.",
        checks: ["profiling-evidence"],
        evidence: ["last_horizon/output/<version>/<profile>/<sample_id>.temporal.json#callbacks"],
      },
      {
        id: "feat-026-c6",
        criterion: "As cadências 15, 30 e 60 FPS têm p95 separado para seis fases por callback; falta de cadência, amostra ou métrica é INCONCLUSIVO.",
        checks: ["profiling-evidence"],
        evidence: ["last_horizon/output/profiling-comparison.json#temporalCadenceMetrics"],
      },
    ],
  },
  {
    feature: "feat-027",
    criteria: [
      {
        id: "feat-027-c1",
        criterion: "O CSV canônico permanece com sample_id, duration_real_s, frame_count, frame_time_median_ms, frame_time_p95_ms, load_time_ms, additional_memory_bytes, icon_builds, floor_band_builds, cache_invalidations e allocations_per_frame.",
        checks: ["profiling-evidence"],
        evidence: ["last_horizon/output/<version>/<profile>/<sample_id>.csv"],
      },
      {
        id: "feat-027-c2",
        criterion: "compare-profiling.mjs rejeita amostras ausentes, manifestos incompatíveis, sidecars incompletos e mistura de identidade entre baseline e revisada.",
        checks: ["profiling-gate", "profiling-evidence"],
        evidence: ["last_horizon/output/profiling-comparison.json", "last_horizon/output/profiling-run-manifest.json"],
      },
      {
        id: "feat-027-c3",
        criterion: "Permanecem ativos os gates de p95 máximo de 33,3 ms, regressão máxima de 10% e tolerância de 1% para allocations_per_frame.",
        checks: ["profiling-gate"],
        evidence: ["last_horizon/output/profiling-comparison.json#gateDecision"],
      },
      {
        id: "feat-027-c4",
        criterion: "A comparação não exige ganho adicional de p95, alocações ou memória além dos gates aprovados.",
        checks: ["profiling-gate"],
        evidence: ["tools/compare-profiling.mjs", "last_horizon/output/profiling-comparison.json#costTable"],
      },
    ],
  },
  {
    feature: "feat-028",
    criteria: [
      {
        id: "feat-028-c1",
        criterion: "tools/run-headless.sh e tools/processing-cli.sh executam o cenário temporal sem interação e recusam início quando falta pré-requisito obrigatório.",
        checks: ["temporal-test"],
        evidence: ["last_horizon/output/integrated/temporal-test.log", "tools/run-headless.sh", "tools/processing-cli.sh"],
      },
      {
        id: "feat-028-c2",
        criterion: "tools/optional-modules.mjs compila e verifica base, capture, manual e complete.",
        checks: ["optional-module-matrix"],
        evidence: ["last_horizon/output/integrated/optional-module-matrix.log"],
      },
      {
        id: "feat-028-c3",
        criterion: "A combinação base não depende permanentemente de relógio fake, recorder ou cena de captura.",
        checks: ["optional-module-matrix"],
        evidence: ["last_horizon/output/integrated/optional-module-matrix.log", "tools/optional-modules.mjs"],
      },
      {
        id: "feat-028-c4",
        criterion: "A mera presença do harness, sem cenário ativo, não altera ordem, passos, áudio ou apresentação no caminho de produção.",
        checks: ["capture", "temporal-test", "optional-module-matrix"],
        evidence: ["last_horizon/output/integrated/capture.log", "last_horizon/output/integrated/temporal-test.log", "last_horizon/output/integrated/optional-module-matrix.log"],
      },
    ],
  },
  {
    feature: "feat-029",
    criteria: [
      {
        id: "feat-029-c1",
        criterion: "Executam-se, conforme pré-requisitos, typecheck, build, capture, hit-test, ladder-test, asset-pipeline-test, matriz opcional, balance-model --simulate, comparação de profiling e verification:final.",
        checks: ["command-status-contract"],
        evidence: ["last_horizon/output/integrated/", "last_horizon/output/integrated-verification-report.json"],
      },
      {
        id: "feat-029-c2",
        criterion: "Cada comando é PASS somente após execução com código zero e verificações satisfeitas, FAIL após execução falha, ou INCONCLUSIVO somente por pré-requisito ausente nomeado.",
        checks: ["command-status-contract"],
        evidence: ["last_horizon/output/integrated-verification-report.json#results"],
      },
      {
        id: "feat-029-c3",
        criterion: "A equivalência de 22 quests por 34 estados permanece PASS e game.pde, tasks.pde, night_projection.pde, editorial.pde e balance-model.mjs não sofrem alteração funcional.",
        checks: ["equivalence-report", "domain-boundary"],
        evidence: ["last_horizon/output/equivalence-report.json", "tools/verify-delivery.mjs#domain-boundary"],
      },
      {
        id: "feat-029-c4",
        criterion: "A busca final confirma callers atualizados de updateRoom, updatePlayerOnDeck, updatePlayerOnLadder, playerCurrentFrame, playDeckStepSound, playLadderStepSound e stopStepSounds, sem assinatura temporal obsoleta nos testes.",
        checks: ["temporal-callers"],
        evidence: ["last_horizon/output/integrated-verification-report.json#results/temporal-callers", "last_horizon/*.pde"],
      },
      {
        id: "feat-029-c5",
        criterion: "A matriz final associa D1–D5 a IDs de sprint/feature e evidência; opções rejeitadas permanecem fora dos requisitos ativos.",
        checks: ["decision-coverage"],
        evidence: ["last_horizon/output/integrated-verification-report.json#decisionCoverage", "last_horizon/output/integrated-verification-report.json#rejectedOptions"],
      },
      {
        id: "feat-029-c6",
        criterion: "O fechamento registra status e evidência para todos os critérios de feat-026 a feat-029; nenhuma feature é encerrada parcialmente, FAIL bloqueia conclusão e INCONCLUSIVO nomeia o pré-requisito sem contar como PASS.",
        checks: ["feature-coverage-definition"],
        evidence: ["last_horizon/output/integrated-verification-report.json#featureCoverage", "last_horizon/output/integrated-verification-report.json#results/feature-closure"],
      },
    ],
  },
];
const EXPECTED_FEATURE_CRITERION_COUNTS = new Map([
  ["feat-026", 6], ["feat-027", 4], ["feat-028", 4], ["feat-029", 6],
]);

function statusFromResult(result, prerequisiteDiagnostic) {
  if (result.error?.code === "ENOENT" && result.pid === undefined) return "INCONCLUSIVO";
  if (result.error?.code === "ETIMEDOUT" || result.signal) return "FAIL";
  if (result.status === 0 && result.pid !== undefined && !result.error) return "PASS";
  if (result.status === 2 && prerequisiteDiagnostic) return "INCONCLUSIVO";
  return "FAIL";
}

function diagnosticFromResult(result, status, prerequisiteDiagnostic) {
  if (status === "INCONCLUSIVO" && prerequisiteDiagnostic) return prerequisiteDiagnostic;
  if (result.error?.code === "ENOENT" && result.pid === undefined) {
    return "pré-requisito ausente antes do início: comando não encontrado";
  }
  if (result.error?.code === "ETIMEDOUT" || result.signal) return "execução iniciada e excedeu o timeout fixo";
  if (result.status === 0 && result.pid === undefined) return "processo não foi iniciado; código zero isolado não comprova execução";
  if (result.error) return result.error.message;
  if (result.status === 2) {
    return "processo executado e terminou com código 2 sem pré-requisito ausente nomeado";
  }
  return `processo executado e terminou com código ${result.status}`;
}

function namedPrerequisite(output) {
  const match = output.match(/pré-requisito ausente(?: antes do início)?\s*:\s*([^\r\n]+)/i);
  return match ? `pré-requisito ausente antes do início: ${match[1].trim()}` : "";
}

async function prerequisiteForResult(spec, output) {
  const outputDiagnostic = namedPrerequisite(output);
  if (outputDiagnostic) return outputDiagnostic;
  if (spec.id === "profiling-collection") {
    try {
      const manifest = JSON.parse(await readFile(profilingManifestPath, "utf8"));
      const command = manifest.commandsExecuted?.[0];
      const diagnostics = command?.prerequisiteDiagnostics;
      if (manifest.schema === "profiling-run-manifest-v1"
        && command?.status === "INCONCLUSIVO"
        && Array.isArray(diagnostics) && diagnostics.length > 0
        && diagnostics.every((diagnostic) => typeof diagnostic === "string"
          && /pré-requisito ausente/i.test(diagnostic))) {
        return `pré-requisito ausente antes da coleta: ${diagnostics.join("; ")}`;
      }
    } catch {
      return "";
    }
  }
  if (spec.id === "profiling-gate") {
    try {
      const comparison = JSON.parse(await readFile(profilingComparisonReportPath, "utf8"));
      if (comparison.schema === "profiling-comparison-v1"
        && comparison.status === "INCONCLUSIVO"
        && typeof comparison.diagnostic === "string") {
        return namedPrerequisite(comparison.diagnostic);
      }
    } catch {
      return "";
    }
  }
  return "";
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
  const output = `${stdout}\n${stderr}`;
  const prerequisiteDiagnostic = result.status === 2
    ? await prerequisiteForResult(spec, output)
    : result.error?.code === "ENOENT" && result.pid === undefined
      ? `pré-requisito ausente antes do início: comando ${spec.command} não encontrado`
      : "";
  const status = statusFromResult(result, prerequisiteDiagnostic);
  const diagnostic = status === "PASS" ? ""
    : diagnosticFromResult(result, status, prerequisiteDiagnostic);
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
    executed: result.pid !== undefined,
    exitCode: result.status,
    timeoutMs: spec.timeout,
    log: `last_horizon/output/integrated/${spec.id}.log`,
    diagnostic,
    prerequisite: status === "INCONCLUSIVO" ? prerequisiteDiagnostic : null,
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
      diagnostic: error.code === "ENOENT"
        ? `pré-requisito ausente: manifesto de profiling (${profilingManifestPath})`
        : `manifesto de profiling inválido: ${error.message}`,
    };
  }
  if (manifest?.schema !== "profiling-run-manifest-v1") {
    return { id: "identity", status: "FAIL", diagnostic: "schema do manifesto de profiling inválido" };
  }
  const identityFor = (version, referenceOverride, manifestOverride) => {
    const entry = manifest?.[version];
    if (!entry || typeof entry.reference !== "string" || entry.reference.length === 0
      || typeof entry.digest !== "string" || !/^[a-f0-9]{64}$/i.test(entry.digest)
      || !Array.isArray(entry.files) || entry.files.length === 0) {
      return null;
    }
    const { digest, ...payload } = entry;
    const calculatedDigest = createHash("sha256").update(JSON.stringify(payload)).digest("hex");
    if (calculatedDigest !== digest.toLowerCase()) return { invalid: true, version };
    if (entry.files.some((file) => !file || typeof file.path !== "string"
      || file.path.length === 0 || typeof file.sha256 !== "string"
      || !/^[a-f0-9]{64}$/i.test(file.sha256))) return { invalid: true, version };
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
      diagnostic: "pré-requisito ausente: manifesto de profiling sem referências e inventários exatos para baseline e versão revisada",
      baseline,
      revised,
    };
  }
  if (baseline.invalid || revised.invalid) {
    return {
      id: "identity",
      status: "FAIL",
      diagnostic: `digest ou inventário de arquivos inválido em ${baseline.version ?? revised.version}`,
    };
  }
  if ((process.env.BASELINE_REVISION && process.env.BASELINE_REVISION !== manifest.baseline.reference)
    || (process.env.REVISED_REVISION && process.env.REVISED_REVISION !== manifest.revised.reference)) {
    return {
      id: "identity",
      status: "FAIL",
      diagnostic: "revisões solicitadas divergem das identidades do manifesto de profiling",
      baseline,
      revised,
    };
  }
  if (baseline.reference === revised.reference || baseline.manifestDigest === revised.manifestDigest) {
    return {
      id: "identity",
      status: "FAIL",
      diagnostic: "baseline e versão revisada compartilham a mesma identidade de execução",
      baseline,
      revised,
    };
  }
  const fixture = manifest.fixture;
  if (fixture?.scenario !== "command-day1" || fixture?.nominalWindowSeconds !== 30
    || !Array.isArray(fixture?.samples) || fixture.samples.length !== 3
    || !["sample-01", "sample-02", "sample-03"].every((sample) => fixture.samples.includes(sample))
    || !Array.isArray(fixture?.profiles) || fixture.profiles.length !== 2
    || !["core-i3-integrated", "reference"].every((profile) => fixture.profiles.includes(profile))) {
    return {
      id: "identity",
      status: "FAIL",
      diagnostic: "fixture do manifesto não é comparável entre baseline e versão revisada",
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
  let runManifest;
  try {
    collection = JSON.parse(await readFile(profilingCollectionReportPath, "utf8"));
    comparison = JSON.parse(await readFile(profilingComparisonReportPath, "utf8"));
    runManifest = JSON.parse(await readFile(profilingManifestPath, "utf8"));
  } catch (error) {
    return {
      id: "profiling-evidence",
      status: error.code === "ENOENT" ? "INCONCLUSIVO" : "FAIL",
      diagnostic: error.code === "ENOENT"
        ? `pré-requisito ausente: relatório de profiling (${error.message})`
        : `relatório de profiling inválido: ${error.message}`,
    };
  }
  if (collection === null || typeof collection !== "object" || Array.isArray(collection)
    || comparison === null || typeof comparison !== "object" || Array.isArray(comparison)
    || runManifest === null || typeof runManifest !== "object" || Array.isArray(runManifest)) {
    return {
      id: "profiling-evidence",
      status: "FAIL",
      diagnostic: "relatórios de coleta e comparação precisam ser objetos JSON",
    };
  }
  const collectionResults = Array.isArray(collection.results) ? collection.results : [];
  const requiredLogPaths = [];
  for (const version of ["baseline", "revised"]) {
    for (const profile of ["core-i3-integrated", "reference"]) {
      for (const sample of ["sample-01", "sample-02", "sample-03"]) {
        requiredLogPaths.push(resolve(outputRoot, version, profile, "command-day1", `${sample}.log`));
        requiredLogPaths.push(resolve(outputRoot, version, profile, `${sample}.temporal.json`));
      }
    }
  }
  const logResults = await Promise.allSettled(requiredLogPaths.map((path) => readFile(path, "utf8")));
  const missingLogs = requiredLogPaths.filter((path, index) => logResults[index].status === "rejected");
  const logsComplete = missingLogs.length === 0;
  const collectionComplete = collection.schema === "profiling-collection-report-v1"
    && collection.manifest === "last_horizon/output/profiling-run-manifest.json"
    && collection.status === "PASS"
    && collectionResults.length === 4
    && collectionResults.every((entry) => entry.status === "PASS")
    && logsComplete;
  const temporalEntries = Array.isArray(comparison.temporalCadenceMetrics)
    ? comparison.temporalCadenceMetrics : [];
  const temporalKeys = new Set(temporalEntries.map((entry) =>
    `${entry?.profile}/${entry?.cadence_fps}/${entry?.metric}`));
  const expectedTemporalKeys = new Set(["core-i3-integrated", "reference"].flatMap((profile) =>
    [15, 30, 60].flatMap((cadence) => [
      "callback_time_p95_ms", "simulation_time_p95_ms", "render_time_p95_ms",
      "draw_base_time_p95_ms", "draw_window_time_p95_ms", "audio_dispatch_time_p95_ms",
    ].map((metric) => `${profile}/${cadence}/${metric}`))));
  const comparisonComplete = comparison.schema === "profiling-comparison-v1"
    && comparison.status === "PASS"
    && comparison.gateDecision === "PASS"
    && comparison.runManifest?.path === "last_horizon/output/profiling-run-manifest.json"
    && comparison.runManifest.baselineReference === runManifest.baseline?.reference
    && comparison.runManifest.baselineDigest === runManifest.baseline?.digest
    && comparison.runManifest.revisedReference === runManifest.revised?.reference
    && comparison.runManifest.revisedDigest === runManifest.revised?.digest
    && Array.isArray(comparison.costTable)
    && comparison.costTable.length === 16
    && comparison.costTable.every((entry) => entry.status === "PASS")
    && temporalEntries.length === 36
    && temporalKeys.size === expectedTemporalKeys.size
    && [...expectedTemporalKeys].every((key) => temporalKeys.has(key))
    && temporalEntries.every((entry) => Number.isFinite(entry.baseline)
      && Number.isFinite(entry.revised)
      && [15, 30, 60].includes(entry.cadence_fps)
      && Array.isArray(entry.baselineSamples) && entry.baselineSamples.length === 1
      && Array.isArray(entry.revisedSamples) && entry.revisedSamples.length === 1
      && entry.baselineSamples[0] === entry.revisedSamples[0]);
  if (!collectionComplete || !comparisonComplete) {
    const failedCollection = collection.status === "FAIL"
      || collectionResults.some((entry) => entry.status === "FAIL");
    const failedComparison = comparison.status === "FAIL"
      || (Array.isArray(comparison.costTable)
        && comparison.costTable.some((entry) => entry.status === "FAIL"));
    const prerequisiteCandidates = [
      ...collectionResults.map((entry) => entry.diagnostic),
      comparison.diagnostic,
    ].filter((value) => typeof value === "string");
    const namedMissingPrerequisite = prerequisiteCandidates
      .map((diagnostic) => namedPrerequisite(diagnostic))
      .find(Boolean);
    const status = failedCollection || failedComparison || !namedMissingPrerequisite
      ? "FAIL" : "INCONCLUSIVO";
    return {
      id: "profiling-evidence",
      status,
      diagnostic: status === "INCONCLUSIVO"
        ? namedMissingPrerequisite
        : `evidência de profiling incompleta após execução; logs ausentes: ${missingLogs.map((path) => path.replace(`${root}/`, "")).join(", ") || "nenhum"}`,
      collection: "last_horizon/output/profiling-collection-report.json",
      comparison: "last_horizon/output/profiling-comparison.json",
    };
  }
  return {
    id: "profiling-evidence",
    status: "PASS",
    diagnostic: "12 coletas PASS, 16 custos canônicos PASS e 36 métricas temporais cobrem os dois perfis, três cadências e seis fases",
    collection: "last_horizon/output/profiling-collection-report.json",
    comparison: "last_horizon/output/profiling-comparison.json",
    manifest: "last_horizon/output/profiling-run-manifest.json",
  };
}

async function validateSnapshotManifest() {
  try {
    const manifest = JSON.parse(await readFile(resolve(root, "output/snapshot-entrega-manifest.json"), "utf8"));
    if (manifest.schema !== "snapshot-entrega-v1" || manifest.status !== "final" || manifest.final !== true) {
      return { id: "final-snapshot-evidence", status: "FAIL", diagnostic: "manifesto não representa um snapshot final" };
    }
    if (manifest.result === "fail") {
      return { id: "final-snapshot-evidence", status: "FAIL", diagnostic: "snapshot final contém falhas" };
    }
    if (manifest.result !== "pass") {
      const prerequisite = manifest.optionalModuleCompileMatrix?.flatMap((entry) =>
        entry.diagnostic ? [entry.diagnostic] : []).find((diagnostic) => /pré-requisito ausente/i.test(diagnostic));
      return prerequisite
        ? { id: "final-snapshot-evidence", status: "INCONCLUSIVO", diagnostic: `pré-requisito ausente: ${prerequisite}` }
        : { id: "final-snapshot-evidence", status: "FAIL", diagnostic: "snapshot executado sem resultado integral e sem pré-requisito nomeado" };
    }
    const expectedExclusions = [
      "output/snapshot-entrega", "output/snapshot-entrega-manifest.json",
      "last_horizon/capture.pde", "last_horizon/test_mode.pde", "prototype", "tools",
    ];
    const requiredRuntime = [
      "last_horizon/last_horizon.pde", "last_horizon/frame.pde", "last_horizon/game.pde",
      "last_horizon/tasks.pde", "last_horizon/night_projection.pde", "last_horizon/editorial.pde",
    ];
    const requiredExcludedFiles = [
      "last_horizon/capture.pde", "last_horizon/test_mode.pde",
      "prototype/balance-model.mjs", "tools/compare-profiling.mjs",
      "tools/profile-runner.mjs", "tools/verify-delivery.mjs",
    ];
    const checks = manifest.runtimeChecks;
    if (manifest.exclusionPolicy?.inherited !== true
      || !Array.isArray(manifest.exclusionPolicy.entries)
      || expectedExclusions.some((path) => !manifest.exclusionPolicy.entries.includes(path))
      || !Array.isArray(manifest.excluded)
      || expectedExclusions.some((path) => !manifest.excluded.includes(path))
      || !Array.isArray(manifest.excludedFiles)
      || requiredExcludedFiles.some((path) => !manifest.excludedFiles.includes(path))
      || !Array.isArray(manifest.runtimeFiles)
      || requiredRuntime.some((path) => !manifest.runtimeFiles.includes(path))
      || !manifest.runtimeFiles.includes("last_horizon/frame.pde")
      || manifest.runtimeFiles.some((path) => path === "last_horizon/capture.pde"
        || path === "last_horizon/test_mode.pde" || path.startsWith("tools/")
        || path.startsWith("prototype/"))
      || checks?.allOptionalCombinationsCompile !== true
      || checks?.intermediateCopyCompiles !== true
      || checks?.optionalControlsAbsent !== true
      || checks?.transientOutputAbsent !== true
      || !Array.isArray(checks?.missingTrackedFiles) || checks.missingTrackedFiles.length > 0
      || !Array.isArray(checks?.forbiddenControlMatches) || checks.forbiddenControlMatches.length > 0
      || !Array.isArray(checks?.transientOutputMatches) || checks.transientOutputMatches.length > 0) {
      return {
        id: "final-snapshot-evidence",
        status: "FAIL",
        diagnostic: "manifesto do snapshot não comprova exclusões herdadas, runtime preservado e verificações completas",
      };
    }
    return {
      id: "final-snapshot-evidence",
      status: "PASS",
      diagnostic: "manifesto final e cópia compilada representam o estado pós-limpeza",
      manifest: "output/snapshot-entrega-manifest.json",
    };
  } catch (error) {
    return {
      id: "final-snapshot-evidence",
      status: error.code === "ENOENT" ? "INCONCLUSIVO" : "FAIL",
      diagnostic: error.code === "ENOENT"
        ? `pré-requisito ausente: manifesto final do snapshot (${error.message})`
        : `manifesto final inválido: ${error.message}`,
    };
  }
}

async function validateEquivalenceReport() {
  let report;
  try {
    report = JSON.parse(await readFile(resolve(outputRoot, "equivalence-report.json"), "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") {
      return { id: "equivalence-report", status: "INCONCLUSIVO", diagnostic: "pré-requisito ausente: relatório canônico de equivalência antes da validação" };
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

async function validateTemporalCallers() {
  let files;
  try {
    files = await readdir(resolve(root, "last_horizon"));
  } catch (error) {
    const status = error.code === "ENOENT" ? "INCONCLUSIVO" : "FAIL";
    return {
      id: "temporal-callers",
      status,
      diagnostic: status === "INCONCLUSIVO"
        ? `pré-requisito ausente: fontes Processing em last_horizon/ (${error.message})`
        : `fontes Processing ilegíveis: ${error.message}`,
    };
  }
  const pdeFiles = files.filter((file) => file.endsWith(".pde"));
  const sources = await Promise.all(pdeFiles.map((file) =>
    readFile(resolve(root, "last_horizon", file), "utf8")));
  const source = sources.join("\n")
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/\/\/[^\n]*/g, "");
  const requiredSignatures = [
    { name: "updateRoom", pattern: /\bvoid\s+updateRoom\s*\(\s*FrameContext\s+\w+\s*\)/ },
    { name: "updatePlayerOnDeck", pattern: /\bvoid\s+updatePlayerOnDeck\s*\(\s*FrameContext\s+\w+\s*\)/ },
    { name: "updatePlayerOnLadder", pattern: /\bvoid\s+updatePlayerOnLadder\s*\(\s*FrameContext\s+\w+\s*\)/ },
    { name: "playerCurrentFrame", pattern: /\bint\s+playerCurrentFrame\s*\(\s*\)/ },
    { name: "stopStepSounds", pattern: /\bvoid\s+stopStepSounds\s*\(\s*\)/ },
  ];
  const missingDefinitions = requiredSignatures.filter(({ pattern }) => !pattern.test(source))
    .map(({ name }) => name);
  const obsoleteCalls = ["updateRoom", "updatePlayerOnDeck", "updatePlayerOnLadder"]
    .flatMap((name) => [...source.matchAll(new RegExp(`\\b${name}\\s*\\(\\s*\\)`, "g"))]
      .map(() => `${name}()`));
  const obsoletePlayerFrameCalls = [...source.matchAll(/\bplayerCurrentFrame\s*\(([^)]*)\)/g)]
    .filter((match) => match[1].trim().length > 0)
    .map(() => "playerCurrentFrame(argument)");
  const removedAudioCalls = ["playDeckStepSound", "playLadderStepSound"]
    .filter((name) => new RegExp(`\\b${name}\\s*\\(`).test(source));
  const obsoleteStopCalls = [...source.matchAll(/\bstopStepSounds\s*\(([^)]*)\)/g)]
    .filter((match) => match[1].trim().length > 0)
    .map(() => "stopStepSounds(argument)");
  if (missingDefinitions.length > 0 || obsoleteCalls.length > 0
    || obsoletePlayerFrameCalls.length > 0
    || removedAudioCalls.length > 0 || obsoleteStopCalls.length > 0) {
    return {
      id: "temporal-callers",
      status: "FAIL",
      diagnostic: `assinaturas ou callers obsoletos: definições=${missingDefinitions.join(",") || "ok"}; updates=${obsoleteCalls.join(",") || "ok"}; playerCurrentFrame=${obsoletePlayerFrameCalls.join(",") || "ok"}; áudio=${removedAudioCalls.join(",") || "ok"}; stop=${obsoleteStopCalls.join(",") || "ok"}`,
    };
  }
  return {
    id: "temporal-callers",
    status: "PASS",
    diagnostic: `varredura de ${pdeFiles.length} arquivos Processing confirmou os updates temporais, playerCurrentFrame(), stopStepSounds() e ausência dos callers removidos de áudio`,
    evidence: pdeFiles.map((file) => `last_horizon/${file}`),
  };
}

function validateDomainBoundary() {
  const protectedFiles = [
    "last_horizon/game.pde", "last_horizon/tasks.pde",
    "last_horizon/night_projection.pde", "last_horizon/editorial.pde",
    "prototype/balance-model.mjs",
  ];
  const result = spawnSync("git", ["diff", "--quiet", "HEAD", "--", ...protectedFiles], {
    cwd: root,
    encoding: "utf8",
    timeout: 10_000,
  });
  if (result.error?.code === "ENOENT") {
    return { id: "domain-boundary", status: "INCONCLUSIVO", diagnostic: "pré-requisito ausente: Git" };
  }
  if (result.status === 0) {
    return { id: "domain-boundary", status: "PASS", diagnostic: "arquivos de regras e modelo numérico não foram alterados", files: protectedFiles };
  }
  return { id: "domain-boundary", status: "FAIL", diagnostic: "há alterações em arquivo protegido de regras ou modelo", files: protectedFiles };
}

function decisionCoverage(results) {
  const resultFor = (id) => results.find((result) => result.id === id)?.status ?? "INCONCLUSIVO";
  const statusFor = (ids) => {
    const statuses = ids.map(resultFor);
    return statuses.includes("FAIL") ? "FAIL"
      : statuses.includes("INCONCLUSIVO") ? "INCONCLUSIVO" : "PASS";
  };
  return [
    { decision: "D1", features: ["feat-026"], checks: ["profiling-evidence"], evidence: ["last_horizon/output/<version>/<profile>/<sample>.temporal.json"] },
    { decision: "D2", features: ["feat-026", "feat-027"], checks: ["profiling-evidence"], evidence: ["last_horizon/output/<version>/<profile>/<sample>.temporal.json#discarded_sequence_seconds"] },
    { decision: "D3", features: ["feat-026", "feat-027"], checks: ["profiling-evidence", "temporal-test"], evidence: ["last_horizon/output/<version>/<profile>/<sample>.temporal.json#step_sequence"] },
    { decision: "D4", features: ["feat-026", "feat-029"], checks: ["capture", "profiling-evidence"], evidence: ["last_horizon/output/<version>/<profile>/<sample>.temporal.json#confirmed_state_version"] },
    { decision: "D5", features: ["feat-028", "feat-029"], checks: ["optional-module-matrix", "temporal-test", "domain-boundary"], evidence: ["last_horizon/output/integrated/optional-module-matrix.log", "last_horizon/output/integrated/temporal-test.log"] },
  ].map((entry) => ({ ...entry, status: statusFor(entry.checks) }));
}

const REJECTED_OPTIONS = {
  variableDelta: "NOT_INTRODUCED",
  temporalDebt: "NOT_INTRODUCED",
  compressedStep: "NOT_INTRODUCED",
  interpolation: "NOT_INTRODUCED",
  extrapolation: "NOT_INTRODUCED",
  broadFunctionalRefactor: "NOT_INTRODUCED",
};

function validateCommandStatusContract(results) {
  const requiredIds = ["cleanup-before", ...COMMANDS.map((command) => command.id)];
  const byId = new Map(results.map((result) => [result.id, result]));
  const missing = requiredIds.filter((id) => !byId.has(id));
  const invalid = requiredIds.flatMap((id) => {
    const result = byId.get(id);
    if (!result) return [];
    if (!["PASS", "FAIL", "INCONCLUSIVO"].includes(result.status)) return [`${id}: status inválido`];
    if (result.status === "PASS" && (result.executed !== true || result.exitCode !== 0)) {
      return [`${id}: PASS sem execução confirmada e código zero`];
    }
    if (result.status === "FAIL" && (result.executed !== true || result.exitCode === 0)) {
      return [`${id}: FAIL sem execução confirmada ou com código zero`];
    }
    if (result.status === "FAIL") return [`${id}: comando executado e falhou`];
    if (result.status === "INCONCLUSIVO" && !namedPrerequisite(result.diagnostic ?? "")) {
      return [`${id}: INCONCLUSIVO sem pré-requisito nomeado`];
    }
    return [];
  });
  const status = missing.length > 0 || invalid.length > 0 ? "FAIL" : "PASS";
  return {
    id: "command-status-contract",
    status,
    diagnostic: status === "PASS"
      ? `${requiredIds.length} comandos têm classificação ligada a execução, código de saída e pré-requisito nomeado`
      : `classificação de comandos inválida: ${[...missing.map((id) => `${id}: resultado ausente`), ...invalid].join("; ")}`,
    evidence: ["last_horizon/output/integrated-verification-report.json#results"],
  };
}

function validateFeatureCoverageDefinitions(results) {
  const definitions = FEATURE_CRITERIA.flatMap((feature) =>
    feature.criteria.map((criterion) => ({ feature: feature.feature, ...criterion })));
  const counts = new Map(FEATURE_CRITERIA.map((feature) => [feature.feature, feature.criteria.length]));
  const ids = definitions.map((criterion) => criterion.id);
  const duplicates = ids.filter((id, index) => ids.indexOf(id) !== index);
  const expectedIds = [...EXPECTED_FEATURE_CRITERION_COUNTS]
    .flatMap(([feature, count]) => Array.from({ length: count }, (_, index) => `${feature}-c${index + 1}`));
  const missingIds = expectedIds.filter((id) => !ids.includes(id));
  const unexpectedIds = ids.filter((id) => !expectedIds.includes(id));
  const invalidCounts = [...EXPECTED_FEATURE_CRITERION_COUNTS]
    .filter(([feature, count]) => counts.get(feature) !== count)
    .map(([feature, count]) => `${feature}: esperado ${count}, encontrado ${counts.get(feature) ?? 0}`);
  const checkIds = new Set([...results.map((result) => result.id), "feature-coverage-definition"]);
  const invalidDefinitions = definitions.flatMap((criterion) => {
    const problems = [];
    if (typeof criterion.criterion !== "string" || criterion.criterion.length === 0) problems.push("critério sem descrição");
    if (!Array.isArray(criterion.checks) || criterion.checks.length === 0) problems.push("critério sem verificações");
    if (!Array.isArray(criterion.evidence) || criterion.evidence.length === 0) problems.push("critério sem evidência");
    const evidenceText = Array.isArray(criterion.evidence) ? criterion.evidence.join(" ") : "";
    if (/Ctrl\+K|teleporte|snapshot-entrega|limpeza de comentários|auditoria lexical/i.test(`${criterion.criterion} ${evidenceText}`)) {
      problems.push("escopo antigo de controles, snapshot ou limpeza misturado à sprint temporal");
    }
    const unknownChecks = (Array.isArray(criterion.checks) ? criterion.checks : [])
      .filter((id) => !checkIds.has(id));
    if (unknownChecks.length > 0) problems.push(`verificações sem resultado: ${unknownChecks.join(", ")}`);
    return problems.map((problem) => `${criterion.id}: ${problem}`);
  });
  const status = duplicates.length > 0 || missingIds.length > 0 || unexpectedIds.length > 0
    || invalidCounts.length > 0 || invalidDefinitions.length > 0
    ? "FAIL" : "PASS";
  return {
    id: "feature-coverage-definition",
    status,
    diagnostic: status === "PASS"
      ? `${definitions.length} critérios únicos cobrem feat-026 a feat-029 com evidência e verificações registradas`
      : `matriz de features incompleta ou inválida: ${[
        ...duplicates.map((id) => `${id}: duplicado`),
        ...missingIds.map((id) => `${id}: ausente`),
        ...unexpectedIds.map((id) => `${id}: fora do escopo`),
        ...invalidCounts,
        ...invalidDefinitions,
      ].join("; ")}`,
    evidence: ["tools/verify-delivery.mjs#FEATURE_CRITERIA"],
  };
}

function validateDecisionCoverage(results) {
  const entries = decisionCoverage(results);
  const resultIds = new Set(results.map((result) => result.id));
  const expected = new Map([
    ["D1", ["feat-026"]],
    ["D2", ["feat-026", "feat-027"]],
    ["D3", ["feat-026", "feat-027"]],
    ["D4", ["feat-026", "feat-029"]],
    ["D5", ["feat-028", "feat-029"]],
  ]);
  const invalid = entries.length !== expected.size
    || [...expected].some(([decision, features]) => {
      const entry = entries.find((candidate) => candidate.decision === decision);
      return !entry || features.some((feature) => !entry.features.includes(feature)
        || !FEATURE_CRITERIA.some((definition) => definition.feature === feature))
        || !Array.isArray(entry.evidence) || entry.evidence.length === 0
        || entry.checks.some((checkId) => !resultIds.has(checkId))
        || !["PASS", "FAIL", "INCONCLUSIVO"].includes(entry.status);
    })
    || Object.values(REJECTED_OPTIONS).some((status) => status !== "NOT_INTRODUCED");
  return {
    id: "decision-coverage",
    status: invalid ? "FAIL" : "PASS",
    diagnostic: invalid
      ? "matriz D1–D5 não associa cada decisão a feature, evidência e status válidos ou opções rejeitadas foram ativadas"
      : "D1–D5 estão associados a critérios das features e evidências; opções rejeitadas seguem fora dos requisitos ativos",
    evidence: ["last_horizon/output/integrated-verification-report.json#decisionCoverage", "last_horizon/output/integrated-verification-report.json#rejectedOptions"],
  };
}

function validateFeatureClosure(featureCoverage) {
  const byId = new Map(featureCoverage.map((feature) => [feature.id, feature]));
  const invalid = [];
  for (const [featureId, expectedCount] of EXPECTED_FEATURE_CRITERION_COUNTS) {
    const feature = byId.get(featureId);
    if (!feature || !Array.isArray(feature.criteria) || feature.criteria.length !== expectedCount) {
      invalid.push(`${featureId}: cobertura de critérios incompleta`);
      continue;
    }
    for (const criterion of feature.criteria) {
      if (!criterion.id || !Array.isArray(criterion.evidence) || criterion.evidence.length === 0) {
        invalid.push(`${criterion.id || featureId}: falta ID ou evidência`);
      }
      if (!["PASS", "FAIL", "INCONCLUSIVO"].includes(criterion.status)) {
        invalid.push(`${criterion.id}: status inválido`);
      }
      if (criterion.status === "INCONCLUSIVO" && !/pré-requisito ausente/i.test(criterion.diagnostic ?? "")) {
        invalid.push(`${criterion.id}: INCONCLUSIVO sem pré-requisito nomeado`);
      }
    }
    const expectedStatus = feature.criteria.some((criterion) => criterion.status === "FAIL") ? "FAIL"
      : feature.criteria.some((criterion) => criterion.status === "INCONCLUSIVO") ? "INCONCLUSIVO" : "PASS";
    if (feature.status !== expectedStatus || feature.canClose !== (expectedStatus === "PASS")) {
      invalid.push(`${featureId}: fechamento parcial ou agregado incorreto`);
    }
  }
  const totalCriteria = featureCoverage.reduce((total, feature) => total + (feature.criteria?.length ?? 0), 0);
  if (featureCoverage.length !== EXPECTED_FEATURE_CRITERION_COUNTS.size || totalCriteria !== 20) {
    invalid.push(`esperados quatro features e 20 critérios; encontrados ${featureCoverage.length} features e ${totalCriteria} critérios`);
  }
  return {
    id: "feature-closure",
    status: invalid.length > 0 ? "FAIL" : "PASS",
    diagnostic: invalid.length > 0
      ? `fechamento de sprint incompleto: ${invalid.join("; ")}`
      : "20/20 critérios têm ID, evidência e status; nenhuma feature com FAIL ou INCONCLUSIVO está marcada como concluída",
    evidence: ["last_horizon/output/integrated-verification-report.json#featureCoverage"],
  };
}

function buildFeatureCoverage(results) {
  const resultsById = new Map(results.map((result) => [result.id, result]));
  return FEATURE_CRITERIA.map((feature) => {
    const criteria = feature.criteria.map((criterion) => {
      const checks = criterion.checks.map((id) => resultsById.get(id));
      const unnamedInconclusives = checks.filter((check) => check?.status === "INCONCLUSIVO"
        && !/pré-requisito ausente/i.test(check.diagnostic ?? ""));
      const missingChecks = criterion.checks.filter((id, index) => !checks[index]);
      const status = missingChecks.length > 0
        || checks.some((check) => !["PASS", "FAIL", "INCONCLUSIVO"].includes(check?.status))
        || checks.some((check) => check?.status === "FAIL")
        || unnamedInconclusives.length > 0 ? "FAIL"
        : checks.some((check) => check.status === "INCONCLUSIVO") ? "INCONCLUSIVO" : "PASS";
      const diagnostics = checks.filter((check) => check && check.status !== "PASS")
        .map((check) => `${check.id}: ${check.diagnostic}`);
      return {
        id: criterion.id,
        criterion: criterion.criterion,
        status,
        checks: criterion.checks,
        evidence: criterion.evidence,
        diagnostic: status === "PASS" ? ""
          : missingChecks.length > 0
            ? `FAIL: verificações ${missingChecks.join(", ")} não foram registradas`
            : unnamedInconclusives.length > 0
              ? `FAIL: verificações ${unnamedInconclusives.map((check) => check.id).join(", ")} marcaram INCONCLUSIVO sem pré-requisito nomeado`
            : diagnostics.join("; "),
      };
    });
    const status = criteria.some((criterion) => criterion.status === "FAIL") ? "FAIL"
      : criteria.some((criterion) => criterion.status === "INCONCLUSIVO") ? "INCONCLUSIVO" : "PASS";
    return {
      id: feature.feature,
      status,
      canClose: status === "PASS",
      criteria,
    };
  });
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
  results.push(await validateTemporalCallers());
  results.push(validateDomainBoundary());
  const equivalence = await validateEquivalenceReport();
  results.push(equivalence);
  results.push(validateCommandStatusContract(results));
  results.push(validateDecisionCoverage(results));
  results.push(validateFeatureCoverageDefinitions(results));
  for (const result of results) {
    if (result.status === "INCONCLUSIVO" && !/pré-requisito ausente/i.test(result.diagnostic ?? "")) {
      result.status = "FAIL";
      result.diagnostic = `classificação inválida: ${result.id} marcou INCONCLUSIVO sem pré-requisito ausente nomeado`;
    }
  }
  const featureCoverage = buildFeatureCoverage(results);
  results.push(validateFeatureClosure(featureCoverage));
  const status = overallStatus([...results, ...featureCoverage]);
  const inconclusiveDiagnostics = results.filter((result) => result.status === "INCONCLUSIVO")
    .map((result) => result.diagnostic);
  results.push({
    id: "verification:final",
    status,
    executed: true,
    exitCode: status === "PASS" ? 0 : status === "INCONCLUSIVO" ? 2 : 1,
    diagnostic: status === "INCONCLUSIVO"
      ? `pré-requisito ausente: ${inconclusiveDiagnostics.join("; ")}`
      : status === "FAIL" ? "um ou mais comandos, verificações ou critérios de feature falharam" : "",
  });
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
    featureCoverage,
    decisionCoverage: decisionCoverage(results),
    rejectedOptions: REJECTED_OPTIONS,
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
