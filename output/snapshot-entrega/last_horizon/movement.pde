boolean useNearbyDoor(){
  if (doorTransitionActive()){
    return false;
  }

  int door = nearbyDoor();

  if (door < 0 || nearestInteractablePoint() >= 0){
    return false;
  }

  enterRoomThroughDoor(door);
  return true;
}


void updateRoom(){
  if (doorTransitionActive()){
    updateDoorTransition();
    jump_queued = false;
    interact_queued = false;
    return;
  }

  if (uiLayer() != LAYER_SCENE){
    jump_queued = false;
    interact_queued = false;
    return;
  }

  if (interact_queued){
    interact_queued = false;

    if (!useNearbyDoor()){
      interactNearby();
    }
  }
  if (uiLayer() != LAYER_SCENE){
    jump_queued = false;
    return;
  }

  updatePlayerFacing();
  if (player_on_ladder){
    updatePlayerOnLadder();
  } else {
    updatePlayerOnDeck();
  }

  jump_queued = false;
}

void updatePlayerFacing(){
  if (move_left_held && !move_right_held){
    player_facing = -1;
  } else if (move_right_held && !move_left_held){
    player_facing = 1;
  }
}


boolean playerIsMoving(){
  return move_left_held || move_right_held || move_up_held || move_down_held;
}

boolean playerIsRunning(){
  return run_held && (move_left_held != move_right_held) && player_grounded && !player_on_ladder;
}

void updatePlayerOnDeck(){
  boolean was_airborne = !player_grounded;
  if (jump_queued && player_grounded){
    player_velocity_y = -sqrt(2 * GRAVITY * JUMP_HEIGHT);
    player_grounded = false;
    player_step_accum = 0;
    walk_step_active = false;
    playDeckStepSound(false);
  }

  float old_bottom = player_y + PLAYER_H;
  player_velocity_y += GRAVITY;
  float next_y = player_y + player_velocity_y;
  player_grounded = false;

  for (int i = 0; i < DECK_COUNT; i++){
    if (player_velocity_y < 0){
      continue;
    }

    boolean crossing = old_bottom <= deck_y[i] && next_y + PLAYER_H >= deck_y[i];
    boolean overlaps = player_x + PLAYER_W > ROOM_LEFT && player_x < ROOM_RIGHT;

    if (crossing && overlaps){
      next_y = deck_y[i] - PLAYER_H;
      player_velocity_y = 0;
      player_grounded = true;
      break;
    }
  }

  player_y = min(next_y, deck_y[DECK_COUNT - 1] - PLAYER_H);

  boolean landed = was_airborne && player_grounded;
  if (landed){
    playDeckStepSound(false);
    player_step_accum = 0;
    walk_step_active = false;
  }

  float horizontal = 0;
  float speed = playerIsRunning() ? PLAYER_RUN_SPEED : PLAYER_SPEED;

  if (move_left_held){
    horizontal -= speed;
  }

  if (move_right_held){
    horizontal += speed;
  }

  player_x = constrain(player_x + horizontal, ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);

  if (player_grounded && horizontal != 0){
    boolean running = playerIsRunning();
    if (running){
      walk_step_active = false;
      if (player_step_accum <= 0 && !landed){
        playDeckStepSound(true);
      }
      player_step_accum += abs(horizontal);
      if (player_step_accum >= RUN_STEP_SPACING){
        player_step_accum -= RUN_STEP_SPACING;
        playDeckStepSound(true);
      }
    } else {
      player_step_accum = 0;
      int phase = (max(0, millis() - player_animation_started_at)
        / WALK_STEP_HALF_CYCLE_MS) % 2;
      if (!walk_step_active){
        player_animation_started_at = millis();
        walk_step_phase = 0;
        walk_step_active = true;
        if (!landed) playDeckStepSound(false);
      } else if (phase != walk_step_phase){
        walk_step_phase = phase;
        playDeckStepSound(false);
      }
    }
  } else {
    player_step_accum = 0;
    walk_step_active = false;
  }

  boolean vertical_input = move_up_held || move_down_held;
  boolean horizontal_input = move_left_held || move_right_held;

  if (!vertical_input){
    ladder_vertical_release_required = false;
  }

  if (vertical_input && !horizontal_input && !ladder_vertical_release_required
    && player_grounded){
    int ladder = nearestLadder();

    if (ladder >= 0){
      current_ladder = ladder;
      player_on_ladder = true;
      player_grounded = false;
      player_x = ladder_x[ladder] - PLAYER_W / 2.0;
      player_velocity_y = 0;
      ladder_climbing_active = false;
      ladder_steps_taken = 0;
      ladder_step_accum = 0;
      updatePlayerOnLadder();
    }
  }
}


void updatePlayerOnLadder(){
  int vertical = 0;

  if (move_up_held){
    vertical -= 1;
  }

  if (move_down_held){
    vertical += 1;
  }

  int horizontal = 0;

  if (move_left_held){
    horizontal -= 1;
  }

  if (move_right_held){
    horizontal += 1;
  }

  if (current_ladder < 0){
    current_ladder = activeLadderIndex();
  }

  int top_deck = current_ladder >= 0 ? ladder_top_deck[current_ladder] : 0;
  int bot_deck = current_ladder >= 0 ? ladder_bottom_deck[current_ladder] : DECK_COUNT - 1;

  float old_y = player_y;
  player_y += vertical * LADDER_SPEED;
  float top = deck_y[top_deck] - PLAYER_H;
  float bottom = deck_y[bot_deck] - PLAYER_H;
  player_y = constrain(player_y, top, bottom);

  float dy = abs(player_y - old_y);
  if (dy > 0){
    if (!ladder_climbing_active){
      ladder_climbing_active = true;
      ladder_steps_taken = 0;
      ladder_step_accum = 0;
    }
    ladder_step_accum += dy;
    float threshold = (ladder_steps_taken == 0) ? LADDER_FIRST_STEP : LADDER_STEP_SPACING;
    if (ladder_step_accum >= threshold){
      ladder_step_accum = 0;
      ladder_steps_taken++;
      playLadderStepSound();
    }
  } else {
    ladder_climbing_active = false;
    ladder_steps_taken = 0;
    ladder_step_accum = 0;
  }

  boolean wants_deck = horizontal != 0 || vertical == 0;
  int deck = ladderDeckAt(old_y, player_y, wants_deck);

  if (deck >= 0 && wants_deck){
    leaveLadderAtDeck(deck, horizontal);
    return;
  }

  if (player_y <= top || player_y >= bottom){
    int end_deck = player_y <= top ? top_deck : bot_deck;
    leaveLadderAtDeck(end_deck, horizontal);
  }
}


int ladderDeckAt(float old_y, float new_y, boolean allow_nearby){
  final float snap_distance = 4;
  int nearest = -1;
  float nearest_distance = snap_distance + 1;

  for (int i = 0; i < DECK_COUNT; i++){
    float target_y = deck_y[i] - PLAYER_H;
    boolean crossed = (old_y <= target_y && new_y >= target_y)
      || (old_y >= target_y && new_y <= target_y);

    if (crossed){
      return i;
    }

    float distance = abs(new_y - target_y);

    if (allow_nearby && distance <= snap_distance && distance < nearest_distance){
      nearest = i;
      nearest_distance = distance;
    }
  }

  return nearest;
}


final int WALK_STEP_HALF_CYCLE_MS = 400;
final float RUN_STEP_SPACING = 27;
final float LADDER_STEP_SPACING = 27;
final float LADDER_FIRST_STEP = 1;
float ladder_step_accum = 0;
int ladder_steps_taken = 0;
float player_step_accum = 0;
boolean walk_step_active = false;
int walk_step_phase = 0;
boolean ladder_climbing_active = false;


void leaveLadderAtDeck(int deck, int horizontal){
  playSound(sound_ladder);
  player_y = deck_y[deck] - PLAYER_H;
  player_x = constrain(player_x + horizontal * PLAYER_SPEED,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
  current_ladder = -1;
  player_on_ladder = false;
  player_grounded = true;
  player_velocity_y = 0;
  ladder_vertical_release_required = move_up_held || move_down_held;
  ladder_climbing_active = false;
  ladder_steps_taken = 0;
  ladder_step_accum = 0;
  player_step_accum = 0;
  walk_step_active = false;
  walk_step_phase = 0;
}


int activeLadderIndex(){
  float center_x = player_x + PLAYER_W / 2.0;
  int best = -1;
  float best_dist = 1000;

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != screen) continue;
    float top_y = deck_y[ladder_top_deck[i]] - PLAYER_H - 2;
    float bot_y = deck_y[ladder_bottom_deck[i]] + 2;
    if (player_y < top_y || player_y > bot_y) continue;
    float dist = abs(center_x - ladder_x[i]);
    if (dist < best_dist){
      best_dist = dist;
      best = i;
    }
  }

  return best;
}


int nearestLadder(){
  if (!player_grounded){
    return -1;
  }

  float center_x = player_x + PLAYER_W / 2.0;
  float bottom = player_y + PLAYER_H;

  int current_deck = -1;
  for (int i = 0; i < DECK_COUNT; i++){
    if (abs(bottom - deck_y[i]) < 1.1){
      current_deck = i;
      break;
    }
  }

  if (current_deck < 0){
    return -1;
  }

  int result = -1;
  float best_distance = INTERACTION_RANGE + 1;

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != screen) continue;

    if (current_deck < ladder_top_deck[i] || current_deck > ladder_bottom_deck[i]){
      continue;
    }

    if (current_deck == ladder_top_deck[i] && !move_down_held){
      continue;
    }
    if (current_deck == ladder_bottom_deck[i] && !move_up_held){
      continue;
    }

    float distance = abs(center_x - ladder_x[i]);

    if (distance <= INTERACTION_RANGE && distance < best_distance){
      result = i;
      best_distance = distance;
    }
  }

  return result;
}


float ladderX(int room_id, int slot){
  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != room_id) continue;
    if (slot-- == 0) return ladder_x[i];
  }

  return 0;
}


boolean isDeckSurface(float bottom){
  for (int i = 0; i < DECK_COUNT; i++){
    if (abs(bottom - deck_y[i]) < 1.1){
      return true;
    }
  }

  return false;
}
