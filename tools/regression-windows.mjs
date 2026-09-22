#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import {
  cpSync,
  existsSync,
  lstatSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  rmSync,
  rmdirSync,
  writeFileSync,
} from "node:fs";
import { join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

function reportInconclusive(reason, impact) {
  console.log(`PROCESSING REGRESSION: INCONCLUSIVO — ${reason}`);
  console.error(`Diagnóstico: ${reason} Impacto: ${impact}`);
  process.exit(2);
}

if (process.platform !== "win32") {
  reportInconclusive(
    "pré-requisito ausente antes do início: plataforma Windows",
    "Processing.exe e os quatro cenários Windows não foram executados; o resultado não é evidência de PASS",
  );
}

const repoRoot = fileURLToPath(new URL("..", import.meta.url));
const sketchRoot = join(repoRoot, "last_horizon");
const outputRoot = join(sketchRoot, "output");
const pipelineProbePng = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB6klEQVR4nBXS0RRAIQAE0YcQQgghhBBCCCGEEMIihBBCCCFksG/6vufM13zfJ4dPjp+cPjl/cvnk+sntkzs+cOETX/jGD37x7wtyCHIMcgpyDnIJcg1yC3LHBy584gvf+MFveIEohyjHKKco5yiXKNcotyh3fODCJ77wjR/8xhdIckhyTHJKck5ySXJNcktyxwcufOIL3/jBb3qBLIcsxyynLOcslyzXLLcsd3zgwie+8I0f/OYXKHIocixyKnIucilyLXIrcscHLnziC9/4wW95gSqHKscqpyrnKpcq1yq3Knd84MInvvCNH/zWF2hyaHJscmpybnJpcm1ya3LHBy584gvf+MFve4HOB50POh90Puh80Pmg80HnA3zgwie+8I0f/PYXGHww+GDwweCDwQeDDwYfDD7ABy584gvf+MHveAHxgfhAfCA+EB+ID8QH4gN84MInvvCNH/zqBSYfTD6YfDD5YPLB5IPJB5MP8IELn/jCN37wO19g8cHig8UHiw8WHyw+WHyw+AAfuPCJL3zjB7/rBTYfbD7YfLD5YPPB5oPNB5sP8IELn/jCN37wu1/g8MHhg8MHhw8OHxw+OHxw+AAfuPCJL3zjB7/nBS4fXD64fHD54PLB5YPLB5cP8IELn/jCN37wi/9CGo8f8dAk5gAAAABJRU5ErkJggg==";
const configuredProcessing = process.env.PROCESSING_BIN;
let processingExe = configuredProcessing;

if (!processingExe) {
  const where = spawnSync("where.exe", ["Processing.exe"], {
    encoding: "utf8",
    windowsHide: true,
  });
  if (where.error) {
    reportInconclusive(
      "pré-requisito ausente antes do início: where.exe",
      "não foi possível localizar Processing.exe e nenhum cenário foi iniciado",
    );
  }
  if (where.status === 0) {
    processingExe = where.stdout.split(/\r?\n/).find((line) => line.trim())?.trim();
  }
}

if (!processingExe) {
  const defaultPath = join(process.env.ProgramFiles ?? "C:\\Program Files", "Processing", "Processing.exe");
  if (existsSync(defaultPath)) processingExe = defaultPath;
}

if (!processingExe || !existsSync(processingExe)) {
  reportInconclusive(
    "pré-requisito ausente antes do início: Processing.exe",
    "nenhum cenário foi iniciado e a regressão Windows não pode ser considerada validada",
  );
}

const cliHelp = spawnSync(processingExe, ["cli", "--help"], {
  encoding: "utf8",
  windowsHide: true,
});
const cliHelpText = `${cliHelp.stdout ?? ""}\n${cliHelp.stderr ?? ""}`;
if (cliHelp.error) {
  reportInconclusive(
    "pré-requisito ausente antes do início: CLI do Processing",
    "Processing.exe não confirmou suporte ao modo CLI e nenhum cenário foi iniciado",
  );
}
if (cliHelp.status !== 0 || !cliHelpText.includes("Command line edition for Processing")) {
  reportInconclusive(
    `pré-requisito ausente antes do início: CLI do Processing (código ${cliHelp.status})`,
    "nenhum cenário foi iniciado porque a interface de execução não está disponível",
  );
}
const versionLine = cliHelpText.split(/\r?\n/)
  .find((line) => line.includes("Command line edition for Processing"))?.trim();
console.log(`Processing: ${versionLine}`);

if (!existsSync(sketchRoot) || !existsSync(join(sketchRoot, "last_horizon.pde"))) {
  reportInconclusive(
    `pré-requisito ausente antes do início: sketch ${join(sketchRoot, "last_horizon.pde")}`,
    "nenhum cenário foi iniciado porque a entrada da regressão não existe",
  );
}

const allScenarios = ["--capture", "--hit-test", "--ladder-test", "--asset-pipeline-test"];
const requestedScenarios = process.argv.slice(2);
const unknownScenarios = requestedScenarios.filter((scenario) => !allScenarios.includes(scenario));
if (unknownScenarios.length > 0) {
  throw new Error(`Cenário(s) desconhecido(s): ${unknownScenarios.join(", ")}`);
}
const scenarios = requestedScenarios.length > 0 ? requestedScenarios : allScenarios;
const SCENARIO_TIMEOUT_MS = 60_000;
const CAPTURE_TIMEOUT_MS = 300_000;
const REGRESSION_TIMEOUT_MS = 300_000;
const regressionStartedAt = Date.now();

if (existsSync(outputRoot)) {
  const outputStat = lstatSync(outputRoot);
  if (outputStat.isSymbolicLink() || !outputStat.isDirectory()) {
    reportInconclusive(
      `pré-requisito ausente antes do início: saída não é uma pasta comum (${outputRoot})`,
      "nenhum cenário foi iniciado para preservar o artefato existente",
    );
  }
} else {
  mkdirSync(outputRoot);
}

const runRoot = mkdtempSync(join(outputRoot, "windows-regression-"));
const scenarioEvidenceRoot = join(outputRoot, "regression-windows");
mkdirSync(scenarioEvidenceRoot, { recursive: true });
const failures = [];

try {
  for (const scenario of scenarios) {
    const remainingRegressionMs = REGRESSION_TIMEOUT_MS - (Date.now() - regressionStartedAt);
    if (remainingRegressionMs <= 0) {
      failures.push("regression: timeout fixo de 300s excedido");
      break;
    }
    const scenarioTimeoutMs = scenario === "--capture"
      ? CAPTURE_TIMEOUT_MS : SCENARIO_TIMEOUT_MS;
    const scenarioName = scenario.slice(2);
    const scenarioRoot = join(runRoot, scenarioName);
    const sketchCopy = join(scenarioRoot, "last_horizon");
    const buildRoot = join(scenarioRoot, "build");
    mkdirSync(sketchCopy, { recursive: true });

    for (const entry of readdirSync(sketchRoot, { withFileTypes: true })) {
      if (entry.name === "output") continue;
      cpSync(join(sketchRoot, entry.name), join(sketchCopy, entry.name), { recursive: true });
    }
    if (scenario === "--asset-pipeline-test") {
      const fixturePath = join(sketchCopy, "data", "pipeline_probe_frame_1.png");
      if (!existsSync(fixturePath)) {
        writeFileSync(fixturePath, Buffer.from(pipelineProbePng, "base64"));
      }
    }

    console.log(`\n=== Processing ${scenario} ===`);
    const result = spawnSync(processingExe, [
      "cli",
      `--sketch=${sketchCopy}`,
      `--output=${buildRoot}`,
      "--run",
      scenario,
    ], {
      cwd: repoRoot,
      encoding: "utf8",
      maxBuffer: 32 * 1024 * 1024,
      windowsHide: true,
      timeout: Math.min(scenarioTimeoutMs, remainingRegressionMs),
    });

    const scenarioOutput = `${result.stdout ?? ""}\n${result.stderr ?? ""}`;
    writeFileSync(join(scenarioEvidenceRoot, `${scenarioName}.log`), scenarioOutput, "utf8");
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
    const outputLines = scenarioOutput.split(/\r?\n/);

    let failure = "";
    if (result.error?.code === "ETIMEDOUT") {
      failure = remainingRegressionMs <= scenarioTimeoutMs
        ? "timeout fixo de 300s excedido"
        : `timeout fixo de ${scenarioTimeoutMs / 1000}s do cenário excedido`;
    } else if (result.error) failure = result.error.message;
    else if (result.status !== 0) failure = `código de saída ${result.status}`;
    else if (/\b(?:FAIL|FALHOU)\b/i.test(scenarioOutput)) failure = "o harness reportou falha";
    else if (/java\.lang\.\w+Exception\b/.test(scenarioOutput)) failure = "exceção Java durante a execução";
    else if (!outputLines.some((line) => line.trim() === "Finished.")) failure = "o Processing não confirmou a finalização do sketch";

    if (failure) {
      failures.push(`${scenario}: ${failure}`);
      console.error(`Diagnóstico: ${scenario}: ${failure}`);
    } else {
      console.log(`PASS ${scenario}`);
    }

    if (Date.now() - regressionStartedAt >= REGRESSION_TIMEOUT_MS) {
      if (!failure || !failure.includes("timeout fixo de 300s excedido")) {
        failures.push(`${scenario}: timeout fixo de 300s excedido`);
      }
      break;
    }
  }

  if (failures.length > 0) {
    console.log(`\nPROCESSING REGRESSION: FAIL (${failures.length}/${scenarios.length})`);
    console.error(`Diagnóstico: ${failures.length}/${scenarios.length} cenário(s) falharam.`);
    for (const failure of failures) console.error(`- ${failure}`);
    process.exitCode = 1;
  } else {
    console.log(`\nPROCESSING REGRESSION: PASS (${scenarios.length} cenário(s))`);
  }
} finally {
  const outputFullPath = resolve(outputRoot);
  const runFullPath = resolve(runRoot);
  const relativeRunPath = relative(outputFullPath, runFullPath);
  if (!relativeRunPath || relativeRunPath.startsWith(`..${sep}`) || relativeRunPath === ".." || relativeRunPath.includes(`..${sep}`)) {
    throw new Error(`Caminho temporário fora de last_horizon/output; limpeza recusada: ${runFullPath}`);
  }
  rmSync(runFullPath, { recursive: true, force: true });

  if (existsSync(outputRoot) && readdirSync(outputRoot).length === 0) {
    rmdirSync(outputRoot);
  }
}
