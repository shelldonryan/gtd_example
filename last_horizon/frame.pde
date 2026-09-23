final double FRAME_FIXED_STEP_SECONDS = 1.0 / 60.0;
final int FRAME_MAX_STEPS_PER_CALLBACK = 4;
final double FRAME_MAX_ACCUMULATOR_SECONDS = FRAME_FIXED_STEP_SECONDS * FRAME_MAX_STEPS_PER_CALLBACK;
final double FRAME_STEP_EPSILON_SECONDS = 0.0000001;


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


class FrameContext {
  public final double fixed_step_seconds;
  public final double accumulator_before;
  public final double observed_seconds;
  public double accepted_seconds;
  public double discarded_seconds;
  public double accumulator_after;
  public double simulation_time_seconds;
  public long presentation_time_ms;
  public int steps_planned;
  public int steps_executed;
  public int step_index;
  public final int callback_start_screen;
  public final int callback_start_room;
  public final int callback_start_ui_layer;
  public boolean paused;
  public final long callback_id;
  public FrameInputSnapshot input_snapshot;
  public boolean jump_action_consumed;
  public boolean jump_action_cleared;
  public boolean interact_action_consumed;
  public boolean interact_action_cleared;
  public boolean door_transition_active;
  public int door_transition_update_count;
  public String interruption_reason = "";
  public boolean callback_open = true;

  FrameContext(double step, double before, double observed, double accepted,
    double discarded, double after, double simulationTime, int planned,
    boolean isPaused, long callbackId, int activeScreen, int activeRoom,
    int uiLayer, boolean doorTransitionActive){
    fixed_step_seconds = step;
    accumulator_before = before;
    observed_seconds = observed;
    accepted_seconds = accepted;
    discarded_seconds = discarded;
    accumulator_after = after;
    simulation_time_seconds = simulationTime;
    steps_planned = planned;
    steps_executed = 0;
    step_index = -1;
    paused = isPaused;
    callback_id = callbackId;
    callback_start_screen = activeScreen;
    callback_start_room = activeRoom;
    callback_start_ui_layer = uiLayer;
    this.door_transition_active = doorTransitionActive;
  }

  void beginStep(int index){
    step_index = index;
  }

  void confirmStep(double accumulator, double simulationTime){
    accumulator_after = accumulator;
    simulation_time_seconds = simulationTime;
    steps_executed++;
    step_index = -1;
  }

  void recordJumpActionConsumed(){
    if (step_index >= 0 && !jump_action_consumed && !jump_action_cleared){
      jump_action_consumed = true;
    }
  }

  void recordJumpActionCleared(){
    if (!jump_action_consumed) jump_action_cleared = true;
  }

  void recordInteractActionConsumed(){
    if (step_index >= 0 && !interact_action_consumed && !interact_action_cleared){
      interact_action_consumed = true;
    }
  }

  void recordInteractActionCleared(){
    if (!interact_action_consumed) interact_action_cleared = true;
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
    if (interruption_reason.length() == 0) interruption_reason = reason;
  }

  void refreshDomainState(boolean isPaused, boolean doorTransitionActive){
    paused = isPaused;
    this.door_transition_active = doorTransitionActive;
  }

  void finishCallback(){
    callback_open = false;
  }
}


class FrameClock {
  private double last_read_seconds;
  private boolean has_previous_read;
  private double accumulator_seconds;
  private double simulation_time_seconds;
  private long callback_id;
  private boolean previous_callback_frozen;
  private long presentation_time_ms;

  FrameClock(){
  }

  FrameContext beginCallback(boolean isPaused, boolean roomActive, int activeScreen,
    int activeRoom, int uiLayer, boolean doorTransitionActive){
    double now = millis() / 1000.0;
    double before = accumulator_seconds;
    double observed = has_previous_read ? now - last_read_seconds : 0.0;
    double accepted = 0.0;
    double discarded = 0.0;
    boolean valid = java.lang.Double.isFinite(now)
      && (!has_previous_read || (java.lang.Double.isFinite(observed) && observed >= 0.0));

    if (!java.lang.Double.isFinite(now)){
      has_previous_read = false;
    } else {
      last_read_seconds = now;
      has_previous_read = true;
    }

    int planned = 0;
    boolean freeze = isPaused || !roomActive || uiLayer != LAYER_SCENE
      || doorTransitionActive;
    boolean resumeRebase = !freeze && previous_callback_frozen;
    if (valid && freeze){
      discarded = java.lang.Math.max(0.0, observed) + before;
      accumulator_seconds = 0.0;
    } else if (valid && resumeRebase){
      discarded = java.lang.Math.max(0.0, observed) + before;
      accumulator_seconds = 0.0;
    } else if (valid && has_previous_read && callback_id > 0){
      double remainingCapacity = java.lang.Math.max(0.0,
        FRAME_MAX_ACCUMULATOR_SECONDS - before);
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
      planned, freeze, callback_id, activeScreen, activeRoom, uiLayer,
      doorTransitionActive);
    if (java.lang.Double.isFinite(now)){
      long observedPresentationTime = java.lang.Math.max(0L,
        java.lang.Math.round(now * 1000.0));
      presentation_time_ms = java.lang.Math.max(presentation_time_ms,
        observedPresentationTime);
    }
    context.presentation_time_ms = presentation_time_ms;
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
    if (context == null || context.step_index < 0){
      throw new IllegalStateException("não é possível confirmar um passo sem contexto ativo");
    }
    if (accumulator_seconds + FRAME_STEP_EPSILON_SECONDS < FRAME_FIXED_STEP_SECONDS){
      throw new IllegalStateException("o acumulador não contém o passo fixo a confirmar");
    }
    accumulator_seconds -= FRAME_FIXED_STEP_SECONDS;
    if (accumulator_seconds < FRAME_STEP_EPSILON_SECONDS) accumulator_seconds = 0.0;
    simulation_time_seconds += FRAME_FIXED_STEP_SECONDS;
    context.confirmStep(accumulator_seconds, simulation_time_seconds);
  }

  double simulationTimeSeconds(){
    return simulation_time_seconds;
  }

  long presentationTimeMillis(){
    return presentation_time_ms;
  }
}


long presentationTimeMillis(){
  if (current_frame_context != null && current_frame_context.callback_open){
    return current_frame_context.presentation_time_ms;
  }
  return frame_clock == null ? 0L : frame_clock.presentationTimeMillis();
}
