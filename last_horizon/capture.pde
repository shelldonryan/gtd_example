/* capture - prova do sketch jogável fora da IDE.
   --capture     : salva um PNG por estado em output/ e encerra sozinho.
   --hit-test    : prova a conversão mouse -> base fora de 16:9.
   --ladder-test : verifica encaixe e saída da escada no convés médio. */

boolean capture_mode = false;
boolean hit_test_mode = false;
boolean ladder_test_mode = false;
int capture_step = 0;
final int CAPTURE_FIRST_FRAME = 4;
final int CAPTURE_FRAME_GAP = 3;
final int HIT_TEST_FRAME = 5;
int capture_next_frame = 0;
int capture_gap = CAPTURE_FRAME_GAP;

String[] capture_label = {
  "menu_init", "vignette_1", "vignette_2", "vignette_3",
  "ship_day1", "hud_alert_a", "hud_alert_b", "energy_walking",
  "energy_ladder", "energy_silvia", "ship_after_silvia", "room_depot",
  "depot_bento", "item_in_hand", "ship_after_item", "room_energy",
  "task_completed", "ship_after_task", "room_command", "ship_after_command",
  "room_dormitory", "ship_after_dormitory", "event_card", "ship_day2",
  "pause", "ship_day2_resumed", "game_over", "menu_init_again",
  "ship_last_day", "victory"
};


void readArgs(){
  if (args == null){
    return;
  }

  for (int i = 0; i < args.length; i++){
    if (args[i].equals("--capture")){
      capture_mode = true;
    }

    if (args[i].equals("--hit-test")){
      hit_test_mode = true;
    }

    if (args[i].equals("--ladder-test")){
      ladder_test_mode = true;
    }
  }

  if (capture_mode || ladder_test_mode){
    new File(sketchPath("output")).mkdirs();
  }
}


void updateCapture(){
  if (hit_test_mode && frameCount == HIT_TEST_FRAME){
    runHitTest();
    return;
  }

  if (ladder_test_mode && frameCount == HIT_TEST_FRAME){
    runLadderTest();
    return;
  }

  if (!capture_mode || frameCount < CAPTURE_FIRST_FRAME){
    return;
  }

  if (frameCount < capture_next_frame){
    return;
  }

  if (capture_step >= capture_label.length){
    exit();
    return;
  }

  saveCanvas(capture_step);
  runCaptureStep(capture_step);

  capture_step++;
  capture_next_frame = frameCount + capture_gap;
  capture_gap = CAPTURE_FRAME_GAP;
}


void saveCanvas(int step){
  String name = "output/" + nf(step + 1, 2) + "_" + capture_label[step];

  base.save(sketchPath(name + ".png"));
  saveFrame(sketchPath(name + "_window.png"));
  println("capture: " + capture_label[step] + " -> " + screenName());
}


void runCaptureStep(int step){
  if (step == 0){
    typeText("TECNICO");
    clickAction(ACTION_START_GAME);
    return;
  }

  if (step <= 3){
    clickAction(ACTION_VIGNETTE_NEXT);
    return;
  }

  if (step <= 9){
    runEnergyCaptureStep(step);
    return;
  }

  if (step <= 13){
    runDepotCaptureStep(step);
    return;
  }

  if (step <= 16){
    runCompletionCaptureStep(step);
    return;
  }

  if (step <= 20){
    runRoomCoverageCaptureStep(step);
    return;
  }

  runEndgameCaptureStep(step);
}


void runEnergyCaptureStep(int step){
  if (step == 4){
    engine_state = ENGINE_DAMAGED;
    energy = 20;
    clickAction(ACTION_OPEN_ENERGY);
    return;
  }

  if (step == 5){
    capture_gap = 32;
    return;
  }

  if (step == 6){
    player_x = 100;
    player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
    player_grounded = true;
    move_right_held = true;
    return;
  }

  if (step == 7){
    player_x = ladder_x[0] - PLAYER_W / 2.0;
    player_y = deck_y[1] - PLAYER_H;
    player_grounded = false;
    player_on_ladder = true;
    move_right_held = false;
    move_up_held = true;
    return;
  }

  if (step == 8){
    setCapturePlayerAtPoint(POINT_SILVIA);
    interactPoint(POINT_SILVIA);
    println("verify: passo intermediário não gasta ação -> "
      + (!action_used && active_task == TASK_REPAIR_ENGINE ? "OK" : "FALHOU"));
    return;
  }

  clickAction(ACTION_BACK_TO_SHIP);
}


void runDepotCaptureStep(int step){
  if (step == 10){
    clickAction(ACTION_OPEN_DEPOT);
    return;
  }

  if (step == 11){
    setCapturePlayerAtPoint(POINT_BENTO);
    interactPoint(POINT_BENTO);
    println("verify: item persistente na mão -> "
      + (held_item == ITEM_ENGINE_PARTS && !action_used ? "OK" : "FALHOU"));
    return;
  }

  if (step == 12){
    return;
  }

  clickAction(ACTION_BACK_TO_SHIP);
}


void runCompletionCaptureStep(int step){
  if (step == 14){
    clickAction(ACTION_OPEN_ENERGY);
    return;
  }

  if (step == 15){
    setCapturePlayerAtPoint(POINT_ENGINE_BENCH);
    boolean was_used = action_used;
    interactPoint(POINT_ENGINE_BENCH);
    println("verify: conclusão é o único consumo da ação -> "
      + (!was_used && action_used && active_task == TASK_NONE ? "OK" : "FALHOU"));
    return;
  }

  clickAction(ACTION_BACK_TO_SHIP);
}


void runRoomCoverageCaptureStep(int step){
  if (step == 17){
    clickAction(ACTION_OPEN_COMMAND);
    return;
  }

  if (step == 18){
    clickAction(ACTION_BACK_TO_SHIP);
    return;
  }

  if (step == 19){
    clickAction(ACTION_OPEN_DORMITORY);
    return;
  }

  clickAction(ACTION_BACK_TO_SHIP);
}


void runEndgameCaptureStep(int step){
  if (step == 21){
    clickAction(ACTION_PASS_DAY);
    return;
  }

  if (step == 22){
    clickAction(eventChoiceOn(0) ? ACTION_EVENT_A : ACTION_EVENT_B);
    return;
  }

  if (step == 23){
    handleEscape();
    return;
  }

  if (step == 24){
    clickAction(ACTION_RESUME);
    return;
  }

  if (step == 25){
    oxygen = 0;
    clickAction(ACTION_PASS_DAY);
    return;
  }

  if (step == 26){
    clickAction(ACTION_NEW_GAME);
    return;
  }

  if (step == 27){
    resetRun();
    day = trip_days;
    openDay();
    screen = SCREEN_SHIP;
    event_open = false;
    return;
  }

  if (step == 28){
    clickAction(ACTION_PASS_DAY);
  }
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
    if (button_action[i] != action || !button_on[i] || button_layer[i] != uiLayer()){
      continue;
    }

    handleClick(button_x[i], button_y[i]);
    drawBase();
    return;
  }

  println("capture: botao " + action + " indisponivel na tela " + screenName());
}


void typeText(String value){
  for (int i = 0; i < value.length(); i++){
    handleChar(value.charAt(i));
  }
}


void runHitTest(){
  int[] expected = {SCREEN_COMMAND, SCREEN_ENERGY, SCREEN_DEPOT, SCREEN_DORMITORY};

  println("hit-test: janela " + width + "x" + height + " | escala " + view_scale
    + " | offset " + int(view_offset_x) + "," + int(view_offset_y)
    + " | base " + BASE_W + "x" + BASE_H);

  for (int i = 0; i < ROOM_COUNT; i++){
    screen = SCREEN_SHIP;
    paused = false;
    event_open = false;
    drawBase();

    float room_cx = room_x[i] + ROOM_W / 2.0;
    float room_cy = ROOM_Y + ROOM_H / 2.0;

    mouseX = int(room_cx * view_scale + view_offset_x);
    mouseY = int(room_cy * view_scale + view_offset_y);
    mouse_pressed = true;
    updateInput();

    println("hit-test: clique na janela (" + mouseX + "," + mouseY + ") -> base ("
      + int(base_mouse_x) + "," + int(base_mouse_y) + ") -> cômodo " + room_label[i]
      + " -> tela " + screenName() + (screen == expected[i] ? " OK" : " FALHOU"));
  }

  screen = SCREEN_SHIP;
  drawBase();
  mouseX = 4;
  mouseY = 4;
  mouse_pressed = true;
  updateInput();

  println("hit-test: clique no letterbox (" + mouseX + "," + mouseY + ") -> base ("
    + int(base_mouse_x) + "," + int(base_mouse_y) + ") -> tela " + screenName()
    + (screen == SCREEN_SHIP ? " OK" : " FALHOU"));

  exit();
}


void runLadderTest(){
  resetRun();
  enterRoom(SCREEN_ENERGY);

  float middle_y = deck_y[1] - PLAYER_H;
  float ladder_player_x = ladder_x[0] - PLAYER_W / 2.0;

  testLadderLateralExit(middle_y, ladder_player_x);
  testLadderCrossingExit(middle_y, ladder_player_x);
  testLadderStableExit(middle_y);
  saveLadderTestCapture();
  testLadderReleaseRearms();
  testLadderIdleSnap(middle_y, ladder_player_x);
  exit();
}


void testLadderLateralExit(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y + 2.5);
  move_right_held = true;
  move_up_held = false;
  move_down_held = false;
  updatePlayerOnLadder();
  reportLadderExit("saída lateral no convés médio", ladderExitAtMiddle(middle_y, ladder_player_x));
}


void testLadderCrossingExit(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y - 0.5);
  move_right_held = true;
  move_down_held = true;
  updatePlayerOnLadder();
  reportLadderExit("travessia lateral captura o convés médio", ladderExitAtMiddle(middle_y, ladder_player_x));
}


boolean ladderExitAtMiddle(float middle_y, float ladder_player_x){
  return !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01 && player_x > ladder_player_x;
}


void reportLadderExit(String label, boolean passed){
  println("ladder-test: " + label + " -> " + (passed ? "OK" : "FALHOU"));
}


void testLadderStableExit(float middle_y){
  move_right_held = false;
  float exit_x = player_x;
  updatePlayerOnDeck();

  boolean passed = !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01 && abs(player_x - exit_x) < 0.01;
  println("ladder-test: direção vertical mantida não reentra na escada -> "
    + (passed ? "OK" : "FALHOU"));
}


void saveLadderTestCapture(){
  drawBase();
  base.save(sketchPath("output/ladder_middle_exit.png"));
  println("ladder-test: captura -> output/ladder_middle_exit.png");
}


void testLadderReleaseRearms(){
  move_down_held = false;
  updatePlayerOnDeck();
  move_down_held = true;
  updatePlayerOnDeck();

  println("ladder-test: soltar vertical rearma a entrada -> "
    + (player_on_ladder ? "OK" : "FALHOU"));
}


void testLadderIdleSnap(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y + 2.5);
  move_right_held = false;
  move_down_held = false;
  updatePlayerOnLadder();

  boolean passed = !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01;
  println("ladder-test: parada próxima encaixa no convés médio -> "
    + (passed ? "OK" : "FALHOU"));
}


void placeLadderTestPlayer(float x, float y){
  player_x = x;
  player_y = y;
  player_on_ladder = true;
  player_grounded = false;
}


String screenName(){
  if (screen == SCREEN_INIT){
    return "menu_init";
  }

  if (screen == SCREEN_VIGNETTE){
    return "vinheta";
  }

  if (screen == SCREEN_SHIP){
    return "nave";
  }

  if (screen == SCREEN_COMMAND){
    return "sala_comando";
  }

  if (screen == SCREEN_ENERGY){
    return "sala_energia";
  }

  if (screen == SCREEN_DEPOT){
    return "deposito";
  }

  if (screen == SCREEN_DORMITORY){
    return "dormitorio";
  }

  if (screen == SCREEN_VICTORY){
    return "vitoria";
  }

  return "derrota";
}
