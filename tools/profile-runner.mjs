#!/usr/bin/env node

import { execFileSync, spawnSync } from "node:child_process";
import {
  cpSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { createHash } from "node:crypto";
import { arch, hostname, release } from "node:os";
import { isAbsolute, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("..", import.meta.url));
const sketchRoot = resolve(repositoryRoot, "last_horizon");
const outputRoot = resolve(sketchRoot, "output");
const processingRunner = resolve(repositoryRoot, "tools/processing-cli.sh");
const requiredProfiles = ["core-i3-integrated", "reference"];
const requiredVersions = ["baseline", "revised"];
const requestedVersions = process.argv.find((argument) => argument.startsWith("--versions="))
  ?.slice("--versions=".length).split(",").filter((version) => requiredVersions.includes(version));
const requestedBaselineRef = process.argv.find((argument) => argument.startsWith("--baseline-ref="))
  ?.slice("--baseline-ref=".length);
const sampleIds = ["sample-01", "sample-02", "sample-03"];
const scenario = "command-day1";
const collectionTimeoutMs = 1_500_000;
const processingTimeoutMs = 240_000;
function commandPath(command) {
  const result = spawnSync("bash", ["-lc", `command -v ${command}`], {
    encoding: "utf8",
    timeout: 10_000,
  });
  return result.status === 0 ? result.stdout.trim() : "";
}

function inspectProcessing() {
  let processingBin = process.env.PROCESSING_BIN || "";
  if (!processingBin && process.platform === "win32") {
    const found = spawnSync("where.exe", ["Processing.exe"], {
      encoding: "utf8",
      windowsHide: true,
      timeout: 10_000,
    });
    if (found.status === 0) {
      processingBin = found.stdout.split(/\r?\n/).find((line) => line.trim())?.trim() || "";
    }
    if (!processingBin) {
      const installed = join(process.env.ProgramFiles || "C:\\Program Files", "Processing", "Processing.exe");
      if (existsSync(installed)) processingBin = installed;
    }
  }
  if (!processingBin && process.platform === "linux") {
    processingBin = (existsSync("/opt/processing/bin/Processing") ? "/opt/processing/bin/Processing" : "")
      || commandPath("Processing") || commandPath("processing");
  }
  if (!processingBin) {
    return {
      available: false,
      path: null,
      version: null,
      diagnostic: "Processing CLI ausente no sistema e no PATH.",
    };
  }

  const result = spawnSync(processingBin, ["cli", "--help"], {
    encoding: "utf8",
    windowsHide: true,
    timeout: 10_000,
    maxBuffer: 1024 * 1024,
  });
  const output = `${result.stdout ?? ""}\n${result.stderr ?? ""}`;
  const match = output.match(/Command line edition for Processing\s+([^\s]+)/i);
  return {
    available: result.error == null && result.status === 0 && match != null,
    path: processingBin,
    version: match?.[1] ?? null,
    diagnostic: result.error?.message
      ?? (match && result.status === 0 ? "" : "Processing CLI não informou uma versão verificável."),
  };
}

function inspectAudioDevice() {
  if (process.platform === "win32") {
    return {
      available: null,
      deviceMetadata: "javax.sound.sampled",
      diagnostic: "Os clips e falhas de reprodução serão verificados pelo sketch durante a coleta.",
    };
  }
  if (process.platform !== "linux") {
    return {
      available: null,
      deviceMetadata: "/proc/asound/cards",
      diagnostic: "A disponibilidade não foi verificada neste sistema operacional.",
    };
  }
  try {
    const cards = readFileSync("/proc/asound/cards", "utf8").trim();
    const available = cards.length > 0 && !cards.includes("--- no soundcards ---");
    return {
      available,
      deviceMetadata: "/proc/asound/cards",
      diagnostic: available ? "" : "Nenhum dispositivo de áudio foi listado.",
    };
  } catch (error) {
    return {
      available: false,
      deviceMetadata: "/proc/asound/cards",
      diagnostic: error instanceof Error ? error.message : String(error),
    };
  }
}

const processingMetadata = inspectProcessing();
const xvfbRunPath = process.platform === "linux" ? commandPath("xvfb-run") : "";
const audioMetadata = inspectAudioDevice();
const nativeWindows = process.platform === "win32";
const environmentMetadata = {
  environment: nativeWindows
    ? "approved-metrics-fixture-v1-windows-native"
    : "approved-metrics-fixture-v1-linux-headless",
  machine: hostname() || "local-verification-host",
  gpu: nativeWindows ? "system-default" : "xvfb-renderer",
  host: {
    operatingSystem: `${process.platform} ${release()}`,
    architecture: arch(),
  },
  graphicalEnvironment: {
    mode: nativeWindows ? "native" : "headless",
    xvfbRunAvailable: xvfbRunPath.length > 0,
    xvfbRunPath: xvfbRunPath || null,
    renderer: nativeWindows ? "system-default" : "xvfb-renderer",
  },
  processing: processingMetadata,
  audio: audioMetadata,
};
const profilePrerequisiteDiagnostics = [
  ...(!nativeWindows && process.platform !== "linux"
    ? [`plataforma de profiling não suportada: ${process.platform}`]
    : []),
  ...(!processingMetadata.available
    ? [`pré-requisito ausente antes do início: Processing CLI (${processingMetadata.diagnostic})`]
    : []),
  ...(!processingMetadata.version
    ? ["pré-requisito ausente antes do início: versão verificável do Processing"]
    : []),
  ...(process.platform === "linux" && xvfbRunPath.length === 0
    ? ["pré-requisito ausente antes do início: xvfb-run"]
    : []),
  ...(process.platform === "linux" && audioMetadata.available !== true
    ? [`pré-requisito ausente antes do início: dispositivo de áudio (${audioMetadata.deviceMetadata}): ${audioMetadata.diagnostic}`]
    : []),
].filter(Boolean);
const manifestPath = resolve(outputRoot, "profiling-run-manifest.json");
const collectionReportPath = resolve(outputRoot, "profiling-collection-report.json");

function fail(message) {
  throw new Error(message);
}

function removeOutputPath(target) {
  const absoluteTarget = resolve(target);
  const insideOutput = relative(outputRoot, absoluteTarget);
  if (!insideOutput || insideOutput === ".." || insideOutput.startsWith(`..${sep}`)
    || isAbsolute(insideOutput)) {
    fail(`limpeza recusada fora de last_horizon/output: ${absoluteTarget}`);
  }
  rmSync(absoluteTarget, { recursive: true, force: true });
}

function git(...args) {
  return execFileSync("git", args, {
    cwd: repositoryRoot,
    encoding: "utf8",
    maxBuffer: 128 * 1024 * 1024,
  }).trim();
}

function sha256(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

function fileManifest(root, relativePaths) {
  return relativePaths.sort().map((relativePath) => ({
    path: relativePath,
    sha256: sha256(readFileSync(resolve(root, relativePath))),
  }));
}

function trackedPathsAtRevision(revision) {
  return git("ls-tree", "-r", "--name-only", revision).split("\n").filter(Boolean);
}

function isProfilingSourcePath(path) {
  return (path.startsWith("last_horizon/") && !path.startsWith("last_horizon/output/"))
    || path === "package.json" || path.startsWith("tools/")
    || path === "prototype/balance-model.mjs";
}

function currentSourcePaths() {
  const tracked = git("ls-files").split("\n").filter(Boolean);
  const untracked = git("ls-files", "--others", "--exclude-standard").split("\n").filter(Boolean);
  return [...new Set([...tracked, ...untracked])].filter(isProfilingSourcePath);
}

function extractRevision(revision, targetRoot) {
  const archive = execFileSync("git", ["archive", "--format=tar", revision], {
    cwd: repositoryRoot,
    encoding: "buffer",
    maxBuffer: 128 * 1024 * 1024,
  });
  execFileSync("tar", ["-xf", "-", "-C", targetRoot], { input: archive });
}

function baselineSupportsTemporalCapture(sourceRoot) {
  const capturePath = resolve(sourceRoot, "capture.pde");
  const source = readFileSync(capturePath, "utf8");
  return source.includes(".temporal.json")
    && source.includes("performance_temporal_clock_status");
}

function copySource(sourceRoot, targetRoot) {
  mkdirSync(targetRoot, { recursive: true });
  for (const entry of readdirSync(sourceRoot, { withFileTypes: true })) {
    if (entry.name === "output") continue;
    cpSync(resolve(sourceRoot, entry.name), resolve(targetRoot, entry.name), {
      recursive: true,
    });
  }
}

function runMetrics(version, profile, sourceRoot) {
  const executable = nativeWindows ? processingMetadata.path : "bash";
  const argumentsList = nativeWindows
    ? ["cli", `--sketch=${sourceRoot}`,
      `--output=${resolve(sourceRoot, "..", `${version}-${profile}-build`)}`,
      "--run", "--metrics"]
    : [processingRunner, "--run", "--metrics"];
  const result = spawnSync(executable, argumentsList, {
    cwd: repositoryRoot,
    encoding: "utf8",
    windowsHide: true,
    env: {
      ...process.env,
      PROCESSING_BIN: processingMetadata.path,
      HEADLESS: nativeWindows ? "0" : "1",
      SKETCH_SOURCE: sourceRoot,
      METRICS_VERSION: version,
      METRICS_PROFILE: profile,
      METRICS_ENVIRONMENT: environmentMetadata.environment,
      METRICS_MACHINE: environmentMetadata.machine,
      METRICS_GPU: environmentMetadata.gpu,
      METRICS_PROCESSING_VERSION: processingMetadata.version,
    },
    maxBuffer: 64 * 1024 * 1024,
    timeout: processingTimeoutMs,
  });
  const output = `${result.stdout ?? ""}\n${result.stderr ?? ""}`.trim();
  const hasPassMarker = /METRICS CHECK: PASS/.test(output);
  const audioCount = output.match(/som:\s*(\d+)\s+de\s+(\d+)\s+carregados/i);
  const audioReady = audioCount != null && Number(audioCount[1]) > 0
    && Number(audioCount[1]) === Number(audioCount[2]);
  const status = result.error?.code === "ENOENT"
    ? "INCONCLUSIVO"
    : result.error?.code === "ETIMEDOUT" || result.signal
      ? "FAIL"
      : result.status === 0 && hasPassMarker && audioReady
        ? "PASS"
        : result.status === 0 && hasPassMarker && !audioReady
          ? "INCONCLUSIVO"
        : result.status === 2
          ? "INCONCLUSIVO"
          : "FAIL";
  return {
    version,
    profile,
    scenario,
    status,
    exitCode: result.status,
    diagnostic: result.error?.message ?? (status === "PASS" ? ""
      : hasPassMarker && !audioReady
        ? "coleta sem confirmação do carregamento completo dos clips de áudio"
        : "coleta iniciada sem confirmação completa"),
    output,
  };
}

function copyCollectedOutput(sourceRoot, version, profile) {
  const sourceOutput = resolve(sourceRoot, "output", version, profile);
  const sourceProfiling = resolve(sourceRoot, "output", "profiling", version, profile);
  if (!existsSync(sourceOutput) || !existsSync(sourceProfiling)) return false;
  const targetOutput = resolve(outputRoot, version, profile);
  const targetProfiling = resolve(outputRoot, "profiling", version, profile);
  removeOutputPath(targetOutput);
  removeOutputPath(targetProfiling);
  mkdirSync(targetOutput, { recursive: true });
  mkdirSync(targetProfiling, { recursive: true });
  cpSync(sourceOutput, targetOutput, { recursive: true });
  cpSync(sourceProfiling, targetProfiling, { recursive: true });
  return true;
}

function writeCollectedLogs(version, profile, result) {
  const logRoot = resolve(outputRoot, version, profile, scenario);
  mkdirSync(logRoot, { recursive: true });
  const content = [
    `version=${version}`,
    `profile=${profile}`,
    `scenario=${scenario}`,
    `status=${result.status}`,
    `exit_code=${result.exitCode ?? "null"}`,
    "[output]",
    result.output,
    result.diagnostic.length > 0 ? `[diagnostic]\n${result.diagnostic}` : "",
  ].join("\n");
  for (const sample of sampleIds) {
    writeFileSync(resolve(logRoot, `${sample}.log`), `${content}\n`, "utf8");
  }
}

function validateRequiredArtifacts(version, profile) {
  const profileRoot = resolve(outputRoot, "profiling", version, profile, scenario);
  const metricsRoot = resolve(outputRoot, version, profile);
  return sampleIds.flatMap((sample) => [
    resolve(metricsRoot, `${sample}.csv`),
    resolve(metricsRoot, `${sample}.sidecar.json`),
    resolve(metricsRoot, `${sample}.temporal.json`),
    resolve(profileRoot, `${sample}.json`),
  ]).every((path) => existsSync(path));
}

function baselineManifest(baselineRoot, revision) {
  const paths = trackedPathsAtRevision(revision).filter(isProfilingSourcePath);
  return {
    kind: "git-revision",
    reference: revision,
    source: `git archive ${revision}`,
    files: fileManifest(baselineRoot, paths),
  };
}

function revisedManifest() {
  const paths = currentSourcePaths().filter((path) => existsSync(resolve(repositoryRoot, path)));
  const files = fileManifest(repositoryRoot, paths);
  return {
    kind: "working-tree",
    reference: `working-tree:${sha256(Buffer.from(JSON.stringify(files)))}`,
    source: "current working tree",
    files,
  };
}

function manifestDigest(manifest) {
  return sha256(Buffer.from(JSON.stringify(manifest)));
}

function run() {
  if (!existsSync(sketchRoot) || !existsSync(resolve(sketchRoot, "last_horizon.pde"))) {
    fail(`sketch ausente: ${sketchRoot}`);
  }
  const baselineRevision = git("rev-parse", "--verify", requestedBaselineRef || "HEAD");
  mkdirSync(outputRoot, { recursive: true });
  const temporaryRoot = mkdtempSync(join(outputRoot, "last-horizon-profiling-"));
  const baselineRoot = resolve(temporaryRoot, "baseline");
  const revisedRoot = resolve(temporaryRoot, "revised", "last_horizon");
  const results = [];
  const startedAt = new Date().toISOString();
  try {
    mkdirSync(baselineRoot, { recursive: true });
    extractRevision(baselineRevision, baselineRoot);
    const baselineSourceRoot = resolve(baselineRoot, "last_horizon");
    if (!baselineSupportsTemporalCapture(baselineSourceRoot)) {
      profilePrerequisiteDiagnostics.push(
        `baseline ${baselineRevision} sem sidecar temporal comparável; selecione uma revisão com instrumentação temporal`,
      );
    }
    copySource(sketchRoot, revisedRoot);
    const runVersions = requestedVersions?.length > 0 ? requestedVersions : requiredVersions;
    if (profilePrerequisiteDiagnostics.length === 0){
      for (const version of runVersions) {
        removeOutputPath(resolve(outputRoot, version));
        removeOutputPath(resolve(outputRoot, "profiling", version));
      }
    }

    for (const version of runVersions) {
      const sourceRoot = version === "baseline"
        ? resolve(baselineRoot, "last_horizon")
        : revisedRoot;
      for (const profile of requiredProfiles) {
        if (Date.now() - Date.parse(startedAt) > collectionTimeoutMs) {
          results.push({ version, profile, scenario, status: "FAIL", diagnostic: "timeout agregado de profiling excedido" });
          break;
        }
        const result = profilePrerequisiteDiagnostics.length === 0
          ? runMetrics(version, profile, sourceRoot)
          : {
            version,
            profile,
            scenario,
            status: "INCONCLUSIVO",
            exitCode: 2,
            diagnostic: `coleta não iniciada: ${profilePrerequisiteDiagnostics.join("; ")}`,
            output: "",
          };
        const copied = profilePrerequisiteDiagnostics.length === 0
          ? copyCollectedOutput(sourceRoot, version, profile)
          : false;
        writeCollectedLogs(version, profile, result);
        const historicalArtifactsValid = validateRequiredArtifacts(version, profile);
        const artifactsValid = profilePrerequisiteDiagnostics.length === 0
          ? copied && historicalArtifactsValid
          : historicalArtifactsValid;
        const finalResult = {
          ...result,
          artifacts: artifactsValid ? "last_horizon/output/<versao>/<perfil>/<sample_id>.*" : "ausentes",
          historicalArtifactsRetained: profilePrerequisiteDiagnostics.length > 0 && artifactsValid,
          logPaths: sampleIds.map((sample) => `last_horizon/output/${version}/${profile}/${scenario}/${sample}.log`),
        };
        if (result.status === "PASS" && !artifactsValid) {
          finalResult.status = "FAIL";
          finalResult.diagnostic = "coleta terminou com PASS, mas artefatos canônicos estão ausentes";
        }
        results.push(finalResult);
        if (finalResult.status === "FAIL") break;
      }
      if (results.some((item) => item.status === "FAIL")) break;
    }

    const baseline = baselineManifest(baselineRoot, baselineRevision);
    const revised = revisedManifest();
    const manifest = {
      schema: "profiling-run-manifest-v1",
      generatedAt: new Date().toISOString(),
      baseline: { ...baseline, digest: manifestDigest(baseline) },
      revised: { ...revised, digest: manifestDigest(revised) },
      fixture: {
        scenario,
        samples: sampleIds,
        profiles: requiredProfiles,
        nominalWindowSeconds: 30,
        processingRunner: nativeWindows ? "Processing.exe cli" : "tools/processing-cli.sh",
        processingTimeoutMs,
        environment: environmentMetadata,
      },
      commandsExecuted: [{
        command: ["node", "tools/profile-runner.mjs", ...process.argv.slice(2)].join(" "),
        status: results.some((item) => item.status === "FAIL")
          ? "FAIL"
          : results.some((item) => item.status === "INCONCLUSIVO")
            ? "INCONCLUSIVO"
            : "PASS",
        startedAt,
        prerequisiteDiagnostics: profilePrerequisiteDiagnostics,
      }],
      results,
      artifacts: {
        collectionReport: "last_horizon/output/profiling-collection-report.json",
        comparisonReport: "last_horizon/output/profiling-comparison.json",
        profilingPattern: "last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json",
        metricsPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.csv",
        sidecarPattern: "last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json",
        logPattern: "last_horizon/output/<versao>/<perfil>/<cenario>/<amostra>.log",
      },
    };
    mkdirSync(outputRoot, { recursive: true });
    writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
    const failed = results.some((item) => item.status === "FAIL");
    const inconclusive = results.some((item) => item.status === "INCONCLUSIVO");
    const collectionStatus = failed ? "FAIL" : inconclusive ? "INCONCLUSIVO" : "PASS";
    writeFileSync(collectionReportPath, `${JSON.stringify({
      schema: "profiling-collection-report-v1",
      generatedAt: new Date().toISOString(),
      status: collectionStatus,
      manifest: "last_horizon/output/profiling-run-manifest.json",
      results,
    }, null, 2)}\n`, "utf8");
    console.log(`PROFILING COLLECTION: ${collectionStatus}`);
    if (collectionStatus === "FAIL") process.exitCode = 1;
    if (collectionStatus === "INCONCLUSIVO") process.exitCode = 2;
  } finally {
    removeOutputPath(temporaryRoot);
  }
}

try {
  run();
} catch (error) {
  console.log("PROFILING COLLECTION: FAIL");
  console.error(`Diagnóstico: ${error.message}`);
  process.exitCode = 1;
}
