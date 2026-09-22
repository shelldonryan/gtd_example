import { readFile, readdir } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const checks = [];

async function readText(relativePath) {
  return readFile(resolve(root, relativePath), "utf8");
}

async function readTransientEntries() {
  try {
    return await readdir(resolve(root, "last_horizon/output"));
  } catch (error) {
    if (error.code === "ENOENT") return [];
    throw error;
  }
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

function records(rows) {
  const [header, ...values] = rows;
  return values.map((row) => Object.fromEntries(
    header.map((key, index) => [key, row[index] ?? ""]),
  ));
}

function check(label, condition) {
  checks.push({ label, passed: condition });
}

function median(values) {
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[middle - 1] + sorted[middle]) / 2
    : sorted[middle];
}

async function run() {
  const evidence = JSON.parse(await readText("docs/evidence/e6-results.json"));
  const snapshot = JSON.parse(await readText("docs/snapshot-manifest.json"));
  const metrics = records(parseCsv(await readText("docs/metrics.csv")));
  const transientEntries = await readTransientEntries();
  const participants = evidence.participants;
  const requiredTasks = [
    "preventive", "acceptance", "collection", "delivery", "incident",
    "insufficientDelivery", "map", "fatalWarning", "voices",
  ];
  const specialScenarios = [
    "V-02", "N-02", "resume", "random hull", "rescue", "dead NPC",
    "missing target", "no route", "arbitrary door", "missing asset",
    "transmission over incident", "pause", "map", "help", "keyboard",
    "mouse", "cursor", "outside click",
  ];

  check("três participantes completos", participants.length === 3
    && participants.every((participant) => requiredTasks.every((task) => participant.tasks.includes(task))));
  check("cinco critérios calculados", Object.values(evidence.successCriteria)
    .every((criterion) => criterion.status === "pass" && criterion.observed >= criterion.target));
  check("roteiro observa salas, conveses, alerta, aceite, custo e vozes",
    participants.every((participant) => participant.route === "Depósito -> Comando -> Dormitório")
    && participants.every((participant) => participant.deckTraversal.length > 0)
    && participants.every((participant) => participant.fatalWarning)
    && participants.some((participant) => participant.selectionVsAcceptance)
    && participants.some((participant) => participant.costOrConsequence)
    && participants.some((participant) => participant.voices.length === 4));
  check("ajustes editoriais respeitam 160 caracteres e mecânica",
    evidence.editorialAdjustments.every((adjustment) => adjustment.characters <= 160
      && adjustment.text.length <= 160 && !adjustment.mechanicsChanged));
  const editorialA3 = evidence.editorialAdjustments.find((adjustment) => adjustment.id === "A3");
  check("A3 preserva voz e contrato de ENG-B",
    editorialA3 !== undefined
    && editorialA3.voice === "Sílvia"
    && editorialA3.text.includes("8 energia")
    && editorialA3.text.includes("motor será destruído")
    && !editorialA3.mechanicsChanged);

  const phases = new Set(metrics.map((record) => record.phase));
  const numericFields = [
    "duration_s", "frames", "frame_median_ms", "frame_p95_ms", "load_ms",
    "memory_additional_bytes", "resource_icon_builds", "deck_strip_builds",
    "cache_invalidations",
  ];
  check("seis amostras completas em janelas de 30 segundos",
    metrics.length === 6
    && phases.size === 2
    && [...phases].every((phase) => metrics.filter((record) => record.phase === phase).length === 3)
    && metrics.every((record) => Number(record.duration_s) === 30
      && numericFields.every((field) => Number.isFinite(Number(record[field])))));
  const environmentFields = ["environment", "machine", "assets", "room", "state", "window", "processing"];
  const baseline = metrics.filter((record) => record.phase === "baseline");
  const final = metrics.filter((record) => record.phase === "final");
  check("baseline e final usam ambiente e estado equivalentes",
    environmentFields.every((field) => new Set(metrics.map((record) => record[field])).size === 1));
  const p95Before = median(baseline.map((record) => Number(record.frame_p95_ms)));
  const p95After = median(final.map((record) => Number(record.frame_p95_ms)));
  const p95Change = ((p95After - p95Before) / p95Before) * 100;
  check("p95 não tem regressão consistente acima de 10%", p95Change <= 10
    && evidence.performance.investigation.includes("none required"));
  check("caches de seis ícones e faixa compartilhada", evidence.cacheContract.availableIconSources === 6
    && evidence.cacheContract.resourceIconBuilds === 6
    && evidence.cacheContract.identicalTileDeckStripBuilds === 1
    && evidence.cacheContract.immutableSharedStrip
    && evidence.cacheContract.selectiveInvalidations === 1);
  check("matriz funcional completa", evidence.functionalCoverage.rooms === 4
    && evidence.functionalCoverage.survivors === 4
    && evidence.functionalCoverage.resources === 6
    && evidence.functionalCoverage.days === 10
    && evidence.functionalCoverage.incidentDays.join(",") === "2,4,6,8,10"
    && evidence.functionalCoverage.incidentTypes === 7
    && evidence.functionalCoverage.incidentsWithoutReplacement === 5
    && evidence.functionalCoverage.questIds === 22
    && evidence.functionalCoverage.dailyCompletionLimit === 1
    && evidence.functionalCoverage.heldQuestObjects === 1);
  check("cenários especiais completos", specialScenarios.every((scenario) =>
    evidence.specialScenarios.includes(scenario)));
  check("snapshot exclui ferramentas e compila sem módulos opcionais",
    snapshot.excluded.includes("last_horizon/capture.pde")
    && snapshot.excluded.includes("last_horizon/test_mode.pde")
    && snapshot.runtimeChecks.allOptionalCombinationsCompile
    && snapshot.optionalModuleCompileMatrix.length === 4
    && snapshot.optionalModuleCompileMatrix.every((entry) => entry.result === "pass")
    && snapshot.runtimeFiles.every((file) => !snapshot.excluded.includes(file)));
  check("estado final da evidência é PASS", evidence.cacheContract.status === "pass"
    && evidence.performance.status === "pass"
    && evidence.snapshot.status === "pass"
    && evidence.modelAndFixtures.status === "pass"
    && evidence.modelAndFixtures.previewPure
    && evidence.modelAndFixtures.previewEqualsProcessedNight
    && evidence.modelAndFixtures.restorationBetweenFixtures
    && !evidence.modelAndFixtures.residualStateAfterRun);
  check("capturas, logs e temporários foram removidos",
    transientEntries.length === 0);

  const failed = checks.filter((item) => !item.passed);
  for (const item of checks) console.log(`${item.passed ? "OK" : "FAIL"} ${item.label}`);
  console.log(`E6 EVIDENCE: ${failed.length === 0 ? "PASS" : "FAIL"} (${checks.length} checks)`);
  if (failed.length > 0) process.exitCode = 1;
}

run().catch((error) => {
  console.error(`E6 EVIDENCE: ERROR ${error.message}`);
  process.exitCode = 1;
});
