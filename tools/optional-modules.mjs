#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("..", import.meta.url));
const processingRunner = resolve(repositoryRoot, "tools/processing-cli.sh");
const sourceRoot = resolve(
  process.env.SKETCH_SOURCE ?? resolve(repositoryRoot, "last_horizon"),
);
const matrixOutputArgument = process.argv.find((argument) =>
  argument.startsWith("--json-output="),
);
const matrixOutput = matrixOutputArgument
  ? resolve(matrixOutputArgument.slice("--json-output=".length))
  : null;
const timeoutMs = 300_000;

const moduleMatrix = [
  { id: "base", modules: [] },
  { id: "capture", modules: ["capture.pde"] },
  { id: "manual", modules: ["test_mode.pde"] },
  { id: "complete", modules: ["capture.pde", "test_mode.pde"] },
];

function normalizeResult(status, error) {
  if (error?.code === "ENOENT") return "inconclusive";
  if (error?.code === "ETIMEDOUT") return "fail";
  if (status === 0) return "pass";
  if (status === 2) return "inconclusive";
  return "fail";
}

function runCombination(combination) {
  const result = spawnSync(
    "bash",
    [processingRunner, "--build", `--module-set=${combination.id}`],
    {
      cwd: repositoryRoot,
      encoding: "utf8",
      env: { ...process.env, SKETCH_SOURCE: sourceRoot },
      timeout: timeoutMs,
      maxBuffer: 16 * 1024 * 1024,
    },
  );
  const output = `${result.stdout ?? ""}\n${result.stderr ?? ""}`.trim();
  if (output.length > 0) process.stdout.write(`${output}\n`);
  const normalized = normalizeResult(result.status, result.error);
  const diagnostic = result.error?.message
    ?? (result.status === 0 ? "" : output.split("\n").at(-1) ?? "runner sem diagnóstico");
  return {
    id: combination.id,
    modules: combination.modules,
    result: normalized,
    exitCode: result.status,
    diagnostic,
  };
}

function verifyBaseIsolation() {
  const framePath = resolve(sourceRoot, "frame.pde");
  const audioPath = resolve(sourceRoot, "audio.pde");
  const mainPath = resolve(sourceRoot, "last_horizon.pde");
  const capturePath = resolve(sourceRoot, "capture.pde");
  if (![framePath, audioPath, mainPath, capturePath].every(existsSync)) {
    return {
      status: "inconclusive",
      diagnostic: "pré-requisito ausente: frame.pde, audio.pde, last_horizon.pde ou capture.pde",
    };
  }
  const frame = readFileSync(framePath, "utf8");
  const audio = readFileSync(audioPath, "utf8");
  const main = readFileSync(mainPath, "utf8");
  const capture = readFileSync(capturePath, "utf8");
  const baseSource = `${frame}\n${audio}\n${main}`;
  const optionalTypes = [
    "FakeFrameClockSource", "ProfileCadenceFrameClockSource",
    "InMemoryMovementAudioRecorder",
  ];
  const missingOptionalTypes = optionalTypes.filter((name) =>
    !new RegExp(`\\bclass\\s+${name}\\b`).test(capture));
  const baseDependencies = optionalTypes.filter((name) =>
    new RegExp(`\\bclass\\s+${name}\\b`).test(baseSource));
  const hasInertObserver = /frame_callback_observer\s*=\s*\(context\)\s*->\s*\{\s*\}/.test(main);
  if (missingOptionalTypes.length > 0 || baseDependencies.length > 0 || !hasInertObserver) {
    return {
      status: "fail",
      diagnostic: `isolamento base inválido: tipos opcionais ausentes=${missingOptionalTypes.join(",") || "nenhum"}; dependências base=${baseDependencies.join(",") || "nenhuma"}; observer inerte=${hasInertObserver}`,
    };
  }
  return {
    status: "pass",
    diagnostic: "relógios fake e recorder ficam em capture.pde; o observer base é inerte",
  };
}


const results = existsSync(sourceRoot)
  ? moduleMatrix.map(runCombination)
  : moduleMatrix.map((combination) => ({
    id: combination.id,
    modules: combination.modules,
    result: "inconclusive",
    exitCode: 2,
    diagnostic: `source ausente: ${sourceRoot}`,
  }));

const baseIsolation = existsSync(sourceRoot)
  ? verifyBaseIsolation()
  : { status: "inconclusive", diagnostic: `source ausente: ${sourceRoot}` };
const hasFailure = baseIsolation.status === "fail"
  || results.some((entry) => entry.result === "fail");
const hasInconclusive = baseIsolation.status === "inconclusive"
  || results.some((entry) => entry.result === "inconclusive");
const overallResult = hasFailure ? "fail" : hasInconclusive ? "inconclusive" : "pass";
const report = {
  schema: "optional-module-matrix-v1",
  generatedAt: new Date().toISOString(),
  sourceRoot,
  baseIsolation,
  combinations: results,
  result: overallResult,
};

if (matrixOutput) {
  writeFileSync(matrixOutput, `${JSON.stringify(report, null, 2)}\n`, "utf8");
}

console.log(`OPTIONAL MODULE MATRIX: ${overallResult.toUpperCase()}`);
console.log(`OPTIONAL BASE ISOLATION: ${baseIsolation.status.toUpperCase()} — ${baseIsolation.diagnostic}`);
process.exitCode = hasFailure ? 1 : hasInconclusive ? 2 : 0;
