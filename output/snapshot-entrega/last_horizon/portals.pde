boolean doorTransitionActive(){
  return door_transition_phase != DOOR_PHASE_CLOSED;
}


void clearPreparedPortalTransition(){
  portal_transition_prepared = false;
  portal_prepared_door = -1;
  portal_prepared_from_room = SCREEN_NONE;
  portal_prepared_target_room = SCREEN_NONE;
  portal_prepared_return_door = -1;
  portal_prepared_departure_x = 0;
  portal_prepared_departure_y = 0;
  portal_prepared_arrival_x = 0;
  portal_prepared_arrival_y = 0;
  portal_prepared_arrival_facing = 1;
  portal_prepared_returning = false;
}


void reportPortalFailure(int door, String reason){
  String target = "unknown";
  if (door >= 0 && door < DOOR_COUNT && door_target != null
    && door < door_target.length){
    target = str(door_target[door]);
  }
  println("portal: " + reason + " | door=" + door
    + " | room=" + screen + " | target=" + target);
}


boolean portalRoomExists(int room_id){
  if (room_screen == null){
    return false;
  }

  for (int i = 0; i < room_screen.length; i++){
    if (room_screen[i] == room_id){
      return true;
    }
  }
  return false;
}


boolean portalDataExists(int door){
  return door >= 0 && door < DOOR_COUNT
    && door_room != null && door < door_room.length
    && door_target != null && door < door_target.length
    && door_x != null && door < door_x.length
    && door_y != null && door < door_y.length
    && door_arrival_x != null && door < door_arrival_x.length
    && door_arrival_y != null && door < door_arrival_y.length
    && door_arrival_facing != null && door < door_arrival_facing.length;
}


boolean portalDataValid(int door){
  if (!portalDataExists(door)){
    return false;
  }

  return !Float.isNaN(door_x[door]) && !Float.isInfinite(door_x[door])
    && !Float.isNaN(door_y[door]) && !Float.isInfinite(door_y[door])
    && !Float.isNaN(door_arrival_x[door])
    && !Float.isInfinite(door_arrival_x[door])
    && !Float.isNaN(door_arrival_y[door])
    && !Float.isInfinite(door_arrival_y[door])
    && (door_arrival_facing[door] == -1 || door_arrival_facing[door] == 1);
}


boolean portalHasCompleteAnimation(){
  return art_door_frames != null && art_door_frames.length > 1
    && art_door_frames[0] != null && art_door_frames[1] != null;
}


boolean preparePortalTransition(int door){
  clearPreparedPortalTransition();

  if (doorTransitionActive()){
    reportPortalFailure(door, "reentry_ignored");
    return false;
  }

  if (!portalDataValid(door) || door_room[door] != screen){
    reportPortalFailure(door, "invalid_door");
    return false;
  }

  int from_screen = screen;
  int target_screen = door_target[door];
  if (!portalRoomExists(target_screen) || target_screen == from_screen){
    reportPortalFailure(door, "invalid_destination");
    return false;
  }

  int return_door = doorInRoomLeadingTo(target_screen, from_screen);
  if (return_door < 0 || !portalDataValid(return_door)){
    reportPortalFailure(door, "missing_return_portal");
    return false;
  }

  boolean returning = last_portal_valid
    && last_portal_from_room == target_screen
    && last_portal_to_room == from_screen;

  portal_prepared_door = door;
  portal_prepared_from_room = from_screen;
  portal_prepared_target_room = target_screen;
  portal_prepared_return_door = return_door;
  portal_prepared_departure_x = player_x + PLAYER_W / 2.0;
  portal_prepared_departure_y = player_y + PLAYER_H;
  portal_prepared_returning = returning;
  portal_prepared_arrival_x = returning ? last_portal_from_x : door_arrival_x[door];
  portal_prepared_arrival_y = returning ? last_portal_from_y : door_arrival_y[door];
  portal_prepared_arrival_facing = door_arrival_facing[door];
  portal_transition_prepared = true;

  last_portal_valid = true;
  last_portal_from_room = from_screen;
  last_portal_to_room = target_screen;
  last_portal_from_x = portal_prepared_departure_x;
  last_portal_from_y = portal_prepared_departure_y;

  return true;
}


void startDoorTransition(int door){
  if (doorTransitionActive()){
    reportPortalFailure(door, "reentry_ignored");
    return;
  }

  if (!portal_transition_prepared
    || portal_prepared_door != door
    || portal_prepared_from_room != screen){
    if (!preparePortalTransition(door)){
      return;
    }
  }

  door_transition_door = portal_prepared_door;
  door_transition_phase = DOOR_PHASE_OPENING;
  door_transition_started = millis();
  door_transition_target = portal_prepared_target_room;
  door_transition_return_door = portal_prepared_return_door;
  door_transition_arrival_x = portal_prepared_arrival_x;
  door_transition_arrival_y = portal_prepared_arrival_y;
  door_transition_facing = portal_prepared_arrival_facing;
  clearPreparedPortalTransition();
}


void updateDoorTransition(){
  if (millis() - door_transition_started < ART_DOOR_PHASE_MS){
    return;
  }

  door_transition_started = millis();

  if (door_transition_phase == DOOR_PHASE_OPENING){
    enterRoomAtPosition(door_transition_target, door_transition_arrival_y,
      door_transition_arrival_x, door_transition_facing);
    door_transition_door = door_transition_return_door;
    door_transition_phase = DOOR_PHASE_CLOSING;
    portal_transition_prepared = false;
    return;
  }

  door_transition_door = -1;
  door_transition_phase = DOOR_PHASE_CLOSED;
  door_transition_target = SCREEN_NONE;
  door_transition_return_door = -1;
  door_transition_arrival_x = 0;
  door_transition_arrival_y = 0;
  door_transition_facing = 1;
  clearPreparedPortalTransition();
}

void enterRoom(int next_screen){
  last_portal_valid = false;
  clearPreparedPortalTransition();
  int door = doorInRoomLeadingTo(SCREEN_COMMAND, next_screen);

  if (door >= 0){
    enterRoomAtPosition(
      next_screen,
      door_arrival_y[door],
      door_arrival_x[door],
      door_arrival_facing[door]
    );
    return;
  }

  enterRoomAtPosition(next_screen, deck_y[DECK_COUNT - 1], ROOM_LEFT + 28, 1);
}



int doorInRoomLeadingTo(int room_id, int target){
  if (door_room == null || door_target == null){
    return -1;
  }

  int available_doors = min(DOOR_COUNT, min(door_room.length, door_target.length));
  for (int i = 0; i < available_doors; i++){
    if (door_room[i] == room_id && door_target[i] == target) return i;
  }

  return -1;
}

void enterRoomThroughDoor(int door){
  if (doorTransitionActive()){
    reportPortalFailure(door, "reentry_ignored");
    return;
  }

  if (!preparePortalTransition(door)){
    return;
  }

  playSound(sound_door);
  if (portalHasCompleteAnimation()){
    startDoorTransition(door);
    return;
  }

  enterRoomAtPosition(
    portal_prepared_target_room,
    portal_prepared_arrival_y,
    portal_prepared_arrival_x,
    portal_prepared_arrival_facing
  );
  clearPreparedPortalTransition();
}


void enterRoomAtPosition(int next_screen, float feet_y, float center_x, int facing){
  clearPreparedPortalTransition();
  screen = next_screen;
  current_room = next_screen;
  player_facing = facing;
  float clamped_feet_y = constrain(feet_y, ROOM_TOP + PLAYER_H, ROOM_BOTTOM);
  player_x = constrain(center_x - PLAYER_W / 2.0,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
  player_y = clamped_feet_y - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = isDeckSurface(clamped_feet_y);
  player_on_ladder = false;
  current_ladder = -1;
  ladder_vertical_release_required = false;
  jump_queued = false;
  player_step_accum = 0;
  walk_step_active = false;
  walk_step_phase = 0;
  interact_queued = false;
}
