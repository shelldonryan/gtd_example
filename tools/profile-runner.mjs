#!/usr/bin/env node

import { execFileSync, spawnSync } from "node:child_process";
import {
  cpSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { createHash } from "node:crypto";
import { hostname } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("..", import.meta.url));
const sketchRoot = resolve(repositoryRoot, "last_horizon");
const outputRoot = resolve(sketchRoot, "output");
const processingRunner = resolve(repositoryRoot, "tools/processing-cli.sh");
const requiredProfiles = ["core-i3-integrated", "reference"];
const requiredVersions = ["baseline", "revised"];
const requestedVersions = process.argv.find((argument) => argument.startsWith("--versions="))
  ?.slice("--versions=".length).split(",").filter((version) => requiredVersions.includes(version));
const sampleIds = ["sample-01", "sample-02", "sample-03"];
const scenario = "command-day1";
const collectionTimeoutMs = 1_500_000;
const processingTimeoutMs = 240_000;
const environmentMetadata = {
  environment: "approved-metrics-fixture-v1-linux-headless",
  machine: hostname() || "local-verification-host",
  gpu: "xvfb-renderer",
};
const manifestPath = resolve(outputRoot, "profiling-run-manifest.json");
const collectionReportPath = resolve(outputRoot, "profiling-collection-report.json");

const canonicalPerformanceBlock = String.raw`
void readArgs(){
  if (args == null){
    return;
  }

  for (int i = 0; i < args.length; i++){
    capture_mode |= args[i].equals("--capture");
    hit_test_mode |= args[i].equals("--hit-test");
    ladder_test_mode |= args[i].equals("--ladder-test");
    pipeline_test_mode |= args[i].equals("--asset-pipeline-test");
    performance_mode |= args[i].equals("--metrics");
  }

  if (pipeline_test_mode){
    pipeline_probe_image = loadImage(PIPELINE_PROBE_FILE);
    preparePipelineProbe();
  }

  if (capture_mode || ladder_test_mode || pipeline_test_mode || performance_mode){
    new File(sketchPath("output")).mkdirs();
  }

  if (performance_mode){
    requirePerformanceStartupEnvironment(PERFORMANCE_VERSION_ENV);
    requirePerformanceStartupEnvironment(PERFORMANCE_PROFILE_ENV);
    requirePerformanceStartupEnvironment("METRICS_ENVIRONMENT");
    requirePerformanceStartupEnvironment("METRICS_MACHINE");
    requirePerformanceStartupEnvironment("METRICS_GPU");
    requirePerformanceStartupEnvironment(PERFORMANCE_PROCESSING_VERSION_ENV);
    performance_version = performanceSegment(System.getenv(PERFORMANCE_VERSION_ENV), PERFORMANCE_VERSION_ENV);
    performance_profile = performanceSegment(System.getenv(PERFORMANCE_PROFILE_ENV), PERFORMANCE_PROFILE_ENV);
    if (performanceAllocatedBytes() < 0){
      performanceFail("métricas de alocação não disponíveis nesta JVM");
    }
  }
}

String performanceSegment(String value, String name){
  if (value == null || value.length() == 0 || !value.matches("[A-Za-z0-9._-]+")){
    throw new RuntimeException(name + " deve conter apenas letras, números, ponto, hífen ou sublinhado");
  }
  return value;
}

String performanceRequiredProperty(String name){
  String value = System.getProperty(name);
  if (value == null || value.length() == 0){
    throw new RuntimeException("Propriedade ausente: " + name);
  }
  return value;
}

String performanceRequiredEnvironment(String name){
  String value = System.getenv(name);
  if (value == null || value.length() == 0){
    throw new RuntimeException("Metadado ausente: " + name);
  }
  return value;
}

void performanceInconclusive(String name){
  String reason = "pré-requisito ausente antes do início: " + name;
  println("METRICS CHECK: INCONCLUSIVO — " + reason);
  System.err.println("Diagnóstico: " + reason + ". Impacto: a captura não foi iniciada e não pode servir como evidência.");
  System.exit(2);
}

void performanceFail(String reason){
  println("METRICS CHECK: FAIL — " + reason);
  System.err.println("Diagnóstico: " + reason + ". Impacto: a amostra não pode servir como evidência.");
  System.exit(1);
}

void requirePerformanceStartupEnvironment(String name){
  String value = System.getenv(name);
  if (value == null || value.length() == 0){
    performanceInconclusive(name);
  }
}

String performanceEnvironment(){ return performanceRequiredEnvironment("METRICS_ENVIRONMENT"); }
String performanceMachine(){ return performanceRequiredEnvironment("METRICS_MACHINE"); }
String performanceGpu(){ return performanceRequiredEnvironment("METRICS_GPU"); }
String performanceProcessingVersion(){ return performanceRequiredEnvironment(PERFORMANCE_PROCESSING_VERSION_ENV); }

String performanceHardware(){
  java.lang.management.OperatingSystemMXBean raw_os_bean =
    java.lang.management.ManagementFactory.getOperatingSystemMXBean();
  if (!(raw_os_bean instanceof com.sun.management.OperatingSystemMXBean)){
    throw new RuntimeException("Memória física indisponível para identificar o hardware");
  }

  com.sun.management.OperatingSystemMXBean os_bean =
    (com.sun.management.OperatingSystemMXBean) raw_os_bean;
  long total_memory_bytes = os_bean.getTotalMemorySize();
  if (total_memory_bytes <= 0){
    throw new RuntimeException("Memória física inválida para identificar o hardware");
  }

  return performanceRequiredProperty("os.arch")
    + "/cpu-" + Runtime.getRuntime().availableProcessors()
    + "/memory-" + total_memory_bytes + "-bytes";
}

String performanceOs(){
  return performanceRequiredProperty("os.name") + " " + performanceRequiredProperty("os.version");
}

String performanceAssets(){
  return "approved-metrics-fixture-v1";
}

JSONObject performanceSidecar(){
  JSONObject sidecar = new JSONObject();
  sidecar.setString("environment", performanceEnvironment());
  sidecar.setString("machine", performanceMachine());
  sidecar.setString("assets", performanceAssets());
  sidecar.setString("room", "command");
  sidecar.setString("state", "day-1-command-ready");
  sidecar.setInt("nominal_window_s", 30);
  sidecar.setString("processing", performanceProcessingVersion());
  sidecar.setString("hardware", performanceHardware());
  sidecar.setString("gpu", performanceGpu());
  sidecar.setString("os", performanceOs());
  return sidecar;
}

void writePerformanceProfile(String sample_id, float median_ms, float p95_ms,
  float allocations_per_frame, int icon_builds, int floor_band_builds, int invalidations){
  String profile_directory = sketchPath("output/profiling/" + performance_version
    + "/" + performance_profile + "/command-day1");
  new File(profile_directory).mkdirs();
  JSONObject profiling = new JSONObject();
  profiling.setString("profile", performance_profile);
  profiling.setString("version", performance_version);
  profiling.setString("scenario", "command-day1");
  profiling.setString("sample", sample_id);
  profiling.setString("status", "EXECUTED");
  profiling.setString("metrics_contract", "code/VERIFICATION.md#contrato-canônico-de-métricas");
  profiling.setString("metrics_csv", "last_horizon/output/" + performance_version
    + "/" + performance_profile + "/" + sample_id + ".csv");
  profiling.setString("sidecar_json", "last_horizon/output/" + performance_version
    + "/" + performance_profile + "/" + sample_id + ".sidecar.json");
  JSONArray hotspots = new JSONArray();
  JSONObject rendering = new JSONObject();
  rendering.setString("hotspot", "rendering");
  rendering.setString("metric", "frame_time_p95_ms");
  rendering.setFloat("value", p95_ms);
  rendering.setString("unit", "ms");
  hotspots.append(rendering);
  JSONObject image_scaling = new JSONObject();
  image_scaling.setString("hotspot", "image_scaling");
  image_scaling.setString("metric", "floor_band_builds");
  image_scaling.setInt("value", floor_band_builds);
  image_scaling.setString("unit", "builds");
  hotspots.append(image_scaling);
  JSONObject frame_allocations = new JSONObject();
  frame_allocations.setString("hotspot", "per_frame_allocations");
  frame_allocations.setString("metric", "allocations_per_frame");
  frame_allocations.setFloat("value", allocations_per_frame);
  frame_allocations.setString("unit", "bytes_per_frame");
  hotspots.append(frame_allocations);
  JSONObject transition_preview = new JSONObject();
  transition_preview.setString("hotspot", "transition_preview");
  transition_preview.setString("metric", "cache_invalidations");
  transition_preview.setInt("value", invalidations);
  transition_preview.setString("unit", "invalidations");
  hotspots.append(transition_preview);
  JSONObject asset_cache = new JSONObject();
  asset_cache.setString("hotspot", "asset_loading_and_cache");
  asset_cache.setString("metric", "load_time_ms");
  asset_cache.setFloat("value", art_load_ms);
  asset_cache.setString("unit", "ms");
  hotspots.append(asset_cache);
  profiling.setJSONArray("hotspots", hotspots);
  saveJSONObject(profiling, profile_directory + "/" + sample_id + ".json");
}

String performanceSampleId(){ return "sample-" + nf(performance_sample_index + 1, 2); }
String performanceSampleDirectory(){ return sketchPath("output/" + performance_version + "/" + performance_profile); }

long performanceAllocatedBytes(){
  try {
    java.lang.management.ThreadMXBean bean = java.lang.management.ManagementFactory.getThreadMXBean();
    if (!(bean instanceof com.sun.management.ThreadMXBean)) return -1;
    com.sun.management.ThreadMXBean allocated = (com.sun.management.ThreadMXBean) bean;
    if (!allocated.isThreadAllocatedMemorySupported()) return -1;
    if (!allocated.isThreadAllocatedMemoryEnabled()) allocated.setThreadAllocatedMemoryEnabled(true);
    return allocated.getThreadAllocatedBytes(Thread.currentThread().getId());
  } catch (RuntimeException error){
    return -1;
  }
}

long performanceUsedMemory(){
  Runtime runtime = Runtime.getRuntime();
  long used = runtime.totalMemory() - runtime.freeMemory();
  return used >= 0 ? used : -1;
}

void beginPerformanceSample(long started_nanos){
  performance_sample_frames = 0;
  performance_sample_started_nanos = started_nanos;
  performance_last_frame_nanos = started_nanos;
  performance_sample_start_memory = performanceUsedMemory();
  performance_sample_peak_memory = performance_sample_start_memory;
  performance_sample_resource_builds = resource_icon_builds;
  performance_sample_deck_builds = deck_strip_builds;
  performance_sample_invalidations = cache_invalidations;
  performance_sample_start_allocated_bytes = performanceAllocatedBytes();
}

float performancePercentile(float[] values, int count, float percentile){
  if (count <= 0) return 0;
  float[] sorted = new float[count];
  arrayCopy(values, sorted, count);
  java.util.Arrays.sort(sorted);
  int index = int(ceil(count * percentile)) - 1;
  index = constrain(index, 0, count - 1);
  return sorted[index];
}

void finishPerformanceSample(long ended_nanos){
  float duration_seconds = (ended_nanos - performance_sample_started_nanos) / 1000000000.0f;
  if (performance_sample_frames <= 0) performanceFail("amostra sem quadros medidos");
  if (performance_sample_start_memory < 0 || performanceUsedMemory() < 0) performanceFail("memória adicional indisponível na amostra");
  if (art_load_ms < 0) performanceFail("tempo de carregamento indisponível na amostra");
  long allocated_bytes = performanceAllocatedBytes();
  if (allocated_bytes < performance_sample_start_allocated_bytes || performance_sample_start_allocated_bytes < 0){
    performanceFail("contador de alocação inválido na amostra");
  }
  if (duration_seconds < 30.0 - PERFORMANCE_DURATION_TOLERANCE_S
    || duration_seconds > 30.0 + PERFORMANCE_DURATION_TOLERANCE_S){
    performanceFail("duração fora da tolerância na " + performanceSampleId());
  }
  float median_ms = performancePercentile(performance_frame_times, performance_sample_frames, 0.50);
  float p95_ms = performancePercentile(performance_frame_times, performance_sample_frames, 0.95);
  long heap_additional_memory = java.lang.Math.max(0L, performanceUsedMemory() - performance_sample_start_memory);
  long additional_memory = java.lang.Math.max(heap_additional_memory, performance_sample_peak_memory - performance_sample_start_memory);
  float allocations_per_frame = (allocated_bytes - performance_sample_start_allocated_bytes) / (float) performance_sample_frames;
  String sample_id = performanceSampleId();
  String sample_directory = performanceSampleDirectory();
  new File(sample_directory).mkdirs();
  java.io.PrintWriter metrics_writer = createWriter(sample_directory + "/" + sample_id + ".csv");
  metrics_writer.println("sample_id,duration_real_s,frame_count,frame_time_median_ms,frame_time_p95_ms,load_time_ms,additional_memory_bytes,icon_builds,floor_band_builds,cache_invalidations,allocations_per_frame");
  metrics_writer.println(sample_id + "," + Float.toString(duration_seconds) + "," + performance_sample_frames + ","
    + Float.toString(median_ms) + "," + Float.toString(p95_ms) + "," + art_load_ms + "," + additional_memory + ","
    + (resource_icon_builds - performance_sample_resource_builds) + "," + (deck_strip_builds - performance_sample_deck_builds) + ","
    + (cache_invalidations - performance_sample_invalidations) + "," + Float.toString(allocations_per_frame));
  metrics_writer.flush();
  metrics_writer.close();
  saveJSONObject(performanceSidecar(), sample_directory + "/" + sample_id + ".sidecar.json");
  writePerformanceProfile(sample_id, median_ms, p95_ms, allocations_per_frame,
    resource_icon_builds - performance_sample_resource_builds,
    deck_strip_builds - performance_sample_deck_builds,
    cache_invalidations - performance_sample_invalidations);
  println("metrics: amostra " + (performance_sample_index + 1) + " | mediana " + Float.toString(median_ms)
    + " ms | p95 " + Float.toString(p95_ms) + " ms | duração " + Float.toString(duration_seconds) + " s");
  performance_sample_index++;
  if (performance_sample_index >= PERFORMANCE_SAMPLE_COUNT){
    println("METRICS CHECK: PASS");
    exit();
    return;
  }
  beginPerformanceSample(ended_nanos);
}

void updatePerformanceMetrics(){
  long now_nanos = System.nanoTime();
  if (performance_last_frame_nanos == 0){
    performance_last_frame_nanos = now_nanos;
    return;
  }
  if (performance_warmup_frames < PERFORMANCE_WARMUP_FRAMES){
    performance_warmup_frames++;
    performance_last_frame_nanos = now_nanos;
    if (performance_warmup_frames == PERFORMANCE_WARMUP_FRAMES) beginPerformanceSample(now_nanos);
    return;
  }
  float frame_ms = (now_nanos - performance_last_frame_nanos) / 1000000.0f;
  if (performance_sample_frames >= performance_frame_times.length) performanceFail("janela excedeu o limite de quadros da captura");
  performance_frame_times[performance_sample_frames] = frame_ms;
  performance_sample_frames++;
  performance_sample_peak_memory = java.lang.Math.max(performance_sample_peak_memory, performanceUsedMemory());
  performance_last_frame_nanos = now_nanos;
  if (now_nanos - performance_sample_started_nanos >= PERFORMANCE_SAMPLE_NANOS) finishPerformanceSample(now_nanos);
}
`;

function fail(message) {
  throw new Error(message);
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

function currentSourcePaths() {
  const tracked = git("ls-files").split("\n").filter(Boolean);
  const untracked = git("ls-files", "--others", "--exclude-standard").split("\n").filter(Boolean);
  return [...new Set([...tracked, ...untracked])].filter((path) =>
    path.startsWith("last_horizon/") || path === "package.json" || path.startsWith("tools/")
      || path === "code/VERIFICATION.md" || path === "prototype/balance-model.mjs");
}

function extractRevision(revision, targetRoot) {
  const archive = execFileSync("git", ["archive", "--format=tar", revision], {
    cwd: repositoryRoot,
    encoding: "buffer",
    maxBuffer: 128 * 1024 * 1024,
  });
  execFileSync("tar", ["-xf", "-", "-C", targetRoot], { input: archive });
}

function prepareBaselineCapture(sourceRoot) {
  const capturePath = resolve(sourceRoot, "capture.pde");
  const source = readFileSync(capturePath, "utf8");
  const readArgsStart = source.indexOf("void readArgs(){");
  const performanceBlockEnd = source.indexOf("void preparePipelineProbe(){", readArgsStart);
  if (readArgsStart < 0 || performanceBlockEnd < 0) {
    fail("baseline capture.pde não oferece a superfície de profiling legada esperada");
  }
  const variables = "\nfinal float PERFORMANCE_DURATION_TOLERANCE_S = 0.5;\n"
    + "final String PERFORMANCE_VERSION_ENV = \"METRICS_VERSION\";\n"
    + "final String PERFORMANCE_PROFILE_ENV = \"METRICS_PROFILE\";\n"
    + "final String PERFORMANCE_PROCESSING_VERSION_ENV = \"METRICS_PROCESSING_VERSION\";\n"
    + "String performance_version = \"\";\nString performance_profile = \"\";\n"
    + "long performance_sample_start_allocated_bytes = -1;\n";
  const variableAnchor = "float[] performance_frame_times = new float[PERFORMANCE_MAX_FRAMES];";
  if (!source.includes(variableAnchor)) fail("variáveis de profiling da baseline não encontradas");
  const withVariables = source.replace(variableAnchor, variableAnchor + variables);
  const adjustedReadArgsStart = withVariables.indexOf("void readArgs(){");
  const adjustedBlockEnd = withVariables.indexOf("void preparePipelineProbe(){", adjustedReadArgsStart);
  const adjusted = withVariables.slice(0, adjustedReadArgsStart)
    + canonicalPerformanceBlock
    + withVariables.slice(adjustedBlockEnd);
  const fixtureAnchor = "readArgs();\n    captureVerificationBaseline();";
  if (!adjusted.includes(fixtureAnchor)) fail("setup da fixture da baseline não encontrado");
  writeFileSync(capturePath, adjusted.replace(
    fixtureAnchor,
    `${fixtureAnchor}\n    if (performance_mode){ beginVerificationFixture(); }`,
  ), "utf8");
}

function copySource(sourceRoot, targetRoot) {
  mkdirSync(targetRoot, { recursive: true });
  cpSync(sourceRoot, targetRoot, { recursive: true });
}

function runMetrics(version, profile, sourceRoot) {
  const result = spawnSync("bash", [processingRunner, "--run", "--metrics"], {
    cwd: repositoryRoot,
    encoding: "utf8",
    env: {
      ...process.env,
      PROCESSING_BIN: process.env.PROCESSING_BIN || "/opt/processing/bin/Processing",
      HEADLESS: "1",
      SKETCH_SOURCE: sourceRoot,
      METRICS_VERSION: version,
      METRICS_PROFILE: profile,
      METRICS_ENVIRONMENT: environmentMetadata.environment,
      METRICS_MACHINE: environmentMetadata.machine,
      METRICS_GPU: environmentMetadata.gpu,
    },
    maxBuffer: 64 * 1024 * 1024,
    timeout: processingTimeoutMs,
  });
  const output = `${result.stdout ?? ""}\n${result.stderr ?? ""}`.trim();
  const hasPassMarker = /METRICS CHECK: PASS/.test(output);
  const status = result.error?.code === "ENOENT"
    ? "INCONCLUSIVO"
    : result.error?.code === "ETIMEDOUT" || result.signal
      ? "FAIL"
      : result.status === 0 && hasPassMarker
        ? "PASS"
        : result.status === 2
          ? "INCONCLUSIVO"
          : "FAIL";
  return {
    version,
    profile,
    scenario,
    status,
    exitCode: result.status,
    diagnostic: result.error?.message ?? (status === "PASS" ? "" : "coleta iniciada sem confirmação completa"),
    output,
  };
}

function copyCollectedOutput(sourceRoot, version, profile) {
  const sourceOutput = resolve(sourceRoot, "output", version, profile);
  const sourceProfiling = resolve(sourceRoot, "output", "profiling", version, profile);
  if (!existsSync(sourceOutput) || !existsSync(sourceProfiling)) return false;
  const targetOutput = resolve(outputRoot, version, profile);
  const targetProfiling = resolve(outputRoot, "profiling", version, profile);
  rmSync(targetOutput, { recursive: true, force: true });
  rmSync(targetProfiling, { recursive: true, force: true });
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
    resolve(profileRoot, `${sample}.json`),
  ]).every((path) => existsSync(path));
}

function baselineManifest(baselineRoot, revision) {
  const paths = trackedPathsAtRevision(revision).filter((path) =>
    path.startsWith("last_horizon/") || path === "package.json" || path.startsWith("tools/")
      || path === "prototype/balance-model.mjs" || path === "code/VERIFICATION.md");
  return {
    kind: "git-revision",
    reference: revision,
    source: "git archive HEAD",
    files: fileManifest(baselineRoot, paths),
  };
}

function revisedManifest() {
  const paths = currentSourcePaths().filter((path) => existsSync(resolve(repositoryRoot, path)));
  return {
    kind: "working-tree",
    reference: `working-tree:${sha256(Buffer.from(git("diff", "--binary")))}`,
    source: "current working tree",
    files: fileManifest(repositoryRoot, paths),
  };
}

function manifestDigest(manifest) {
  return sha256(Buffer.from(JSON.stringify(manifest)));
}

function run() {
  if (!existsSync(sketchRoot) || !existsSync(resolve(sketchRoot, "last_horizon.pde"))) {
    fail(`sketch ausente: ${sketchRoot}`);
  }
  const baselineRevision = git("rev-parse", "HEAD");
  const temporaryRoot = mkdtempSync(join("/tmp", "last-horizon-profiling-"));
  const baselineRoot = resolve(temporaryRoot, "baseline");
  const revisedRoot = resolve(temporaryRoot, "revised");
  const results = [];
  const startedAt = new Date().toISOString();
  try {
    mkdirSync(baselineRoot, { recursive: true });
    extractRevision(baselineRevision, baselineRoot);
    const baselineSourceRoot = resolve(baselineRoot, "last_horizon");
    prepareBaselineCapture(baselineSourceRoot);
    copySource(sketchRoot, revisedRoot);
    const runVersions = requestedVersions?.length > 0 ? requestedVersions : requiredVersions;
    for (const version of runVersions) {
      rmSync(resolve(outputRoot, version), { recursive: true, force: true });
      rmSync(resolve(outputRoot, "profiling", version), { recursive: true, force: true });
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
        const result = runMetrics(version, profile, sourceRoot);
        const copied = copyCollectedOutput(sourceRoot, version, profile);
        writeCollectedLogs(version, profile, result);
        const artifactsValid = copied && validateRequiredArtifacts(version, profile);
        const finalResult = {
          ...result,
          artifacts: artifactsValid ? "last_horizon/output/<versao>/<perfil>/<sample_id>.*" : "ausentes",
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
        processingRunner: "tools/processing-cli.sh",
        processingTimeoutMs,
        environment: environmentMetadata,
      },
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
    rmSync(temporaryRoot, { recursive: true, force: true });
  }
}

try {
  run();
} catch (error) {
  console.log("PROFILING COLLECTION: FAIL");
  console.error(`Diagnóstico: ${error.message}`);
  process.exitCode = 1;
}
