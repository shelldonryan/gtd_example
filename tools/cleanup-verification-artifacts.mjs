import { lstat, readdir, rm } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const verificationOutput = resolve(root, "last_horizon/output");
const CLEANUP_TIMEOUT_MS = 60_000;
const TRANSIENT_FILE_PATTERN = /^(?:capture|capture_window|pipeline|pipeline_window|manual|rules|catalogue|ladder)__.+\.(?:png|jpg|jpeg)$/i;
const TRANSIENT_DIRECTORY_PATTERN = /^windows-regression-[A-Za-z0-9._-]+$/;
const TRANSIENT_ROOT_FILES = new Set(["performance__metricas.csv"]);

async function removeTransientArtifacts() {
  let outputStat;
  try {
    outputStat = await lstat(verificationOutput);
  } catch (error) {
    if (error.code === "ENOENT") return [];
    throw error;
  }
  if (outputStat.isSymbolicLink() || !outputStat.isDirectory()) {
    throw new Error(`saída de verificação não é uma pasta comum: ${verificationOutput}`);
  }

  const removed = [];
  const entries = await readdir(verificationOutput, { withFileTypes: true });
  for (const entry of entries) {
    const shouldRemove = (entry.isFile() && (TRANSIENT_FILE_PATTERN.test(entry.name)
      || TRANSIENT_ROOT_FILES.has(entry.name)))
      || (entry.isDirectory() && TRANSIENT_DIRECTORY_PATTERN.test(entry.name));
    if (!shouldRemove) continue;
    await rm(resolve(verificationOutput, entry.name), { recursive: entry.isDirectory(), force: true });
    removed.push(entry.name);
  }
  return removed;
}

async function cleanupVerificationArtifacts() {
  let timeoutHandle;
  const timeout = new Promise((_, reject) => {
    timeoutHandle = setTimeout(() => reject(
      new Error("cleanup excedeu o timeout fixo de 60s")), CLEANUP_TIMEOUT_MS);
  });
  try {
    return await Promise.race([removeTransientArtifacts(), timeout]);
  } finally {
    clearTimeout(timeoutHandle);
  }
}

cleanupVerificationArtifacts().then((removed) => {
  console.log(`CLEANUP CHECK: PASS — ${removed.length} saídas transitórias removidas; evidências permanentes preservadas`);
}).catch((error) => {
  console.log("CLEANUP CHECK: FAIL");
  console.error(`Diagnóstico: Verification artifact cleanup failed: ${error.message}`);
  process.exitCode = 1;
});
