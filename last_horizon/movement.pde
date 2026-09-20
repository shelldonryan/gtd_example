/* Movimento do técnico: coordena a atualização por quadro e mantém a entrada
   modal fora da física. A resolução de gravidade, escadas e passos continua
   nas rotinas especializadas do sketch; esta aba reúne o fluxo que as chama. */

boolean useNearbyDoor(){
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
