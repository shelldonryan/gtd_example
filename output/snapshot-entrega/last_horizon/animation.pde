void drawPlayer(PGraphics g){
  recordCurrentPresentationSurface("player");
  if (!player_assets_loaded){
    drawPlayerFallback(g);
    return;
  }

  int frame = playerCurrentFrame();
  updatePlayerFrameLayer(frame);
  if (!player_frame_layer_valid || player_frame_layer == null){
    drawPlayerFallback(g);
    return;
  }

  g.imageMode(CENTER);
  g.image(player_frame_layer,
    player_x + PLAYER_W / 2.0,
    player_y + PLAYER_H / 2.0,
    PLAYER_DRAW_W,
    PLAYER_DRAW_H
  );
}


void drawPlayerFallback(PGraphics g){
  g.noStroke();
  g.fill(player_on_ladder ? COL_CYAN : COL_ORANGE);
  g.rect(player_x, player_y, PLAYER_W, PLAYER_H);
  g.fill(COL_BG);
  g.rect(player_x + 4, player_y + 5, 2, 2);
  g.rect(player_x + 10, player_y + 5, 2, 2);
  g.rect(player_x + 4, player_y + 17, 8, 2);
}

final int PLAYER_ANIM_IDLE = 0;
final int PLAYER_ANIM_WALK = 1;
final int PLAYER_ANIM_CLIMB = 2;
final int PLAYER_ANIM_JUMP = 3;
final int PLAYER_ANIM_RUN = 4;

PGraphics player_frame_layer_staging;
boolean player_frame_layer_valid = false;
int player_frame_layer_failed_frame = -1;
int player_frame_layer_failed_facing = 0;
long player_frame_layer_queries = 0;
long player_frame_layer_reuses = 0;
long player_frame_layer_rebuilds = 0;
String player_frame_layer_failure = "";


int resolvePlayerAnimationState(){
  if (player_has_climb && player_on_ladder){
    return PLAYER_ANIM_CLIMB;
  }
  if (player_has_jump && !player_grounded && !player_on_ladder){
    return PLAYER_ANIM_JUMP;
  }
  if (playerIsRunning()){
    return player_has_run ? PLAYER_ANIM_RUN : PLAYER_ANIM_WALK;
  }
  if (playerIsMoving()){
    return PLAYER_ANIM_WALK;
  }
  return PLAYER_ANIM_IDLE;
}


boolean playerAnimationIsMoving(int state){
  if (state == PLAYER_ANIM_WALK) return true;
  return state == PLAYER_ANIM_CLIMB && (move_up_held || move_down_held);
}


void updatePlayerAnimationState(FrameContext context){
  if (context == null || !context.callback_open
    || context.step_index < 0
    || context.step_index >= context.steps_planned
    || context.steps_executed != context.step_index
    || !java.lang.Double.isFinite(context.simulation_time_seconds)){
    return;
  }

  int next_state = resolvePlayerAnimationState();
  boolean next_moving = playerAnimationIsMoving(next_state);
  if (next_state == player_anim_state && next_moving == player_animation_moving){
    return;
  }

  player_anim_state = next_state;
  player_animation_moving = next_moving;
  player_animation_started_at = (int) java.lang.Math.round(
    (context.simulation_time_seconds + context.fixed_step_seconds) * 1000.0
  );
}


int playerCurrentAnimationState(){
  return player_anim_state >= PLAYER_ANIM_IDLE
    && player_anim_state <= PLAYER_ANIM_RUN
    ? player_anim_state
    : PLAYER_ANIM_IDLE;
}


int playerCurrentFrame(){
  if (frame_clock == null){
    throw new IllegalStateException("o FrameClock precisa existir para selecionar a animação do jogador");
  }
  return playerCurrentFrameAt(frame_clock.simulationTimeSeconds());
}


int playerCurrentFrameAt(double simulationTimeSeconds){
  if (!player_assets_loaded){
    return 0;
  }
  if (!java.lang.Double.isFinite(simulationTimeSeconds)){
    throw new IllegalArgumentException("o tempo simulado da animação precisa ser finito");
  }

  int state = playerCurrentAnimationState();
  int first = player_idle_start;
  int last = player_idle_end;

  if (state == PLAYER_ANIM_WALK){
    first = player_walk_start;
    last = player_walk_end;
  } else if (state == PLAYER_ANIM_RUN && player_has_run){
    first = player_run_start;
    last = player_run_end;
  } else if (state == PLAYER_ANIM_CLIMB && player_has_climb){
    first = player_climb_start;
    last = player_climb_end;
    if (!player_animation_moving){
      return first;
    }
  } else if (state == PLAYER_ANIM_JUMP && player_has_jump){
    first = player_jump_start;
    last = player_jump_end;
  }

  if (!validPlayerFrameRange(first, last)){
    return player_idle_start;
  }

  int total_duration = 0;
  for (int index = first; index <= last; index++){
    total_duration += max(1, player_frame_durations[index]);
  }

  int frame = first;
  long logicalTimeMs = java.lang.Math.round(simulationTimeSeconds * 1000.0);
  long rawElapsed = java.lang.Math.max(0L,
    logicalTimeMs - player_animation_started_at);
  long elapsed = state == PLAYER_ANIM_JUMP
    ? java.lang.Math.min(rawElapsed, total_duration - 1L)
    : (total_duration > 0 ? rawElapsed % total_duration : 0L);

  while (frame < last){
    int duration = max(1, player_frame_durations[frame]);
    if (elapsed < duration){
      break;
    }
    elapsed -= duration;
    frame++;
  }

  return frame;
}


boolean validPlayerFrameRange(int first, int last){
  return player_frame_images != null && player_frame_durations != null
    && first >= 0 && last >= first
    && last < player_frame_images.length
    && last < player_frame_durations.length;
}


boolean updatePlayerFrameLayer(int frame){
  player_frame_layer_queries++;
  if (player_frame_layer_valid && player_frame_layer != null
    && frame == player_rendered_frame
    && player_facing == player_rendered_facing){
    player_frame_layer_reuses++;
    return true;
  }

  if (player_frame_layer_valid && player_frame_layer != null
    && frame == player_frame_layer_failed_frame
    && player_facing == player_frame_layer_failed_facing){
    player_frame_layer_reuses++;
    return true;
  }

  if (!validPlayerFrameRange(frame, frame)
    || player_frame_images[frame] == null){
    rememberPlayerFrameLayerFailure(frame, player_facing,
      "selected_frame_unavailable");
    return player_frame_layer_valid && player_frame_layer != null;
  }

  PGraphics target = player_frame_layer_staging;
  boolean target_created = false;
  if (target == null || target == player_frame_layer){
    try {
      target = createGraphics(PLAYER_DRAW_W * RENDER_SCALE,
        PLAYER_DRAW_H * RENDER_SCALE);
      target_created = target != null;
      if (target != null){
        target.noSmooth();
      }
    } catch (RuntimeException error){
      if (target_created && target != null){
        player_frame_layer_staging = target;
        registerCacheBitmap(target);
      }
      rememberPlayerFrameLayerFailure(frame, player_facing,
        describePlayerFrameLayerError(error));
      return player_frame_layer_valid && player_frame_layer != null;
    }
    if (target_created){
      player_frame_layer_staging = target;
      registerCacheBitmap(target);
    }
  }

  if (target == null){
    rememberPlayerFrameLayerFailure(frame, player_facing,
      "graphics_buffer_unavailable");
    return player_frame_layer_valid && player_frame_layer != null;
  }

  boolean drawing = false;
  try {
    target.beginDraw();
    drawing = true;
    target.clear();
    target.imageMode(CENTER);
    target.pushMatrix();
    target.translate(
      PLAYER_DRAW_W * RENDER_SCALE / 2.0,
      PLAYER_DRAW_H * RENDER_SCALE / 2.0
    );
    target.scale(player_facing, 1);
    target.image(
      player_frame_images[frame],
      0,
      0,
      PLAYER_DRAW_W * RENDER_SCALE,
      PLAYER_DRAW_H * RENDER_SCALE
    );
    target.popMatrix();
    target.endDraw();
    drawing = false;
  } catch (RuntimeException error){
    String failure = describePlayerFrameLayerError(error);
    if (drawing){
      try {
        target.endDraw();
      } catch (RuntimeException endError){
        failure += "; fim do desenho: " + describePlayerFrameLayerError(endError);
      }
    }
    rememberPlayerFrameLayerFailure(frame, player_facing, failure);
    return player_frame_layer_valid && player_frame_layer != null;
  }

  PGraphics previous = player_frame_layer;
  player_frame_layer = target;
  player_frame_layer_staging = previous;
  player_frame_layer_valid = true;
  player_rendered_frame = frame;
  player_rendered_facing = player_facing;
  player_frame_layer_failed_frame = -1;
  player_frame_layer_failed_facing = 0;
  player_frame_layer_failure = "";
  player_frame_layer_rebuilds++;
  return true;
}


void rememberPlayerFrameLayerFailure(int frame, int facing, String failure){
  player_frame_layer_failed_frame = frame;
  player_frame_layer_failed_facing = facing;
  player_frame_layer_failure = failure == null || failure.length() == 0
    ? "falha não identificada ao reconstruir a camada"
    : failure;
  recordFallbackDiagnostic(PLAYER_SHEET_FILE, "player_frame_layer",
    player_frame_layer_failure, "last_valid_or_geometric_fallback");
  if (current_frame_context != null){
    current_frame_context.diagnostic = appendFrameDiagnostic(
      current_frame_context.diagnostic,
      "player_frame_layer: " + player_frame_layer_failure
    );
  }
  try {
    recordFallbackDiagnostic(PLAYER_SHEET_FILE, "player_frame_layer",
      player_frame_layer_failure, "previous_frame_or_geometric_fallback");
  } catch (RuntimeException diagnosticError){
    player_frame_layer_failure += "; diagnóstico: "
      + describePlayerFrameLayerError(diagnosticError);
  }
}


String describePlayerFrameLayerError(RuntimeException error){
  if (error == null) return "falha não identificada";
  String message = error.getMessage();
  return message == null || message.length() == 0
    ? error.getClass().getSimpleName()
    : error.getClass().getSimpleName() + ": " + message;
}
