void drawPlayer(PGraphics g){
  if (!player_assets_loaded){
    drawPlayerFallback(g);
    return;
  }

  int frame = playerCurrentFrame();
  updatePlayerFrameLayer(frame);
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


int playerCurrentAnimationState(){
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


int playerCurrentFrame(){
  if (!player_assets_loaded){
    return 0;
  }

  int state = playerCurrentAnimationState();
  boolean climb_moving = (state == PLAYER_ANIM_CLIMB && (move_up_held || move_down_held));
  if (state != player_anim_state || (state == PLAYER_ANIM_CLIMB && climb_moving != player_animation_moving)){
    player_anim_state = state;
    player_animation_moving = (state == PLAYER_ANIM_WALK || climb_moving);
    player_animation_started_at = millis();
  }

  int first = player_idle_start;
  int last = player_idle_end;

  if (state == PLAYER_ANIM_WALK){
    first = player_walk_start;
    last = player_walk_end;
  } else if (state == PLAYER_ANIM_RUN){
    first = player_run_start;
    last = player_run_end;
  } else if (state == PLAYER_ANIM_CLIMB && player_has_climb){
    first = player_climb_start;
    last = player_climb_end;
    if (!move_up_held && !move_down_held){
      return first;
    }
  } else if (state == PLAYER_ANIM_JUMP && player_has_jump){
    first = player_jump_start;
    last = player_jump_end;
  }

  int total_duration = 0;
  for (int index = first; index <= last; index++){
    total_duration += max(1, player_frame_durations[index]);
  }

  int frame = first;
  int raw_elapsed = max(0, millis() - player_animation_started_at);
  int elapsed = (state == PLAYER_ANIM_JUMP)
    ? min(raw_elapsed, total_duration - 1)
    : (total_duration > 0 ? raw_elapsed % total_duration : 0);

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


void updatePlayerFrameLayer(int frame){
  if (player_frame_layer == null
    || frame == player_rendered_frame
    && player_facing == player_rendered_facing){
    return;
  }

  player_frame_layer.beginDraw();
  player_frame_layer.clear();
  player_frame_layer.imageMode(CENTER);
  player_frame_layer.pushMatrix();
  player_frame_layer.translate(
    PLAYER_DRAW_W * RENDER_SCALE / 2.0,
    PLAYER_DRAW_H * RENDER_SCALE / 2.0
  );
  player_frame_layer.scale(player_facing, 1);
  player_frame_layer.image(
    player_frame_images[frame],
    0,
    0,
    PLAYER_DRAW_W * RENDER_SCALE,
    PLAYER_DRAW_H * RENDER_SCALE
  );
  player_frame_layer.popMatrix();
  player_frame_layer.endDraw();

  player_rendered_frame = frame;
  player_rendered_facing = player_facing;
}
