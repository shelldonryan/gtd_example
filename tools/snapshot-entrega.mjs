#!/usr/bin/env node


import { execFileSync, spawnSync } from "node:child_process";
import {
  copyFileSync,
  existsSync,
  lstatSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { dirname, relative, resolve } from "node:path";

const repositoryRoot = resolve(
  execFileSync("git", ["rev-parse", "--show-toplevel"], {
    cwd: process.cwd(),
    encoding: "utf8",
  }).trim(),
);
const outputRoot = resolve(repositoryRoot, "output");
const intermediateRoot = resolve(outputRoot, "snapshot-entrega");
const intermediateRuntimeRoot = resolve(intermediateRoot, "last_horizon");
const manifestPath = resolve(outputRoot, "snapshot-entrega-manifest.json");
const processingRunner = resolve(repositoryRoot, "tools/processing-cli.sh");
const moduleMatrixRunner = resolve(repositoryRoot, "tools/optional-modules.mjs");

const EXCLUDED = [
  "SESSION_START.md",
  "SPEC_PROGRESS.md",
  "discovery-notes.md",
  ".codegraph",
  ".lionclaw",
  "code/VERIFICATION.md",
  "prototype",
  "tools",
  "skills-lock.json",
  ".obsidian",
  ".sprint-validation-report.md",
  "output/snapshot-entrega",
  "output/snapshot-entrega-manifest.json",
  "last_horizon/capture.pde",
  "last_horizon/test_mode.pde",
  "last_horizon/output",
  "last_horizon/data/pipeline_probe.aseprite",
  "last_horizon/data/pipeline_probe_frame_1.png",
];

const forbiddenRuntimeControls = [
  /Ctrl\s*\+\s*K/i,
  /handleOptionalModeKey\s*\(/,
  /testModeTeleport\s*\(/,
  /drawOptionalModeOverlay\s*\(/,
  /TEST-MODE/,
];
const transientOutputPattern = /^(?:capture|capture_window|pipeline|pipeline_window|manual|rules|catalogue|ladder)__.+\.(?:png|jpg|jpeg)$/i;
const transientOutputDirectoryPattern = /^windows-regression-[A-Za-z0-9._-]+$/;

function git(...args) {
  return execFileSync("git", args, {
    cwd: repositoryRoot,
    encoding: "utf8",
  }).trim();
}

function isExcluded(repositoryPath) {
  return EXCLUDED.some((entry) =>
    repositoryPath === entry || repositoryPath.startsWith(`${entry}/`),
  );
}

function copyWorkingTreeSnapshot() {
  const trackedFiles = git("ls-files", "-z")
    .split("\0")
    .filter(Boolean);
  const untrackedRuntimeFiles = git("ls-files", "--others", "--exclude-standard", "-z", "--", "last_horizon")
    .split("\0")
    .filter(Boolean);
  const sourceFiles = [...new Set([...trackedFiles, ...untrackedRuntimeFiles])];
  const copied = [];
  const excluded = [];
  const missing = [];

  for (const repositoryPath of sourceFiles) {
    if (isExcluded(repositoryPath)) {
      excluded.push(repositoryPath);
      continue;
    }

    const sourcePath = resolve(repositoryRoot, repositoryPath);
    if (!existsSync(sourcePath)) {
      missing.push(repositoryPath);
      continue;
    }

    const targetPath = resolve(intermediateRoot, repositoryPath);
    mkdirSync(dirname(targetPath), { recursive: true });
    copyFileSync(sourcePath, targetPath);
    copied.push(repositoryPath);
  }

  return { copied, excluded, missing };
}

function runCommand(command, args, environment, timeout) {
  const result = spawnSync(command, args, {
    cwd: repositoryRoot,
    encoding: "utf8",
    env: { ...process.env, ...environment },
    maxBuffer: 32 * 1024 * 1024,
    timeout,
  });
  const output = `${result.stdout ?? ""}\n${result.stderr ?? ""}`.trim();
  if (output.length > 0) process.stdout.write(`${output}\n`);
  if (result.error?.code === "ENOENT") {
    return { status: "inconclusive", exitCode: 2, output };
  }
  if (result.error?.code === "ETIMEDOUT") {
    return { status: "fail", exitCode: 124, output };
  }
  if (result.status === 0) return { status: "pass", exitCode: 0, output };
  if (result.status === 2) return { status: "inconclusive", exitCode: 2, output };
  return { status: "fail", exitCode: result.status, output };
}

function runOptionalModuleMatrix(reportDirectory) {
  const reportPath = resolve(reportDirectory, "optional-module-matrix.json");
  runCommand(
    process.execPath,
    [moduleMatrixRunner, `--json-output=${reportPath}`],
    { SKETCH_SOURCE: resolve(repositoryRoot, "last_horizon") },
    300_000,
  );

  if (!existsSync(reportPath)) {
    return {
      schema: "optional-module-matrix-v1",
      combinations: [],
      result: "fail",
      diagnostic: "a matriz não produziu seu relatório intermediário",
    };
  }
  return JSON.parse(readFileSync(reportPath, "utf8"));
}

function checkRuntimeControls(runtimeFiles) {
  const matches = [];
  for (const repositoryPath of runtimeFiles) {
    if (!repositoryPath.startsWith("last_horizon/") || !repositoryPath.endsWith(".pde")) {
      continue;
    }
    const source = readFileSync(resolve(intermediateRoot, repositoryPath), "utf8");
    if (forbiddenRuntimeControls.some((expression) => expression.test(source))) {
      matches.push(repositoryPath);
    }
  }
  return { passed: matches.length === 0, matches };
}

function checkTransientOutput() {
  const outputRoot = resolve(repositoryRoot, "last_horizon/output");
  if (!existsSync(outputRoot)) return { passed: true, matches: [] };
  const outputStat = lstatSync(outputRoot);
  if (outputStat.isSymbolicLink() || !outputStat.isDirectory()) {
    return { passed: false, matches: [relative(repositoryRoot, outputRoot)] };
  }
  const matches = readdirSync(outputRoot, { withFileTypes: true })
    .filter((entry) => (entry.isFile() && transientOutputPattern.test(entry.name))
      || (entry.isDirectory() && transientOutputDirectoryPattern.test(entry.name)))
    .map((entry) => `last_horizon/output/${entry.name}`);
  return { passed: matches.length === 0, matches };
}

function compileIntermediateRuntime() {
  return runCommand(
    "bash",
    [processingRunner, "--build", "--module-set=base"],
    { SKETCH_SOURCE: intermediateRuntimeRoot },
    300_000,
  );
}

function run() {
  if (existsSync(outputRoot)) {
    const outputStat = lstatSync(outputRoot);
    if (outputStat.isSymbolicLink() || !outputStat.isDirectory()) {
      throw new Error(`a saída não é uma pasta comum: ${outputRoot}`);
    }
  } else {
    mkdirSync(outputRoot, { recursive: true });
  }

  rmSync(intermediateRoot, { recursive: true, force: true });
  mkdirSync(intermediateRoot, { recursive: true });
  const temporaryRoot = mkdtempSync(resolve(outputRoot, ".snapshot-entrega-run-"));

  try {
    const inventory = copyWorkingTreeSnapshot();
    const runtimeFiles = inventory.copied.filter((path) =>
      path.startsWith("last_horizon/") && !path.startsWith("last_horizon/output/"),
    );
    const matrix = runOptionalModuleMatrix(temporaryRoot);
    const intermediateCompile = compileIntermediateRuntime();
    const controls = checkRuntimeControls(runtimeFiles);
    const transientOutput = checkTransientOutput();

    rmSync(resolve(intermediateRuntimeRoot, "output"), { recursive: true, force: true });

    const matrixHasFailure = matrix.result === "fail"
      || matrix.combinations.some((entry) => entry.result === "fail");
    const hasInconclusive = matrix.result === "inconclusive"
      || matrix.combinations.some((entry) => entry.result === "inconclusive")
      || intermediateCompile.status === "inconclusive";
    const hasFailure = matrixHasFailure
      || intermediateCompile.status === "fail"
      || inventory.missing.length > 0
      || !controls.passed
      || !transientOutput.passed;
    const result = hasFailure ? "fail" : hasInconclusive ? "inconclusive" : "pass";
    const manifest = {
      schema: "snapshot-entrega-v1",
      status: "final",
      final: true,
      generatedAt: new Date().toISOString(),
      source: {
        branch: git("branch", "--show-current"),
        revision: git("rev-parse", "HEAD"),
        workingTree: "current working tree, including non-ignored runtime sources",
      },
      exclusionPolicy: {
        source: "tools/snapshot-entrega.mjs",
        inherited: true,
        entries: EXCLUDED,
      },
      excluded: EXCLUDED,
      excludedFiles: inventory.excluded,
      runtimeFiles,
      intermediateRoot: relative(repositoryRoot, intermediateRoot),
      optionalModuleCompileMatrix: matrix.combinations,
      runtimeChecks: {
        allOptionalCombinationsCompile: matrix.result === "pass",
        intermediateCopyCompiles: intermediateCompile.status === "pass",
        optionalControlsAbsent: controls.passed,
        missingTrackedFiles: inventory.missing,
        forbiddenControlMatches: controls.matches,
        transientOutputAbsent: transientOutput.passed,
        transientOutputMatches: transientOutput.matches,
      },
      result,
    };
    writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
    console.log(`SNAPSHOT CHECK: ${result.toUpperCase()} — manifesto final gerado após a limpeza`);
    if (hasFailure) return 1;
    if (hasInconclusive) return 2;
    return 0;
  } finally {
    rmSync(temporaryRoot, { recursive: true, force: true });
  }
}

try {
  process.exitCode = run();
} catch (error) {
  console.log(`SNAPSHOT CHECK: FAIL — ${error.message}`);
  console.error(`Diagnóstico: ${error.message} Impacto: o manifesto final não foi concluído.`);
  process.exitCode = 1;
}
