/* Portal controller. A door transition is prepared once, then the same
   immutable departure/arrival record drives the animated and instant paths. */

boolean doorTransitionActive(){
  return door_transition_phase != DOOR_PHASE_CLOSED;
}


boolean preparePortalTransition(int door){
  portal_transition_prepared = false;

  if (door < 0 || door >= DOOR_COUNT || door_room[door] != screen){
    return false;
  }

  int from_screen = screen;
  int target_screen = door_target[door];
  if (target_screen == SCREEN_NONE || target_screen == from_screen){
    return false;
  }

  boolean returning = last_portal_valid
    && last_portal_from_room == target_screen
    && last_portal_to_room == from_screen;

  portal_prepared_door = door;
  portal_prepared_from_room = from_screen;
  portal_prepared_target_room = target_screen;
  portal_prepared_return_door = doorInRoomLeadingTo(target_screen, from_screen);
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
}
