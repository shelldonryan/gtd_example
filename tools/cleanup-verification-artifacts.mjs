import { rm } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(new URL("..", import.meta.url).pathname);
const transientOutput = resolve(root, "last_horizon/output");

/**
 * Remove generated verification artifacts that have no approved retention.
 *
 * @returns {Promise<void>} Resolves after the transient output is removed.
 * @throws {Error} If the output cannot be removed.
 */
async function cleanupVerificationArtifacts() {
  await rm(transientOutput, { recursive: true, force: true });
}

cleanupVerificationArtifacts().catch((error) => {
  console.error(`Verification artifact cleanup failed: ${error.message}`);
  process.exitCode = 1;
});
