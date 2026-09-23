boolean capture_mode = false;
boolean hit_test_mode = false;
boolean ladder_test_mode = false;
boolean pipeline_test_mode = false;
boolean performance_mode = false;
PImage pipeline_probe_image;
PGraphics pipeline_probe_layer;
final int PIPELINE_TEST_FRAME = 4;
final int PIPELINE_PROBE_SIZE = 16;
final String PIPELINE_PROBE_FILE = "pipeline_probe_frame_1.png";

class FakeFrameClockSource implements FrameClockSource {
  private double now_seconds;

  FakeFrameClockSource(double initial_seconds){
    now_seconds = initial_seconds;
  }

  public double readSeconds(){
    return now_seconds;
  }

  public String origin(){
    return "fake";
  }

  void setSeconds(double value){
    now_seconds = value;
  }

  void advanceSeconds(double delta){
    now_seconds += delta;
  }
}


class ProfileCadenceFrameClockSource implements FrameClockSource {
  private double now_seconds;
  private int cadence_fps = 60;
  private int callback_count;

  ProfileCadenceFrameClockSource(double initial_seconds){
    now_seconds = initial_seconds;
  }

  public double readSeconds(){
    callback_count++;
    int callbacks_per_tick = 60 / cadence_fps;
    if (callback_count % callbacks_per_tick == 0){
      now_seconds += 1.0 / cadence_fps;
    }
    return now_seconds;
  }

  public String origin(){
    return "fake";
  }

  void setCadence(int fps){
    if (fps != 15 && fps != 30 && fps != 60){
      throw new IllegalArgumentException("cadência temporal deve ser 15, 30 ou 60 FPS");
    }
    cadence_fps = fps;
    callback_count = 0;
  }
}


class InMemoryMovementAudioRecorder implements MovementAudioAdapter {
  private final java.util.ArrayList<MovementAudioEvent> recorded_events =
    new java.util.ArrayList<MovementAudioEvent>();

  public void beginCallback(long callbackId){
  }

  public void emit(MovementAudioEvent event, boolean physicalPlaybackAllowed){
    if (event == null) throw new IllegalArgumentException("evento de áudio obrigatório");
    recorded_events.add(event);
  }

  public void dispatchCallback(long callbackId){
  }

  int eventCount(){
    return recorded_events.size();
  }

  MovementAudioEvent eventAt(int index){
    return recorded_events.get(index);
  }

  void clear(){
    recorded_events.clear();
  }
}

int capture_step = 0;
int presentation_callback_checks = 0;
int presentation_callback_failures = 0;
int presentation_room_callback_checks = 0;
java.util.LinkedHashMap<String, Integer> presentation_surface_observations =
  new java.util.LinkedHashMap<String, Integer>();
boolean presentation_coverage_checked = false;
int capture_next_frame = 0;
boolean checks_failed = false;
boolean rule_checks_started = false;
boolean rule_checks_finished = false;
boolean campaign_checks_running = false;
int campaign_phase = 0;
int campaign_strategy = 0;
int[] campaign_sequence = new int[5];
int[] campaign_next_candidate = new int[5];
int campaign_depth = 0;
int campaign_used = 0;
boolean campaign_permutation_ready = false;
int capture_campaign_wins = 0;
final int CAPTURE_FIRST_FRAME = 4;
final int CAPTURE_FRAME_GAP = 3;
final int HIT_TEST_FRAME = 5;
final int PERFORMANCE_WARMUP_FRAMES = 120;
final int PERFORMANCE_SAMPLE_COUNT = 3;
final long PERFORMANCE_SAMPLE_NANOS = 30000000000L;
final float PERFORMANCE_DURATION_TOLERANCE_S = 0.5;
final int PERFORMANCE_MAX_FRAMES = 4096;
final String PERFORMANCE_FIXTURE_ID = "approved-metrics-fixture-v1";
final String PERFORMANCE_ROOM_ID = "command";
final String PERFORMANCE_STATE_ID = "day-1-command-ready";
final String PERFORMANCE_SCENARIO_ID = "command-day1";
final String PERFORMANCE_VERSION_ENV = "METRICS_VERSION";
final String PERFORMANCE_PROFILE_ENV = "METRICS_PROFILE";
final String PERFORMANCE_PROCESSING_VERSION_ENV = "METRICS_PROCESSING_VERSION";
final String PERFORMANCE_METRICS_HEADER =
  "sample_id,duration_real_s,frame_count,frame_time_median_ms,frame_time_p95_ms,"
  + "load_time_ms,additional_memory_bytes,icon_builds,floor_band_builds,"
  + "cache_invalidations,allocations_per_frame";
final String EQUIVALENCE_REPORT_SCHEMA = "night-equivalence-v1";
final String EQUIVALENCE_REPORT_FILE = "output/equivalence-report.json";
final int EQUIVALENCE_EXPECTED_QUEST_COUNT = 22;
final int EQUIVALENCE_EXPECTED_STATE_COUNT = 34;
final String[] EQUIVALENCE_EXPECTED_QUEST_IDS = {
  "V-01", "V-02", "B-01", "B-02", "N-01", "N-02", "S-01", "S-02",
  "ENG-A", "ENG-B", "HUL-A", "HUL-B", "FOOD-A", "FOOD-B", "CON-A", "CON-B",
  "LIFE-A", "LIFE-B", "PWR-A", "PWR-B", "COM-A", "COM-B"
};
final String[] EQUIVALENCE_EXPECTED_STATE_IDS = {
  "menu_init", "vignette_1", "vignette_2", "vignette_3", "preventive_offers",
  "preventive_selected", "preventive_confirmation", "quest_collect_route", "quest_map",
  "quest_collect_confirmation", "quest_carrying", "quest_delivery_confirmation", "preventive_reward",
  "night_forecast", "incident_choices", "incident_confirmation", "urgent_collect",
  "urgent_carrying", "urgent_delivery", "urgent_solved", "preventive_failure",
  "preventive_neglect", "urgent_retry", "survivor_risk", "rescue_confirmation",
  "survivor_rescued", "pause", "defeat", "victory", "dense_night_forecast",
  "day_3_night_modal", "help_panel", "day_2_free_dormitory", "earth_transmission"
};

int performance_warmup_frames = 0;
int performance_sample_index = 0;
int performance_sample_frames = 0;
long performance_last_frame_nanos = 0;
long performance_sample_started_nanos = 0;
long performance_sample_start_memory = 0;
int performance_sample_resource_builds = 0;
int performance_sample_deck_builds = 0;
int performance_sample_invalidations = 0;
long performance_sample_start_allocated_bytes = -1;
float[] performance_frame_times = new float[PERFORMANCE_MAX_FRAMES];
String performance_version = "";
String performance_profile = "";

String[] capture_label = {
  "menu_init", "vignette_1", "vignette_2", "vignette_3", "preventive_offers",
  "preventive_selected", "preventive_confirmation", "quest_collect_route", "quest_map",
  "quest_collect_confirmation", "quest_carrying", "quest_delivery_confirmation", "preventive_reward",
  "night_forecast", "incident_choices", "incident_confirmation", "urgent_collect",
  "urgent_carrying", "urgent_delivery", "urgent_solved", "preventive_failure",
  "preventive_neglect", "urgent_retry", "survivor_risk", "rescue_confirmation",
  "survivor_rescued", "pause", "defeat", "victory", "dense_night_forecast",
  "day_3_night_modal", "help_panel", "day_2_free_dormitory", "earth_transmission"
};
boolean harness_installed = installHarness();


boolean installHarness(){
  harness_setup = () -> {
    readArgs();
    captureVerificationBaseline();
    if (performance_mode){
      beginVerificationFixture();
    }
  };
  harness_update = () -> updateCapture();
  harness_scene = (target) -> harnessDrawScene(target);
  return true;
}


PImage[] door_art_saved;
boolean door_art_cleared = false;


void clearDoorArt(){
  if (!door_art_cleared){
    door_art_saved = art_door_frames;
    door_art_cleared = true;
  }

  art_door_frames = new PImage[2];
}


void restoreDoorArt(){
  if (door_art_cleared){
    art_door_frames = door_art_saved;
    door_art_saved = null;
    door_art_cleared = false;
  }
}

boolean verification_baseline_ready = false;
int[] verification_baseline_incident_sequence = new int[5];
float[] verification_baseline_ladder_x;
float[] verification_baseline_door_x;
float[] verification_baseline_door_y;
int[] verification_baseline_door_deck;
int[] verification_baseline_door_target;
float[] verification_baseline_door_arrival_x;
float[] verification_baseline_door_arrival_y;
int[] verification_baseline_door_arrival_facing;
int[] verification_baseline_point_room;
float[] verification_baseline_point_x;
float[] verification_baseline_point_y;
PImage[] verification_baseline_door_art;

void captureVerificationBaseline(){
  if (verification_baseline_ready) return;

  verification_baseline_ladder_x = new float[LADDER_COUNT];
  verification_baseline_door_x = new float[DOOR_COUNT];
  verification_baseline_door_y = new float[DOOR_COUNT];
  verification_baseline_door_deck = new int[DOOR_COUNT];
  verification_baseline_door_target = new int[DOOR_COUNT];
  verification_baseline_door_arrival_x = new float[DOOR_COUNT];
  verification_baseline_door_arrival_y = new float[DOOR_COUNT];
  verification_baseline_door_arrival_facing = new int[DOOR_COUNT];
  verification_baseline_point_room = new int[POINT_COUNT];
  verification_baseline_point_x = new float[POINT_COUNT];
  verification_baseline_point_y = new float[POINT_COUNT];

  arrayCopy(incident_sequence, verification_baseline_incident_sequence);
  arrayCopy(ladder_x, verification_baseline_ladder_x);
  arrayCopy(door_x, verification_baseline_door_x);
  arrayCopy(door_y, verification_baseline_door_y);
  arrayCopy(door_deck, verification_baseline_door_deck);
  arrayCopy(door_target, verification_baseline_door_target);
  arrayCopy(door_arrival_x, verification_baseline_door_arrival_x);
  arrayCopy(door_arrival_y, verification_baseline_door_arrival_y);
  arrayCopy(door_arrival_facing, verification_baseline_door_arrival_facing);
  arrayCopy(point_room, verification_baseline_point_room);
  arrayCopy(point_x, verification_baseline_point_x);
  arrayCopy(point_y, verification_baseline_point_y);
  verification_baseline_door_art = art_door_frames;
  verification_baseline_ready = true;
}

void restoreVerificationTables(){
  if (!verification_baseline_ready) return;

  arrayCopy(verification_baseline_incident_sequence, incident_sequence);
  arrayCopy(verification_baseline_ladder_x, ladder_x);
  arrayCopy(verification_baseline_door_x, door_x);
  arrayCopy(verification_baseline_door_y, door_y);
  arrayCopy(verification_baseline_door_deck, door_deck);
  arrayCopy(verification_baseline_door_target, door_target);
  arrayCopy(verification_baseline_door_arrival_x, door_arrival_x);
  arrayCopy(verification_baseline_door_arrival_y, door_arrival_y);
  arrayCopy(verification_baseline_door_arrival_facing, door_arrival_facing);
  arrayCopy(verification_baseline_point_room, point_room);
  arrayCopy(verification_baseline_point_x, point_x);
  arrayCopy(verification_baseline_point_y, point_y);
  art_door_frames = verification_baseline_door_art;
  door_art_saved = null;
  door_art_cleared = false;
}

void restoreVerificationFixture(){
  if (!verification_baseline_ready) return;

  resetRun();
  restoreVerificationTables();
  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  run_held = false;
  mouse_pressed = false;
  esc_pressed = false;
  enter_pressed = false;
  backspace_pressed = false;
  key_char_pressed = false;
  door_transition_door = -1;
  door_transition_phase = DOOR_PHASE_CLOSED;
  door_transition_started = 0;
  door_transition_target = SCREEN_NONE;
  door_transition_return_door = -1;
  door_transition_arrival_x = 0;
  door_transition_arrival_y = 0;
  door_transition_facing = 1;
  screen = SCREEN_COMMAND;
  current_room = SCREEN_COMMAND;
}

void beginVerificationFixture(){
  captureVerificationBaseline();
  restoreVerificationFixture();
  randomSeed(20260919);
  resetRun();
  restoreVerificationTables();

  int[] deterministic_sequence = {
    PROBLEM_ENGINE, PROBLEM_FOOD, PROBLEM_CONFLICT, PROBLEM_HULL, PROBLEM_LIFE_SUPPORT
  };
  arrayCopy(deterministic_sequence, incident_sequence);
  screen = SCREEN_COMMAND;
  current_room = SCREEN_COMMAND;
}

void endVerificationFixture(){
  restoreVerificationFixture();
}


boolean harnessDrawScene(PGraphics target){
  if (pipeline_test_mode){
    drawPipelineProbe(target);
    return true;
  }

  if (capture_mode && capture_step >= capture_label.length && campaign_checks_running){
    drawCaptureCheckScreen(target);
    return true;
  }

  return false;
}


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
    File pipeline_file = new File(sketchPath("data/" + PIPELINE_PROBE_FILE));
    if (!pipeline_file.isFile()){
      recordFallbackDiagnostic(PIPELINE_PROBE_FILE, "pipeline_image",
        "missing_file", "geometric_fallback");
      pipeline_probe_image = null;
    } else {
      try {
        pipeline_probe_image = loadImage(PIPELINE_PROBE_FILE);
      } catch (RuntimeException error){
        pipeline_probe_image = null;
      }
      if (!validArtImage(pipeline_probe_image)){
        recordFallbackDiagnostic(PIPELINE_PROBE_FILE, "pipeline_image",
          "invalid_png", "geometric_fallback");
        pipeline_probe_image = null;
      }
    }
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
  System.err.println("Diagnóstico: " + reason
    + ". Impacto: a captura não foi iniciada e não pode servir como evidência.");
  System.exit(2);
}


void performanceFail(String reason){
  println("METRICS CHECK: FAIL — " + reason);
  System.err.println("Diagnóstico: " + reason
    + ". Impacto: a amostra não pode servir como evidência.");
  System.exit(1);
}


void requirePerformanceStartupEnvironment(String name){
  String value = System.getenv(name);
  if (value == null || value.length() == 0){
    performanceInconclusive(name);
  }
}


String performanceEnvironment(){
  return performanceRequiredEnvironment("METRICS_ENVIRONMENT");
}


String performanceMachine(){
  return performanceRequiredEnvironment("METRICS_MACHINE");
}


String performanceGpu(){
  return performanceRequiredEnvironment("METRICS_GPU");
}


String performanceProcessingVersion(){
  return performanceRequiredEnvironment(PERFORMANCE_PROCESSING_VERSION_ENV);
}


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
  return performanceRequiredProperty("os.name")
    + " " + performanceRequiredProperty("os.version");
}


String performanceAssets(){
  return PERFORMANCE_FIXTURE_ID;
}


JSONObject performanceSidecar(){
  JSONObject sidecar = new JSONObject();
  sidecar.setString("environment", performanceEnvironment());
  sidecar.setString("machine", performanceMachine());
  sidecar.setString("assets", performanceAssets());
  sidecar.setString("room", PERFORMANCE_ROOM_ID);
  sidecar.setString("state", PERFORMANCE_STATE_ID);
  sidecar.setInt("nominal_window_s", 30);
  sidecar.setString("processing", performanceProcessingVersion());
  sidecar.setString("hardware", performanceHardware());
  sidecar.setString("gpu", performanceGpu());
  sidecar.setString("os", performanceOs());
  return sidecar;
}


void writePerformanceProfile(String sample_id, float median_ms, float p95_ms,
  float allocations_per_frame, int icon_builds,
  int floor_band_builds, int invalidations){
  String profile_directory = sketchPath("output/profiling/" + performance_version
    + "/" + performance_profile + "/" + PERFORMANCE_SCENARIO_ID);
  new File(profile_directory).mkdirs();

  JSONObject profiling = new JSONObject();
  profiling.setString("profile", performance_profile);
  profiling.setString("version", performance_version);
  profiling.setString("scenario", PERFORMANCE_SCENARIO_ID);
  profiling.setString("sample", sample_id);
  profiling.setString("status", "EXECUTED");
  profiling.setString("metrics_contract", "code/VERIFICATION.md#contrato-canônico-de-métricas");
  profiling.setString("metrics_csv", "last_horizon/output/" + performance_version
    + "/" + performance_profile + "/" + sample_id + ".csv");
  profiling.setString("sidecar_json", "last_horizon/output/" + performance_version
    + "/" + performance_profile + "/" + sample_id + ".sidecar.json");
  profiling.setString("temporal_json", "last_horizon/output/" + performance_version
    + "/" + performance_profile + "/" + sample_id + ".temporal.json");

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


String performanceSampleId(){
  return "sample-" + nf(performance_sample_index + 1, 2);
}


String performanceSampleDirectory(){
  return sketchPath("output/" + performance_version + "/" + performance_profile);
}


long performanceAllocatedBytes(){
  try {
    java.lang.management.ThreadMXBean bean =
      java.lang.management.ManagementFactory.getThreadMXBean();
    if (!(bean instanceof com.sun.management.ThreadMXBean)){
      return -1;
    }

    com.sun.management.ThreadMXBean allocated = (com.sun.management.ThreadMXBean) bean;
    if (!allocated.isThreadAllocatedMemorySupported()){
      return -1;
    }
    if (!allocated.isThreadAllocatedMemoryEnabled()){
      allocated.setThreadAllocatedMemoryEnabled(true);
    }
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
  performance_sample_resource_builds = resource_icon_builds;
  performance_sample_deck_builds = deck_strip_builds;
  performance_sample_invalidations = cache_invalidations;
  performance_sample_start_allocated_bytes = performanceAllocatedBytes();
  performance_sample_start_audio_failures = movement_audio_playback_failure_count;
  performance_sample_finish_pending = false;
  performance_cadence_fps = PERFORMANCE_CADENCE_SEQUENCE[performance_sample_index];
  if (performance_fake_clock != null){
    performance_fake_clock.setCadence(performance_cadence_fps);
  }
  int temporalCapacity = performance_frame_times.length;
  if (performance_temporal_callback_ms == null
    || performance_temporal_callback_ms.length != temporalCapacity){
    performance_temporal_callback_ms = new float[temporalCapacity];
    performance_temporal_simulation_ms = new float[temporalCapacity];
    performance_temporal_render_ms = new float[temporalCapacity];
    performance_temporal_draw_base_ms = new float[temporalCapacity];
    performance_temporal_draw_window_ms = new float[temporalCapacity];
    performance_temporal_audio_dispatch_ms = new float[temporalCapacity];
  }
  performance_temporal_callbacks.ensureCapacity(temporalCapacity);
  performance_temporal_callbacks.clear();
  performance_temporal_metric_count = 0;
  performance_temporal_distance_px = 0.0f;
  performance_temporal_previous_x = player_x;
  performance_temporal_previous_y = player_y;
  performance_temporal_clock_status = "PASS";
  performance_temporal_audio_status = "PASS";
  performance_temporal_asset_status = "PASS";
  performance_temporal_cache_status = cacheMetricsAvailable() ? "PASS" : "INCONCLUSIVO";
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
  if (performance_sample_frames <= 0){
    performanceFail("amostra sem quadros medidos");
  }
  if (!cacheMetricsAvailable()){
    performanceFail("contadores dos caches indisponíveis na amostra");
  }
  if (performance_sample_start_memory < 0 || performanceUsedMemory() < 0){
    performanceFail("memória adicional indisponível na amostra");
  }
  float median_ms = performancePercentile(performance_frame_times, performance_sample_frames, 0.50);
  float p95_ms = performancePercentile(performance_frame_times, performance_sample_frames, 0.95);
  long additional_memory = cache_memory_peak_bytes;
  if (additional_memory < 0){
    performanceFail("memória adicional do cache inválida na amostra");
  }
  if (!art_load_measured || art_load_ms < 0){
    performanceFail("tempo de carregamento indisponível na amostra");
  }
  long allocated_bytes = performanceAllocatedBytes();
  if (allocated_bytes < performance_sample_start_allocated_bytes
    || performance_sample_start_allocated_bytes < 0){
    performanceFail("contador de alocação inválido na amostra");
  }
  float allocations_per_frame = (allocated_bytes - performance_sample_start_allocated_bytes)
    / (float) performance_sample_frames;
  if (duration_seconds < PERFORMANCE_SAMPLE_NANOS / 1000000000.0f
    - PERFORMANCE_DURATION_TOLERANCE_S
    || duration_seconds > PERFORMANCE_SAMPLE_NANOS / 1000000000.0f
    + PERFORMANCE_DURATION_TOLERANCE_S){
    performanceFail("duração fora da tolerância na " + performanceSampleId());
  }
  String sample_id = performanceSampleId();
  String sample_directory = performanceSampleDirectory();
  new File(sample_directory).mkdirs();

  java.io.PrintWriter metrics_writer = createWriter(
    sample_directory + "/" + sample_id + ".csv");
  metrics_writer.println(PERFORMANCE_METRICS_HEADER);
  metrics_writer.println(
    sample_id + ","
      + Float.toString(duration_seconds) + ","
      + performance_sample_frames + ","
      + Float.toString(median_ms) + ","
      + Float.toString(p95_ms) + ","
      + art_load_ms + ","
      + additional_memory + ","
      + (resource_icon_builds - performance_sample_resource_builds) + ","
      + (deck_strip_builds - performance_sample_deck_builds) + ","
      + (cache_invalidations - performance_sample_invalidations) + ","
      + Float.toString(allocations_per_frame)
  );
  metrics_writer.flush();
  metrics_writer.close();
  saveJSONObject(performanceSidecar(),
    sample_directory + "/" + sample_id + ".sidecar.json");
  saveJSONObject(performanceTemporalSidecar(sample_id, duration_seconds),
    sample_directory + "/" + sample_id + ".temporal.json");
  writePerformanceProfile(sample_id, median_ms, p95_ms,
    allocations_per_frame,
    resource_icon_builds - performance_sample_resource_builds,
    deck_strip_builds - performance_sample_deck_builds,
    cache_invalidations - performance_sample_invalidations);

  println("metrics: amostra " + (performance_sample_index + 1)
    + " | mediana " + Float.toString(median_ms)
    + " ms | p95 " + Float.toString(p95_ms) + " ms"
    + " | memória adicional " + additional_memory + " bytes"
    + " | duração " + Float.toString(duration_seconds) + " s");
  println("metrics: csv=last_horizon/output/" + performance_version + "/"
    + performance_profile + "/" + sample_id + ".csv"
    + " | sidecar=last_horizon/output/" + performance_version + "/"
    + performance_profile + "/" + sample_id + ".sidecar.json"
    + " | profiling=last_horizon/output/profiling/" + performance_version + "/"
    + performance_profile + "/" + PERFORMANCE_SCENARIO_ID + "/" + sample_id + ".json");

  performance_sample_index++;
  if (performance_sample_index >= PERFORMANCE_SAMPLE_COUNT){
    println("METRICS CHECK: PASS");
    exit();
    return;
  }

  beginPerformanceSample(System.nanoTime());
}


void updatePerformanceMetrics(){
  if (!performance_observer_installed){
    frame_callback_observer = (context) -> recordPerformanceCallback(context);
    performance_observer_installed = true;
  }
  if (!performance_fake_clock_installed){
    performance_fake_clock = new ProfileCadenceFrameClockSource(
      frame_clock.simulationTimeSeconds());
    frame_clock.replaceSource(performance_fake_clock);
    performance_fake_clock_installed = true;
  }

  long now_nanos = System.nanoTime();
  if (performance_last_frame_nanos == 0){
    performance_last_frame_nanos = now_nanos;
    return;
  }

  if (performance_warmup_frames < PERFORMANCE_WARMUP_FRAMES){
    performance_warmup_frames++;
    performance_last_frame_nanos = now_nanos;
    if (performance_warmup_frames == PERFORMANCE_WARMUP_FRAMES){
      beginPerformanceSample(now_nanos);
    }
    return;
  }

  float frame_ms = (now_nanos - performance_last_frame_nanos) / 1000000.0f;
  if (performance_sample_frames >= performance_frame_times.length){
    performanceFail("janela excedeu o limite de quadros da captura");
  }
  performance_frame_times[performance_sample_frames] = frame_ms;
  performance_sample_frames++;
  performance_last_frame_nanos = now_nanos;

  if (now_nanos - performance_sample_started_nanos >= PERFORMANCE_SAMPLE_NANOS){
    performance_sample_finish_pending = true;
  }
}

void preparePipelineProbe(){
  pipeline_probe_layer = createGraphics(
    PIPELINE_PROBE_SIZE * RENDER_SCALE,
    PIPELINE_PROBE_SIZE * RENDER_SCALE
  );
  pipeline_probe_layer.noSmooth();
  pipeline_probe_layer.beginDraw();
  pipeline_probe_layer.clear();
  pipeline_probe_layer.imageMode(CENTER);
  if (pipeline_probe_image != null){
    pipeline_probe_layer.image(
      pipeline_probe_image,
      PIPELINE_PROBE_SIZE * RENDER_SCALE / 2,
      PIPELINE_PROBE_SIZE * RENDER_SCALE / 2,
      PIPELINE_PROBE_SIZE * RENDER_SCALE,
      PIPELINE_PROBE_SIZE * RENDER_SCALE
    );
  } else {
    pipeline_probe_layer.noStroke();
    pipeline_probe_layer.fill(COL_PANEL_2);
    pipeline_probe_layer.rect(0, 0,
      PIPELINE_PROBE_SIZE * RENDER_SCALE,
      PIPELINE_PROBE_SIZE * RENDER_SCALE);
    pipeline_probe_layer.stroke(COL_ORANGE);
    pipeline_probe_layer.line(0, 0,
      PIPELINE_PROBE_SIZE * RENDER_SCALE,
      PIPELINE_PROBE_SIZE * RENDER_SCALE);
    pipeline_probe_layer.line(
      PIPELINE_PROBE_SIZE * RENDER_SCALE, 0, 0,
      PIPELINE_PROBE_SIZE * RENDER_SCALE);
  }
  pipeline_probe_layer.endDraw();
}



void checkCurrentPresentationCallback(){
  presentation_callback_checks++;
  FrameContext context = current_frame_context;
  if (context != null && context.presentation_count == 1){
    for (String surface : context.presentation_surfaces.keySet()){
      Integer observed_count = presentation_surface_observations.get(surface);
      presentation_surface_observations.put(surface,
        observed_count == null ? 1 : observed_count + 1);
    }
  }
  boolean valid = context != null && context.presentation_count == 1
    && !context.presentation_active
    && context.presentation_state_version == context.confirmed_state_version
    && context.final_state_version == context.confirmed_state_version
    && context.viewport_width == width && context.viewport_height == height
    && context.viewport_scale == view_scale
    && context.presentation_surfaces.containsKey("cursor")
    && context.presentation_surfaces.containsKey("window")
    && (context.presentation_surfaces.containsKey("screens")
      || context.presentation_surfaces.containsKey("harness_scene"));

  if (valid){
    int draw_base_index = context.phase_sequence.indexOf("draw_base");
    int cursor_index = context.phase_sequence.indexOf("cursor");
    int draw_window_index = context.phase_sequence.indexOf("draw_window");
    valid = draw_base_index >= 0 && cursor_index > draw_base_index
      && draw_window_index > cursor_index;
  }
  if (valid && context.presentation_surfaces.containsKey("screens")
    && isRoomScreen()){
    presentation_room_callback_checks++;
    valid = context.presentation_surfaces.containsKey("screen_content")
      && context.presentation_surfaces.containsKey("room")
      && context.presentation_surfaces.containsKey("player")
      && context.presentation_surfaces.containsKey("hud")
      && context.presentation_surfaces.containsKey("ui")
      && context.hud_pass_count == 1;
  }
  valid &= context != null && context.button_reset_count == 1
    && context.button_add_count >= button_count;
  if (valid){
    for (java.util.Map.Entry<String, Long> entry : context.presentation_surfaces.entrySet()){
      if (entry.getValue() != context.presentation_state_version){
        valid = false;
        break;
      }
    }
  }

  if (!valid){
    presentation_callback_failures++;
    checks_failed = true;
    println("presentation: FAIL callback="
      + (context == null ? "ausente" : String.valueOf(context.callback_id))
      + "; diagnóstico=versão, superfícies, viewport ou sequência inválida");
  }
}


void updateCapture(){
  if (performance_mode){
    updatePerformanceMetrics();
    return;
  }

  if (capture_mode){
    checkCurrentPresentationCallback();
  }

  if (pipeline_test_mode && frameCount == PIPELINE_TEST_FRAME){
    runPipelineProbe();
    return;
  }

  if (hit_test_mode && frameCount == HIT_TEST_FRAME){
    runHitTest();
    return;
  }

  if (ladder_test_mode && frameCount == HIT_TEST_FRAME){
    runLadderTest();
    return;
  }

  if (!capture_mode || frameCount < CAPTURE_FIRST_FRAME
    || frameCount < capture_next_frame){
    return;
  }

  if (capture_step >= capture_label.length){
    if (!rule_checks_started){
      rule_checks_started = true;
      runRuleChecks();
    }

    if (checks_failed){
      reportQuestCheck();
      exit();
      return;
    }

    if (campaign_checks_running){
      advanceCampaignChecks();
      return;
    }

    if (!rule_checks_finished){
      rule_checks_finished = true;
      reportQuestCheck();
      restoreVerificationFixture();
      exit();
    }
    return;
  }

  saveCanvas(capture_step);
  runCaptureStep(capture_step);
  capture_step++;
  capture_next_frame = frameCount + CAPTURE_FRAME_GAP;
}
void drawCaptureCheckScreen(PGraphics g){
  drawStars(g);
  textCentered(g, "VERIFICAÇÃO DO SKETCH", BASE_W / 2.0, 96, 24, COL_CYAN);
  drawPanel(g, 126, 130, 388, 112, COL_BORDER);
  textCentered(g, "A JANELA CONTINUA RESPONSIVA", BASE_W / 2.0, 148, 16, COL_TEXT);

  String status = campaign_phase < 2
    ? "VALIDANDO CAMPANHAS REPRESENTATIVAS"
    : "VALIDANDO TODAS AS PERMUTAÇÕES";
  textCentered(g, status, BASE_W / 2.0, 180, 16, COL_MUTED);

  if (campaign_phase >= 2){
    textCentered(g, capture_campaign_wins + " / 2520 CAMPANHAS", BASE_W / 2.0, 208, 16, COL_GREEN);
  } else {
    textCentered(g, "RECURSOS DA PARTIDA NÃO SÃO EXIBIDOS", BASE_W / 2.0, 208, 16, COL_GREEN);
  }
}



void runPipelineProbe(){
  boolean loaded = pipeline_probe_image != null
    && pipeline_probe_image.width == PIPELINE_PROBE_SIZE
    && pipeline_probe_image.height == PIPELINE_PROBE_SIZE;

  verify("fixture PNG 16x16 carregado via loadImage", loaded);
  if (!loaded) return;

  base.save(verificationOutputPath("pipeline", "probe", RENDER_W, RENDER_H));
  saveFrame(verificationOutputPath("pipeline_window", "probe", width, height));

  println("pipeline: OK - " + PIPELINE_PROBE_FILE
    + " carregado via loadImage()");

  restoreVerificationFixture();
  exit();
}


void drawPipelineProbe(PGraphics target){
  target.background(COL_BG);
  target.fill(COL_CYAN);
  target.textSize(16);
  target.text("ASSET PIPELINE", 24, 24);
  target.fill(COL_TEXT);
  target.textSize(12);
  target.text("PNG 16x16 -> loadImage()", 24, 48);

  target.fill(COL_PANEL);
  target.rect(244, 96, 152, 152);
  if (pipeline_probe_layer != null){
    target.image(pipeline_probe_layer, BASE_W / 2, 172,
      PIPELINE_PROBE_SIZE, PIPELINE_PROBE_SIZE);
  }

  target.fill(COL_TEXT);
  target.text("16 x 16 PNG / render lógico 2x", 24, 278);
  target.fill(COL_MUTED);
  target.text("pixel art sem interpolação", 24, 300);
}


void saveCanvas(int step){
  base.save(verificationOutputPath("capture", capture_label[step], RENDER_W, RENDER_H));
  saveFrame(verificationOutputPath("capture_window", capture_label[step], width, height));
  println("capture: " + capture_label[step] + " -> " + screenName());
}

String verificationOutputPath(String stage, String state, int viewport_w, int viewport_h){
  return sketchPath("output/" + stage + "__" + state + "__"
    + viewport_w + "x" + viewport_h + ".png");
}


void runCaptureStep(int step){
  if (step == 0){ typeText("TECNICO"); clickAction(ACTION_START_GAME); }
  else if (step >= 1 && step <= 3) clickAction(ACTION_VIGNETTE_NEXT);
  else if (step == 4){
    verify("dia 1 começa livre com ofertas disponíveis", day == 1 && screen == SCREEN_COMMAND && !modalOpen() && ordersAvailable());
    clickAction(ACTION_OPEN_ORDERS);
    base.save(verificationOutputPath("manual", "preventive_offers", RENDER_W, RENDER_H));
    clickAction(ACTION_ORDER_A);
  } else if (step == 5){
    captureInteract(POINT_VERA);
  } else if (step == 6){
    verify("escolha remota não aceita ordem", active_quest < 0 && dialog_open);
    pressEnter();
    verify("aceite presencial habilita coleta", active_quest == 0 && quest_stage == QUEST_COLLECT);
  } else if (step == 7){ clickAction(ACTION_OPEN_MAP); }
  else if (step == 8){
    float before = player_x;
    int before_room = screen;
    verify("mapa gráfico não transporta", map_open
      && screen == before_room && player_x == before);
    clickAction(ACTION_CLOSE_MODAL);
    captureInteract(POINT_RESERVE);
  } else if (step == 9){
    verify("coleta aguarda confirmação", held_item == ITEM_NONE && technical_open);
    pressEnter();
  } else if (step == 10){ captureInteract(POINT_ANTENNA); }
  else if (step == 11){
    verify("entrega aguarda confirmação", morale == 80 && held_item != ITEM_NONE);
    pressEnter();
    verify("preventiva recompensa e conclui", morale == 88 && quest_completed && held_item == ITEM_NONE);
  } else if (step == 12){ captureInteract(POINT_TECH_BUNK); }
  else if (step == 13){
    incident_sequence[0] = PROBLEM_ENGINE;
    projectNight();
    pressEnter();
    verify("dormir aplica consumo e abre incidente", day == 2 && event_open && energy == 73 && morale == 86);
    verify("transmissão da Terra precede o incidente", transmission_open);
    closeTopModal();
  } else if (step == 14){ clickAction(ACTION_EVENT_A); }
  else if (step == 15){
    verify("solução exige confirmação", event_open && active_quest < 0);
    pressEnter();
  } else if (step == 16){ captureInteract(POINT_ROUTE); pressEnter(); }
  else if (step == 17){ captureInteract(POINT_ENGINE_BENCH); }
  else if (step == 18){
    pressEnter();
    verify("entrega urgente paga e remove problema", parts == 2 && !problem_active[PROBLEM_ENGINE] && quest_completed);
  } else if (step == 19){
    captureSleep();
    verify("dia tranquilo não abre ordens automaticamente", !orders_open && ordersAvailable());
    clickAction(ACTION_OPEN_ORDERS);
    clickAction(ACTION_ORDER_A);
    captureInteract(POINT_VERA); pressEnter();
    captureInteract(POINT_TECH_BUNK);
  } else if (step == 20){
    verify("previsão mostra falha aceita", preventiveNightLoss(RESOURCE_ENERGY) == 3);
    closeTopModal();
    captureStartDay(3);
    captureInteract(POINT_TECH_BUNK);
  } else if (step == 21){
    verify("previsão mostra duas perdas", preventiveNightLoss(RESOURCE_ENERGY) == 4 && preventiveNightLoss(RESOURCE_WATER) == 4);
    captureStartDay(2);
    applyEventChoice(0); pressEnter(); captureSleep();
    clickAction(ACTION_OPEN_ORDERS);
    clickAction(ACTION_NEXT_RETRY);
  } else if (step == 22){
    verify("retomada mantém solução e prazo", orders_page == PROBLEM_ENGINE && problem_deadline[PROBLEM_ENGINE] == 2);
    closeTopModal();
    putSurvivorAtRisk(PROBLEM_CONFLICT);
    enterRoom(SCREEN_DORMITORY);
  } else if (step == 23){ captureInteract(POINT_RISK_BUNK); }
  else if (step == 24){
    pressEnter();
    verify("socorro usa quest sem cancelar negligência", urgentRisk() < 0 && quest_completed && preventiveNightLoss(RESOURCE_ENERGY) == 4);
  } else if (step == 25){ handleEscape(); }
  else if (step == 26){ clickAction(ACTION_RESUME); oxygen = 0; checkEndConditions(); }
  else if (step == 27){
    captureStartDay(9); day = TRIP_DAYS; resetDailyQuest(); captureSleep();
  } else if (step == 28){
    captureStartDay(3);
    for (int p = 0; p < PROBLEM_COUNT; p++) activateProblem(p, 1);
    putSurvivorAtRisk(PROBLEM_FOOD);
    captureInteract(POINT_TECH_BUNK);
  }
  else if (step == 30){
    closeTopModal();
    clickAction(ACTION_OPEN_HELP);
  } else if (step == 31){
    verify("ajuda abre pelo botão do rodapé", help_open && !paused);
    handleEscape();
  } else if (step == 32){
    resetRun();
    day = 2;
    incident_sequence[0] = PROBLEM_ENGINE;
    enterRoom(SCREEN_DORMITORY);
    openDay();
  } else if (step == 33){
    verify("dia com falha do motor abre pela transmissão da Terra",
      transmission_open && event_open && transmission_text.indexOf("O MOTOR FALHOU") >= 0);
    closeTopModal();
    verify("fechar a transmissão revela o cartão do incidente", !transmission_open && event_open);
  }
}

void captureStartDay(int target){
  resetRun();
  day = target;
  int[] capture_sequence = {PROBLEM_ENGINE, PROBLEM_HULL, PROBLEM_FOOD,
    PROBLEM_CONFLICT, PROBLEM_LIFE_SUPPORT};
  arrayCopy(capture_sequence, incident_sequence);
  enterRoom(target == 1 ? SCREEN_COMMAND : SCREEN_DORMITORY);
  openDay();
  transmission_open = false;
  if (orders_open) closeTopModal();
}

void captureInteract(int point){
  enterRoom(point_room[point]);
  setCapturePlayerAtPoint(point);
  interact_queued = true;
  updateRoom(movementHarnessStepContext());
}

void captureSleep(){
  if (orders_open) closeTopModal();
  captureInteract(POINT_TECH_BUNK);
  pressEnter();
}

void captureCompleteQuest(){
  int q = active_quest;
  if (quest_stage == QUEST_COLLECT){
    captureInteract(quest_origin[q]); pressEnter();
  }
  captureInteract(quest_destination[q]); pressEnter();
}

void captureAcceptPreventive(int choice){
  int selected_offer = choice >= 0 && choice < 2 ? daily_offers[choice] : choice;
  choosePreventive(selected_offer);
  if (selected_preventive_id < 0) return;
  captureInteract(crew_point[quest_owner[selected_preventive_id]]);
  pressEnter();
}

void checkNpcDialogue(){
  captureStartDay(1);
  int owner = quest_owner[daily_offers[0]];
  int other = (owner + 1) % CREW_COUNT;

  while (!crew_alive[other]) other = (other + 1) % CREW_COUNT;

  captureInteract(crew_point[owner]);
  verify("oferta do dia aparece na fala do responsável",
    dialog_open && !technical_open && dialog_text.indexOf("Minha oferta") >= 0);
  closeTopModal();

  choosePreventive(0);
  captureInteract(crew_point[owner]);
  verify("responsável pede confirmação presencial",
    dialog_open && pending_quest_action == ACTION_ACCEPT_ORDER && active_quest < 0);
  pressEnter();
  verify("confirmação presencial aceita a ordem",
    active_quest == daily_offers[0] && quest_stage == QUEST_COLLECT);

  captureInteract(crew_point[owner]);
  verify("responsável com quest ativa orienta a etapa",
    dialog_open && dialog_result.length() > 0 && dialog_text.indexOf("etapa atual") >= 0);
  closeTopModal();

  captureInteract(crew_point[other]);
  verify("terceiro orienta o próximo passo sem repetir a quest",
    dialog_open && !technical_open && dialog_text.indexOf(crewDisplayName(owner)) >= 0
    && dialog_text.indexOf(editorialSentenceCase(quest_object[active_quest])) >= 0);
  closeTopModal();

  captureCompleteQuest();
  captureInteract(crew_point[owner]);
  verify("quest concluída encerra a conversa",
    dialog_open && (dialog_text.indexOf("Rota conferida") >= 0
      || dialog_text.indexOf("trabalho de hoje acabou") >= 0));
  closeTopModal();

  crew_alive[owner] = false;
  verify("sobrevivente morto não interage", !pointIsAvailable(crew_point[owner]));
  crew_alive[owner] = true;
}


void checkEditorialContract(){
  verify("catálogo editorial cobre 22 IDs únicos", editorialCatalogValid());

  String saved_motivation = editorial_catalog[0][EDITORIAL_SHORT_MOTIVATION];
  editorial_catalog[0][EDITORIAL_SHORT_MOTIVATION] = "";
  String fallback = questMotivation(0);
  editorial_catalog[0][EDITORIAL_SHORT_MOTIVATION] = saved_motivation;
  verify("entrada editorial inválida usa fallback factual",
    fallback.length() > 0 && fallback.indexOf(quest_id[0]) < 0);

  int crew = CREW_VERA;
  int saved_day = day;
  boolean saved_alive = crew_alive[crew];
  resetEditorialMemory();
  crew_alive[crew] = true;
  day = 1;
  recordEditorialResult(0, EDITORIAL_RESULT_HELP);
  int count_before = editorial_conversation_count[crew];
  boolean presented_before = editorial_was_presented[crew];
  String phase_a = editorialPhaseLine(crew);
  String phase_b = editorialPhaseLine(crew);
  verify("consultas editoriais são puras",
    phase_a.equals(phase_b) && editorial_conversation_count[crew] == count_before
    && editorial_was_presented[crew] == presented_before);
  String recognition = editorialRecognition(crew);
  verify("reconhecimento fica disponível no dia do resultado", recognition.length() > 0);
  String context = editorialContextLine(crew);
  verify("contexto não marca apresentação", context.length() > 0 && !editorial_was_presented[crew]);
  beginNpcConversation(crew);
  verify("abertura incrementa uma conversa e apresenta reconhecimento",
    editorial_conversation_count[crew] == count_before + 1 && editorial_was_presented[crew]);
  closeTopModal();

  resetEditorialMemory();
  day = 1;
  recordEditorialResult(0, EDITORIAL_RESULT_HELP);
  day = 2;
  verify("reconhecimento sobrevive ao dia seguinte", editorialRecognition(crew).length() > 0);
  day = 3;
  verify("reconhecimento envelhece depois do dia seguinte", editorialRecognition(crew).length() == 0);

  resetEditorialMemory();
  day = 1;
  recordEditorialResult(0, EDITORIAL_RESULT_HELP);
  recordEditorialRisk(crew);
  verify("risco não sobrescreve resultado editorial",
    editorial_last_result[crew] == EDITORIAL_RESULT_HELP
    && editorial_last_risk_day[crew] == day);
  editorial_last_result[crew] = EDITORIAL_RESULT_OMISSION;
  recordEditorialResult(0, EDITORIAL_RESULT_FAILURE);
  recordEditorialResult(0, EDITORIAL_RESULT_RESCUE);
  verify("prioridade de resultado é socorro, ajuda, falha, omissão",
    editorial_last_result[crew] == EDITORIAL_RESULT_RESCUE);

  resetEditorialMemory();
  day = saved_day;
  crew_alive[crew] = saved_alive;
}


void checkCacheContract(){
  boolean six_sources_available = art_icon != null && art_icon.length == 6;
  for (int icon = 0; icon < 6 && six_sources_available; icon++){
    six_sources_available &= art_icon[icon] != null;
  }
  verify("seis fontes de ícone constroem seis caches", six_sources_available
    && resource_icon_builds == 6
    && resource_icon_entries.size() == 6);

  int icon_builds_before = resource_icon_builds;
  PImage icon_zero_before = resource_icon_cache[0];
  prepareResourceIconCache();
  verify("ícones estabilizam sem buffer por quadro",
    resource_icon_builds == icon_builds_before
    && resource_icon_cache[0] == icon_zero_before);

  boolean shared_floor_source = true;
  boolean shared_floor_bitmap = true;
  for (int deck = 1; deck < DECK_COUNT; deck++){
    shared_floor_source &= deck_strip_sources[deck] == deck_strip_sources[0];
    shared_floor_bitmap &= art_deck_strip[deck] == art_deck_strip[0];
  }
  verify("faixas de piso idênticas compartilham uma entrada imutável",
    shared_floor_source && shared_floor_bitmap && deck_strip_builds == 1);

  int saved_floor_width = deck_strip_widths[0];
  int saved_floor_scale = deck_strip_scales[0];
  PImage saved_floor_source = art_floor[0];
  int floor_builds_before = deck_strip_builds;
  int floor_invalidations_before = cache_invalidations;
  prepareDeckStrips(saved_floor_width + 1, saved_floor_scale);
  boolean width_rebuilt = deck_strip_builds == floor_builds_before + 1
    && cache_invalidations == floor_invalidations_before + 1;
  prepareDeckStrips(saved_floor_width, saved_floor_scale + 1);
  boolean scale_rebuilt = deck_strip_builds == floor_builds_before + 2
    && cache_invalidations == floor_invalidations_before + 2;
  PImage replacement_floor = createImage(saved_floor_source.width,
    saved_floor_source.height, ARGB);
  art_floor[0] = replacement_floor;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  boolean source_rebuilt = deck_strip_builds == floor_builds_before + 3
    && cache_invalidations == floor_invalidations_before + 3;
  art_floor[0] = saved_floor_source;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  verify("faixas invalidam largura, escala e fonte seletivamente",
    width_rebuilt && scale_rebuilt && source_rebuilt);

  PImage saved_icon = art_icon[0];
  PImage alternate_icon = art_icon[1];
  PImage unaffected_cache = resource_icon_cache[1];
  int unaffected_builds = resource_icon_builds_by_icon[1];
  int invalidations_before = cache_invalidations;
  art_icon[0] = alternate_icon;
  ensureResourceIconCache(0);
  boolean selective = resource_icon_cache[1] == unaffected_cache
    && resource_icon_builds_by_icon[1] == unaffected_builds
    && cache_invalidations == invalidations_before + 1;
  art_icon[0] = saved_icon;
  ensureResourceIconCache(0);
  verify("invalidação reconstrói somente a fonte alterada", selective);

  String probe_name = "__room_detail_pipeline_probe__";
  String probe_path = ART_DECORATION_DIR + probe_name + ".png";
  long filesystem_before = art_filesystem_checks;
  PImage first_miss = roomDetail(probe_name);
  long filesystem_after_first = art_filesystem_checks;
  PImage cached_miss = roomDetail(probe_name);
  long filesystem_after_hit = art_filesystem_checks;
  boolean policy_cached = first_miss == null && cached_miss == null
    && art_cache.containsKey(probe_path)
    && art_cache.containsKey("legacy-room:" + probe_name)
    && filesystem_after_first > filesystem_before
    && filesystem_after_hit == filesystem_after_first;
  invalidateArtPath(probe_path);
  long filesystem_before_retry = art_filesystem_checks;
  roomDetail(probe_name);
  boolean explicit_invalidation_retries = art_filesystem_checks
    == filesystem_before_retry + 2;
  room_detail_cache.remove(probe_name);
  art_cache.remove(probe_path);
  art_cache.remove("legacy-room:" + probe_name);
  verify("roomDetail usa loadArt e memoriza miss até invalidar a fonte",
    policy_cached && explicit_invalidation_retries);

  PImage last_valid_probe = createImage(2, 2, ARGB);
  room_detail_last_valid_cache.put(probe_name, last_valid_probe);
  invalidateArtPath(probe_path);
  PImage recovered_probe = roomDetail(probe_name);
  boolean retained_last_valid = recovered_probe == last_valid_probe;
  room_detail_cache.remove(probe_name);
  room_detail_last_valid_cache.remove(probe_name);
  art_cache.remove(probe_path);
  art_cache.remove("legacy-room:" + probe_name);
  verify("roomDetail preserva a última imagem válida durante uma falha de fonte",
    retained_last_valid);

  PImage valid_icon = resource_icon_cache[0];
  PImage saved_icon_source = art_icon[0];
  PImage invalid_icon_source = new PImage(0, 0, ARGB);
  int icon_builds_before_invalid = resource_icon_builds;
  long icon_misses_before_invalid = resource_icon_cache_misses;
  long icon_hits_before_invalid = resource_icon_cache_hits;
  long fallbacks_before_invalid_icon = fallback_diagnostic_count;
  art_icon[0] = invalid_icon_source;
  ensureResourceIconCache(0);
  long fallbacks_after_invalid_icon = fallback_diagnostic_count;
  ensureResourceIconCache(0);
  boolean invalid_icon_cached = resource_icon_cache[0] == valid_icon
    && resource_icon_cache_misses == icon_misses_before_invalid + 1
    && resource_icon_cache_hits == icon_hits_before_invalid + 1
    && resource_icon_builds == icon_builds_before_invalid
    && fallbacks_after_invalid_icon == fallbacks_before_invalid_icon + 1
    && fallback_diagnostic_count == fallbacks_after_invalid_icon;
  art_icon[0] = saved_icon_source;
  ensureResourceIconCache(0);
  verify("ícone inválido preserva cache válido e memoiza o fallback",
    invalid_icon_cached);

  art_icon[0] = null;
  ensureResourceIconCache(0);
  boolean icon_fallback_kept = resource_icon_cache[0] == valid_icon;
  art_icon[0] = saved_icon_source;
  ensureResourceIconCache(0);
  verify("ícone indisponível preserva sua última representação válida",
    icon_fallback_kept);

  PImage saved_valid_floor = art_floor[0];
  PImage valid_floor_strip = art_deck_strip[0];
  PImage invalid_floor_source = new PImage(0, 0, ARGB);
  int floor_builds_before_invalid = deck_strip_builds;
  long floor_misses_before_invalid = deck_strip_cache_misses;
  long floor_hits_before_invalid = deck_strip_cache_hits;
  long fallbacks_before_invalid_floor = fallback_diagnostic_count;
  art_floor[0] = invalid_floor_source;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  long fallbacks_after_invalid_floor = fallback_diagnostic_count;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  boolean all_decks_kept_floor = true;
  for (int deck = 0; deck < DECK_COUNT; deck++){
    all_decks_kept_floor &= art_deck_strip[deck] == valid_floor_strip;
  }
  boolean invalid_floor_cached = all_decks_kept_floor
    && deck_strip_builds == floor_builds_before_invalid
    && deck_strip_cache_misses == floor_misses_before_invalid + 1
    && deck_strip_cache_hits == floor_hits_before_invalid
      + (DECK_COUNT * 2) - 1
    && fallbacks_after_invalid_floor == fallbacks_before_invalid_floor + 1
    && fallback_diagnostic_count == fallbacks_after_invalid_floor;
  art_floor[0] = saved_valid_floor;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  verify("faixa com fonte inválida preserva bitmap e não repete construção",
    invalid_floor_cached);

  valid_floor_strip = art_deck_strip[0];
  art_floor[0] = null;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  boolean floor_fallback_kept = art_deck_strip[0] == valid_floor_strip;
  art_floor[0] = saved_floor_source;
  prepareDeckStrips(saved_floor_width, saved_floor_scale);
  verify("faixa sem fonte preserva a última representação válida",
    floor_fallback_kept);
}

void checkNpcFacingDuringJump(){
  resetRun();
  float npc_x = 200;
  float npc_y = deck_y[DECK_COUNT - 1];

  player_x = npc_x - PLAYER_W - 4;
  player_y = npc_y - PLAYER_H;
  player_grounded = true;
  player_on_ladder = false;
  verify("NPC olha para o jogador no convés",
    npcFacingForPlayer(npc_x, npc_y) == -1);

  player_grounded = false;
  player_y -= JUMP_HEIGHT / 2.0;
  verify("NPC mantém a direção durante o pulo",
    npcFacingForPlayer(npc_x, npc_y) == -1);

  player_x = npc_x + 4;
  verify("NPC acompanha o jogador no ar",
    npcFacingForPlayer(npc_x, npc_y) == 1);

  resetRun();
}


void checkTransmissionMessages(){
  resetRun();
  day = 2;
  incident_sequence[0] = PROBLEM_ENGINE;
  enterRoom(SCREEN_DORMITORY);
  openDay();
  verify("falha do motor traz transmissão da Terra",
    transmission_open && event_open && transmission_text.indexOf("O MOTOR FALHOU") >= 0);
  closeTopModal();
  day = 4;
  opened_day = 0;
  incident_sequence[1] = PROBLEM_ENGINE;
  openDay();
  verify("transmissão do motor dispara uma vez por partida", !transmission_open && event_open);
  closeTopModal();

  resetRun();
  day = 2;
  incident_sequence[0] = PROBLEM_HULL;
  enterRoom(SCREEN_DORMITORY);
  openDay();
  verify("chuva de meteoros traz transmissão do casco",
    transmission_open && transmission_text.indexOf("CHUVA DE METEOROS") >= 0);
  closeTopModal();

  resetRun();
  day = 3;
  enterRoom(SCREEN_DORMITORY);
  putSurvivorAtRisk(PROBLEM_FOOD);
  processSurvivorRisks();
  verify("risco sem socorro ainda não transmite", !transmission_open);
  processSurvivorRisks();
  verify("primeira perda transmite e reduz a bordo",
    transmission_open && survivors == CREW_START - 1 && transmission_text.indexOf("UMA VIDA FOI PERDIDA") >= 0);

  resetRun();
  verify("vitória com todos vivos usa a variação dos quatro",
    marsMessage().indexOf("OS QUATRO SOBREVIVENTES") >= 0);
  survivors = CREW_START - 1;
  crew_alive[CREW_VERA] = false;
  verify("vitória com perdas usa a variação dos que restaram",
    marsMessage().indexOf("OS SOBREVIVENTES QUE RESTARAM") >= 0
    && survivorsSummary().indexOf("BENTO") >= 0 && survivorsSummary().indexOf("VERA") < 0);
  engine_repaired_at_limit = true;
  verify("reparo no limite prevalece quando há perdas",
    marsMessage().indexOf("NO LIMITE") >= 0);
  resetRun();
}


void checkModalLayerContract(){
  resetRun();
  screen = SCREEN_INIT;
  paused = true;
  event_open = true;
  verify("modal ativo mantém prioridade mesmo sobre tela de menu",
    uiLayer() == LAYER_PAUSE);
  handleEscape();
  verify("ESC consulta a camada ativa antes da tela de menu",
    !paused && event_open);

  resetRun();
  screen = SCREEN_COMMAND;
  paused = true;
  transmission_open = event_open = orders_open = map_open = dialog_open = true;
  technical_open = end_day_open = help_open = true;
  verify("prioridade começa na pausa", uiLayer() == LAYER_PAUSE);
  paused = false;
  verify("transmissão cobre incidente", uiLayer() == LAYER_TRANSMISSION);
  transmission_open = false;
  verify("incidente precede ordens", uiLayer() == LAYER_EVENT);
  event_open = false;
  verify("ordens precedem mapa", uiLayer() == LAYER_ORDERS);
  orders_open = false;
  verify("mapa precede diálogo", uiLayer() == LAYER_MAP);
  map_open = false;
  verify("diálogo precede painel técnico", uiLayer() == LAYER_DIALOGUE);
  dialog_open = false;
  verify("painel técnico precede sono", uiLayer() == LAYER_TECHNICAL);
  technical_open = false;
  verify("sono precede ajuda", uiLayer() == LAYER_SLEEP);
  end_day_open = false;
  verify("ajuda precede cena", uiLayer() == LAYER_HELP);
  help_open = false;
  verify("sem modal usa a cena", uiLayer() == LAYER_SCENE);

  event_open = true;
  event_index = PROBLEM_ENGINE;
  quest_review = PREVENTIVE_COUNT;
  closeTopModal();
  verify("ESC no detalhe retorna à comparação",
    event_open && !paused && quest_review < 0);
  closeTopModal();
  verify("ESC na comparação abre pausa e preserva incidente",
    paused && event_open);

  resetRun();
  screen = SCREEN_COMMAND;
  transmission_open = event_open = true;
  doAction(ACTION_OPEN_MAP);
  verify("ação de mapa encoberta é ignorada", !map_open
    && uiLayer() == LAYER_TRANSMISSION);
  doAction(ACTION_CLOSE_MODAL);
  verify("fechar transmissão revela incidente", !transmission_open && event_open);

  resetRun();
  screen = SCREEN_COMMAND;
  orders_open = true;
  selected_preventive_id = 0;
  active_quest = 1;
  orders_page = PROBLEM_ENGINE;
  orders_details_open = true;
  closeTopModal();
  verify("fechar ordens limpa apenas seu cursor",
    !orders_open && selected_preventive_id == 0 && active_quest == 1
      && orders_page < 0 && !orders_details_open);

  resetRun();
  screen = SCREEN_COMMAND;
  end_day_open = true;
  NightProjection preview = projectNight();
  closeTopModal();
  verify("fechar sono preserva a previsão exibida",
    !end_day_open && night_preview == preview);

  resetButtons();
  help_open = true;
  draw_layer = LAYER_HELP;
  for (int button = 0; button < MAX_BUTTONS + 1; button++){
    addButton(10 + button, 20, 12, 12, ACTION_CLOSE_MODAL, true);
  }
  verify("limite de botões é por camada e registra diagnóstico",
    button_count == MAX_BUTTONS && uiButtonOverflowCount(LAYER_HELP) == 1
      && uiButtonOverflowDiagnostic(LAYER_HELP).indexOf("button_limit_exceeded") >= 0);

  resetButtons();
  addButton(10, 20, 30, 40, ACTION_CLOSE_MODAL, true);
  verify("hit-test usa a área visível do controle",
    findButton(10, 20, LAYER_HELP) == ACTION_CLOSE_MODAL
      && findButton(40, 60, LAYER_HELP) == ACTION_CLOSE_MODAL
      && findButton(41, 61, LAYER_HELP) == ACTION_NONE);
  resetRun();
}


void runRuleChecks(){
  checkFrameClockContract();
  checkPresentationClockAndTelemetry();
  beginVerificationFixture();
  checkCacheContract();
  endVerificationFixture();
  beginVerificationFixture();
  checkConnectedDoors();
  endVerificationFixture();
  if (!checks_failed){ beginVerificationFixture(); checkDoorTraversalArt(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkEditorialContract(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNpcDialogue(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNpcFacingDuringJump(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerFacing(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerAnimationLoop(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerAnimationTransitions(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerAnimationLayerCache(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerRun(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerFootsteps(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkMovementAudioAdapterContract(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkFixedStepMovementCadence(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkLongFrameAudioContract(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkTemporalPauseAndBarriers(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkOrdersBadge(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkQuestCatalogue(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkQuestBoundaries(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNightConsequences(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNightProjection(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkRetryPriority(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkCrewRules(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkHullDamageLocation(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkTransmissionMessages(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkModalLayerContract(); endVerificationFixture(); }
  if (!checks_failed) startCampaignChecks();
  if (temporalTestRequested()){
    println(checks_failed ? "TEMPORAL CHECK: FAIL" : "TEMPORAL CHECK: PASS");
  }
}


boolean temporalTestRequested(){
  if (args == null) return false;
  for (String argument : args){
    if ("--temporal-test".equals(argument)) return true;
  }
  return false;
}


void checkPresentationClockAndTelemetry(){
  FrameClock previous_clock = frame_clock;
  FrameContext previous_context = current_frame_context;
  FakeFrameClockSource source = new FakeFrameClockSource(0.0);
  FrameClock clock = new FrameClock(source);
  frame_clock = clock;

  try {
    clock.beginCallback(false, true, SCREEN_COMMAND, SCREEN_COMMAND,
      LAYER_SCENE, "capture", false);
    source.advanceSeconds(FRAME_FIXED_STEP_SECONDS);
    FrameContext active = clock.beginCallback(false, true, SCREEN_COMMAND,
      SCREEN_COMMAND, LAYER_SCENE, "capture", false);
    active.beginStep(0);
    clock.confirmStep(active);
    double simulation_before_pause = clock.simulationTimeSeconds();
    long version_before_pause = clock.confirmedStateVersion();

    source.advanceSeconds(0.35);
    FrameContext paused_first = clock.beginCallback(true, true, SCREEN_COMMAND,
      SCREEN_COMMAND, LAYER_PAUSE, "capture", false);
    current_frame_context = paused_first;
    float pulse_before = ordersPulse();
    source.advanceSeconds(0.35);
    FrameContext paused_second = clock.beginCallback(true, true, SCREEN_COMMAND,
      SCREEN_COMMAND, LAYER_PAUSE, "capture", false);
    current_frame_context = paused_second;
    float pulse_after = ordersPulse();
    boolean pause_contract = paused_first.steps_planned == 0
      && paused_second.steps_planned == 0
      && paused_second.presentation_time_ms > paused_first.presentation_time_ms
      && java.lang.Math.abs(pulse_after - pulse_before) > 0.1f
      && clock.simulationTimeSeconds() == simulation_before_pause
      && clock.confirmedStateVersion() == version_before_pause;

    FrameContext presentation = new FrameContext(FRAME_FIXED_STEP_SECONDS,
      0.0, 0.0, 0.0, 0.0, 0.0, simulation_before_pause,
      version_before_pause, 0, true, "fake", "capture", 999,
      SCREEN_COMMAND, SCREEN_COMMAND, LAYER_PAUSE, false, "");
    presentation.presentation_time_ms = paused_second.presentation_time_ms;
    presentation.beginPhase("draw_base");
    presentation.beginPresentation(clock.confirmedStateVersion());
    presentation.recordPresentationSurface("screens");
    presentation.recordPresentationSurface("room");
    presentation.recordPresentationSurface("player");
    presentation.recordPresentationSurface("hud");
    presentation.recordPresentationSurface("ui");

    boolean mutation_blocked = false;
    clock.lockPresentation();
    try {
      presentation.beginStep(0);
      clock.confirmStep(presentation);
    } catch (IllegalStateException expected){
      mutation_blocked = true;
    } finally {
      clock.unlockPresentation();
      presentation.step_index = -1;
    }

    presentation.beginPhase("cursor");
    presentation.recordPresentationSurface("cursor");
    presentation.beginPhase("draw_window");
    presentation.recordPresentationSurface("window");
    presentation.finishPresentation(clock.confirmedStateVersion(),
      RENDER_W, RENDER_H, RENDER_SCALE, 0, 0);

    boolean surfaces_share_version = true;
    for (java.util.Map.Entry<String, Long> entry : presentation.presentation_surfaces.entrySet()){
      surfaces_share_version &= entry.getValue() == version_before_pause;
    }
    verify("relógio visual avança pausado com simulação congelada",
      pause_contract);
    verify("uma apresentação consome a mesma versão em todas as superfícies e bloqueia passo",
      presentation.presentation_count == 1
        && !presentation.presentation_active
        && presentation.presentation_state_version == version_before_pause
        && presentation.final_state_version == version_before_pause
        && surfaces_share_version && mutation_blocked
        && presentation.viewport_width == RENDER_W
        && presentation.viewport_height == RENDER_H
        && presentation.viewport_scale == RENDER_SCALE
        && presentation.phase_sequence.indexOf("draw_base")
          < presentation.phase_sequence.indexOf("cursor")
        && presentation.phase_sequence.indexOf("cursor")
          < presentation.phase_sequence.indexOf("draw_window"));
  } finally {
    frame_clock = previous_clock;
    current_frame_context = previous_context;
  }
}


class CaptureMovementAudioPlaybackPort implements MovementAudioPlaybackPort {
  ArrayList<String> played_families = new ArrayList<String>();

  public String play(MovementAudioEvent event){
    played_families.add(event.family);
    return "played";
  }
}


class ControlledMovementAudioPlaybackPort implements MovementAudioPlaybackPort {
  final String result_status;
  int attempts;

  ControlledMovementAudioPlaybackPort(String status){
    result_status = status;
  }

  public String play(MovementAudioEvent event){
    attempts++;
    return result_status;
  }
}


class RecordingMovementAudioAdapter implements MovementAudioAdapter {
  final InMemoryMovementAudioRecorder recorder;
  final CoalescingMovementAudioAdapter physical;

  RecordingMovementAudioAdapter(MovementAudioPlaybackPort port){
    recorder = new InMemoryMovementAudioRecorder();
    physical = new CoalescingMovementAudioAdapter(port);
  }

  public void beginCallback(long callbackId){
    recorder.beginCallback(callbackId);
    physical.beginCallback(callbackId);
  }

  public void emit(MovementAudioEvent event, boolean physicalPlaybackAllowed){
    recorder.emit(event, physicalPlaybackAllowed);
    physical.emit(event, physicalPlaybackAllowed);
  }

  public void dispatchCallback(long callbackId){
    recorder.dispatchCallback(callbackId);
    physical.dispatchCallback(callbackId);
  }
}


class MovementAudioFailureOutcome {
  String playback_status;
  String logical_family;
  int logical_event_count;
  int physical_result_count;
  int play_attempts;
  float distance;
  float x_after_dispatch;
  float y_after_dispatch;
  float velocity_after_dispatch;
  boolean grounded_after_dispatch;
}


MovementAudioFailureOutcome simulateMovementAudioFailure(String status,
  long callbackId){
  MovementAudioAdapter previous_adapter = movement_audio_adapter;
  FrameContext previous_context = current_frame_context;
  int previous_walk_variant = sound_walk_step_index;
  int previous_run_variant = sound_run_step_index;
  int previous_ladder_variant = sound_ladder_step_index;
  int previous_sound_count = sound_step_play_count;
  long previous_global_order = movement_audio_global_order;
  ControlledMovementAudioPlaybackPort port =
    new ControlledMovementAudioPlaybackPort(status);
  RecordingMovementAudioAdapter adapter = new RecordingMovementAudioAdapter(port);
  MovementAudioFailureOutcome outcome = new MovementAudioFailureOutcome();
  try {
    resetRun();
    enterRoom(SCREEN_COMMAND);
    player_x = ROOM_LEFT + 100;
    player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
    player_grounded = true;
    player_velocity_y = 0;
    sound_walk_step_index = 0;
    sound_run_step_index = 0;
    sound_ladder_step_index = 0;
    sound_step_play_count = 0;
    movement_audio_global_order = 0;
    replaceMovementAudioAdapter(adapter);

    FrameContext context = new FrameContext(FRAME_FIXED_STEP_SECONDS,
      0.0, FRAME_FIXED_STEP_SECONDS, FRAME_FIXED_STEP_SECONDS, 0.0, 0.0,
      5.0, 4, 1, false, "production", "capture", callbackId,
      screen, current_room, LAYER_SCENE, false, "");
    context.setInputSnapshot(new FrameInputSnapshot(mouseX, mouseY,
      false, false, false, false, false, '\0', false, true, false, false,
      false, false, false));
    context.beginStep(0);
    current_frame_context = context;
    adapter.beginCallback(callbackId);
    float before_x = player_x;
    updateRoom(context);
    context.confirmStep(0.0, 5.0 + FRAME_FIXED_STEP_SECONDS, 5);
    float after_step_x = player_x;
    adapter.dispatchCallback(callbackId);

    outcome.playback_status = adapter.physical.resultCount() == 0
      ? "missing_playback_result"
      : adapter.physical.resultAt(0).status;
    outcome.logical_event_count = adapter.recorder.eventCount();
    outcome.logical_family = outcome.logical_event_count == 0
      ? "" : adapter.recorder.eventAt(0).family;
    outcome.physical_result_count = adapter.physical.resultCount();
    outcome.play_attempts = port.attempts;
    outcome.distance = after_step_x - before_x;
    outcome.x_after_dispatch = player_x;
    outcome.y_after_dispatch = player_y;
    outcome.velocity_after_dispatch = player_velocity_y;
    outcome.grounded_after_dispatch = player_grounded;
  } finally {
    replaceMovementAudioAdapter(previous_adapter);
    current_frame_context = previous_context;
    sound_walk_step_index = previous_walk_variant;
    sound_run_step_index = previous_run_variant;
    sound_ladder_step_index = previous_ladder_variant;
    sound_step_play_count = previous_sound_count;
    movement_audio_global_order = previous_global_order;
  }
  return outcome;
}


void checkMovementAudioPlaybackFailures(){
  MovementAudioFailureOutcome missing = simulateMovementAudioFailure(
    "clip_missing", 8101);
  MovementAudioFailureOutcome failed = simulateMovementAudioFailure(
    "playback_exception", 8102);
  verify("clip ausente e falha física preservam evento lógico e estado do jogador",
    "clip_missing".equals(missing.playback_status)
      && "playback_exception".equals(failed.playback_status)
      && missing.logical_event_count == 1 && failed.logical_event_count == 1
      && MOVEMENT_AUDIO_WALK.equals(missing.logical_family)
      && MOVEMENT_AUDIO_WALK.equals(failed.logical_family)
      && missing.physical_result_count == 1 && failed.physical_result_count == 1
      && missing.play_attempts == 1 && failed.play_attempts == 1
      && abs(missing.distance - PLAYER_SPEED) <= 0.01
      && abs(failed.distance - PLAYER_SPEED) <= 0.01
      && abs(missing.x_after_dispatch - (ROOM_LEFT + 100 + PLAYER_SPEED)) <= 0.01
      && abs(failed.x_after_dispatch - (ROOM_LEFT + 100 + PLAYER_SPEED)) <= 0.01
      && abs(missing.y_after_dispatch - failed.y_after_dispatch) <= 0.01
      && abs(missing.velocity_after_dispatch - failed.velocity_after_dispatch) <= 0.01
      && missing.grounded_after_dispatch && failed.grounded_after_dispatch);
}


void checkMovementAudioAdapterContract(){
  MovementAudioAdapter previousAdapter = movement_audio_adapter;
  InMemoryMovementAudioRecorder recorder = new InMemoryMovementAudioRecorder();
  try {
    replaceMovementAudioAdapter(recorder);
    FrameContext context = new FrameContext(FRAME_FIXED_STEP_SECONDS,
      0.0, 0.0, 0.0, 0.0, 0.0, 12.5, 4, 2, false,
      "harness", "capture", 7001, screen, current_room, uiLayer(),
      doorTransitionActive(), "");
    context.beginStep(0);
    emitMovementAudioEvent(context, MOVEMENT_AUDIO_WALK);
    emitMovementAudioEvent(context, MOVEMENT_AUDIO_WALK);
    emitMovementAudioEvent(context, MOVEMENT_AUDIO_RUN);
    context.confirmStep(0.0, 12.5 + FRAME_FIXED_STEP_SECONDS, 5);
    context.beginStep(1);
    emitMovementAudioEvent(context, MOVEMENT_AUDIO_LADDER);

    verify("recorder mantém eventos repetidos e metadados do passo",
      recorder.eventCount() == 4
      && MOVEMENT_AUDIO_WALK.equals(recorder.eventAt(0).family)
      && MOVEMENT_AUDIO_WALK.equals(recorder.eventAt(1).family)
      && recorder.eventAt(0).callback_id == 7001
      && recorder.eventAt(0).step_index == 0
      && recorder.eventAt(0).logical_timestamp_seconds == 12.5 + FRAME_FIXED_STEP_SECONDS
      && recorder.eventAt(3).step_index == 1
      && recorder.eventAt(0).global_order < recorder.eventAt(1).global_order
      && recorder.eventAt(1).global_order < recorder.eventAt(2).global_order
      && recorder.eventAt(2).global_order < recorder.eventAt(3).global_order);

    MovementAudioEvent[] recorded = new MovementAudioEvent[recorder.eventCount()];
    for (int i = 0; i < recorded.length; i++) recorded[i] = recorder.eventAt(i);
    MovementAudioPlaybackResult[] noPlayback = new MovementAudioPlaybackResult[0];
    MovementAudioSequenceComparison equivalent = compareMovementAudioSequences(
      recorded, noPlayback, recorded, noPlayback);
    MovementAudioEvent[] reordered = new MovementAudioEvent[recorded.length];
    for (int i = 0; i < recorded.length; i++) reordered[i] = recorded[recorded.length - 1 - i];
    MovementAudioSequenceComparison divergent = compareMovementAudioSequences(
      recorded, noPlayback, reordered, noPlayback);
    MovementAudioSequenceComparison unavailable = compareMovementAudioSequences(
      null, noPlayback, recorded, noPlayback);
    verify("comparador distingue equivalência, divergência e baseline ausente",
      "PASS".equals(equivalent.status) && "FAIL".equals(divergent.status)
        && "INCONCLUSIVO".equals(unavailable.status)
        && audioOptimizationHasEquivalentTrace(equivalent)
        && !audioOptimizationHasEquivalentTrace(divergent)
        && !audioOptimizationHasEquivalentTrace(unavailable));

    CaptureMovementAudioPlaybackPort playbackPort = new CaptureMovementAudioPlaybackPort();
    CoalescingMovementAudioAdapter physicalAdapter =
      new CoalescingMovementAudioAdapter(playbackPort);
    physicalAdapter.beginCallback(8001);
    MovementAudioEvent firstWalk = new MovementAudioEvent(MOVEMENT_AUDIO_WALK,
      0, 13.0, 80001, 8001, 0);
    MovementAudioEvent secondWalk = new MovementAudioEvent(MOVEMENT_AUDIO_WALK,
      1, 13.0 + FRAME_FIXED_STEP_SECONDS, 80002, 8001, 1);
    MovementAudioEvent firstRun = new MovementAudioEvent(MOVEMENT_AUDIO_RUN,
      0, 13.0 + 2 * FRAME_FIXED_STEP_SECONDS, 80003, 8001, 2);
    physicalAdapter.emit(firstWalk, true);
    physicalAdapter.emit(secondWalk, true);
    physicalAdapter.emit(firstRun, true);
    int metricsBefore = stop_step_sound_metrics.size();
    physicalAdapter.dispatchCallback(8001);

    verify("despacho coalesce por família e registra status por evento",
      playbackPort.played_families.size() == 2
      && MOVEMENT_AUDIO_WALK.equals(playbackPort.played_families.get(0))
      && MOVEMENT_AUDIO_RUN.equals(playbackPort.played_families.get(1))
      && physicalAdapter.resultCount() == 3
      && "played".equals(physicalAdapter.resultAt(0).status)
      && "coalesced".equals(physicalAdapter.resultAt(1).status)
      && "played".equals(physicalAdapter.resultAt(2).status));

    MovementAudioPlaybackResult[] playback = new MovementAudioPlaybackResult[
      physicalAdapter.resultCount()];
    for (int i = 0; i < playback.length; i++) playback[i] = physicalAdapter.resultAt(i);
    MovementAudioPlaybackResult[] reorderedPlayback = new MovementAudioPlaybackResult[
      playback.length];
    for (int i = 0; i < playback.length; i++){
      reorderedPlayback[i] = playback[playback.length - 1 - i];
    }
    MovementAudioSequenceComparison physicalEquivalent = compareMovementAudioSequences(
      recorded, playback, recorded, playback);
    MovementAudioSequenceComparison physicalDivergent = compareMovementAudioSequences(
      recorded, playback, recorded, reorderedPlayback);
    verify("comparador verifica ordem de reprodução física",
      "PASS".equals(physicalEquivalent.status)
      && "FAIL".equals(physicalDivergent.status));

    verify("stopStepSounds registra duração e ordem completa de visitas",
      stop_step_sound_metrics.size() == metricsBefore + 3
      && stop_step_sound_metrics.get(metricsBefore).duration_nanos >= 0
      && stop_step_sound_metrics.get(metricsBefore).clips_visited
        == sound_walk_step.length * 3
      && "walk[0]".equals(stop_step_sound_metrics.get(metricsBefore).visit_order[0])
      && "run[0]".equals(stop_step_sound_metrics.get(metricsBefore).visit_order[1])
      && "ladder[0]".equals(stop_step_sound_metrics.get(metricsBefore).visit_order[2]));
    String previousHarnessMode = current_frame_context.harness_mode;
    int productionMetricsBefore = stop_step_sound_metrics.size();
    try {
      current_frame_context.harness_mode = "base";
      CoalescingMovementAudioAdapter productionAdapter =
        new CoalescingMovementAudioAdapter(playbackPort);
      for (int callback = 0; callback < 24; callback++){
        long callbackId = 9000 + callback;
        productionAdapter.beginCallback(callbackId);
        productionAdapter.emit(new MovementAudioEvent(MOVEMENT_AUDIO_WALK,
          0, 15.0 + callback * FRAME_FIXED_STEP_SECONDS,
          9000 + callback, callbackId, 0), true);
        productionAdapter.dispatchCallback(callbackId);
      }
      verify("áudio de produção não retém histórico nem métricas por passo",
        productionAdapter.resultCount() == 1
        && productionAdapter.playbackHistoryCount() == 0
        && stop_step_sound_metrics.size() == productionMetricsBefore);
    }
    finally {
      current_frame_context.harness_mode = previousHarnessMode;
    }
    checkMovementAudioPlaybackFailures();
  }
  finally {
    replaceMovementAudioAdapter(previousAdapter);
  }
}


long movement_harness_callback_id = 0;
double movement_harness_simulation_time_seconds = 0.0;


FrameContext movementHarnessStepContext(){
  movement_harness_callback_id++;
  double simulation_time = movement_harness_simulation_time_seconds;
  FrameContext context = new FrameContext(FRAME_FIXED_STEP_SECONDS,
    0.0, FRAME_FIXED_STEP_SECONDS, FRAME_FIXED_STEP_SECONDS, 0.0, 0.0,
    simulation_time, 0, 1, false, "harness", "capture", movement_harness_callback_id,
    screen, current_room, uiLayer(), doorTransitionActive(), "");
  movement_harness_simulation_time_seconds += FRAME_FIXED_STEP_SECONDS;
  context.beginStep(0);
  return context;
}


class MovementCadenceResult {
  float distance;
  float x;
  float y;
  float vertical_distance;
  float velocity_y;
  float minimum_y;
  float walk_step_accum;
  float run_step_accum;
  float ladder_step_accum;
  int walk_phase;
  int run_phase;
  int ladder_phase;
  int ladder_steps;
  int current_ladder;
  int contact_count;
  int[] contact_steps = new int[16];
  int confirmed_steps;
  double simulation_time_seconds;
  double accumulator_after;
  boolean schedule_valid;
  MovementAudioEvent[] logical_events = new MovementAudioEvent[0];
  int animation_state;
  int animation_started_at;
  int animation_frame;
  boolean grounded;
  boolean on_ladder;
  boolean release_required;
  boolean walk_active;
  boolean jump_consumed;
  int jump_action_step;
}


class MovementCadenceHarness {
  final FrameClock previous_clock;
  final FrameContext previous_context;
  final MovementAudioAdapter previous_audio_adapter;
  final int previous_walk_variant;
  final int previous_run_variant;
  final int previous_ladder_variant;
  final int previous_sound_count;
  final long previous_global_event_order;
  final FakeFrameClockSource source;
  final FrameClock clock;
  final InMemoryMovementAudioRecorder recorder;
  float minimum_y;
  boolean schedule_valid = true;

  MovementCadenceHarness(){
    previous_clock = frame_clock;
    previous_context = current_frame_context;
    previous_audio_adapter = movement_audio_adapter;
    previous_walk_variant = sound_walk_step_index;
    previous_run_variant = sound_run_step_index;
    previous_ladder_variant = sound_ladder_step_index;
    previous_sound_count = sound_step_play_count;
    previous_global_event_order = movement_audio_global_order;
    sound_walk_step_index = 0;
    sound_run_step_index = 0;
    sound_ladder_step_index = 0;
    sound_step_play_count = 0;
    movement_audio_global_order = 0;
    source = new FakeFrameClockSource(0.0);
    clock = new FrameClock(source);
    recorder = new InMemoryMovementAudioRecorder();
    frame_clock = clock;
    current_frame_context = null;
    replaceMovementAudioAdapter(recorder);
    FrameContext initial = clock.beginCallback(false, true, SCREEN_COMMAND,
      SCREEN_COMMAND, LAYER_SCENE, "capture", false);
    initial.finishCallback();
  }

  FrameContext beginCallback(int fps, boolean right, boolean up,
    boolean down, boolean running, boolean jumpEdge, boolean interactEdge){
    return beginCallbackDelta(1.0 / fps, 60 / fps, false, true,
      screen, current_room, uiLayer(), doorTransitionActive(), right, up,
      down, running, jumpEdge, interactEdge);
  }

  FrameContext beginCallbackDelta(double deltaSeconds, int expectedSteps,
    boolean isPaused, boolean roomActive, int activeScreen, int activeRoom,
    int activeLayer, boolean doorActive, boolean right, boolean up,
    boolean down, boolean running, boolean jumpEdge, boolean interactEdge){
    source.advanceSeconds(deltaSeconds);
    FrameContext context = clock.beginCallback(isPaused, roomActive,
      activeScreen, activeRoom, activeLayer, "capture", doorActive);
    context.setInputSnapshot(new FrameInputSnapshot(mouseX, mouseY,
      false, false, false, false, false, '\0', false, right, up, down,
      running, jumpEdge, interactEdge));
    jump_queued = jumpEdge;
    interact_queued = interactEdge;
    recorder.beginCallback(context.callback_id);
    current_frame_context = context;
    boolean frozen = isPaused || !roomActive || activeLayer != LAYER_SCENE
      || doorActive;
    double available = java.lang.Math.max(0.0,
      FRAME_MAX_ACCUMULATOR_SECONDS - context.accumulator_before);
    double expectedAccepted = frozen || context.rebased_after_freeze ? 0.0
      : java.lang.Math.min(deltaSeconds, available);
    schedule_valid &= context.steps_planned == expectedSteps
      && java.lang.Math.abs(context.observed_seconds - deltaSeconds) < 0.0000001
      && java.lang.Math.abs(context.accepted_seconds - expectedAccepted) < 0.0000001;
    return context;
  }

  int executeRoomSteps(FrameContext context){
    int contacts_before_callback = sound_step_play_count;
    for (int step = 0; step < context.steps_planned; step++){
      if (paused || !isRoomScreen() || uiLayer() != LAYER_SCENE
        || doorTransitionActive()){
        context.interrupt(frameFrozenReason());
        discardQueuedFrameActions(context, context.interruption_reason);
        clock.pauseCallback(context);
        break;
      }
      int step_screen = screen;
      int step_room = current_room;
      int step_layer = uiLayer();
      boolean step_door_active = doorTransitionActive();
      context.beginStep(step);
      updateRoom(context);
      minimum_y = min(minimum_y, player_y);
      String change = frameControlChangeReason(step_screen, step_room,
        step_layer, step_door_active);
      if (change.length() > 0) context.interrupt(change);
      clock.confirmStep(context);
      while (sound_step_play_count > contacts_before_callback){
        contacts_before_callback++;
        if (contact_cursor < 16){
          cadence_contact_buffer[contact_cursor++] = confirmed_steps + 1;
        }
      }
      confirmed_steps++;
      if (context.interruption_reason.length() > 0){
        discardQueuedFrameActions(context, context.interruption_reason);
        clock.pauseCallback(context);
        break;
      }
    }
    return context.steps_executed;
  }

  int confirmed_steps = 0;
  int contact_cursor = 0;

  void finishCallback(FrameContext context){
    context.finishCallback();
    if (current_frame_context == context) current_frame_context = null;
  }

  MovementAudioEvent[] logicalEvents(){
    MovementAudioEvent[] events = new MovementAudioEvent[recorder.eventCount()];
    for (int index = 0; index < events.length; index++){
      events[index] = recorder.eventAt(index);
    }
    return events;
  }

  void restore(){
    frame_clock = previous_clock;
    current_frame_context = previous_context;
    replaceMovementAudioAdapter(previous_audio_adapter);
    sound_walk_step_index = previous_walk_variant;
    sound_run_step_index = previous_run_variant;
    sound_ladder_step_index = previous_ladder_variant;
    sound_step_play_count = previous_sound_count;
    movement_audio_global_order = previous_global_event_order;
  }
}


void prepareMovementCadenceFixture(){
  resetRun();
  movement_harness_simulation_time_seconds = 0.0;
  event_open = false;
  enterRoom(SCREEN_COMMAND);
  player_x = ROOM_LEFT + 100;
  player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  current_ladder = -1;
  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  run_held = false;
  jump_queued = false;
  interact_queued = false;
  player_anim_state = PLAYER_ANIM_IDLE;
  player_animation_moving = false;
  player_animation_started_at = 0;
}


MovementCadenceResult simulateDeckCadence(int fps, boolean running,
  boolean jumping){
  return simulateDeckCadence(fps, running, jumping, false);
}


MovementCadenceResult simulateDeckCadence(int fps, boolean running,
  boolean jumping, boolean falling){
  MovementCadenceHarness harness = new MovementCadenceHarness();
  MovementCadenceResult result = new MovementCadenceResult();
  try {
  prepareMovementCadenceFixture();
  float start_x = player_x;
  float start_y = player_y;
  if (falling){
    player_y -= 70;
    player_grounded = false;
  }
  float movement_start_y = player_y;
  harness.minimum_y = player_y;
  int initial_contacts = sound_step_play_count;
  boolean jump_consumed = false;
  int jump_action_step = -1;

  for (int callback = 0; callback < fps; callback++){
    boolean jump_edge = jumping && callback == 0;
    boolean right = !jumping && !falling;
    FrameContext context = harness.beginCallback(fps, right, false, false,
      running, jump_edge, false);
    harness.executeRoomSteps(context);
    if (jump_edge){
      jump_consumed = context.jump_action_consumed;
      jump_action_step = context.jump_action_step;
    }
    harness.finishCallback(context);
  }

  result.distance = player_x - start_x;
  result.x = player_x;
  result.y = player_y;
  result.vertical_distance = player_y - movement_start_y;
  result.velocity_y = player_velocity_y;
  result.minimum_y = harness.minimum_y;
  result.walk_step_accum = walk_step_accum;
  result.run_step_accum = player_step_accum;
  result.ladder_step_accum = ladder_step_accum;
  result.walk_phase = walk_step_phase;
  result.run_phase = run_step_phase;
  result.ladder_phase = ladder_step_phase;
  result.ladder_steps = ladder_steps_taken;
  result.current_ladder = current_ladder;
  result.grounded = player_grounded;
  result.on_ladder = player_on_ladder;
  result.release_required = ladder_vertical_release_required;
  result.jump_consumed = jump_consumed;
  result.jump_action_step = jump_action_step;
  result.confirmed_steps = harness.confirmed_steps;
  result.simulation_time_seconds = harness.clock.simulationTimeSeconds();
  result.accumulator_after = harness.clock.accumulatorSeconds();
  result.schedule_valid = harness.schedule_valid;
  result.animation_state = playerCurrentAnimationState();
  result.animation_started_at = player_animation_started_at;
  result.animation_frame = playerCurrentFrameAt(
    harness.clock.simulationTimeSeconds());
  result.walk_active = walk_step_active;
  result.contact_count = min(16, sound_step_play_count - initial_contacts);
  for (int contact = 0; contact < result.contact_count && contact < 16; contact++){
    result.contact_steps[contact] = cadence_contact_buffer[contact];
  }
  result.logical_events = harness.logicalEvents();
  } finally {
    harness.restore();
  }
  return result;
}


int[] cadence_contact_buffer = new int[16];


MovementCadenceResult simulateLadderCadence(int fps, boolean ascending){
  MovementCadenceHarness harness = new MovementCadenceHarness();
  MovementCadenceResult result = new MovementCadenceResult();
  try {
  prepareMovementCadenceFixture();
  int ladder = 0;
  float start_y = (deck_y[ladder_top_deck[ladder]]
    + deck_y[ladder_bottom_deck[ladder]]) / 2.0 - PLAYER_H;
  player_x = ladder_x[ladder] - PLAYER_W / 2.0;
  player_y = start_y;
  player_grounded = false;
  player_on_ladder = true;
  current_ladder = ladder;
  int initial_contacts = sound_step_play_count;

  for (int callback = 0; callback < fps; callback++){
    FrameContext context = harness.beginCallback(fps, false,
      ascending, !ascending, false, false, false);
    harness.executeRoomSteps(context);
    harness.finishCallback(context);
  }

  result.distance = abs(player_y - start_y);
  result.x = player_x;
  result.y = player_y;
  result.vertical_distance = player_y - start_y;
  result.velocity_y = player_velocity_y;
  result.minimum_y = min(start_y, player_y);
  result.walk_step_accum = walk_step_accum;
  result.run_step_accum = player_step_accum;
  result.ladder_step_accum = ladder_step_accum;
  result.walk_phase = walk_step_phase;
  result.run_phase = run_step_phase;
  result.ladder_phase = ladder_step_phase;
  result.ladder_steps = ladder_steps_taken;
  result.current_ladder = current_ladder;
  result.grounded = player_grounded;
  result.on_ladder = player_on_ladder;
  result.release_required = ladder_vertical_release_required;
  result.confirmed_steps = harness.confirmed_steps;
  result.simulation_time_seconds = harness.clock.simulationTimeSeconds();
  result.accumulator_after = harness.clock.accumulatorSeconds();
  result.schedule_valid = harness.schedule_valid;
  result.animation_state = playerCurrentAnimationState();
  result.animation_started_at = player_animation_started_at;
  result.animation_frame = playerCurrentFrameAt(
    harness.clock.simulationTimeSeconds());
  result.walk_active = walk_step_active;
  result.contact_count = min(16, sound_step_play_count - initial_contacts);
  for (int contact = 0; contact < result.contact_count && contact < 16; contact++){
    result.contact_steps[contact] = cadence_contact_buffer[contact];
  }
  result.logical_events = harness.logicalEvents();
  } finally {
    harness.restore();
  }
  return result;
}


boolean sameCadenceContacts(MovementCadenceResult a, MovementCadenceResult b){
  if (a.contact_count != b.contact_count) return false;
  for (int contact = 0; contact < a.contact_count; contact++){
    if (a.contact_steps[contact] != b.contact_steps[contact]) return false;
  }
  return true;
}


boolean sameCadenceEvents(MovementCadenceResult a, MovementCadenceResult b){
  if (a.logical_events.length != b.logical_events.length) return false;
  for (int index = 0; index < a.logical_events.length; index++){
    MovementAudioEvent first = a.logical_events[index];
    MovementAudioEvent second = b.logical_events[index];
    if (!first.family.equals(second.family) || first.variant != second.variant
      || java.lang.Math.abs(first.logical_timestamp_seconds
        - second.logical_timestamp_seconds) > 0.0000001){
      return false;
    }
    if (index > 0){
      double first_interval = first.logical_timestamp_seconds
        - a.logical_events[index - 1].logical_timestamp_seconds;
      double second_interval = second.logical_timestamp_seconds
        - b.logical_events[index - 1].logical_timestamp_seconds;
      if (java.lang.Math.abs(first_interval - second_interval) > 0.0000001){
        return false;
      }
    }
  }
  return true;
}


boolean cadenceHasFamily(MovementCadenceResult result, String family){
  for (MovementAudioEvent event : result.logical_events){
    if (family.equals(event.family)) return true;
  }
  return false;
}


boolean cadenceOnlyFamily(MovementCadenceResult result, String family){
  if (result.logical_events.length == 0) return false;
  for (MovementAudioEvent event : result.logical_events){
    if (!family.equals(event.family)) return false;
  }
  return true;
}


boolean sameCadenceBudget(MovementCadenceResult a, MovementCadenceResult b){
  return a.schedule_valid && b.schedule_valid
    && a.confirmed_steps == 60 && b.confirmed_steps == 60
    && java.lang.Math.abs(a.simulation_time_seconds - 1.0) < 0.0000001
    && java.lang.Math.abs(b.simulation_time_seconds - 1.0) < 0.0000001
    && a.accumulator_after < FRAME_FIXED_STEP_SECONDS
    && b.accumulator_after < FRAME_FIXED_STEP_SECONDS;
}


boolean sameDeckCadence(MovementCadenceResult a, MovementCadenceResult b){
  return abs(a.x - b.x) <= 0.01 && abs(a.y - b.y) <= 0.01
    && abs(a.velocity_y - b.velocity_y) <= 0.01
    && abs(a.minimum_y - b.minimum_y) <= 0.01
    && abs(a.walk_step_accum - b.walk_step_accum) <= 0.01
    && abs(a.run_step_accum - b.run_step_accum) <= 0.01
    && a.walk_phase == b.walk_phase && a.run_phase == b.run_phase
    && a.animation_state == b.animation_state
    && a.animation_started_at == b.animation_started_at
    && a.animation_frame == b.animation_frame
    && a.walk_active == b.walk_active
    && a.grounded == b.grounded && a.on_ladder == b.on_ladder
    && sameCadenceContacts(a, b) && sameCadenceEvents(a, b)
    && sameCadenceBudget(a, b);
}


boolean sameLadderCadence(MovementCadenceResult a, MovementCadenceResult b){
  return abs(a.x - b.x) <= 0.01 && abs(a.y - b.y) <= 0.01
    && abs(a.ladder_step_accum - b.ladder_step_accum) <= 0.01
    && a.ladder_phase == b.ladder_phase && a.ladder_steps == b.ladder_steps
    && a.current_ladder == b.current_ladder && a.grounded == b.grounded
    && a.on_ladder == b.on_ladder && a.release_required == b.release_required
    && a.animation_state == b.animation_state
    && a.animation_started_at == b.animation_started_at
    && a.animation_frame == b.animation_frame
    && sameCadenceContacts(a, b) && sameCadenceEvents(a, b)
    && sameCadenceBudget(a, b);
}


void checkFixedStepMovementCadence(){
  MovementCadenceResult walk15 = simulateDeckCadence(15, false, false);
  MovementCadenceResult walk30 = simulateDeckCadence(30, false, false);
  MovementCadenceResult walk60 = simulateDeckCadence(60, false, false);
  verify("cada cadência confirma 60 passos e um segundo simulado por fixture",
    sameCadenceBudget(walk15, walk30) && sameCadenceBudget(walk30, walk60));
  verify("60 passos reproduzem 60 unidades de caminhada",
    abs(walk60.distance - 60.0) <= 0.01);
  verify("caminhada mantém posição, contatos e eventos em 15, 30 e 60 FPS",
    sameDeckCadence(walk15, walk30) && sameDeckCadence(walk30, walk60)
      && cadenceOnlyFamily(walk15, MOVEMENT_AUDIO_WALK)
      && walk15.logical_events.length > 1);
  verify("take visual inicia no instante da cadência de caminhada",
    walk15.walk_active && walk15.animation_state == PLAYER_ANIM_WALK
      && walk15.animation_started_at == (int) java.lang.Math.round(
        FRAME_FIXED_STEP_SECONDS * 1000.0));

  MovementCadenceResult run15 = simulateDeckCadence(15, true, false);
  MovementCadenceResult run30 = simulateDeckCadence(30, true, false);
  MovementCadenceResult run60 = simulateDeckCadence(60, true, false);
  verify("60 passos reproduzem 144 unidades de corrida",
    abs(run60.distance - 144.0) <= 0.01);
  verify("corrida mantém posição, fase e contatos em 15, 30 e 60 FPS",
    sameDeckCadence(run15, run30) && sameDeckCadence(run30, run60)
      && cadenceOnlyFamily(run15, MOVEMENT_AUDIO_RUN)
      && run15.logical_events.length > 1);

  MovementCadenceResult gravity15 = simulateDeckCadence(15, false, false, true);
  MovementCadenceResult gravity30 = simulateDeckCadence(30, false, false, true);
  MovementCadenceResult gravity60 = simulateDeckCadence(60, false, false, true);
  verify("queda por gravidade termina no mesmo estado em 15, 30 e 60 FPS",
    sameDeckCadence(gravity15, gravity30)
      && sameDeckCadence(gravity30, gravity60)
      && abs(gravity60.vertical_distance - 70.0) <= 0.01
      && gravity60.grounded
      && cadenceHasFamily(gravity60, MOVEMENT_AUDIO_LANDING));

  MovementCadenceResult jump15 = simulateDeckCadence(15, false, true);
  MovementCadenceResult jump30 = simulateDeckCadence(30, false, true);
  MovementCadenceResult jump60 = simulateDeckCadence(60, false, true);
  verify("uma borda de salto em quatro passos inicia um único salto",
    jump15.jump_consumed && jump15.jump_action_step == 0
      && jump15.contact_count == 2);
  verify("salto preserva altura, pouso e eventos em 15, 30 e 60 FPS",
    sameDeckCadence(jump15, jump30) && sameDeckCadence(jump30, jump60)
      && abs((deck_y[DECK_COUNT - 1] - PLAYER_H - jump60.minimum_y) - 44.5) <= 0.1
      && jump15.grounded
      && jump15.logical_events.length == 2
      && MOVEMENT_AUDIO_TAKEOFF.equals(jump15.logical_events[0].family)
      && MOVEMENT_AUDIO_LANDING.equals(jump15.logical_events[1].family));

  MovementCadenceResult climbUp15 = simulateLadderCadence(15, true);
  MovementCadenceResult climbUp30 = simulateLadderCadence(30, true);
  MovementCadenceResult climbUp60 = simulateLadderCadence(60, true);
  MovementCadenceResult climbDown15 = simulateLadderCadence(15, false);
  MovementCadenceResult climbDown30 = simulateLadderCadence(30, false);
  MovementCadenceResult climbDown60 = simulateLadderCadence(60, false);
  verify("subida e descida preservam estado e eventos após 60 passos",
    sameLadderCadence(climbUp15, climbUp30)
      && sameLadderCadence(climbUp30, climbUp60)
      && sameLadderCadence(climbDown15, climbDown30)
      && sameLadderCadence(climbDown30, climbDown60)
      && !climbUp60.on_ladder && !climbDown60.on_ladder
      && climbUp60.grounded && climbDown60.grounded
      && cadenceOnlyFamily(climbUp15, MOVEMENT_AUDIO_LADDER)
      && cadenceOnlyFamily(climbDown15, MOVEMENT_AUDIO_LADDER));
  resetRun();
}


void checkLongFrameAudioContract(){
  MovementCadenceHarness harness = new MovementCadenceHarness();
  try {
    prepareMovementCadenceFixture();
    FrameContext long_frame = harness.beginCallbackDelta(0.25, 4,
      false, true, screen, current_room, LAYER_SCENE, false,
      true, false, false, false, false, false);
    int long_callback_steps = harness.executeRoomSteps(long_frame);
    double long_frame_accepted = long_frame.accepted_seconds;
    long long_callback_id = long_frame.callback_id;
    harness.finishCallback(long_frame);

    MovementAudioEvent[] events = harness.logicalEvents();
    ArrayList<String> event_families = new ArrayList<String>();
    boolean events_within_accepted_time = events.length > 0;
    CaptureMovementAudioPlaybackPort playback_port =
      new CaptureMovementAudioPlaybackPort();
    CoalescingMovementAudioAdapter physical =
      new CoalescingMovementAudioAdapter(playback_port);
    physical.beginCallback(long_callback_id);
    for (MovementAudioEvent event : events){
      if (event.callback_id != long_callback_id) continue;
      events_within_accepted_time &= event.logical_timestamp_seconds
        <= long_frame_accepted + 0.0000001;
      physical.emit(event, true);
      if (!event_families.contains(event.family)) event_families.add(event.family);
    }
    physical.dispatchCallback(long_callback_id);
    boolean onePhysicalShotPerFamily = playback_port.played_families.size()
      == event_families.size();
    for (int index = 0; index < playback_port.played_families.size(); index++){
      String family = playback_port.played_families.get(index);
      for (int next = index + 1; next < playback_port.played_families.size(); next++){
        onePhysicalShotPerFamily &= !family.equals(
          playback_port.played_families.get(next));
      }
    }

    int logical_events_before_next = harness.recorder.eventCount();
    FrameContext next_frame = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS, 1, false, true, screen, current_room,
      LAYER_SCENE, false, true, false, false, false, false, false);
    int next_callback_steps = harness.executeRoomSteps(next_frame);
    double next_observed = next_frame.observed_seconds;
    double next_discarded = next_frame.discarded_seconds;
    harness.finishCallback(next_frame);

    verify("frame longo executa quatro passos e registra delta aceito e descartado",
      long_callback_steps == FRAME_MAX_STEPS_PER_CALLBACK
        && abs((float) (long_frame.observed_seconds - 0.25)) < 0.0000001
        && abs((float) (long_frame_accepted
          - FRAME_MAX_ACCUMULATOR_SECONDS)) < 0.0000001
        && abs((float) (long_frame.discarded_seconds
          - (0.25 - FRAME_MAX_ACCUMULATOR_SECONDS))) < 0.0000001
        && long_frame.accumulator_after < FRAME_FIXED_STEP_SECONDS);
    verify("descarte não vira dívida nem emite eventos retrospectivos",
      next_callback_steps == 1
        && abs((float) (next_observed - FRAME_FIXED_STEP_SECONDS)) < 0.0000001
        && next_discarded == 0.0
        && harness.recorder.eventCount() == logical_events_before_next
        && events_within_accepted_time);
    verify("despacho do frame longo coalesce cada família física no callback",
      onePhysicalShotPerFamily
        && physical.resultCount() == event_families.size());
  } finally {
    harness.restore();
  }
}


void checkTemporalPauseAndBarriers(){
  MovementCadenceHarness harness = new MovementCadenceHarness();
  PImage[] saved_door_art = art_door_frames;
  try {
    prepareMovementCadenceFixture();
    float initial_x = player_x;
    FrameContext active = harness.beginCallback(60, true,
      false, false, false, false, false);
    harness.executeRoomSteps(active);
    harness.finishCallback(active);
    float frozen_x = player_x;
    int logical_events_before_freeze = harness.recorder.eventCount();
    double frozen_simulation_time = harness.clock.simulationTimeSeconds();
    long frozen_state_version = harness.clock.confirmedStateVersion();
    long presentation_before_freeze = harness.clock.presentationTimeMillis();

    paused = true;
    FrameContext paused_callback = harness.beginCallbackDelta(0.35, 0,
      true, true, screen, current_room, LAYER_PAUSE, false,
      true, false, false, false, false, false);
    harness.executeRoomSteps(paused_callback);
    harness.finishCallback(paused_callback);
    paused = false;
    long presentation_during_pause = paused_callback.presentation_time_ms;

    int saved_screen = screen;
    int saved_room = current_room;
    screen = SCREEN_INIT;
    current_room = SCREEN_INIT;
    FrameContext outside_callback = harness.beginCallbackDelta(0.35, 0,
      false, false, SCREEN_INIT, SCREEN_INIT, LAYER_SCENE, false,
      true, false, false, false, false, false);
    harness.executeRoomSteps(outside_callback);
    harness.finishCallback(outside_callback);
    screen = saved_screen;
    current_room = saved_room;

    FrameContext resume_callback = harness.beginCallbackDelta(0.35, 0,
      false, true, screen, current_room, LAYER_SCENE, false,
      true, false, false, false, false, false);
    harness.executeRoomSteps(resume_callback);
    harness.finishCallback(resume_callback);

    verify("pausa e telas fora da sala avançam só o relógio visual",
      paused_callback.steps_executed == 0
        && outside_callback.steps_executed == 0
        && presentation_during_pause > presentation_before_freeze
        && outside_callback.presentation_time_ms > presentation_during_pause
        && harness.clock.simulationTimeSeconds() == frozen_simulation_time
        && harness.clock.confirmedStateVersion() == frozen_state_version
        && player_x == frozen_x
        && harness.recorder.eventCount() == logical_events_before_freeze);
    verify("retomar rebasa o relógio e o passo seguinte não recupera dívida",
      resume_callback.rebased_after_freeze
        && resume_callback.steps_planned == 0
        && resume_callback.accumulator_after == 0.0
        && harness.clock.simulationTimeSeconds() == frozen_simulation_time);

    float before_resumed_step = player_x;
    FrameContext resumed_step = harness.beginCallback(60, true,
      false, false, false, false, false);
    harness.executeRoomSteps(resumed_step);
    harness.finishCallback(resumed_step);
    verify("retomada avança um único passo lógico sem recuperar o atraso",
      resumed_step.steps_executed == 1
        && abs((player_x - before_resumed_step) - PLAYER_SPEED) <= 0.01);

    resetRun();
    enterRoom(SCREEN_COMMAND);
    boolean safe_position_found = false;
    for (float x = ROOM_LEFT + 4; x <= ROOM_RIGHT - PLAYER_W - 4; x += 4){
      player_x = x;
      boolean nearby_door = false;
      for (int door = 0; door < DOOR_COUNT; door++){
        if (door_room[door] == screen && doorInRange(door)) nearby_door = true;
      }
      if (!nearby_door && nearestInteractablePoint() < 0){
        safe_position_found = true;
        break;
      }
    }
    float before_interact = player_x;
    FrameContext interact_two_steps = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS * 2.0, 2, false, true, screen, current_room,
      LAYER_SCENE, false, true, false, false, false, false, true);
    harness.executeRoomSteps(interact_two_steps);
    harness.finishCallback(interact_two_steps);
    verify("uma borda de E é consumida uma vez em callback de dois passos",
      safe_position_found && interact_two_steps.steps_executed == 2
        && interact_two_steps.interact_action_consumed
        && interact_two_steps.interact_action_step == 0
        && abs((player_x - before_interact) - PLAYER_SPEED * 2.0) <= 0.01);

    resetRun();
    enterRoom(SCREEN_COMMAND);
    setCapturePlayerAtPoint(POINT_VERA);
    float before_modal = player_x;
    FrameContext modal_callback = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS * 4.0, 4, false, true, screen, current_room,
      LAYER_SCENE, false, true, false, false, false, false, true);
    harness.executeRoomSteps(modal_callback);
    harness.finishCallback(modal_callback);
    verify("modal aberto no primeiro passo interrompe movimento e interações",
      dialog_open && modal_callback.steps_executed == 1
        && modal_callback.interact_action_consumed
        && modal_callback.interact_action_step == 0
        && modal_callback.interruption_reason.length() > 0
        && player_x == before_modal);

    resetRun();
    enterRoom(SCREEN_COMMAND);
    int door = doorInRoomLeadingTo(SCREEN_COMMAND, SCREEN_DORMITORY);
    placePlayerAtDoor(door);
    float before_portal = player_x;
    FrameContext portal_rebase = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS, 0, false, true, screen, current_room,
      LAYER_SCENE, false, false, false, false, false, false, false);
    harness.executeRoomSteps(portal_rebase);
    harness.finishCallback(portal_rebase);
    art_door_frames = new PImage[2];
    art_door_frames[0] = createGraphics(64, 128);
    art_door_frames[1] = createGraphics(64, 128);
    FrameContext portal_callback = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS * 4.0, 4, false, true, screen, current_room,
      LAYER_SCENE, false, true, false, false, false, false, true);
    harness.executeRoomSteps(portal_callback);
    harness.finishCallback(portal_callback);
    verify("interação de porta inicia a fase de abertura no primeiro passo",
      screen == SCREEN_COMMAND && doorTransitionActive()
        && door_transition_phase == DOOR_PHASE_OPENING);
    verify("porta interrompe callback de quatro passos após um passo confirmado",
      portal_callback.steps_executed == 1
        && portal_callback.interact_action_consumed
        && portal_callback.interact_action_step == 0
        && portal_callback.interruption_reason.length() > 0);
    verify("iniciar a porta bloqueia movimento no restante do callback",
      player_x == before_portal);
    cancelDoorTransition();

    resetRun();
    enterRoom(SCREEN_COMMAND);
    door = doorInRoomLeadingTo(SCREEN_COMMAND, SCREEN_DORMITORY);
    placePlayerAtDoor(door);
    art_door_frames = new PImage[1];
    FrameContext screen_rebase = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS, 0, false, true, screen, current_room,
      LAYER_SCENE, false, false, false, false, false, false, false);
    harness.executeRoomSteps(screen_rebase);
    harness.finishCallback(screen_rebase);
    FrameContext screen_change_callback = harness.beginCallbackDelta(
      FRAME_FIXED_STEP_SECONDS * 4.0, 4, false, true, screen, current_room,
      LAYER_SCENE, false, true, false, false, false, false, true);
    harness.executeRoomSteps(screen_change_callback);
    harness.finishCallback(screen_change_callback);
    verify("troca de tela pela porta incompleta interrompe os passos restantes",
      screen == SCREEN_DORMITORY && !doorTransitionActive()
        && screen_change_callback.steps_executed == 1
        && screen_change_callback.interact_action_consumed
        && screen_change_callback.interact_action_step == 0
        && screen_change_callback.interruption_reason.length() > 0
        && abs(player_x - (door_arrival_x[door] - PLAYER_W / 2.0)) < 0.01);
  } finally {
    art_door_frames = saved_door_art;
    harness.restore();
  }
}


void checkFrameClockContract(){
  FakeFrameClockSource source = new FakeFrameClockSource(0.0);
  FrameClock clock = new FrameClock(source);
  FrameContext first = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  verify("FrameClock primeira leitura executa zero passos",
    first.steps_planned == 0 && first.steps_executed == 0
      && clock.simulationTimeSeconds() == 0.0
      && clock.confirmedStateVersion() == 0
      && first.diagnostic.indexOf("primeira leitura") >= 0);

  source.advanceSeconds(FRAME_FIXED_STEP_SECONDS * 2.0);
  FrameContext twoSteps = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  for (int step = 0; step < twoSteps.steps_planned; step++){
    twoSteps.beginStep(step);
    clock.confirmStep(twoSteps);
  }
  verify("FrameClock usa dois passos fixos para delta de 1/30 s",
    twoSteps.steps_planned == 2 && twoSteps.steps_executed == 2
      && abs((float) clock.simulationTimeSeconds() - 2.0f / 60.0f) < 0.00001f
      && clock.confirmedStateVersion() == 2);

  double confirmedTime = clock.simulationTimeSeconds();
  long confirmedVersion = clock.confirmedStateVersion();
  source.setSeconds(Double.NaN);
  FrameContext nonFinite = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  verify("FrameClock delta não finito preserva estado e registra diagnóstico",
    nonFinite.steps_planned == 0 && nonFinite.diagnostic.length() > 0
      && clock.simulationTimeSeconds() == confirmedTime
      && clock.confirmedStateVersion() == confirmedVersion);

  source.setSeconds(0.05);
  FrameContext rebased = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  source.setSeconds(0.04);
  FrameContext negative = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  verify("FrameClock delta negativo rebasa sem avançar estado",
    rebased.steps_planned == 0 && negative.steps_planned == 0
      && negative.diagnostic.length() > 0
      && clock.simulationTimeSeconds() == confirmedTime
      && clock.confirmedStateVersion() == confirmedVersion);

  source.advanceSeconds(FRAME_FIXED_STEP_SECONDS);
  FrameContext recovered = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  for (int step = 0; step < recovered.steps_planned; step++){
    recovered.beginStep(step);
    clock.confirmStep(recovered);
  }

  source.advanceSeconds(0.25);
  FrameContext longFrame = clock.beginCallback(false, true, SCREEN_COMMAND,
    SCREEN_COMMAND, LAYER_SCENE, "capture", false);
  for (int step = 0; step < longFrame.steps_planned; step++){
    longFrame.beginStep(step);
    clock.confirmStep(longFrame);
  }
  verify("FrameClock limita quatro passos e descarta excedente",
    recovered.steps_planned == 1 && longFrame.steps_planned == FRAME_MAX_STEPS_PER_CALLBACK
      && longFrame.steps_executed == FRAME_MAX_STEPS_PER_CALLBACK
      && abs((float) (longFrame.observed_seconds - 0.25)) < 0.0000001
      && abs((float) (longFrame.accepted_seconds
        - FRAME_MAX_ACCUMULATOR_SECONDS)) < 0.0000001
      && abs((float) (longFrame.discarded_seconds
        - (0.25 - FRAME_MAX_ACCUMULATOR_SECONDS))) < 0.0000001
      && longFrame.accumulator_after < FRAME_FIXED_STEP_SECONDS
      && clock.accumulatorSeconds() < FRAME_FIXED_STEP_SECONDS);
}


void reportQuestCheck(){
  if (!presentation_coverage_checked){
    presentation_coverage_checked = true;
    String[] required_surfaces = {
      "screens", "screen_content", "room", "player", "hud", "ui"
    };
    boolean room_surfaces_observed = presentation_room_callback_checks > 0;
    for (int i = 0; i < required_surfaces.length; i++){
      Integer observations = presentation_surface_observations.get(
        required_surfaces[i]);
      room_surfaces_observed &= observations != null && observations > 0;
    }
    if (!room_surfaces_observed){
      presentation_callback_failures++;
      checks_failed = true;
    }
  }
  writeEquivalenceReport();
  println(checks_failed ? "QUEST CHECK: FALHOU" : "QUEST CHECK: PASS");
  println("PRESENTATION CHECK: "
    + (presentation_callback_failures == 0 ? "PASS" : "FAIL")
    + "; callbacks=" + presentation_callback_checks
    + "; falhas=" + presentation_callback_failures
    + "; callbacks_de_sala=" + presentation_room_callback_checks
    + "; superfícies_observadas="
    + presentation_surface_observations.toString()
    + (current_frame_context == null ? "" : "; superfícies="
      + current_frame_context.presentation_surfaces.toString()
      + "; versão=" + current_frame_context.presentation_state_version
      + "; viewport=" + current_frame_context.viewport_width + "x"
      + current_frame_context.viewport_height + " scale="
      + current_frame_context.viewport_scale + " offset="
      + current_frame_context.viewport_offset_x + ","
      + current_frame_context.viewport_offset_y));
}


void configureEquivalenceCase(int quest, int state_index){
  beginVerificationFixture();
  day = 1 + state_index % TRIP_DAYS;
  opened_day = day;
  resetDailyQuest();
  current_room = SCREEN_DORMITORY;
  screen = SCREEN_DORMITORY;
  system_message = "EQUIVALENCE FIXTURE";

  boolean carrying = state_index % 2 == 1;
  if (quest < PREVENTIVE_COUNT){
    daily_offers[0] = quest;
    daily_offers[1] = -1;
    preventive_committed = true;
    active_quest = quest;
    quest_stage = carrying ? QUEST_DELIVER : QUEST_COLLECT;
    held_item = carrying ? quest + 1 : ITEM_NONE;
    return;
  }

  int problem = questProblem(quest);
  activateProblem(problem, problem_initial_deadline[problem]);
  problem_solution[problem] = quest;
  active_quest = quest;
  quest_stage = carrying ? QUEST_DELIVER : QUEST_COLLECT;
  held_item = carrying ? quest + 1 : ITEM_NONE;
  event_index = problem;
  event_open = false;
  if (state_index % 11 == 0){
    crew_risk_deadline[CREW_VERA] = 1;
  }
}


JSONArray nightIntArrayJson(int[] values){
  JSONArray result = new JSONArray();
  for (int value : values) result.append(value);
  return result;
}


JSONArray nightBooleanArrayJson(boolean[] values){
  JSONArray result = new JSONArray();
  for (boolean value : values) result.append(value);
  return result;
}


JSONArray nightStringArrayJson(String[] values){
  JSONArray result = new JSONArray();
  for (String value : values) result.append(value == null ? "" : value);
  return result;
}


JSONObject equivalenceResources(NightSnapshot state){
  JSONObject resources = new JSONObject();
  resources.setFloat("energy", state.energy);
  resources.setFloat("oxygen", state.oxygen);
  resources.setFloat("water", state.water);
  resources.setFloat("food", state.food);
  resources.setFloat("morale", state.morale);
  resources.setInt("parts", state.parts);
  return resources;
}


String equivalenceStage(int stage){
  if (stage == QUEST_COLLECT) return "collect";
  if (stage == QUEST_DELIVER) return "deliver";
  return "idle";
}


JSONObject equivalenceState(NightSnapshot before, NightProjection projection){
  NightSnapshot after = projection.projected_state;
  JSONObject state = new JSONObject();
  state.setInt("day", after.day);
  state.setInt("opened_day", after.opened_day);
  state.setString("quest_stage_before", equivalenceStage(before.quest_stage));
  state.setString("quest_stage", equivalenceStage(after.quest_stage));
  state.setInt("active_quest_before", before.active_quest);
  state.setInt("active_quest", after.active_quest);
  state.setJSONObject("resources_before", equivalenceResources(before));
  state.setJSONObject("resources", equivalenceResources(after));

  JSONObject inventory_before = new JSONObject();
  inventory_before.setInt("held_item", before.held_item);
  inventory_before.setBoolean("quest_completed", before.quest_completed);
  inventory_before.setBoolean("preventive_committed", before.preventive_committed);
  state.setJSONObject("inventory_before", inventory_before);

  JSONObject inventory = new JSONObject();
  inventory.setInt("held_item", after.held_item);
  inventory.setBoolean("quest_completed", after.quest_completed);
  inventory.setBoolean("preventive_committed", after.preventive_committed);
  state.setJSONObject("inventory", inventory);
  state.setInt("object_loaded_before", before.held_item);
  state.setInt("object_loaded", after.held_item);
  state.setJSONArray("problems_active_before", nightBooleanArrayJson(before.problem_active));
  state.setJSONArray("problems_active", nightBooleanArrayJson(after.problem_active));
  state.setJSONArray("problem_deadlines_before", nightIntArrayJson(before.problem_deadline));
  state.setJSONArray("problem_deadlines", nightIntArrayJson(after.problem_deadline));
  state.setJSONArray("risks_before", nightIntArrayJson(before.crew_risk_deadline));
  state.setJSONArray("risks", nightIntArrayJson(after.crew_risk_deadline));
  state.setJSONArray("crew_alive_before", nightBooleanArrayJson(before.crew_alive));
  state.setJSONArray("crew_alive", nightBooleanArrayJson(after.crew_alive));
  state.setInt("deaths", max(0, before.survivors - after.survivors));
  state.setInt("survivors_before", before.survivors);
  state.setInt("survivors", after.survivors);
  state.setInt("engine_state", after.engine_state);
  state.setJSONObject("editorial_before", equivalenceEditorialMemory(before));
  state.setJSONObject("editorial", equivalenceEditorialMemory(after));

  JSONArray editorial = new JSONArray();
  for (int i = 0; i < projection.editorial_result_count; i++){
    JSONObject result = new JSONObject();
    result.setInt("quest", projection.editorial_quest_ids[i]);
    result.setInt("result", projection.editorial_quest_results[i]);
    editorial.append(result);
  }
  state.setJSONArray("editorial_result", editorial);
  state.setJSONArray("effects", nightStringArrayJson(projection.effects));
  state.setJSONArray("fatal_conditions", nightStringArrayJson(projection.fatal_conditions));
  state.setString("outcome", projection.game_outcome == NIGHT_OUTCOME_VICTORY
    ? "victory" : projection.game_outcome == NIGHT_OUTCOME_DEFEAT ? "defeat" : "ongoing");
  state.setInt("game_over_reason", projection.game_over_reason);
  return state;
}


JSONObject equivalenceEditorialMemory(NightSnapshot state){
  JSONObject editorial = new JSONObject();
  editorial.setJSONArray("last_result", nightIntArrayJson(state.editorial_last_result));
  editorial.setJSONArray("last_result_day", nightIntArrayJson(state.editorial_last_result_day));
  editorial.setJSONArray("last_seen_day", nightIntArrayJson(state.editorial_last_seen_day));
  editorial.setJSONArray("was_presented", nightBooleanArrayJson(state.editorial_was_presented));
  editorial.setJSONArray("last_risk_day", nightIntArrayJson(state.editorial_last_risk_day));
  editorial.setJSONArray("risk_was_presented", nightBooleanArrayJson(state.editorial_risk_was_presented));
  editorial.setJSONArray("conversation_count", nightIntArrayJson(state.editorial_conversation_count));
  return editorial;
}


boolean sameNightIntArray(int[] left, int[] right){
  if (left == null || right == null || left.length != right.length) return false;
  for (int i = 0; i < left.length; i++) if (left[i] != right[i]) return false;
  return true;
}


boolean sameNightFloatArray(float[] left, float[] right){
  if (left == null || right == null || left.length != right.length) return false;
  for (int i = 0; i < left.length; i++) if (left[i] != right[i]) return false;
  return true;
}


boolean sameNightStringArray(String[] left, String[] right){
  if (left == null || right == null || left.length != right.length) return false;
  for (int i = 0; i < left.length; i++){
    String left_value = left[i] == null ? "" : left[i];
    String right_value = right[i] == null ? "" : right[i];
    if (!left_value.equals(right_value)) return false;
  }
  return true;
}


JSONArray projectionDifferences(NightProjection reference, NightProjection revised){
  JSONArray differences = new JSONArray();
  if (!reference.source_signature.equals(revised.source_signature)) differences.append("source");
  if (!reference.projected_signature.equals(revised.projected_signature)) differences.append("projected_state");
  if (reference.game_outcome != revised.game_outcome) differences.append("outcome");
  if (reference.game_over_reason != revised.game_over_reason) differences.append("game_over_reason");
  if (reference.survivor_loss != revised.survivor_loss) differences.append("deaths");
  if (!reference.quest_summary.equals(revised.quest_summary)) differences.append("quest_summary");
  if (!reference.resource_line_a.equals(revised.resource_line_a)) differences.append("resources_a");
  if (!reference.resource_line_b.equals(revised.resource_line_b)) differences.append("resources_b");
  if (!reference.risk_line.equals(revised.risk_line)) differences.append("risks");
  if (!reference.outcome_line.equals(revised.outcome_line)) differences.append("outcome_line");
  if (!sameNightStringArray(reference.effects, revised.effects)) differences.append("effects");
  if (!sameNightStringArray(reference.fatal_conditions, revised.fatal_conditions)) differences.append("fatal_conditions");
  if (reference.editorial_result_count != revised.editorial_result_count
    || !sameNightIntArray(reference.editorial_quest_ids, revised.editorial_quest_ids)
    || !sameNightIntArray(reference.editorial_quest_results, revised.editorial_quest_results)){
    differences.append("editorial_result");
  }
  if (reference.deltas == null || revised.deltas == null
    || !sameNightFloatArray(reference.deltas.resources, revised.deltas.resources)
    || reference.deltas.survivors != revised.deltas.survivors
    || reference.deltas.engine_state != revised.deltas.engine_state
    || !sameNightIntArray(reference.deltas.crew_risk_deadline, revised.deltas.crew_risk_deadline)
    || !sameNightIntArray(reference.deltas.problem_deadline, revised.deltas.problem_deadline)){
    differences.append("deltas");
  }
  return differences;
}


JSONArray appliedStateDifferences(NightProjection projection, NightSnapshot actual){
  NightSnapshot expected = projection.projected_state;
  JSONArray differences = new JSONArray();
  if (expected.day != actual.day || expected.opened_day != actual.opened_day) differences.append("calendar");
  if (expected.energy != actual.energy || expected.oxygen != actual.oxygen
    || expected.water != actual.water || expected.food != actual.food
    || expected.morale != actual.morale || expected.parts != actual.parts) differences.append("resources");
  if (expected.engine_state != actual.engine_state || expected.survivors != actual.survivors) differences.append("survivors_or_engine");
  if (expected.active_quest != actual.active_quest || expected.quest_stage != actual.quest_stage
    || expected.held_item != actual.held_item || expected.quest_completed != actual.quest_completed
    || expected.preventive_committed != actual.preventive_committed) differences.append("inventory");
  if (!sameNightBooleanArray(expected.problem_active, actual.problem_active)
    || !sameNightIntArray(expected.problem_deadline, actual.problem_deadline)
    || !sameNightIntArray(expected.problem_solution, actual.problem_solution)) differences.append("problems");
  if (!sameNightBooleanArray(expected.crew_alive, actual.crew_alive)
    || !sameNightIntArray(expected.crew_risk_deadline, actual.crew_risk_deadline)) differences.append("risks");
  if (!sameNightIntArray(expected.editorial_last_result, actual.editorial_last_result)
    || !sameNightIntArray(expected.editorial_last_result_day, actual.editorial_last_result_day)
    || !sameNightIntArray(expected.editorial_last_seen_day, actual.editorial_last_seen_day)
    || !sameNightBooleanArray(expected.editorial_was_presented, actual.editorial_was_presented)
    || !sameNightIntArray(expected.editorial_last_risk_day, actual.editorial_last_risk_day)
    || !sameNightBooleanArray(expected.editorial_risk_was_presented, actual.editorial_risk_was_presented)
    || !sameNightIntArray(expected.editorial_conversation_count, actual.editorial_conversation_count))
    differences.append("editorial");
  if (expected.transmission_open != actual.transmission_open
    || !expected.transmission_text.equals(actual.transmission_text)) differences.append("transmission");
  if (expected.game_over_reason != actual.game_over_reason) differences.append("game_over_reason");
  return differences;
}


boolean sameNightBooleanArray(boolean[] left, boolean[] right){
  if (left == null || right == null || left.length != right.length) return false;
  for (int i = 0; i < left.length; i++) if (left[i] != right[i]) return false;
  return true;
}


void writeEquivalenceReport(){
  JSONObject report = new JSONObject();
  report.setString("schema", EQUIVALENCE_REPORT_SCHEMA);
  report.setString("fixture_source", "last_horizon/capture.pde");
  report.setString("status", checks_failed ? "FAIL" : "PASS");
  report.setInt("quest_count", quest_id.length);
  report.setInt("state_count", capture_label.length);
  report.setInt("expected_quest_count", EQUIVALENCE_EXPECTED_QUEST_COUNT);
  report.setInt("expected_state_count", EQUIVALENCE_EXPECTED_STATE_COUNT);
  report.setInt("expected_entries", EQUIVALENCE_EXPECTED_QUEST_COUNT * EQUIVALENCE_EXPECTED_STATE_COUNT);

  boolean fixture_shape_valid = quest_id.length == EQUIVALENCE_EXPECTED_QUEST_COUNT
    && capture_label.length == EQUIVALENCE_EXPECTED_STATE_COUNT
    && sameNightStringArray(quest_id, EQUIVALENCE_EXPECTED_QUEST_IDS)
    && sameNightStringArray(capture_label, EQUIVALENCE_EXPECTED_STATE_IDS);
  report.setBoolean("fixture_shape_valid", fixture_shape_valid);
  if (!fixture_shape_valid) checks_failed = true;

  JSONArray entries = new JSONArray();
  boolean equivalent = true;
  for (int quest = 0; quest < quest_id.length; quest++){
    for (int state_index = 0; state_index < capture_label.length; state_index++){
      configureEquivalenceCase(quest, state_index);
      NightSnapshot source = captureNightSnapshot();
      NightProjection reference = simulateNightTransition(source);
      NightProjection revised = projectNight();
      JSONArray differences = projectionDifferences(reference, revised);
      boolean applied = applyNightProjection(revised);
      if (!applied){
        differences.append("application");
      } else {
        NightSnapshot applied_state = captureNightSnapshot();
        JSONArray application_differences = appliedStateDifferences(revised, applied_state);
        for (int difference = 0; difference < application_differences.size(); difference++){
          differences.append("applied_" + application_differences.getString(difference));
        }
      }
      boolean case_equivalent = differences.size() == 0;
      equivalent &= case_equivalent;

      JSONObject entry = new JSONObject();
      entry.setString("identifier", quest_id[quest] + "::" + capture_label[state_index]);
      entry.setString("state_id", capture_label[state_index]);
      entry.setString("quest_id", quest_id[quest]);
      entry.setString("quest", quest_id[quest]);
      entry.setInt("day", source.day);
      entry.setString("stage", equivalenceStage(source.quest_stage));
      entry.setJSONObject("reference", equivalenceState(source, reference));
      entry.setJSONObject("revised", equivalenceState(source, revised));
      entry.setJSONObject("fields", equivalenceState(source, revised));
      entry.setJSONArray("differences", differences);
      entry.setBoolean("application_valid", applied);
      entry.setString("status", case_equivalent ? "PASS" : "FAIL");
      entries.append(entry);
      invalidateNightPreview();
    }
  }

  if (!equivalent) checks_failed = true;
  report.setString("status", checks_failed ? "FAIL" : "PASS");
  report.setJSONArray("entries", entries);
  new File(sketchPath("output")).mkdirs();
  saveJSONObject(report, sketchPath(EQUIVALENCE_REPORT_FILE));
  restoreVerificationFixture();
}

float[] badgeInkBox(PGraphics g, float cx, float cy, float radius){
  g.loadPixels();
  int x0 = max(0, int((cx - radius) * RENDER_SCALE));
  int y0 = max(0, int((cy - radius) * RENDER_SCALE));
  int x1 = min(g.width, int((cx + radius) * RENDER_SCALE));
  int y1 = min(g.height, int((cy + radius) * RENDER_SCALE));
  float inset = radius - 1;
  float[] box = {0, 0, 0, 0};

  for (int y = y0; y < y1; y++){
    for (int x = x0; x < x1; x++){
      float lx = (x + 0.5) / RENDER_SCALE;
      float ly = (y + 0.5) / RENDER_SCALE;
      float dx = lx - cx;
      float dy = ly - cy;
      if (dx * dx + dy * dy > inset * inset) continue;
      if (((g.pixels[y * g.width + x] >> 8) & 0xFF) >= 150) continue;
      if (box[0] == 0 || lx < box[0]) box[0] = lx;
      if (box[1] == 0 || ly < box[1]) box[1] = ly;
      box[2] = max(box[2], lx);
      box[3] = max(box[3], ly);
    }
  }

  return box;
}

void checkOrdersBadge(){
  base.beginDraw();
  base.resetMatrix();
  base.scale(RENDER_SCALE);
  base.background(COL_BG);
  base.textFont(ui_font);
  base.textAlign(LEFT, TOP);
  drawOrdersBadge(base, 70, 100, 0);
  drawOrdersBadge(base, 130, 100, 1);
  base.endDraw();
  float[] small = badgeInkBox(base, 70, 100, 4);
  float[] large = badgeInkBox(base, 130, 100, 5.5);
  float small_h = small[3] - small[1];
  float large_h = large[3] - large[1];
  float dx = (large[0] + large[2]) / 2 - 130;
  float dy = (large[1] + large[3]) / 2 - 100;
  base.save(verificationOutputPath("rules", "orders_badge_pulse", RENDER_W, RENDER_H));
  println("verify: selo de ordens, tinta " + nf(small_h, 1, 2) + " -> " + nf(large_h, 1, 2)
    + " px; centro deslocado " + nf(dx, 1, 2) + "," + nf(dy, 1, 2));
  verify("exclamação pulsa junto com o círculo", small_h > 0 && large_h > small_h * 1.25);
  verify("exclamação centralizada no círculo", abs(dx) <= 0.5 && abs(dy) <= 0.5);
}

void checkQuestCatalogue(){
  for (int q = 0; q < quest_id.length; q++){
    captureStartDay(q < PREVENTIVE_COUNT ? 1 : 2);
    if (q < PREVENTIVE_COUNT){
      daily_offers[0] = q;
      captureAcceptPreventive(0);
    } else {
      event_index = questProblem(q);
      if (event_index == PROBLEM_HULL){ placeHullDamage(); problem_room[event_index] = point_room[POINT_HULL]; }
      drawBase();
      base.save(verificationOutputPath("catalogue", quest_id[q] + "_options", RENDER_W, RENDER_H));
      applyEventChoice((q - PREVENTIVE_COUNT) % 2);
      pressEnter();
    }
    int resource = q < PREVENTIVE_COUNT ? preventive_resource[q] : solution_resource[q - PREVENTIVE_COUNT];
    float before = resourceValue(resource);
    int delta = q < PREVENTIVE_COUNT ? preventiveReward(q) : -solution_cost[q - PREVENTIVE_COUNT];
    drawBase();
    base.save(verificationOutputPath("catalogue", quest_id[q] + "_hud", RENDER_W, RENDER_H));
    captureCompleteQuest();
    verify(quest_id[q] + " coleta, entrega e efeito no recurso", quest_completed && active_quest < 0
      && held_item == ITEM_NONE && resourceValue(resource) == before + delta
      && (q < PREVENTIVE_COUNT || !problem_active[questProblem(q)]));
  }
}

void checkQuestBoundaries(){
  captureStartDay(1);
  endDay();
  verify("dormir exige o beliche físico", day == 1);
  captureInteract(POINT_ANTENNA);
  verify("antena sem ordem não abre painel", !modalOpen() && !pointIsAvailable(POINT_ANTENNA));
  captureInteract(POINT_RESERVE); pressEnter();
  verify("reserva sem ordem não permite interação", !modalOpen() && held_item == ITEM_NONE && !quest_completed);
  choosePreventive(0);
  acceptPreventive();
  verify("aceite distante é recusado", active_quest < 0);
  enterRoom(SCREEN_COMMAND);
  setCapturePlayerAtPoint(POINT_VERA);
  float before_modal_x = player_x;
  move_right_held = true;
  interact_queued = true;
  updateRoom(movementHarnessStepContext());
  move_right_held = false;
  verify("abrir modal bloqueia movimento no mesmo quadro", player_x == before_modal_x);
  interact_queued = true; updateRoom(movementHarnessStepContext());
  verify("E não confirma a ordem", dialog_open && active_quest < 0);
  pressEnter();
  choosePreventive(1);
  verify("aceite impede trocar de ordem", active_quest == 0 && selected_preventive_id < 0);
  verify("coleta habilita só a origem", pointIsAvailable(POINT_RESERVE) && !pointIsAvailable(POINT_ANTENNA) && !ordersAvailable());
  collectQuestObject();
  verify("coleta distante é recusada", held_item == ITEM_NONE);
  captureInteract(POINT_RESERVE);
  handleEscape();
  verify("cancelar painel não cancela ordem", active_quest == 0 && held_item == ITEM_NONE);
  captureInteract(POINT_RESERVE); pressEnter();
  verify("coleta desabilita origem e habilita destino", !pointIsAvailable(POINT_RESERVE) && pointIsAvailable(POINT_ANTENNA));
  deliverQuest();
  verify("entrega distante é recusada", active_quest == 0 && !quest_completed);
  captureInteract(POINT_ANTENNA); pressEnter();
  verify("entrega desabilita ponto concluído", !pointIsAvailable(POINT_ANTENNA) && !ordersAvailable());
  choosePreventive(1);
  putSurvivorAtRisk(PROBLEM_FOOD);
  captureInteract(POINT_RISK_BUNK); pressEnter();
  verify("segunda quest e socorro bloqueados", active_quest < 0 && quest_completed && urgentRisk() >= 0);
  closeTopModal();
  captureStartDay(3);
  choosePreventive(daily_offers[0]);
  captureInteract(POINT_VERA); pressEnter();
  verify("aceite de preventiva do responsável entrega em mãos",
    active_quest == 1 && quest_stage == QUEST_DELIVER && held_item == 2 && nextQuestPoint() == POINT_ROUTE && pointIsAvailable(POINT_ROUTE));
  captureInteract(POINT_VERA);
  verify("responsável pós-entrega orienta a rota no destino",
    dialog_open && dialog_text.indexOf("Já entreguei") >= 0);
  closeTopModal();
  captureInteract(POINT_ROUTE); pressEnter();
  verify("entrega conclui preventiva direta", quest_completed && held_item == ITEM_NONE);

  captureStartDay(2);
  parts = 0; energy = 1;
  applyEventChoice(0); pressEnter();
  captureCompleteQuest();
  verify("custo inviável preserva item e não causa overdraft", parts == 0 && energy == 1 && !quest_completed
    && held_item != ITEM_NONE && problem_active[PROBLEM_ENGINE]);
  closeTopModal();
  handleEscape();
  pressEnter();
  verify("ENTER em pausa não entrega", paused && parts == 0 && !quest_completed);
  handleEscape();
}

void checkNightConsequences(){
  captureStartDay(1); captureSleep();
  verify("negligência cobra ambos recursos além do consumo", morale == 74 && food == 60 && energy == 73 && oxygen == 81 && water == 74);
  captureStartDay(1); captureAcceptPreventive(0);
  captureInteract(POINT_RESERVE); pressEnter(); captureSleep();
  verify("falha aceita menor que negligência e limpa item", morale == 75 && food == 64 && held_item == ITEM_NONE);
  captureStartDay(1); captureAcceptPreventive(0); captureCompleteQuest(); captureSleep();
  verify("sucesso recebe recompensa sem anular consumo", morale == 86 && energy == 73 && food == 64);
  captureStartDay(5); daily_offers[0] = 3; captureAcceptPreventive(0);
  parts = 100; captureCompleteQuest();
  verify("peças não são limitadas a cem", parts == 102);
  captureStartDay(1); morale = 99; captureAcceptPreventive(0); captureCompleteQuest();
  verify("barras são limitadas a cem", morale == 100);
}


void checkNightProjection(){
  captureStartDay(1);
  int editorial_owner = quest_owner[daily_offers[0]];
  int editorial_before = editorial_last_result[editorial_owner];
  float saved_energy = energy;
  float saved_oxygen = oxygen;
  float saved_food = food;
  int saved_deadline = problem_deadline[PROBLEM_ENGINE];
  int saved_risk_day = editorial_last_risk_day[CREW_VERA];

  randomSeed(817);
  random(1000);
  float expected_random = random(1000);
  randomSeed(817);
  random(1000);
  NightProjection preview = projectNight();
  float actual_random = random(1000);
  verify("preview não consome RNG nem altera globais",
    abs(expected_random - actual_random) < 0.001
      && energy == saved_energy && oxygen == saved_oxygen && food == saved_food
      && problem_deadline[PROBLEM_ENGINE] == saved_deadline
      && editorial_last_risk_day[CREW_VERA] == saved_risk_day);
  verify("preview projeta memória editorial sem escrevê-la",
    preview.projected_state.editorial_last_result[editorial_owner] == EDITORIAL_RESULT_OMISSION
      && editorial_last_result[editorial_owner] == editorial_before);
  NightProjection second_preview = projectNight();
  verify("recalcular preview é determinístico",
    preview == second_preview
      && preview.projected_state.energy == second_preview.projected_state.energy
      && preview.projected_state.food == second_preview.projected_state.food
      && preview.game_outcome == second_preview.game_outcome);

  NightSnapshot snapshot = captureNightSnapshot();
  snapshot.crew_alive[CREW_VERA] = false;
  snapshot.incident_sequence[0] = PROBLEM_COMMS;
  verify("snapshot não compartilha arrays com o estado real",
    crew_alive[CREW_VERA] && incident_sequence[0] != PROBLEM_COMMS);

  NightProjection applied = processNight();
  verify("aplicação usa o mesmo resultado do preview",
    applied == preview
      && energy == applied.projected_state.energy && oxygen == applied.projected_state.oxygen
      && food == applied.projected_state.food && morale == applied.projected_state.morale
      && survivors == applied.projected_state.survivors && day == 1);
  verify("aplicação preserva o resultado editorial projetado",
    editorial_last_result[editorial_owner] == applied.projected_state.editorial_last_result[editorial_owner]
      && editorial_last_result_day[editorial_owner]
        == applied.projected_state.editorial_last_result_day[editorial_owner]);
  float applied_energy = energy;
  verify("segunda confirmação não reaplica efeitos", processNight() == null && energy == applied_energy);

  captureStartDay(1);
  projectNight();
  energy -= 1;
  verify("mudança no estado invalida confirmação obsoleta",
    processNight() == null && night_preview == null && energy == 79);

  captureStartDay(3);
  activateProblem(PROBLEM_FOOD, 1);
  NightProjection crisis_preview = projectNight();
  verify("preview inclui perda, crise e risco sem processar globais",
    crisis_preview.projected_state.food < food
      && crisis_preview.projected_state.problem_deadline[PROBLEM_FOOD] == 2
      && urgentRisk() < 0 && problem_deadline[PROBLEM_FOOD] == 1);
  processNight();
  verify("crise e risco são aplicados uma única vez",
    problem_deadline[PROBLEM_FOOD] == 2 && urgentRisk() == CREW_VERA);

  captureStartDay(3);
  putSurvivorAtRisk(PROBLEM_FOOD);
  crew_risk_deadline[CREW_VERA] = 1;
  NightProjection loss_preview = projectNight();
  verify("perda noturna projeta transmissão sem abrir modal",
    loss_preview.projected_state.transmission_open && !transmission_open
      && loss_preview.projected_state.survivors == CREW_START - 1);
  processNight();
  verify("aplicação da perda usa a transmissão projetada",
    transmission_open && transmission_text.indexOf("UMA VIDA FOI PERDIDA") >= 0
      && survivors == CREW_START - 1);

  captureStartDay(9);
  day = TRIP_DAYS;
  opened_day = TRIP_DAYS;
  resetDailyQuest();
  NightProjection final_preview = projectNight();
  verify("noite do dia 10 projeta vitória",
    final_preview.game_outcome == NIGHT_OUTCOME_VICTORY
      && final_preview.fatal_conditions.length == 0);

  captureStartDay(3);
  for (int crew = 0; crew < CREW_COUNT; crew++) crew_alive[crew] = false;
  survivors = 0;
  NightProjection defeat_preview = projectNight();
  boolean crew_fatal = false;
  for (String condition : defeat_preview.fatal_conditions){
    if (condition.equals("nenhum sobrevivente vivo")) crew_fatal = true;
  }
  verify("morte individual só derrota quando não resta sobrevivente",
    defeat_preview.game_outcome == NIGHT_OUTCOME_DEFEAT && crew_fatal);
}

void checkRetryPriority(){
  captureStartDay(2); applyEventChoice(1); pressEnter();
  captureSleep();
  verify("falha urgente só cobra consumo e perda ativa", energy == 69 && problem_deadline[PROBLEM_ENGINE] == 2 && problem_solution[PROBLEM_ENGINE] == 9);
  closeTopModal(); acceptSolution(8);
  verify("retomada não permite trocar solução", active_quest < 0);
  clickAction(ACTION_OPEN_ORDERS);
  clickAction(ACTION_NEXT_RETRY);
  clickAction(ACTION_RETRY_QUEST);
  verify("retomada exibe detalhes no painel de ordens sem aceitar",
    orders_open && orders_details_open && !technical_open
      && pending_quest_action == ACTION_RETRY_QUEST && active_quest < 0);
  pressEnter();
  verify("ENTER retoma a solução escolhida", active_quest == 9 && problem_deadline[PROBLEM_ENGINE] == 2);
  captureCompleteQuest(); captureSleep();
  verify("retomada remove problema e preserva negligência", !problem_active[PROBLEM_ENGINE] && energy == 50 && water == 64);
  captureStartDay(2); applyEventChoice(0); pressEnter(); captureSleep();
  closeTopModal(); captureSleep();
  verify("incidente novo tem prioridade", day == 4 && event_open);
  acceptSolution(8);
  verify("problema anterior não substitui incidente novo", event_open && active_quest < 0);
}

void checkCrewRules(){
  captureStartDay(3);
  putSurvivorAtRisk(PROBLEM_FOOD);
  putSurvivorAtRisk(PROBLEM_LIFE_SUPPORT);
  int risks = 0;
  for (int deadline : crew_risk_deadline) if (deadline > 0) risks++;
  verify("crises simultâneas mantêm um único risco", risks == 1 && urgentRisk() == CREW_VERA);
  captureInteract(POINT_RISK_BUNK); pressEnter(); captureSleep();
  verify("socorro custa 8 água e 2 comida e mantém negligência", water == 62 && food == 62 && urgentRisk() < 0);
  captureStartDay(3); putSurvivorAtRisk(PROBLEM_FOOD);
  processSurvivorRisks(); processSurvivorRisks();
  verify("duas noites sem socorro causam morte", survivors == 3 && !crew_alive[CREW_VERA] && urgentRisk() < 0);
  for (int mask = 1; mask < 16; mask++){
    resetRun(); day = 3;
    for (int crew = 0; crew < CREW_COUNT; crew++) crew_alive[crew] = (mask & (1 << crew)) != 0;
    selectPreventiveOffers();
    verify("pool vivo e distinto, máscara " + mask, daily_offers[0] >= 0 && daily_offers[1] >= 0
      && crew_alive[quest_owner[daily_offers[0]]] && crew_alive[quest_owner[daily_offers[1]]]
      && preventive_resource[daily_offers[0]] != preventive_resource[daily_offers[1]]);
  }
  captureStartDay(2); crew_alive[CREW_SILVIA] = false; survivors--;
  applyEventChoice(0); pressEnter(); captureCompleteQuest();
  verify("morte não altera custo nem bloqueia solução", parts == 2 && !problem_active[PROBLEM_ENGINE]);
  captureStartDay(3); activateProblem(PROBLEM_FOOD, 1); captureSleep();
  verify("risco criado pela crise ganha duas noites inteiras", urgentRisk() >= 0 && crew_risk_deadline[urgentRisk()] == 2);
}

void checkHullDamageLocation(){
  captureStartDay(1);
  boolean reachable = true;
  boolean varied = false;
  int first_room = SCREEN_NONE;
  randomSeed(97031);
  for (int sample = 0; sample < 32; sample++){
    clearProblem(PROBLEM_HULL); activateProblem(PROBLEM_HULL, 3);
    int room = point_room[POINT_HULL];
    reachable &= isDeckSurface(point_y[POINT_HULL]) && hullPointClear(room, point_y[POINT_HULL], point_x[POINT_HULL]);
    if (sample == 0) first_room = room;
    else varied |= room != first_room;
  }
  verify("casco sorteado alcançável e sem sobreposição", reachable && varied);
  clearProblem(PROBLEM_HULL);
  verify("resolver casco remove ponto físico", point_room[POINT_HULL] == SCREEN_NONE);
}

float capturePressure(int q){
  int resource = preventive_resource[q];
  if (resource == RESOURCE_PARTS) return parts == 0 ? 1 : 0;
  int[] consumption = {7, 4, 6, 6, 2};
  return (100 - resourceValue(resource)) / consumption[resource];
}

void playCaptureCampaign(int[] sequence, int strategy){
  resetRun(); arrayCopy(sequence, incident_sequence);
  enterRoom(SCREEN_COMMAND); openDay();
  while (isRoomScreen()){
    transmission_open = false;
    if (event_open){
      int q = PREVENTIVE_COUNT + event_index * 2;
      int i = q - PREVENTIVE_COUNT;
      boolean first = canPayResource(solution_resource[i], solution_cost[i]);
      boolean second = canPayResource(solution_resource[i + 1], solution_cost[i + 1]);
      int choice = first ? 0 : second ? 1 : 0;
      if (strategy == 0 && first && second){
        float a = solution_cost[i] / max(1.0, resourceValue(solution_resource[i]));
        float b = solution_cost[i + 1] / max(1.0, resourceValue(solution_resource[i + 1]));
        choice = b < a ? 1 : 0;
      }
      applyEventChoice(choice); pressEnter();
      if (strategy != 3) captureCompleteQuest();
    } else if (strategy != 3){
      if (orders_open) closeTopModal();
      int choice = capturePressure(daily_offers[1]) > capturePressure(daily_offers[0]) ? 1 : 0;
      if (strategy == 1){
        for (int i = 0; i < 2; i++) if (preventive_resource[daily_offers[i]] == RESOURCE_PARTS) choice = i;
      }
      captureAcceptPreventive(choice); captureCompleteQuest();
    }
    if (technical_open) closeTopModal();
    captureSleep();
  }
}

void startCampaignChecks(){
  campaign_checks_running = true;
  campaign_phase = 0;
  campaign_strategy = 0;
  campaign_sequence[0] = PROBLEM_ENGINE;
  campaign_sequence[1] = PROBLEM_FOOD;
  campaign_sequence[2] = PROBLEM_CONFLICT;
  campaign_sequence[3] = PROBLEM_HULL;
  campaign_sequence[4] = PROBLEM_LIFE_SUPPORT;
  capture_campaign_wins = 0;
  campaign_depth = 0;
  campaign_used = 0;
  campaign_permutation_ready = false;
  for (int i = 0; i < campaign_next_candidate.length; i++) campaign_next_candidate[i] = 0;
}


boolean nextCampaignPermutation(){
  while (campaign_depth >= 0){
    boolean descended = false;
    while (campaign_next_candidate[campaign_depth] < PROBLEM_COUNT){
      int candidate = campaign_next_candidate[campaign_depth]++;
      if ((campaign_used & (1 << candidate)) != 0) continue;

      campaign_sequence[campaign_depth] = candidate;
      campaign_used |= 1 << candidate;
      campaign_depth++;
      if (campaign_depth == campaign_sequence.length) return true;
      campaign_next_candidate[campaign_depth] = 0;
      descended = true;
      break;
    }

    if (descended) continue;
    campaign_depth--;
    if (campaign_depth >= 0){
      campaign_used &= ~(1 << campaign_sequence[campaign_depth]);
    }
  }

  return false;
}


void advanceCampaignPermutation(){
  int last = campaign_sequence.length - 1;
  campaign_depth = last;
  campaign_used &= ~(1 << campaign_sequence[last]);
}


void advanceCampaignChecks(){
  if (campaign_phase == 0){
    playCaptureCampaign(campaign_sequence, campaign_strategy);
    verify("estratégia " + campaign_strategy + " vence campanha completa",
      screen == SCREEN_VICTORY && day == 10);
    campaign_strategy++;
    if (campaign_strategy == 3) campaign_phase = 1;
    return;
  }

  if (campaign_phase == 1){
    playCaptureCampaign(campaign_sequence, 3);
    verify("omissão perde por motor destruído",
      screen == SCREEN_GAME_OVER && game_over_reason == REASON_ENGINE);
    campaign_phase = 2;
    return;
  }

  if (campaign_phase == 2){
    if (!campaign_permutation_ready){
      if (!nextCampaignPermutation()){
        verify("reserva de peças vence " + capture_campaign_wins + "/2520 no sketch",
          capture_campaign_wins == 2520);
        campaign_checks_running = false;
        campaign_phase = 3;
        return;
      }
      campaign_permutation_ready = true;
    }

    playCaptureCampaign(campaign_sequence, 1);
    if (screen != SCREEN_VICTORY){
      verify("campanha " + join(nf(campaign_sequence, 1), ",") + " chega a Marte",
        false);
      campaign_checks_running = false;
      return;
    }

    capture_campaign_wins++;
    campaign_permutation_ready = false;
    advanceCampaignPermutation();
  }
}

void checkPlayerFacing(){
  resetRun();
  move_left_held = true;
  updatePlayerFacing();
  verify("jogador olha para a esquerda", player_facing == -1);

  move_left_held = false;
  move_right_held = true;
  updatePlayerFacing();
  verify("jogador olha para a direita", player_facing == 1);

  move_right_held = false;
  clearDoorArt();
  enterRoom(SCREEN_DEPOT);
  placePlayerAtDoor(doorInRoomLeadingTo(SCREEN_DEPOT, SCREEN_COMMAND));
  useNearbyDoor();
  verify("retorno ao hub olha para a esquerda",
    screen == SCREEN_COMMAND && player_facing == -1);
  restoreDoorArt();
}

void checkPlayerAnimationLoop(){
  if (!player_assets_loaded){
    verify("spritesheet do jogador carregada", false);
    return;
  }

  int previous_state = player_anim_state;
  boolean previous_moving = player_animation_moving;
  int previous_started_at = player_animation_started_at;
  player_anim_state = PLAYER_ANIM_IDLE;
  player_animation_moving = false;
  player_animation_started_at = 0;
  int idle_duration = playerAnimationTakeDuration(player_idle_start,
    player_idle_end);
  verify("idle usa o loop e as durações carregadas",
    playerCurrentFrameAt(0.0) == player_idle_start
      && playerCurrentFrameAt(idle_duration / 1000.0) == player_idle_start);

  player_anim_state = PLAYER_ANIM_WALK;
  player_animation_moving = true;
  int walk_duration = playerAnimationTakeDuration(player_walk_start,
    player_walk_end);
  verify("walk usa o loop e as durações carregadas",
    playerCurrentFrameAt(0.0) == player_walk_start
      && playerCurrentFrameAt(walk_duration / 1000.0) == player_walk_start);

  if (player_has_climb){
    player_anim_state = PLAYER_ANIM_CLIMB;
    player_animation_moving = false;
    verify("climb parado preserva o primeiro quadro",
      playerCurrentFrameAt(20.0) == player_climb_start);
  }

  if (player_has_jump){
    player_anim_state = PLAYER_ANIM_JUMP;
    player_animation_moving = false;
    int jump_duration = playerAnimationTakeDuration(player_jump_start,
      player_jump_end);
    verify("jump permanece no último quadro após a duração carregada",
      playerCurrentFrameAt((jump_duration + 1000) / 1000.0)
        == player_jump_end);
  }

  int selected_state = player_anim_state;
  boolean selected_moving = player_animation_moving;
  int selected_started_at = player_animation_started_at;
  playerCurrentFrameAt(3.0);
  playerCurrentFrameAt(3.0);
  verify("selecionar quadro não altera o estado confirmado do take",
    player_anim_state == selected_state
      && player_animation_moving == selected_moving
      && player_animation_started_at == selected_started_at);
  player_anim_state = previous_state;
  player_animation_moving = previous_moving;
  player_animation_started_at = previous_started_at;
}


int playerAnimationTakeDuration(int first, int last){
  if (!validPlayerFrameRange(first, last)) return 0;
  int duration = 0;
  for (int frame = first; frame <= last; frame++){
    duration += max(1, player_frame_durations[frame]);
  }
  return duration;
}


class PlayerAnimationSequence {
  int[] states;
  int[] frames;
  int[] started_at;
  boolean[] moving;
  boolean render_queries_pure;

  PlayerAnimationSequence(int length){
    states = new int[length];
    frames = new int[length];
    started_at = new int[length];
    moving = new boolean[length];
  }
}


PlayerAnimationSequence simulatePlayerAnimationSequence(){
  final int sequence_length = 11;
  PlayerAnimationSequence result = new PlayerAnimationSequence(sequence_length);
  FrameClock previous_clock = frame_clock;
  FakeFrameClockSource source = new FakeFrameClockSource(0.0);
  frame_clock = new FrameClock(source);
  try {
    frame_clock.beginCallback(false, true, SCREEN_COMMAND,
      SCREEN_COMMAND, LAYER_SCENE, "capture", false);
    player_anim_state = PLAYER_ANIM_IDLE;
    player_animation_moving = false;
    player_animation_started_at = 0;
    player_grounded = true;
    player_on_ladder = false;
    move_left_held = false;
    move_right_held = false;
    move_up_held = false;
    move_down_held = false;
    run_held = false;

    result.states[0] = playerCurrentAnimationState();
    result.frames[0] = playerCurrentFrame();
    result.started_at[0] = player_animation_started_at;
    result.moving[0] = player_animation_moving;

    for (int step = 1; step < sequence_length; step++){
      move_left_held = false;
      move_right_held = false;
      move_up_held = false;
      move_down_held = false;
      run_held = false;
      player_on_ladder = false;
      player_grounded = true;

      if (step <= 2){
        move_right_held = true;
      } else if (step <= 4){
        move_right_held = true;
        run_held = true;
      } else if (step <= 7){
        player_grounded = false;
        player_on_ladder = true;
        move_up_held = step <= 6;
      } else if (step <= 9){
        player_grounded = false;
      }

      source.advanceSeconds(FRAME_FIXED_STEP_SECONDS);
      FrameContext context = frame_clock.beginCallback(false, true,
        SCREEN_COMMAND, SCREEN_COMMAND, LAYER_SCENE, "capture", false);
      if (context.steps_planned != 1){
        result.states[step] = playerCurrentAnimationState();
        result.frames[step] = playerCurrentFrame();
        result.started_at[step] = player_animation_started_at;
        result.moving[step] = player_animation_moving;
        continue;
      }
      context.beginStep(0);
      updatePlayerAnimationState(context);
      frame_clock.confirmStep(context);
      result.states[step] = playerCurrentAnimationState();
      result.frames[step] = playerCurrentFrame();
      result.started_at[step] = player_animation_started_at;
      result.moving[step] = player_animation_moving;
    }

    int saved_state = player_anim_state;
    boolean saved_moving = player_animation_moving;
    int saved_started_at = player_animation_started_at;
    int first_query = playerCurrentFrame();
    playerCurrentFrame();
    playerCurrentFrame();
    result.render_queries_pure = first_query == result.frames[sequence_length - 1]
      && player_anim_state == saved_state
      && player_animation_moving == saved_moving
      && player_animation_started_at == saved_started_at;
  } finally {
    frame_clock = previous_clock;
  }
  return result;
}


boolean samePlayerAnimationSequence(PlayerAnimationSequence a,
  PlayerAnimationSequence b){
  if (a == null || b == null || a.frames.length != b.frames.length){
    return false;
  }
  for (int index = 0; index < a.frames.length; index++){
    if (a.states[index] != b.states[index]
      || a.frames[index] != b.frames[index]
      || a.started_at[index] != b.started_at[index]
      || a.moving[index] != b.moving[index]){
      return false;
    }
  }
  return true;
}


void checkPlayerAnimationTransitions(){
  if (!player_assets_loaded){
    verify("spritesheet do jogador carregada", false);
    return;
  }

  int previous_state = player_anim_state;
  boolean previous_moving = player_animation_moving;
  int previous_started_at = player_animation_started_at;
  boolean previous_grounded = player_grounded;
  boolean previous_on_ladder = player_on_ladder;
  boolean previous_left = move_left_held;
  boolean previous_right = move_right_held;
  boolean previous_up = move_up_held;
  boolean previous_down = move_down_held;
  boolean previous_run = run_held;

  PlayerAnimationSequence first = simulatePlayerAnimationSequence();
  PlayerAnimationSequence second = simulatePlayerAnimationSequence();
  int walk_started = (int) java.lang.Math.round(
    FRAME_FIXED_STEP_SECONDS * 1000.0);
  verify("idle para walk registra o tempo lógico confirmado",
    first.states[1] == PLAYER_ANIM_WALK
      && first.started_at[1] == walk_started
      && first.started_at[2] == walk_started);
  verify("corrida e escada reiniciam o take somente nas transições",
    first.states[3] == (player_has_run ? PLAYER_ANIM_RUN : PLAYER_ANIM_WALK)
      && first.started_at[4] == first.started_at[3]
      && (!player_has_climb
        || (first.states[5] == PLAYER_ANIM_CLIMB
          && first.moving[5] && !first.moving[7]
          && first.started_at[7] > first.started_at[6]))
      && (!player_has_jump
        || (first.states[8] == PLAYER_ANIM_JUMP
          && first.started_at[8] > first.started_at[7]))
      && first.states[10] == PLAYER_ANIM_IDLE
      && (!player_has_jump
        || first.started_at[10] > first.started_at[9]));
  verify("relógio fake repete os mesmos takes, quadros e instantes",
    samePlayerAnimationSequence(first, second));
  verify("consultas repetidas preservam o take e seu início lógico",
    first.render_queries_pure);

  player_anim_state = previous_state;
  player_animation_moving = previous_moving;
  player_animation_started_at = previous_started_at;
  player_grounded = previous_grounded;
  player_on_ladder = previous_on_ladder;
  move_left_held = previous_left;
  move_right_held = previous_right;
  move_up_held = previous_up;
  move_down_held = previous_down;
  run_held = previous_run;
}


void checkPlayerAnimationLayerCache(){
  if (!player_assets_loaded){
    verify("spritesheet do jogador carregada", false);
    return;
  }

  int previous_facing = player_facing;
  long queries_before = player_frame_layer_queries;
  long reuses_before = player_frame_layer_reuses;
  int selected_frame = playerCurrentFrame();
  player_rendered_frame = -1;
  player_rendered_facing = 0;
  boolean first_ready = updatePlayerFrameLayer(selected_frame);
  long rebuilds_after_selection = player_frame_layer_rebuilds;

  FrameContext previous_context = current_frame_context;
  FrameContext callback_without_steps = new FrameContext(
    FRAME_FIXED_STEP_SECONDS, 0.0, 0.0, 0.0, 0.0, 0.0,
    frame_clock.simulationTimeSeconds(), frame_clock.confirmedStateVersion(),
    0, false, "harness", "capture",
    previous_context == null ? 1 : previous_context.callback_id + 1,
    screen, current_room, uiLayer(), doorTransitionActive(), "");
  callback_without_steps.presentation_time_ms = 999999;
  current_frame_context = callback_without_steps;
  updatePlayerFrameLayer(selected_frame);

  FrameContext callback_with_steps = new FrameContext(
    FRAME_FIXED_STEP_SECONDS, 0.0, FRAME_FIXED_STEP_SECONDS,
    FRAME_FIXED_STEP_SECONDS, 0.0, 0.0,
    frame_clock.simulationTimeSeconds(), frame_clock.confirmedStateVersion(),
    3, false, "harness", "capture", callback_without_steps.callback_id + 1,
    screen, current_room, uiLayer(), doorTransitionActive(), "");
  callback_with_steps.steps_executed = 3;
  current_frame_context = callback_with_steps;
  updatePlayerFrameLayer(selected_frame);
  current_frame_context = previous_context;

  verify("cache registra consultas e reutiliza sem passo ou por callback",
    first_ready && player_frame_layer_queries - queries_before == 3
      && player_frame_layer_reuses - reuses_before == 2
      && player_frame_layer_rebuilds == rebuilds_after_selection);

  int changed_frame = selected_frame == player_idle_start
    ? player_walk_start : player_idle_start;
  if (changed_frame == selected_frame){
    changed_frame = selected_frame < player_frame_images.length - 1
      ? selected_frame + 1 : selected_frame - 1;
  }
  long before_frame_change = player_frame_layer_rebuilds;
  updatePlayerFrameLayer(changed_frame);
  long after_frame_change = player_frame_layer_rebuilds;
  updatePlayerFrameLayer(changed_frame);
  player_facing = previous_facing == 1 ? -1 : 1;
  updatePlayerFrameLayer(changed_frame);
  verify("cache reconstrói apenas após mudança de quadro ou direção",
    after_frame_change == before_frame_change + 1
      && player_frame_layer_rebuilds == after_frame_change + 1);

  player_facing = previous_facing;
  updatePlayerFrameLayer(selected_frame);
}


boolean samePixels(PImage a, PImage b){
  if (a == null || b == null || a.width != b.width || a.height != b.height){
    return false;
  }

  a.loadPixels();
  b.loadPixels();

  for (int i = 0; i < a.pixels.length; i++){
    if (a.pixels[i] != b.pixels[i]){
      return false;
    }
  }

  return true;
}


void checkPlayerRun(){
  if (!player_assets_loaded){
    verify("spritesheet do jogador carregada", false);
    return;
  }

  boolean has_run_take = player_has_run;
  resetRun();
  event_open = false;
  enterRoom(SCREEN_COMMAND);
  move_right_held = true;

  float start_x = player_x;
  updatePlayerOnDeck(movementHarnessStepContext());
  float walk_step = player_x - start_x;

  player_x = start_x;
  run_held = true;
  updatePlayerOnDeck(movementHarnessStepContext());
  float run_step = player_x - start_x;

  verify("shift acelera o passo no convés",
    abs(walk_step - PLAYER_SPEED) <= 0.001 && abs(run_step - PLAYER_RUN_SPEED) <= 0.001);

  player_x = start_x;
  player_has_run = false;
  updatePlayerOnDeck(movementHarnessStepContext());
  confirmPlayerAnimationStateInHarness();
  verify("sem faixa de corrida o passo acelera do mesmo jeito",
    abs((player_x - start_x) - PLAYER_RUN_SPEED) <= 0.001
      && playerCurrentAnimationState() == PLAYER_ANIM_WALK);
  player_has_run = has_run_take;

  player_x = start_x;
  confirmPlayerAnimationStateInHarness();
  int start_frame = playerCurrentFrameAt(player_animation_started_at / 1000.0);
  if (has_run_take){
    verify("corrida anima a faixa carregada",
      playerCurrentAnimationState() == PLAYER_ANIM_RUN
        && start_frame == player_run_start
        && player_run_end - player_run_start == 7);

    int run_started_at = player_animation_started_at;
    verify("a corrida avança um quadro a cada 75 ms",
      playerCurrentFrameAt((run_started_at + 76) / 1000.0)
        == player_run_start + 1);

    verify("a corrida fecha o ciclo de 8 quadros",
      playerCurrentFrameAt((run_started_at + 600) / 1000.0)
        == player_run_start);
  } else {
    verify("corrida sem faixa usa o take de caminhada",
      playerCurrentAnimationState() == PLAYER_ANIM_WALK
        && start_frame >= player_walk_start
        && start_frame <= player_walk_end);
  }

  if (has_run_take && player_sheet != null && player_sheet.height >= 42 * 64){
    verify("a faixa de corrida sai dos 8 quadros da linha 41",
      samePixels(player_frame_images[player_run_start], player_sheet.get(0, 41 * 64, 64, 64))
        && !samePixels(player_frame_images[player_run_start], player_sheet.get(0, 11 * 64, 64, 64)));
  }

  run_held = false;
  confirmPlayerAnimationStateInHarness();
  int walk_frame = playerCurrentFrameAt(player_animation_started_at / 1000.0);
  verify("soltar o shift volta para a caminhada",
    playerCurrentAnimationState() == PLAYER_ANIM_WALK
      && walk_frame >= player_walk_start && walk_frame <= player_walk_end);

  run_held = true;
  move_right_held = false;
  confirmPlayerAnimationStateInHarness();
  verify("shift parado não corre no lugar", playerCurrentAnimationState() == PLAYER_ANIM_IDLE);

  move_right_held = true;
  player_on_ladder = true;
  player_grounded = false;
  confirmPlayerAnimationStateInHarness();
  verify("shift não interfere na escada",
    playerCurrentAnimationState() == (player_has_climb ? PLAYER_ANIM_CLIMB : PLAYER_ANIM_WALK));
  player_on_ladder = false;

  confirmPlayerAnimationStateInHarness();
  verify("shift não troca a animação do pulo",
    playerCurrentAnimationState() == (player_has_jump ? PLAYER_ANIM_JUMP : PLAYER_ANIM_WALK));

  player_grounded = true;
  player_x = start_x;
  jump_queued = true;
  updatePlayerOnDeck(movementHarnessStepContext());
  confirmPlayerAnimationStateInHarness();
  verify("no quadro da decolagem o passo já é o do ar",
    abs((player_x - start_x) - PLAYER_SPEED) <= 0.001
      && playerCurrentAnimationState() == (player_has_jump ? PLAYER_ANIM_JUMP : PLAYER_ANIM_WALK));

  jump_queued = false;
  move_right_held = false;
  resetRun();
  player_has_run = has_run_take;
  event_open = false;
}


void confirmPlayerAnimationStateInHarness(){
  FrameContext context = movementHarnessStepContext();
  updatePlayerAnimationState(context);
  context.confirmStep(0.0,
    context.simulation_time_seconds + context.fixed_step_seconds,
    context.confirmed_state_version + 1);
}



void checkPlayerFootsteps(){
  resetRun();
  if (sound_walk_step[0] == null || sound_run_step[0] == null){
    println("audio footsteps: INCONCLUSIVE — backend de áudio indisponível");
    return;
  }
  enterRoom(SCREEN_COMMAND);
  move_right_held = true;
  verify("caminhada usa take de ataque único",
    sound_walk_step[0] != null && sound_run_step[0] != null
      && sound_walk_step[0].getMicrosecondLength() <= 15000
      && sound_run_step[0].getMicrosecondLength() > sound_walk_step[0].getMicrosecondLength());

  int before_walk = sound_step_play_count;
  updatePlayerOnDeck(movementHarnessStepContext());
  verify("caminhada toca o primeiro passo",
    sound_step_play_count == before_walk + 1);
  for (int frame = 0; frame < 23; frame++){
    updatePlayerOnDeck(movementHarnessStepContext());
  }
  verify("caminhada não antecipa o contato do pé",
    sound_step_play_count == before_walk + 1);
  updatePlayerOnDeck(movementHarnessStepContext());
  verify("caminhada toca após 24 unidades simuladas",
    sound_step_play_count == before_walk + 2);

  resetRun();
  enterRoom(SCREEN_COMMAND);
  move_right_held = true;
  run_held = true;
  int before_run = sound_step_play_count;
  updatePlayerOnDeck(movementHarnessStepContext());
  for (int frame = 0; frame < 11; frame++){
    updatePlayerOnDeck(movementHarnessStepContext());
  }
  verify("corrida acelera a cadência dos passos",
    sound_step_play_count == before_run + 2);

  resetRun();
  enterRoom(SCREEN_COMMAND);
  move_right_held = false;
  int before_jump = sound_step_play_count;
  jump_queued = true;
  updatePlayerOnDeck(movementHarnessStepContext());
  jump_queued = false;
  verify("pulo toca a decolagem",
    sound_step_play_count == before_jump + 1);

  for (int frame = 0; frame < 64 && !player_grounded; frame++){
    updatePlayerOnDeck(movementHarnessStepContext());
  }
  verify("pulo toca a aterrissagem",
    player_grounded && sound_step_play_count == before_jump + 2);

  resetRun();
}
void checkDoorTraversalArt(){
  int door = doorInRoomLeadingTo(SCREEN_COMMAND, SCREEN_MACHINES);
  clearDoorArt();
  resetRun();
  event_open = false;
  enterRoom(SCREEN_COMMAND);
  placePlayerAtDoor(door);
  art_door_frames[0] = createGraphics(64, 128);
  art_door_frames[1] = createGraphics(64, 128);

  verify("arte da porta assume a travessia em dois quadros",
    doorFrame(door) != null && useNearbyDoor()
    && screen == SCREEN_COMMAND && doorTransitionActive());

  enterRoomThroughDoor(door);
  verify("reentrada durante abertura é ignorada",
    screen == SCREEN_COMMAND && doorTransitionActive()
    && door_transition_target == SCREEN_MACHINES);

  FrameContext previous_context = current_frame_context;
  FrameContext single_update_context = new FrameContext(
    FRAME_FIXED_STEP_SECONDS, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0, 0, true, "harness", "capture", 8401,
    screen, current_room, uiLayer(), doorTransitionActive(), "");
  current_frame_context = single_update_context;
  door_transition_started = millis();
  updateDoorTransition();
  boolean duplicate_update_rejected = false;
  try {
    updateDoorTransition();
  } catch (IllegalStateException expected){
    duplicate_update_rejected = true;
  } finally {
    current_frame_context = previous_context;
  }
  verify("segunda atualização da porta no callback é rejeitada sem troca de sala",
    duplicate_update_rejected
      && single_update_context.door_transition_update_count == 2
      && screen == SCREEN_COMMAND && doorTransitionActive()
      && door_transition_target == SCREEN_MACHINES);

  door_transition_started = millis() - ART_DOOR_PHASE_MS - 1;
  FrameContext opening_tick = advanceDoorTransitionInHarness();
  verify("travessia troca de sala com o quadro aberto",
    screen == SCREEN_MACHINES && doorTransitionActive()
      && opening_tick.door_transition_update_count == 1
      && opening_tick.steps_executed == 0);

  int return_door = doorInRoomLeadingTo(SCREEN_MACHINES, SCREEN_COMMAND);
  placePlayerAtDoor(return_door);
  enterRoomThroughDoor(return_door);
  verify("reentrada durante fechamento é ignorada",
    screen == SCREEN_MACHINES && doorTransitionActive()
    && door_transition_door == return_door);

  door_transition_started = millis() - ART_DOOR_PHASE_MS - 1;
  FrameContext closing_tick = advanceDoorTransitionInHarness();
  verify("travessia fecha o quadro ao chegar",
    !doorTransitionActive() && screen == SCREEN_MACHINES
      && closing_tick.door_transition_update_count == 1
      && closing_tick.steps_executed == 0);

  restoreDoorArt();
}


FrameContext advanceDoorTransitionInHarness(){
  FrameContext previous_context = current_frame_context;
  long callback_id = previous_context == null ? 1 : previous_context.callback_id + 1;
  FrameContext transition_context = new FrameContext(FRAME_FIXED_STEP_SECONDS,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, true,
    "harness", "capture", callback_id, screen, current_room, uiLayer(),
    doorTransitionActive(), "");
  transition_context.presentation_time_ms = millis();
  current_frame_context = transition_context;
  try {
    updateDoorTransition();
  }
  finally {
    transition_context.refreshDomainState(screen, current_room, uiLayer(),
      true, doorTransitionActive());
    transition_context.finishCallback();
    current_frame_context = previous_context;
  }
  return transition_context;
}


void checkConnectedDoors(){
  clearDoorArt();

  for (int door = 0; door < DOOR_COUNT; door++){
    resetRun();
    event_open = false;
    enterRoom(door_room[door]);
    placePlayerAtDoor(door);
    int target = door_target[door];
    verify("porta " + door + " reconhece o limiar configurado",
      doorInRange(door));
    float departure_x = player_x + PLAYER_W / 2.0;
    float departure_y = player_y + PLAYER_H;
    verify("preparação resolve saída, chegada e retorno antes da execução",
      preparePortalTransition(door)
      && abs(portal_prepared_departure_x - departure_x) <= 0.1
      && abs(portal_prepared_departure_y - departure_y) <= 0.1
      && portal_prepared_target_room == target
      && portal_prepared_return_door == doorInRoomLeadingTo(target, door_room[door])
      && !doorTransitionActive());
    clearPreparedPortalTransition();
    verify("porta " + door + " leva a " + roomTitle(target),
      useNearbyDoor() && screen == target);
    verify("chegada usa coordenada e direção configuradas",
      abs(player_x + PLAYER_W / 2.0 - door_arrival_x[door]) <= 0.1
    && abs(player_y + PLAYER_H - door_arrival_y[door]) <= 0.1
    && player_facing == door_arrival_facing[door]);
  }

  final int invalid_door = 0;
  int saved_invalid_target = door_target[invalid_door];
  resetRun();
  enterRoom(door_room[invalid_door]);
  placePlayerAtDoor(invalid_door);
  door_target[invalid_door] = SCREEN_NONE;
  verify("destino inválido mantém a sala e limpa a preparação",
    !preparePortalTransition(invalid_door)
    && screen == door_room[invalid_door]
    && !portal_transition_prepared);
  door_target[invalid_door] = saved_invalid_target;

  int outbound = doorInRoomLeadingTo(SCREEN_COMMAND, SCREEN_MACHINES);
  int inbound = doorInRoomLeadingTo(SCREEN_MACHINES, SCREEN_COMMAND);
  int saved_return_target = door_target[inbound];
  resetRun();
  enterRoom(SCREEN_COMMAND);
  placePlayerAtDoor(outbound);
  door_target[inbound] = SCREEN_NONE;
  verify("retorno ausente mantém a sala e limpa a preparação",
    !preparePortalTransition(outbound)
    && screen == SCREEN_COMMAND && !portal_transition_prepared);
  door_target[inbound] = saved_return_target;

  resetRun();
  enterRoom(SCREEN_COMMAND);
  placePlayerAtDoor(outbound);
  float entered_center_x = player_x + PLAYER_W / 2.0;
  float entered_feet_y = player_y + PLAYER_H;
  verify("porta de Máquinas abre a sala correta",
    useNearbyDoor() && screen == SCREEN_MACHINES);
  placePlayerAtDoor(inbound);
  verify("retorno da porta usa a posição de entrada",
    useNearbyDoor() && screen == SCREEN_COMMAND
    && abs(player_x + PLAYER_W / 2.0 - entered_center_x) <= 0.1
    && abs(player_y + PLAYER_H - entered_feet_y) <= 0.1);

  checkDoorAnywhere();
  restoreDoorArt();
}




void placePlayerAtDoor(int door){
  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  player_x = constrain(door_x[door] - PLAYER_W / 2.0,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
  player_y = door_y[door] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = isDeckSurface(door_y[door]);
  player_on_ladder = false;
}


void checkDoorAnywhere(){
  clearDoorArt();
  final int door = 1;
  float saved_x = door_x[door];
  float saved_y = door_y[door];
  int saved_deck = door_deck[door];
  int saved_target = door_target[door];
  float saved_arrival_x = door_arrival_x[door];
  float saved_arrival_y = door_arrival_y[door];
  int saved_arrival_facing = door_arrival_facing[door];
  float test_x = 320;
  float test_y = deck_y[1] - 20;
  float test_arrival_x = ROOM_RIGHT - 40;
  float test_arrival_y = deck_y[0];

  door_x[door] = test_x;
  door_y[door] = test_y;
  door_deck[door] = DOOR_DECK_NONE;
  door_target[door] = SCREEN_DORMITORY;
  door_arrival_x[door] = test_arrival_x;
  door_arrival_y[door] = test_arrival_y;
  door_arrival_facing[door] = -1;

  resetRun();
  event_open = false;
  enterRoom(door_room[door]);
  placePlayerAtDoor(door);
  verify("porta em abertura fora de deck interage no limiar",
    doorInRange(door) && useNearbyDoor() && screen == door_target[door]);
  verify("chegada independente coloca no canto configurado",
    abs(player_x + PLAYER_W / 2.0 - test_arrival_x) <= 0.1
    && abs(player_y + PLAYER_H - test_arrival_y) <= 0.1
    && player_facing == -1);

  resetRun();
  event_open = false;
  enterRoom(door_room[door]);
  player_x = test_x - PLAYER_W / 2.0;
  player_y = test_y - PLAYER_H + DOOR_VERTICAL_RANGE + 1;
  player_velocity_y = 0;
  player_grounded = false;
  verify("distância vertical fora do limiar não abre a porta",
    !doorInRange(door));

  int saved_hull_room = point_room[POINT_HULL];
  float saved_hull_x = point_x[POINT_HULL];
  float saved_hull_y = point_y[POINT_HULL];
  int saved_active_quest = active_quest;
  int saved_quest_stage = quest_stage;
  int saved_held_item = held_item;
  boolean saved_quest_completed = quest_completed;
  boolean saved_technical_open = technical_open;
  int saved_pending_action = pending_quest_action;

  resetRun();
  point_room[POINT_HULL] = SCREEN_COMMAND;
  point_x[POINT_HULL] = door_x[2];
  point_y[POINT_HULL] = door_y[2];
  active_quest = PREVENTIVE_COUNT + PROBLEM_HULL * 2;
  quest_stage = QUEST_DELIVER;
  held_item = active_quest + 1;
  enterRoom(SCREEN_COMMAND);
  setCapturePlayerAtPoint(POINT_HULL);
  interact_queued = true;
  updateRoom(movementHarnessStepContext());
  verify("ponto de quest vence portal coincidente",
    screen == SCREEN_COMMAND && technical_open
    && pending_quest_action == ACTION_DELIVER_QUEST);

  point_room[POINT_HULL] = saved_hull_room;
  point_x[POINT_HULL] = saved_hull_x;
  point_y[POINT_HULL] = saved_hull_y;
  active_quest = saved_active_quest;
  quest_stage = saved_quest_stage;
  held_item = saved_held_item;
  quest_completed = saved_quest_completed;
  technical_open = saved_technical_open;
  pending_quest_action = saved_pending_action;
  door_x[door] = saved_x;
  door_y[door] = saved_y;
  door_deck[door] = saved_deck;
  door_target[door] = saved_target;
  door_arrival_x[door] = saved_arrival_x;
  door_arrival_y[door] = saved_arrival_y;
  door_arrival_facing[door] = saved_arrival_facing;
  restoreDoorArt();
}
void runHitTest(){
  resetRun();
  enterRoom(SCREEN_COMMAND);
  map_open = true;
  drawBase();
  println("hit-test: janela " + width + "x" + height + " | escala " + view_scale
    + " | offset " + int(view_offset_x) + "," + int(view_offset_y));

  for (int i = 0; i < ROOM_COUNT; i++){
    int before_screen = screen;
    float room_cx = room_x[i] + room_w[i] / 2.0;
    float room_cy = room_y[i] + room_h[i] / 2.0;
    mouseX = int(room_cx * RENDER_SCALE * view_scale + view_offset_x);
    mouseY = int(room_cy * RENDER_SCALE * view_scale + view_offset_y);
    mouse_pressed = true;
    updateInput();
    verify("hit-test imagem inerte " + room_label[i],
      screen == before_screen && map_open);
  }

  mouseX = 4;
  mouseY = 4;
  mouse_pressed = true;
  updateInput();
  verify("hit-test letterbox preserva mapa", map_open && screen == SCREEN_COMMAND);
  restoreVerificationFixture();
  exit();
}


void runLadderTest(){
  resetRun();
  enterRoom(SCREEN_MACHINES);
  float middle_y = deck_y[1] - PLAYER_H;
  float ladder_player_x = ladderX(SCREEN_MACHINES, 0) - PLAYER_W / 2.0;
  testLadderLateralExit(middle_y, ladder_player_x);
  testLadderCrossingExit(middle_y, ladder_player_x);
  testLadderStableExit(middle_y);
  drawBase();
  base.save(verificationOutputPath("ladder", "middle_exit", RENDER_W, RENDER_H));
  testLadderReleaseRearms();
  testLadderIdleSnap(middle_y, ladder_player_x);
  checkLadderAnywhere();
  restoreVerificationFixture();
  exit();
}


void checkLadderAnywhere(){
  int index = -1;

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] == SCREEN_MACHINES && index < 0) index = i;
  }

  float saved_x = ladder_x[index];
  float test_x = 320;
  ladder_x[index] = test_x;
  enterRoom(SCREEN_MACHINES);
  player_x = test_x - PLAYER_W / 2.0;
  player_y = deck_y[1] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  move_down_held = true;
  updatePlayerOnDeck(movementHarnessStepContext());
  move_down_held = false;
  verify("escada fora das posições fixas é reconhecida",
    player_on_ladder && abs(player_x - (test_x - PLAYER_W / 2.0)) < 0.01);
  ladder_x[index] = saved_x;
  enterRoom(SCREEN_MACHINES);
}


void testLadderLateralExit(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y + 2.5);
  move_right_held = true;
  move_up_held = false;
  move_down_held = false;
  updatePlayerOnLadder(movementHarnessStepContext());
  verify("ladder saída lateral", ladderExitAtMiddle(middle_y, ladder_player_x));
}


void testLadderCrossingExit(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y - 0.5);
  move_right_held = true;
  move_down_held = true;
  updatePlayerOnLadder(movementHarnessStepContext());
  verify("ladder travessia lateral", ladderExitAtMiddle(middle_y, ladder_player_x));
}


boolean ladderExitAtMiddle(float middle_y, float ladder_player_x){
  return !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01 && player_x > ladder_player_x;
}


void testLadderStableExit(float middle_y){
  move_right_held = false;
  float exit_x = player_x;
  updatePlayerOnDeck(movementHarnessStepContext());
  verify("ladder não reentra com direção mantida", !player_on_ladder
    && player_grounded && abs(player_y - middle_y) < 0.01
    && abs(player_x - exit_x) < 0.01);
}


void testLadderReleaseRearms(){
  move_down_held = false;
  updatePlayerOnDeck(movementHarnessStepContext());
  move_down_held = true;
  updatePlayerOnDeck(movementHarnessStepContext());
  verify("ladder rearma após soltar", player_on_ladder);
}


void testLadderIdleSnap(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y + 2.5);
  move_right_held = false;
  move_down_held = false;
  updatePlayerOnLadder(movementHarnessStepContext());
  verify("ladder encaixa no convés", !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01);
}


void placeLadderTestPlayer(float x, float y){
  player_x = x;
  player_y = y;
  player_on_ladder = true;
  player_grounded = false;
}


void setCapturePlayerAtPoint(int point){
  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  player_x = point_x[point] - PLAYER_W / 2.0;
  player_y = point_y[point] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
}


void clickAction(int action){
  drawBase();
  for (int i = 0; i < button_count; i++){
    if (button_action[i] == action && button_on[i] && button_layer[i] == uiLayer()){
      handleClick(button_x[i], button_y[i]);
      drawBase();
      return;
    }
  }
  println("capture: botão " + action + " indisponível -> FALHOU");
}
final int[] PERFORMANCE_CADENCE_SEQUENCE = {15, 30, 60};
boolean performance_observer_installed = false;
boolean performance_sample_finish_pending = false;
int performance_cadence_fps = 60;
long performance_sample_start_audio_failures = 0;
boolean performance_fake_clock_installed = false;
ProfileCadenceFrameClockSource performance_fake_clock;
java.util.ArrayList<FrameContext> performance_temporal_callbacks =
  new java.util.ArrayList<FrameContext>();
float[] performance_temporal_callback_ms;
float[] performance_temporal_simulation_ms;
float[] performance_temporal_render_ms;
float[] performance_temporal_draw_base_ms;
float[] performance_temporal_draw_window_ms;
float[] performance_temporal_audio_dispatch_ms;
int performance_temporal_metric_count = 0;
float performance_temporal_distance_px = 0.0f;
float performance_temporal_previous_x = 0.0f;
float performance_temporal_previous_y = 0.0f;
String performance_temporal_clock_status = "PASS";
String performance_temporal_audio_status = "PASS";
String performance_temporal_asset_status = "PASS";
String performance_temporal_cache_status = "PASS";


void recordPerformanceCallback(FrameContext context){
  if (context == null || performance_sample_started_nanos <= 0
    || context.callback_started_nanos < performance_sample_started_nanos){
    return;
  }

  boolean phaseMetricsAvailable = context.callback_duration_nanos > 0
    && context.simulation_duration_nanos >= 0
    && context.render_duration_nanos > 0
    && context.draw_base_duration_nanos >= 0
    && context.draw_window_duration_nanos >= 0
    && context.audio_dispatch_duration_nanos >= 0;
  if (!phaseMetricsAvailable){
    performance_temporal_clock_status = "INCONCLUSIVO";
  }
  if (context.diagnostic != null && context.diagnostic.length() > 0
    && !context.diagnostic.startsWith("primeira leitura do relógio")){
    performance_temporal_clock_status = "FAIL";
  }
  if (frame_audio_diagnostic != null && frame_audio_diagnostic.length() > 0){
    performance_temporal_audio_status = "FAIL";
  }
  if (movement_audio_playback_failure_count > performance_sample_start_audio_failures){
    performance_temporal_audio_status = "FAIL";
  }
  if (audio_loaded < audio_expected){
    if (!"FAIL".equals(performance_temporal_audio_status)){
      performance_temporal_audio_status = "INCONCLUSIVO";
    }
  }
  if (art_load_ms < 0 || art_loaded < 0){
    performance_temporal_asset_status = "INCONCLUSIVO";
  }
  if (!cacheMetricsAvailable()){
    performance_temporal_cache_status = "INCONCLUSIVO";
  }

  float distance = dist(performance_temporal_previous_x,
    performance_temporal_previous_y, player_x, player_y);
  performance_temporal_previous_x = player_x;
  performance_temporal_previous_y = player_y;
  performance_temporal_distance_px += distance;

  if (performance_temporal_metric_count >= performance_temporal_callback_ms.length){
    performance_temporal_clock_status = "INCONCLUSIVO";
  } else {
    int index = performance_temporal_metric_count;
    context.distance_delta_px = distance;
    performance_temporal_callbacks.add(context);
    performance_temporal_callback_ms[index] = context.callback_duration_nanos / 1000000.0f;
    performance_temporal_simulation_ms[index] = context.simulation_duration_nanos / 1000000.0f;
    performance_temporal_render_ms[index] = context.render_duration_nanos / 1000000.0f;
    performance_temporal_draw_base_ms[index] = context.draw_base_duration_nanos / 1000000.0f;
    performance_temporal_draw_window_ms[index] = context.draw_window_duration_nanos / 1000000.0f;
    performance_temporal_audio_dispatch_ms[index] = context.audio_dispatch_duration_nanos / 1000000.0f;
    performance_temporal_metric_count++;
  }

  if (performance_sample_finish_pending){
    finishPerformanceSample(System.nanoTime());
  }
}


float temporalP95(float[] values, int count){
  if (values == null || count <= 0 || count > values.length) return -1.0f;
  float[] ordered = new float[count];
  java.lang.System.arraycopy(values, 0, ordered, 0, count);
  ordered = sort(ordered);
  int percentileIndex = java.lang.Math.max(0,
    (int) java.lang.Math.ceil(ordered.length * 0.95) - 1);
  return ordered[percentileIndex];
}


JSONObject temporalCallbackRow(FrameContext context){
  JSONObject row = new JSONObject();
  row.setLong("callback", context.callback_id);
  row.setInt("active_screen", context.active_screen);
  row.setInt("active_room", context.active_room);
  row.setInt("ui_layer", context.ui_layer);
  row.setBoolean("paused", context.paused);
  row.setString("clock_origin", context.clock_origin);
  row.setString("harness_mode", context.harness_mode);
  row.setFloat("observed_delta_seconds", (float) context.observed_seconds);
  row.setInt("steps_planned", context.steps_planned);
  row.setInt("steps_executed", context.steps_executed);
  row.setInt("last_executed_step", context.last_executed_step);
  row.setFloat("accepted_seconds", (float) context.accepted_seconds);
  row.setFloat("remaining_seconds", (float) context.accumulator_after);
  row.setFloat("discarded_seconds", (float) context.discarded_seconds);
  row.setFloat("distance_delta_px", context.distance_delta_px);
  row.setBoolean("jump_edge_consumed", context.jump_action_consumed);
  row.setInt("jump_edge_step", context.jump_action_step);
  row.setBoolean("interact_edge_consumed", context.interact_action_consumed);
  row.setInt("interact_edge_step", context.interact_action_step);
  row.setBoolean("door_transition_active", context.door_transition_active);
  row.setInt("door_transition_update_count", context.door_transition_update_count);
  row.setLong("confirmed_state_version", context.confirmed_state_version);
  row.setFloat("callback_time_ms", context.callback_duration_nanos / 1000000.0f);
  row.setFloat("simulation_time_ms", context.simulation_duration_nanos / 1000000.0f);
  row.setFloat("render_time_ms", context.render_duration_nanos / 1000000.0f);
  row.setFloat("draw_base_time_ms", context.draw_base_duration_nanos / 1000000.0f);
  row.setFloat("draw_window_time_ms", context.draw_window_duration_nanos / 1000000.0f);
  row.setFloat("audio_dispatch_time_ms", context.audio_dispatch_duration_nanos / 1000000.0f);

  JSONArray events = new JSONArray();
  if (context.logical_audio_events != null){
    for (MovementAudioEvent event : context.logical_audio_events){
      JSONObject eventRow = new JSONObject();
      eventRow.setString("family", event.family);
      eventRow.setInt("variant", event.variant);
      eventRow.setFloat("logical_timestamp_seconds", (float) event.logical_timestamp_seconds);
      eventRow.setLong("global_order", event.global_order);
      eventRow.setInt("step_index", event.step_index);
      events.append(eventRow);
    }
  }
  row.setJSONArray("logical_events", events);
  return row;
}


JSONObject performanceTemporalSidecar(String sampleId, float durationSeconds){
  JSONObject temporal = new JSONObject();
  temporal.setString("schema", "frame-temporal-profile-v1");
  temporal.setString("version", performance_version);
  temporal.setString("profile", performance_profile);
  temporal.setString("scenario", PERFORMANCE_SCENARIO_ID);
  temporal.setString("sample_id", sampleId);
  temporal.setInt("cadence_fps", performance_cadence_fps);
  temporal.setFloat("duration_real_s", durationSeconds);
  temporal.setInt("callback_count", performance_temporal_callbacks.size());
  JSONArray callbackRows = new JSONArray();
  JSONArray deltaSequence = new JSONArray();
  JSONArray stepSequence = new JSONArray();
  JSONArray acceptedSequence = new JSONArray();
  JSONArray remainingSequence = new JSONArray();
  JSONArray discardedSequence = new JSONArray();
  for (FrameContext callback : performance_temporal_callbacks){
    callbackRows.append(temporalCallbackRow(callback));
    deltaSequence.append((float) callback.observed_seconds);
    stepSequence.append(callback.steps_executed);
    acceptedSequence.append((float) callback.accepted_seconds);
    remainingSequence.append((float) callback.accumulator_after);
    discardedSequence.append((float) callback.discarded_seconds);
  }
  temporal.setJSONArray("callbacks", callbackRows);
  temporal.setJSONArray("delta_sequence_seconds", deltaSequence);
  temporal.setJSONArray("step_sequence", stepSequence);
  temporal.setJSONArray("accepted_sequence_seconds", acceptedSequence);
  temporal.setJSONArray("remaining_sequence_seconds", remainingSequence);
  temporal.setJSONArray("discarded_sequence_seconds", discardedSequence);
  temporal.setFloat("distance_px", performance_temporal_distance_px);

  float callbackP95 = temporalP95(performance_temporal_callback_ms, performance_temporal_metric_count);
  float simulationP95 = temporalP95(performance_temporal_simulation_ms, performance_temporal_metric_count);
  float renderP95 = temporalP95(performance_temporal_render_ms, performance_temporal_metric_count);
  float drawBaseP95 = temporalP95(performance_temporal_draw_base_ms, performance_temporal_metric_count);
  float drawWindowP95 = temporalP95(performance_temporal_draw_window_ms, performance_temporal_metric_count);
  float audioDispatchP95 = temporalP95(performance_temporal_audio_dispatch_ms, performance_temporal_metric_count);
  if (callbackP95 >= 0) temporal.setFloat("callback_time_p95_ms", callbackP95);
  if (simulationP95 >= 0) temporal.setFloat("simulation_time_p95_ms", simulationP95);
  if (renderP95 >= 0) temporal.setFloat("render_time_p95_ms", renderP95);
  if (drawBaseP95 >= 0) temporal.setFloat("draw_base_time_p95_ms", drawBaseP95);
  if (drawWindowP95 >= 0) temporal.setFloat("draw_window_time_p95_ms", drawWindowP95);
  if (audioDispatchP95 >= 0) temporal.setFloat("audio_dispatch_time_p95_ms", audioDispatchP95);

  JSONObject statuses = new JSONObject();
  statuses.setString("clock", performance_temporal_clock_status);
  statuses.setString("audio", performance_temporal_audio_status);
  statuses.setString("asset", performance_temporal_asset_status);
  statuses.setString("cache", performance_temporal_cache_status);
  temporal.setJSONObject("statuses", statuses);
  String overallStatus = statuses.getString("clock").equals("FAIL")
    || statuses.getString("audio").equals("FAIL")
    || statuses.getString("asset").equals("FAIL")
    || statuses.getString("cache").equals("FAIL")
      ? "FAIL" : "PASS";
  if (performance_temporal_callbacks.size() != performance_sample_frames
    || performance_temporal_metric_count != performance_sample_frames
    || callbackP95 < 0 || simulationP95 < 0 || renderP95 < 0 || drawBaseP95 < 0
    || drawWindowP95 < 0 || audioDispatchP95 < 0
    || statuses.getString("clock").equals("INCONCLUSIVO")
    || statuses.getString("audio").equals("INCONCLUSIVO")
    || statuses.getString("asset").equals("INCONCLUSIVO")
    || statuses.getString("cache").equals("INCONCLUSIVO")){
    if (!"FAIL".equals(overallStatus)) overallStatus = "INCONCLUSIVO";
  }
  temporal.setString("status", overallStatus);
  return temporal;
}


void pressEnter(){
  enter_pressed = true;
  updateInput();
  if (isRoomScreen()){
    updateRoom(movementHarnessStepContext());
  }
}


void typeText(String value){
  for (int i = 0; i < value.length(); i++){
    handleChar(value.charAt(i));
  }
}


void verify(String label, boolean passed){
  println("verify: " + label + " -> " + (passed ? "OK" : "FALHOU"));
  if (!passed){
    checks_failed = true;
    restoreVerificationFixture();
    exit();
  }
}

String screenName(){
  if (screen == SCREEN_INIT) return "menu_init";
  if (screen == SCREEN_VIGNETTE) return "vinheta";
  if (screen == SCREEN_COMMAND) return "sala_comando";
  if (screen == SCREEN_MACHINES) return "sala_maquinas";
  if (screen == SCREEN_DEPOT) return "deposito";
  if (screen == SCREEN_DORMITORY) return "dormitorio";
  if (screen == SCREEN_VICTORY) return "vitoria";
  if (screen == SCREEN_GAME_OVER) return "derrota";
  return "desconhecida";
}
