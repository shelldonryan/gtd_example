#!/usr/bin/env node

import { spawnSync } from "node:child_process";

const TYPECHECK_TIMEOUT_MS = 60_000;
const modules = [
  "tools/typecheck.mjs",
  "prototype/balance-model.mjs",
  "tools/snapshot-entrega.mjs",
  "tools/optional-modules.mjs",
  "tools/cleanup-verification-artifacts.mjs",
  "tools/e6-audit.mjs",
  "tools/compare-metrics.mjs",
  "tools/compare-profiling.mjs",
  "tools/profile-runner.mjs",
  "tools/verify-delivery.mjs",
  "tools/e6-evidence.mjs",
  "tools/regression-windows.mjs",
];
const startedAt = Date.now();

function reportFailure(summary, diagnostic, exitCode) {
  console.log(summary);
  console.error(`Diagnóstico: ${diagnostic}`);
  process.exitCode = exitCode;
}

for (const modulePath of modules) {
  const remaining = TYPECHECK_TIMEOUT_MS - (Date.now() - startedAt);
  if (remaining <= 0) {
    reportFailure(
      "TYPECHECK: FAIL — timeout fixo de 60s excedido",
      "a verificação foi iniciada, mas o limite total de 60s foi excedido antes do próximo módulo; o resultado não é evidência de PASS",
      124,
    );
    break;
  }
  const result = spawnSync(process.execPath, ["--check", modulePath], {
    encoding: "utf8",
    timeout: remaining,
  });
  if (result.stdout) process.stdout.write(result.stdout);
  if (result.stderr) process.stderr.write(result.stderr);
  if (result.error || result.status !== 0) {
    const reason = result.error?.message ?? `código de saída ${result.status}`;
    const timedOut = result.error?.code === "ETIMEDOUT" || result.signal === "SIGTERM";
    reportFailure(
      `TYPECHECK: FAIL — ${modulePath}: ${reason}`,
      timedOut
        ? `${modulePath} excedeu o timeout fixo de 60s; o módulo foi iniciado e a verificação falhou`
        : `${modulePath} terminou com ${reason}; o resultado não é evidência de PASS`,
      timedOut ? 124 : 1,
    );
    break;
  }
}

if (process.exitCode === undefined) console.log("TYPECHECK: PASS");
