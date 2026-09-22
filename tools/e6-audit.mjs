import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const checks = [];

async function readText(relativePath) {
  return readFile(resolve(root, relativePath), "utf8");
}

function assertCheck(label, condition) {
  checks.push({ label, passed: condition });
}

function countMatches(source, expression) {
  return [...source.matchAll(expression)].length;
}

function sourceBlock(source, startExpression) {
  const start = source.search(startExpression);
  if (start < 0) return "";
  const end = source.indexOf("};", start);
  return end < 0 ? "" : source.slice(start, end + 2);
}

async function run() {
  const files = {
    tasks: await readText("last_horizon/tasks.pde"),
    editorial: await readText("last_horizon/editorial.pde"),
    assets: await readText("last_horizon/assets.pde"),
    hud: await readText("last_horizon/hud.pde"),
    capture: await readText("last_horizon/capture.pde"),
    main: await readText("last_horizon/last_horizon.pde"),
    ship: await readText("last_horizon/ship.pde"),
    game: await readText("last_horizon/game.pde"),
    projection: await readText("last_horizon/night_projection.pde"),
    snapshot: await readText("tools/snapshot-entrega.mjs"),
    package: await readText("package.json"),
    spec: await readText("SPEC_ENXUGAMENTO_E_IMERSAO.md"),
    normalizedSpec: await readText("docs/Docs20260919_145427/SPEC20260919_145427.md"),
    metricsCompare: await readText("tools/compare-metrics.mjs"),
  };

  const questBlock = sourceBlock(files.tasks, /String\[\] quest_id\s*=\s*\{/);
  const editorialBlock = sourceBlock(files.editorial, /String\[\]\[\] editorial_catalog\s*=\s*\{/);
  const captureLabelBlock = sourceBlock(files.capture, /String\[\] capture_label\s*=\s*\{/);
  const questIds = [...questBlock.matchAll(/"([A-Z]+-[A-Z0-9]+)"/g)].map((match) => match[1]);
  const editorialIds = [...editorialBlock.matchAll(/\{"([A-Z]+-[A-Z0-9]+)"/g)].map((match) => match[1]);
  const runtimeSources = files.main + files.ship + files.tasks + files.game + files.projection;

  assertCheck("quatro salas", /ROOM_COUNT\s*=\s*4/.test(runtimeSources));
  assertCheck("quatro sobreviventes", /CREW_COUNT\s*=\s*4/.test(files.tasks));
  const resourceNames = ["ENERGY", "OXYGEN", "WATER", "FOOD", "MORALE", "PARTS"];
  assertCheck("seis recursos", resourceNames.every((name) =>
    new RegExp(`RESOURCE_${name}\\s*=`).test(runtimeSources)));
  assertCheck("dez dias", /TRIP_DAYS\s*=\s*10/.test(files.main));
  assertCheck("sete tipos de incidente", /PROBLEM_COUNT\s*=\s*7/.test(files.tasks));
  assertCheck("cinco incidentes sem reposição", /new int\[5\]/.test(files.tasks));
  assertCheck("22 quests mecânicas", questIds.length === 22);
  assertCheck("22 entradas editoriais ligadas por ID", editorialIds.length === 22
    && editorialIds.every((id, index) => id === questIds[index]));
  assertCheck("uma conclusão diária", /quest_completed/.test(files.tasks)
    && /dailyQuestFree\(\)/.test(files.tasks)
    && /QUEST_REASON_DAILY_LIMIT/.test(files.tasks));
  assertCheck("34 estados de captura", countMatches(captureLabelBlock, /"[^"]+"/g) === 34);
  assertCheck("10 contratos T01-T10", new Set(
    [...files.spec.matchAll(/\bT(?:0[1-9]|10)\b/g)].map((match) => match[0]),
  ).size === 10);
  assertCheck("7 etapas E0-E6", new Set(
    [...files.spec.matchAll(/\bE[0-6]\b/g)].map((match) => match[0]),
  ).size === 7);
  assertCheck("27 user stories", new Set(
    [...files.normalizedSpec.matchAll(/\bUS-(?:0[1-9]|1[0-9]|2[0-7])\b/g)].map((match) => match[0]),
  ).size === 27);
  assertCheck("matriz de rastreabilidade", /Matriz de Rastreabilidade/.test(files.normalizedSpec));

  for (const name of [
    "simulateNightTransition",
    "projectNight",
    "processNight",
    "uiLayer",
    "findButton",
    "currentObjectiveLine",
    "currentAlertLine",
  ]) {
    assertCheck(`contrato ${name}`, new RegExp(`\\b${name}\\s*\\(`).test(
      files.projection + files.main + files.hud + files.capture,
    ));
  }

  assertCheck("contador de ícones", /resource_icon_builds/.test(files.hud));
  assertCheck("contador de faixas", /deck_strip_builds/.test(files.assets));
  assertCheck("contador de invalidações", /cache_invalidations/.test(files.assets + files.hud));
  assertCheck("seis caches são preparados na carga", /prepareResourceIconCache\(\)/.test(files.assets));
  assertCheck("faixas compartilham entradas", /findDeckStripCacheEntry/.test(files.assets));
  assertCheck("contrato de cache no harness", /checkCacheContract\(\)/.test(files.capture));
  assertCheck("métricas têm três amostras", /PERFORMANCE_SAMPLE_COUNT\s*=\s*3/.test(files.capture));
  assertCheck("métricas têm janelas de 30 segundos", /PERFORMANCE_SAMPLE_NANOS\s*=\s*30000000000L/.test(files.capture));
  assertCheck("comparação investiga p95 acima de 10%", /INVESTIGATE/.test(files.metricsCompare)
    && /10/.test(files.metricsCompare));
  assertCheck("snapshot exclui capture.pde", /last_horizon\/capture\.pde/.test(files.snapshot));
  assertCheck("snapshot exclui test_mode.pde", /last_horizon\/test_mode\.pde/.test(files.snapshot));
  assertCheck("script de auditoria no package", /e6-audit\.mjs/.test(files.package));

  const failed = checks.filter((check) => !check.passed);
  for (const check of checks) {
    console.log(`${check.passed ? "OK" : "FAIL"} ${check.label}`);
  }
  console.log(`E6 AUDIT: ${failed.length === 0 ? "PASS" : "FAIL"} (${checks.length} checks)`);
  if (failed.length > 0) process.exitCode = 1;
}

run().catch((error) => {
  console.error(`E6 AUDIT: ERROR ${error.message}`);
  process.exitCode = 1;
});
