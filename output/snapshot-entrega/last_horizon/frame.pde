final double FRAME_FIXED_STEP_SECONDS = 1.0 / 60.0;
final int FRAME_MAX_STEPS_PER_CALLBACK = 4;
final double FRAME_MAX_ACCUMULATOR_SECONDS = FRAME_FIXED_STEP_SECONDS * FRAME_MAX_STEPS_PER_CALLBACK;
final double FRAME_STEP_EPSILON_SECONDS = 0.0000001;


interface FrameClockSource {
  double readSeconds();
  String origin();
}


interface FrameCallbackObserver {
  void onCallbackComplete(FrameContext context);
}


class FrameInputSnapshot {
  public final int mouse_x;
  public final int mouse_y;
  public final boolean mouse_pressed;
  public final boolean esc_pressed;
  public final boolean enter_pressed;
  public final boolean backspace_pressed;
  public final boolean key_char_pressed;
  public final char key_char;
  public final boolean move_left_held;
  public final boolean move_right_held;
  public final boolean move_up_held;
  public final boolean move_down_held;
  public final boolean run_held;
  public final boolean jump_queued;
  public final boolean interact_queued;

  FrameInputSnapshot(int mouseX, int mouseY, boolean mousePressed,
    boolean escPressed, boolean enterPressed, boolean backspacePressed,
    boolean keyCharPressed, char keyChar, boolean moveLeftHeld,
    boolean moveRightHeld, boolean moveUpHeld, boolean moveDownHeld,
    boolean runHeld, boolean jumpQueued, boolean interactQueued){
    mouse_x = mouseX;
    mouse_y = mouseY;
    mouse_pressed = mousePressed;
    esc_pressed = escPressed;
    enter_pressed = enterPressed;
    backspace_pressed = backspacePressed;
    key_char_pressed = keyCharPressed;
    key_char = keyChar;
    move_left_held = moveLeftHeld;
    move_right_held = moveRightHeld;
    move_up_held = moveUpHeld;
    move_down_held = moveDownHeld;
    run_held = runHeld;
    jump_queued = jumpQueued;
    interact_queued = interactQueued;
  }
}


class ProcessingFrameClockSource implements FrameClockSource {
  public double readSeconds(){
    return millis() / 1000.0;
  }

  public String origin(){
    return "production";
  }
}


class FrameContext {
  public final double fixed_step_seconds;
  public final double accumulator_before;
  public final double observed_seconds;
  public double accepted_seconds;
  public double discarded_seconds;
  public double accumulator_after;
  public double simulation_time_seconds;
  public long presentation_time_ms;
  public long presentation_state_version;
  public int presentation_count;
  public boolean presentation_active;
  public float viewport_width;
  public float viewport_height;
  public float viewport_offset_x;
  public float viewport_offset_y;
  public int viewport_scale;
  public int button_reset_count;
  public int button_add_count;
  public int hud_pass_count;
  public long presentation_started_nanos;
  public long presentation_duration_nanos;
  public long resource_icon_build_delta;
  public long resource_icon_hit_delta;
  public long resource_icon_miss_delta;
  public long floor_band_build_delta;
  public long floor_band_hit_delta;
  public long floor_band_miss_delta;
  public long cache_invalidation_delta;
  public long asset_cache_hit_delta;
  public long asset_cache_miss_delta;
  public long fallback_delta;
  public long player_layer_build_delta;
  public long player_layer_query_delta;
  public long player_layer_reuse_delta;
  public long room_detail_cache_hit_delta;
  public long room_detail_cache_miss_delta;
  public long room_detail_cache_invalidation_delta;
  public long cache_memory_delta_bytes;
  public long cache_memory_peak_delta_bytes;
  public long loaded_asset_delta;
  public long initial_asset_load_ms;
  public long cache_memory_bytes_at_presentation;
  public long cache_memory_peak_bytes_at_presentation;
  public final java.util.ArrayList<String> phase_sequence =
    new java.util.ArrayList<String>();
  public final java.util.LinkedHashMap<String, Long> presentation_surfaces =
    new java.util.LinkedHashMap<String, Long>();
  public long confirmed_state_version;
  public int steps_planned;
  public int steps_executed;
  public int step_index;
  public int active_screen;
  public int active_room;
  public int ui_layer;
  public final int callback_start_screen;
  public final int callback_start_room;
  public final int callback_start_ui_layer;
  public boolean paused;
  public final String clock_origin;
  public String harness_mode;
  public final long callback_id;
  public FrameInputSnapshot input_snapshot;
  public boolean jump_action_consumed;
  public int jump_action_step;
  public boolean jump_action_cleared;
  public String jump_action_clear_reason;
  public boolean interact_action_consumed;
  public int interact_action_step;
  public boolean interact_action_cleared;
  public String interact_action_clear_reason;
  public boolean door_transition_active;
  public int door_transition_update_count;
  public boolean rebased_after_freeze;
  public String interruption_reason;
  public int last_executed_step;
  public long final_state_version;
  public boolean callback_open;
  public String diagnostic;
  public long frame_start_duration_nanos;
  public long input_duration_nanos;
  public long simulation_duration_nanos;
  public long audio_dispatch_duration_nanos;
  public long physical_audio_dispatch_duration_nanos;
  public long draw_base_duration_nanos;
  public long cursor_duration_nanos;
  public long draw_window_duration_nanos;
  public long harness_duration_nanos;
  public long callback_duration_nanos;
  public long render_duration_nanos;
  public float distance_delta_px;
  long callback_started_nanos;
  long phase_started_nanos;
  long render_started_nanos;
  String phase_name;
  public java.util.ArrayList<MovementAudioEvent> logical_audio_events;

  FrameContext(double step, double before, double observed, double accepted,
    double discarded, double after, double simulationTime, long confirmedVersion,
    int planned, boolean isPaused, String origin, String harnessMode,
    long callbackId, int activeScreen, int activeRoom, int uiLayer,
    boolean doorTransitionActive, String diagnostic){
    fixed_step_seconds = step;
    accumulator_before = before;
    observed_seconds = observed;
    accepted_seconds = accepted;
    discarded_seconds = discarded;
    accumulator_after = after;
    simulation_time_seconds = simulationTime;
    confirmed_state_version = confirmedVersion;
    steps_planned = planned;
    steps_executed = 0;
    step_index = -1;
    paused = isPaused;
    clock_origin = origin;
    harness_mode = harnessMode;
    callback_id = callbackId;
    active_screen = activeScreen;
    active_room = activeRoom;
    this.ui_layer = uiLayer;
    callback_start_screen = activeScreen;
    callback_start_room = activeRoom;
    callback_start_ui_layer = uiLayer;
    this.door_transition_active = doorTransitionActive;
    this.diagnostic = diagnostic;
    jump_action_step = -1;
    jump_action_clear_reason = "";
    interact_action_step = -1;
    interact_action_clear_reason = "";
    interruption_reason = "";
    last_executed_step = -1;
    final_state_version = confirmedVersion;
    callback_open = true;
    callback_started_nanos = System.nanoTime();
  }

  void beginStep(int index){
    step_index = index;
  }

  void confirmStep(double accumulator, double simulationTime, long stateVersion){
    last_executed_step = step_index;
    accumulator_after = accumulator;
    simulation_time_seconds = simulationTime;
    confirmed_state_version = stateVersion;
    final_state_version = stateVersion;
    steps_executed++;
    step_index = -1;
  }

  void recordJumpActionConsumed(){
    if (step_index < 0){
      diagnostic = appendFrameDiagnostic(diagnostic,
        "ação jump consumida fora de um passo de sala");
    } else if (!jump_action_consumed && !jump_action_cleared){
      jump_action_consumed = true;
      jump_action_step = step_index;
    }
  }

  void recordJumpActionCleared(String reason){
    if (!jump_action_consumed && !jump_action_cleared){
      jump_action_cleared = true;
      jump_action_clear_reason = reason == null ? "" : reason;
    }
  }

  void recordInteractActionConsumed(){
    if (step_index < 0){
      diagnostic = appendFrameDiagnostic(diagnostic,
        "ação interact consumida fora de um passo de sala");
    } else if (!interact_action_consumed && !interact_action_cleared){
      interact_action_consumed = true;
      interact_action_step = step_index;
    }
  }

  void recordInteractActionCleared(String reason){
    if (!interact_action_consumed && !interact_action_cleared){
      interact_action_cleared = true;
      interact_action_clear_reason = reason == null ? "" : reason;
    }
  }

  void recordLogicalAudioEvent(MovementAudioEvent event){
    if (event == null){
      throw new IllegalArgumentException("evento de áudio de movimento obrigatório");
    }
    if (logical_audio_events == null){
      logical_audio_events = new java.util.ArrayList<MovementAudioEvent>();
    }
    logical_audio_events.add(event);
  }

  void setInputSnapshot(FrameInputSnapshot snapshot){
    if (input_snapshot != null){
      throw new IllegalStateException("o snapshot de input do callback já foi definido");
    }
    if (snapshot == null){
      throw new IllegalArgumentException("o snapshot de input do callback é obrigatório");
    }
    input_snapshot = snapshot;
  }

  void interrupt(String reason){
    if (reason == null || reason.length() == 0) return;
    if (interruption_reason.length() == 0){
      interruption_reason = reason;
    }
  }

  void refreshDomainState(int activeScreen, int activeRoom, int uiLayer,
    boolean isPaused, boolean doorTransitionActive){
    active_screen = activeScreen;
    active_room = activeRoom;
    this.ui_layer = uiLayer;
    paused = isPaused;
    this.door_transition_active = doorTransitionActive;
  }

  void beginPhase(String name){
    phase_name = name;
    phase_started_nanos = System.nanoTime();
    if ("draw_base".equals(name)) render_started_nanos = phase_started_nanos;
    phase_sequence.add(name);
  }

  void beginPresentation(long actualStateVersion){
    if (!callback_open || !"draw_base".equals(phase_name)) return;
    if (presentation_count != 0){
      throw new IllegalStateException("mais de uma apresentação no mesmo callback");
    }
    if (confirmed_state_version != actualStateVersion){
      throw new IllegalStateException("a apresentação não recebeu a última versão confirmada");
    }
    presentation_count++;
    presentation_active = true;
    presentation_state_version = confirmed_state_version;
    presentation_started_nanos = System.nanoTime();
    cache_memory_bytes_at_presentation = cache_memory_bytes;
    cache_memory_peak_bytes_at_presentation = cache_memory_peak_bytes;
    snapshotPresentationCounters();
  }

  void recordPresentationSurface(String surface){
    if (!presentation_active) return;
    if (surface == null || surface.length() == 0){
      throw new IllegalArgumentException("a superfície apresentada precisa de um nome");
    }
    if (presentation_surfaces.containsKey(surface)){
      throw new IllegalStateException("superfície apresentada mais de uma vez: " + surface);
    }
    long consumedStateVersion = frame_clock == null
      ? presentation_state_version : frame_clock.confirmedStateVersion();
    if (consumedStateVersion != presentation_state_version){
      throw new IllegalStateException("a superfície " + surface
        + " leu uma versão diferente do estado confirmado");
    }
    presentation_surfaces.put(surface, consumedStateVersion);
  }

  void finishPresentation(long actualStateVersion, int viewportWidth,
    int viewportHeight, int viewportScale, float offsetX, float offsetY){
    if (!presentation_active) return;
    if (actualStateVersion != presentation_state_version
      || confirmed_state_version != presentation_state_version){
      presentation_active = false;
      throw new IllegalStateException("o estado confirmado mudou durante a apresentação");
    }
    for (java.util.Map.Entry<String, Long> entry : presentation_surfaces.entrySet()){
      if (entry.getValue() != presentation_state_version){
        presentation_active = false;
        throw new IllegalStateException("superfície desenhada com versão divergente: "
          + entry.getKey());
      }
    }
    if (presentation_surfaces.size() == 0){
      presentation_active = false;
      throw new IllegalStateException("a apresentação não registrou nenhuma superfície");
    }
    viewport_width = viewportWidth;
    viewport_height = viewportHeight;
    viewport_scale = viewportScale;
    viewport_offset_x = offsetX;
    viewport_offset_y = offsetY;
    resource_icon_build_delta = resource_icon_builds - resource_icon_builds_before_presentation;
    resource_icon_hit_delta = resource_icon_cache_hits - resource_icon_hits_before_presentation;
    resource_icon_miss_delta = resource_icon_cache_misses - resource_icon_misses_before_presentation;
    floor_band_build_delta = deck_strip_builds - floor_band_builds_before_presentation;
    floor_band_hit_delta = deck_strip_cache_hits - deck_strip_hits_before_presentation;
    floor_band_miss_delta = deck_strip_cache_misses - deck_strip_misses_before_presentation;
    cache_invalidation_delta = cache_invalidations - cache_invalidations_before_presentation;
    asset_cache_hit_delta = art_cache_hits - art_cache_hits_before_presentation;
    asset_cache_miss_delta = art_cache_misses - art_cache_misses_before_presentation;
    fallback_delta = fallback_diagnostic_count - fallback_count_before_presentation;
    player_layer_build_delta = player_frame_layer_rebuilds - player_layer_builds_before_presentation;
    player_layer_query_delta = player_frame_layer_queries - player_layer_queries_before_presentation;
    player_layer_reuse_delta = player_frame_layer_reuses - player_layer_reuses_before_presentation;
    room_detail_cache_hit_delta = room_detail_cache_hits - room_detail_hits_before_presentation;
    room_detail_cache_miss_delta = room_detail_cache_misses - room_detail_misses_before_presentation;
    room_detail_cache_invalidation_delta = room_detail_cache_invalidations
      - room_detail_invalidations_before_presentation;
    cache_memory_delta_bytes = cache_memory_bytes - cache_memory_bytes_at_presentation;
    cache_memory_peak_delta_bytes = cache_memory_peak_bytes
      - cache_memory_peak_bytes_at_presentation;
    loaded_asset_delta = art_loaded - art_loaded_before_presentation;
    presentation_duration_nanos = java.lang.Math.max(0L,
      System.nanoTime() - presentation_started_nanos);
    presentation_active = false;
  }

  long resource_icon_builds_before_presentation;
  long resource_icon_hits_before_presentation;
  long resource_icon_misses_before_presentation;
  long floor_band_builds_before_presentation;
  long deck_strip_hits_before_presentation;
  long deck_strip_misses_before_presentation;
  long cache_invalidations_before_presentation;
  long art_cache_hits_before_presentation;
  long art_cache_misses_before_presentation;
  long fallback_count_before_presentation;
  long player_layer_builds_before_presentation;
  long player_layer_queries_before_presentation;
  long player_layer_reuses_before_presentation;
  long art_loaded_before_presentation;
  long room_detail_hits_before_presentation;
  long room_detail_misses_before_presentation;
  long room_detail_invalidations_before_presentation;

  void snapshotPresentationCounters(){
    resource_icon_builds_before_presentation = resource_icon_builds;
    resource_icon_hits_before_presentation = resource_icon_cache_hits;
    resource_icon_misses_before_presentation = resource_icon_cache_misses;
    floor_band_builds_before_presentation = deck_strip_builds;
    deck_strip_hits_before_presentation = deck_strip_cache_hits;
    deck_strip_misses_before_presentation = deck_strip_cache_misses;
    cache_invalidations_before_presentation = cache_invalidations;
    art_cache_hits_before_presentation = art_cache_hits;
    art_cache_misses_before_presentation = art_cache_misses;
    fallback_count_before_presentation = fallback_diagnostic_count;
    player_layer_builds_before_presentation = player_frame_layer_rebuilds;
    player_layer_queries_before_presentation = player_frame_layer_queries;
    player_layer_reuses_before_presentation = player_frame_layer_reuses;
    art_loaded_before_presentation = art_loaded;
    room_detail_hits_before_presentation = room_detail_cache_hits;
    room_detail_misses_before_presentation = room_detail_cache_misses;
    room_detail_invalidations_before_presentation = room_detail_cache_invalidations;
    initial_asset_load_ms = art_load_ms;
  }

  void finishPhase(String name){
    long elapsed = java.lang.Math.max(0L, System.nanoTime() - phase_started_nanos);
    if (!name.equals(phase_name)){
      diagnostic = appendFrameDiagnostic(diagnostic, "fase encerrada fora de ordem: " + name);
      return;
    }
    if ("frame_start".equals(name)) frame_start_duration_nanos = elapsed;
    else if ("input".equals(name)) input_duration_nanos = elapsed;
    else if ("simulation".equals(name)) simulation_duration_nanos = elapsed;
    else if ("audio_dispatch".equals(name)) audio_dispatch_duration_nanos = elapsed;
    else if ("draw_base".equals(name)) draw_base_duration_nanos = elapsed;
    else if ("cursor".equals(name)) cursor_duration_nanos = elapsed;
    else if ("draw_window".equals(name)) draw_window_duration_nanos = elapsed;
    else if ("harness".equals(name)) harness_duration_nanos = elapsed;
    else diagnostic = appendFrameDiagnostic(diagnostic, "fase desconhecida: " + name);
    if ("draw_window".equals(name) && render_started_nanos > 0){
      render_duration_nanos = java.lang.Math.max(0L,
        System.nanoTime() - render_started_nanos);
    }
    phase_name = "";
  }

  void finishCallback(){
    callback_duration_nanos = java.lang.Math.max(0L, System.nanoTime() - callback_started_nanos);
    final_state_version = confirmed_state_version;
    callback_open = false;
  }
}


class FrameClock {
  private FrameClockSource source;
  private double last_read_seconds;
  private boolean has_previous_read;
  private double accumulator_seconds;
  private double simulation_time_seconds;
  private long confirmed_state_version;
  private long callback_id;
  private boolean previous_callback_frozen;
  private String last_diagnostic = "";
  private int invalid_delta_count;
  private long presentation_time_ms;
  private boolean presentation_locked;

  FrameClock(FrameClockSource clockSource){
    if (clockSource == null){
      throw new IllegalArgumentException("a fonte do FrameClock é obrigatória");
    }
    source = clockSource;
  }

  void replaceSource(FrameClockSource clockSource){
    if (clockSource == null){
      throw new IllegalArgumentException("a fonte do FrameClock é obrigatória");
    }
    source = clockSource;
    last_read_seconds = source.readSeconds();
    has_previous_read = java.lang.Double.isFinite(last_read_seconds);
    accumulator_seconds = 0.0;
    previous_callback_frozen = true;
  }

  FrameContext beginCallback(boolean isPaused, boolean roomActive, int activeScreen,
    int activeRoom, int uiLayer, String harnessMode, boolean doorTransitionActive){
    double now = source.readSeconds();
    double before = accumulator_seconds;
    double observed = has_previous_read ? now - last_read_seconds : 0.0;
    double accepted = 0.0;
    double discarded = 0.0;
    String diagnostic = "";
    boolean valid = java.lang.Double.isFinite(now)
      && (!has_previous_read || (java.lang.Double.isFinite(observed) && observed >= 0.0));

    if (!java.lang.Double.isFinite(now)){
      has_previous_read = false;
      diagnostic = "leitura do relógio não finita; próxima leitura será a nova base";
    } else {
      last_read_seconds = now;
      has_previous_read = true;
      if (callback_id == 0){
        diagnostic = "primeira leitura do relógio usada como base temporal";
      }
    }

    int planned = 0;
    boolean freeze = isPaused || !roomActive || uiLayer != LAYER_SCENE
      || doorTransitionActive;
    boolean resumeRebase = !freeze && previous_callback_frozen;
    if (!valid){
      invalid_delta_count++;
      last_diagnostic = diagnostic.length() > 0
        ? diagnostic
        : "delta negativo ou não finito; estado confirmado preservado e relógio rebaseado";
      diagnostic = last_diagnostic;
    } else if (freeze){
      discarded = java.lang.Math.max(0.0, observed) + before;
      accumulator_seconds = 0.0;
    } else if (resumeRebase){
      discarded = java.lang.Math.max(0.0, observed) + before;
      accumulator_seconds = 0.0;
    } else if (has_previous_read && callback_id > 0){
      double remainingCapacity = java.lang.Math.max(0.0, FRAME_MAX_ACCUMULATOR_SECONDS - before);
      accepted = java.lang.Math.min(observed, remainingCapacity);
      discarded = java.lang.Math.max(0.0, observed - accepted);
      accumulator_seconds = before + accepted;
      planned = (int) java.lang.Math.floor(
        (accumulator_seconds + FRAME_STEP_EPSILON_SECONDS) / FRAME_FIXED_STEP_SECONDS);
      planned = java.lang.Math.min(FRAME_MAX_STEPS_PER_CALLBACK, java.lang.Math.max(0, planned));
    }

    callback_id++;
    FrameContext context = new FrameContext(FRAME_FIXED_STEP_SECONDS, before,
      observed, accepted, discarded, accumulator_seconds, simulation_time_seconds,
      confirmed_state_version, planned, freeze, source.origin(), harnessMode,
      callback_id, activeScreen, activeRoom, uiLayer, doorTransitionActive, diagnostic);
    if (java.lang.Double.isFinite(now)){
      long observedPresentationTime = java.lang.Math.max(0L,
        java.lang.Math.round(now * 1000.0));
      presentation_time_ms = java.lang.Math.max(presentation_time_ms,
        observedPresentationTime);
    }
    context.presentation_time_ms = presentation_time_ms;
    context.rebased_after_freeze = resumeRebase;
    previous_callback_frozen = freeze;
    if (doorTransitionActive){
      context.interrupt("door_transition_active");
    } else if (!roomActive){
      context.interrupt("outside_room");
    } else if (isPaused || uiLayer != LAYER_SCENE){
      context.interrupt("simulation_paused_or_modal");
    }
    return context;
  }

  void pauseCallback(FrameContext context){
    if (presentation_locked){
      throw new IllegalStateException("a simulação não pode ser rebased durante a apresentação");
    }
    if (context == null) return;
    double confirmedThisCallback = context.steps_executed * context.fixed_step_seconds;
    context.discarded_seconds = java.lang.Math.max(0.0,
      java.lang.Math.max(0.0, context.observed_seconds)
        + context.accumulator_before - confirmedThisCallback);
    context.accepted_seconds = confirmedThisCallback;
    context.accumulator_after = 0.0;
    context.steps_planned = 0;
    context.paused = true;
    accumulator_seconds = 0.0;
    previous_callback_frozen = true;
  }

  void confirmStep(FrameContext context){
    if (presentation_locked){
      throw new IllegalStateException("o estado simulado não pode avançar durante a apresentação");
    }
    if (context == null || context.step_index < 0){
      throw new IllegalStateException("não é possível confirmar um passo sem contexto ativo");
    }
    if (accumulator_seconds + FRAME_STEP_EPSILON_SECONDS < FRAME_FIXED_STEP_SECONDS){
      throw new IllegalStateException("o acumulador não contém o passo fixo a confirmar");
    }
    accumulator_seconds -= FRAME_FIXED_STEP_SECONDS;
    if (accumulator_seconds < FRAME_STEP_EPSILON_SECONDS) accumulator_seconds = 0.0;
    simulation_time_seconds += FRAME_FIXED_STEP_SECONDS;
    confirmed_state_version++;
    context.confirmStep(accumulator_seconds, simulation_time_seconds, confirmed_state_version);
  }

  double accumulatorSeconds(){
    return accumulator_seconds;
  }

  double simulationTimeSeconds(){
    return simulation_time_seconds;
  }

  long confirmedStateVersion(){
    return confirmed_state_version;
  }

  long presentationTimeMillis(){
    return presentation_time_ms;
  }

  void lockPresentation(){
    if (presentation_locked){
      throw new IllegalStateException("a trava de apresentação já está ativa");
    }
    presentation_locked = true;
  }

  void unlockPresentation(){
    presentation_locked = false;
  }

  int invalidDeltaCount(){
    return invalid_delta_count;
  }

  String lastDiagnostic(){
    return last_diagnostic;
  }
}


long presentationTimeMillis(){
  if (current_frame_context != null && current_frame_context.callback_open){
    return current_frame_context.presentation_time_ms;
  }
  return frame_clock == null ? 0L : frame_clock.presentationTimeMillis();
}


void recordCurrentPresentationSurface(String surface){
  if (current_frame_context != null){
    current_frame_context.recordPresentationSurface(surface);
  }
}


void replaceFrameClockSource(FrameClockSource source){
  frame_clock = new FrameClock(source);
  current_frame_context = null;
}


String appendFrameDiagnostic(String current, String next){
  if (current == null || current.length() == 0) return next;
  return current + "; " + next;
}
