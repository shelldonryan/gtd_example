#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { existsSync, writeFileSync } from "node:fs";
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

const results = existsSync(sourceRoot)
  ? moduleMatrix.map(runCombination)
  : moduleMatrix.map((combination) => ({
    id: combination.id,
    modules: combination.modules,
    result: "inconclusive",
    exitCode: 2,
    diagnostic: `source ausente: ${sourceRoot}`,
  }));

const hasFailure = results.some((entry) => entry.result === "fail");
const hasInconclusive = results.some((entry) => entry.result === "inconclusive");
const overallResult = hasFailure ? "fail" : hasInconclusive ? "inconclusive" : "pass";
const report = {
  schema: "optional-module-matrix-v1",
  generatedAt: new Date().toISOString(),
  sourceRoot,
  combinations: results,
  result: overallResult,
};

if (matrixOutput) {
  writeFileSync(matrixOutput, `${JSON.stringify(report, null, 2)}\n`, "utf8");
}

console.log(`OPTIONAL MODULE MATRIX: ${overallResult.toUpperCase()}`);
process.exitCode = hasFailure ? 1 : hasInconclusive ? 2 : 0;
