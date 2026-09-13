boolean capture_mode = false;
boolean hit_test_mode = false;
boolean ladder_test_mode = false;
int capture_step = 0;
int capture_next_frame = 0;
final int CAPTURE_FIRST_FRAME = 4;
final int CAPTURE_FRAME_GAP = 3;
final int HIT_TEST_FRAME = 5;

String[] capture_label = {
  "menu_init", "vignette_1", "vignette_2", "vignette_3",
  "command_start", "briefing_console", "task_accepted", "silvia_dialog",
  "energy_entry", "map_position", "map_details", "energy_room",
  "task_completed", "task_locked", "dormitory", "end_day_summary",
  "end_day_cancelled", "end_day_confirm", "event_modal", "event_result",
  "pause", "game_over", "victory"
};


void readArgs(){
  if (args == null){
    return;
  }

  for (int i = 0; i < args.length; i++){
    capture_mode |= args[i].equals("--capture");
    hit_test_mode |= args[i].equals("--hit-test");
    ladder_test_mode |= args[i].equals("--ladder-test");
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

  if (!capture_mode || frameCount < CAPTURE_FIRST_FRAME
    || frameCount < capture_next_frame){
    return;
  }

  if (capture_step >= capture_label.length){
    runRuleChecks();
    exit();
    return;
  }

  saveCanvas(capture_step);
  runCaptureStep(capture_step);
  capture_step++;
  capture_next_frame = frameCount + CAPTURE_FRAME_GAP;
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
  } else if (step >= 1 && step <= 3){
    clickAction(ACTION_VIGNETTE_NEXT);
  } else if (step == 4){
    verify("vinheta inicia na Sala de comando", screen == SCREEN_COMMAND);
    verify("comida inicial 70", day == 1 && food == FOOD_START && FOOD_START == 70);
    engine_state = ENGINE_DAMAGED;
    setCapturePlayerAtPoint(POINT_COMMAND_BRIEFING);
    interactPoint(POINT_COMMAND_BRIEFING);
  } else if (step == 5){
    verify("console lista tarefas disponíveis", task_choice_open && task_choice_count > 0);
    interact_queued = true;
    updateTaskChoice();
  } else if (step == 6){
    verify("console exige escolha explícita", active_task != TASK_NONE && !action_used);
    captureReach(task_step_room[active_task][0], task_step_point[active_task][0]);
    interactPoint(task_step_point[active_task][0]);
  } else if (step == 7){
    verify("NPC abre diálogo modal", dialog_open);
    dialog_open = false;

    while (task_step_index < task_step_count[active_task]){
      int room = task_step_room[active_task][task_step_index];
      int point = task_step_point[active_task][task_step_index];
      captureReach(room, point);
      interactPoint(point);
      dialog_open = false;
    }

    enterRoomFrom(task_completion_room[active_task], -1);
  } else if (step == 8){
    verify("entrada pela esquerda preservada", player_x < ROOM_LEFT + 60);
    clickAction(ACTION_OPEN_MAP);
  } else if (step == 9){
    float before_x = player_x;
    int before_screen = screen;
    clickAction(ACTION_INSPECT_DORMITORY);
    verify("mapa não transporta o técnico", screen == before_screen && player_x == before_x);
  } else if (step == 10){
    verify("mapa mostra a ficha escolhida", map_open && map_selected_room == 3);
    clickAction(ACTION_CLOSE_MODAL);
  } else if (step == 11){
    captureReach(task_completion_room[active_task], task_completion_point[active_task]);
    interactPoint(task_completion_point[active_task]);
  } else if (step == 12){
    verify("ação final usa a tarefa do dia", action_used && active_task == TASK_NONE);
    enterRoom(SCREEN_COMMAND);
    setCapturePlayerAtPoint(POINT_COMMAND_BRIEFING);
    interactPoint(POINT_COMMAND_BRIEFING);
  } else if (step == 13){
    verify("segunda tarefa é bloqueada", technical_open && !task_choice_open);
    technical_open = false;
    enterRoom(SCREEN_DORMITORY);
  } else if (step == 14){
    setCapturePlayerAtPoint(POINT_TECH_BUNK);
    interactPoint(POINT_TECH_BUNK);
  } else if (step == 15){
    verify("beliche abre resumo previsto", end_day_open
      && dailyEnergyCost() > 0 && dailyOxygenCost() > 0);
    int before_day = day;
    float before_energy = energy;
    float before_oxygen = oxygen;
    float before_water = water;
    float before_food = food;
    float before_morale = morale;
    int before_item = held_item;
    clickAction(ACTION_CLOSE_MODAL);
    verify("cancelar resumo não altera estado", day == before_day
      && energy == before_energy && oxygen == before_oxygen
      && water == before_water && food == before_food && morale == before_morale
      && held_item == before_item && !end_day_open);
  } else if (step == 16){
    interactPoint(POINT_TECH_BUNK);
  } else if (step == 17){
    clickAction(ACTION_END_DAY);
  } else if (step == 18){
    verify("novo dia começa no Dormitório", day == 2 && screen == SCREEN_DORMITORY);
    verify("evento abre como modal", event_open && uiLayer() == LAYER_MODAL);
    clickAction(eventChoiceOn(0) ? ACTION_EVENT_A : ACTION_EVENT_B);
  } else if (step == 19){
    verify("evento devolve a exploração", !event_open && isRoomScreen());
    handleEscape();
  } else if (step == 20){
    clickAction(ACTION_RESUME);
    oxygen = 0;
    endDay();
  } else if (step == 21){
    resetRun();
    day = trip_days;
    engine_state = ENGINE_WORKING;
    enterRoom(SCREEN_DORMITORY);
    endDay();
  }
}


void runRuleChecks(){
  checkConnectedDoors();
  checkMapState();
  checkTaskRules();
  checkEndDayForecast();
  checkFailureRules();
}


void checkConnectedDoors(){
  resetRun();
  enterRoom(SCREEN_COMMAND);
  player_x = ROOM_RIGHT - 28 - PLAYER_W;
  player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
  boolean moved_right = useNearbyDoor();
  boolean right_entry = moved_right && screen == SCREEN_ENERGY && player_x < ROOM_LEFT + 60;
  verify("porta direita entra pela esquerda", right_entry);

  player_x = ROOM_LEFT + 20;
  boolean moved_left = useNearbyDoor();
  boolean left_entry = moved_left && screen == SCREEN_COMMAND && player_x > ROOM_RIGHT - 60;
  verify("porta esquerda entra pela direita", left_entry);
}


void checkMapState(){
  resetRun();
  enterRoom(SCREEN_DEPOT);
  active_task = TASK_REPAIR_HULL;
  task_step_index = 1;
  held_item = ITEM_SEAL_KIT;
  float before_x = player_x;
  int before_room = screen;
  int before_task = active_task;
  int before_item = held_item;
  map_open = true;
  map_selected_room = 0;
  map_open = false;
  verify("mapa preserva sala posição tarefa e item", screen == before_room
    && player_x == before_x && active_task == before_task && held_item == before_item);
}
void checkEndDayForecast(){
  resetRun();
  saving_on = true;
  rationing_on = true;
  leak_on = true;
  comms_silent = true;
  int energy_cost = dailyEnergyCost();
  int oxygen_cost = dailyOxygenCost();
  int water_cost = dailyWaterCost();
  int food_cost = dailyFoodCost();
  int morale_cost = dailyMoraleCost();
  float before_energy = energy;
  float before_oxygen = oxygen;
  float before_water = water;
  float before_food = food;
  float before_morale = morale;
  consumeResources();
  verify("resumo previsto corresponde ao consumo", energy == before_energy - energy_cost
    && oxygen == before_oxygen - oxygen_cost && water == before_water - water_cost
    && food == before_food - food_cost && morale == before_morale - morale_cost);
}




void checkTaskRules(){
  resetRun();
  engine_state = ENGINE_DAMAGED;
  enterRoom(SCREEN_COMMAND);
  interactPoint(POINT_VERA);
  verify("conversa não inicia tarefa", active_task == TASK_NONE && dialog_open);
  dialog_open = false;

  openTaskConsole();
  int selected = task_choice_indices[0];
  task_choice_open = false;
  beginTask(selected);
  verify("console inicia tarefa confirmada", active_task == selected);

  action_used = true;
  active_task = TASK_NONE;
  openTaskConsole();
  verify("uma tarefa por dia", technical_open && !task_choice_open);
  technical_open = false;

  system_message = "";
  verify("orientação não usa jargão", taskNextInstruction().indexOf("PASSOS LIVRES") < 0
    && taskNextInstruction().indexOf("PONTO FINAL") < 0);
}


void checkFailureRules(){
  resetRun();
  engine_state = ENGINE_DAMAGED;
  life_support_emergency = true;
  power_fault_on = true;
  comms_silent = true;
  verify("falha ativa não volta ao sorteio", !eventAllowed(EVENT_ENGINE)
    && !eventAllowed(EVENT_LIFE_SUPPORT) && !eventAllowed(EVENT_POWER)
    && !eventAllowed(EVENT_COMMS));

  resetRun();
  power_fault_on = true;
  parts = 0;
  water = 0;
  verify("variante ignora custo impagável", drawPowerVariant() == POWER_VARIANT_CABLE);

  resetRun();
  boolean no_repeat = true;
  int previous = EVENT_NONE;
  for (int i = 0; i < 40; i++){
    int drawn = pickEvent();
    if (drawn == previous){
      no_repeat = false;
    }
    previous = drawn;
  }
  verify("evento não repete imediatamente", no_repeat);
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
    float room_cx = room_x[i] + MAP_ROOM_W / 2.0;
    float room_cy = MAP_ROOM_Y + MAP_ROOM_H / 2.0;
    mouseX = int(room_cx * view_scale + view_offset_x);
    mouseY = int(room_cy * view_scale + view_offset_y);
    mouse_pressed = true;
    updateInput();
    verify("hit-test ficha " + room_label[i], map_selected_room == i
      && screen == before_screen && map_open);
  }

  int before_selection = map_selected_room;
  mouseX = 4;
  mouseY = 4;
  mouse_pressed = true;
  updateInput();
  verify("hit-test letterbox preserva mapa", map_open
    && map_selected_room == before_selection && screen == SCREEN_COMMAND);
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
  drawBase();
  base.save(sketchPath("output/ladder_middle_exit.png"));
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
  verify("ladder saída lateral", ladderExitAtMiddle(middle_y, ladder_player_x));
}


void testLadderCrossingExit(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y - 0.5);
  move_right_held = true;
  move_down_held = true;
  updatePlayerOnLadder();
  verify("ladder travessia lateral", ladderExitAtMiddle(middle_y, ladder_player_x));
}


boolean ladderExitAtMiddle(float middle_y, float ladder_player_x){
  return !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01 && player_x > ladder_player_x;
}


void testLadderStableExit(float middle_y){
  move_right_held = false;
  float exit_x = player_x;
  updatePlayerOnDeck();
  verify("ladder não reentra com direção mantida", !player_on_ladder
    && player_grounded && abs(player_y - middle_y) < 0.01
    && abs(player_x - exit_x) < 0.01);
}


void testLadderReleaseRearms(){
  move_down_held = false;
  updatePlayerOnDeck();
  move_down_held = true;
  updatePlayerOnDeck();
  verify("ladder rearma após soltar", player_on_ladder);
}


void testLadderIdleSnap(float middle_y, float ladder_player_x){
  placeLadderTestPlayer(ladder_player_x, middle_y + 2.5);
  move_right_held = false;
  move_down_held = false;
  updatePlayerOnLadder();
  verify("ladder encaixa no convés", !player_on_ladder && player_grounded
    && abs(player_y - middle_y) < 0.01);
}


void placeLadderTestPlayer(float x, float y){
  player_x = x;
  player_y = y;
  player_on_ladder = true;
  player_grounded = false;
}


void captureReach(int next_screen, int point){
  enterRoom(next_screen);
  setCapturePlayerAtPoint(point);
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


void typeText(String value){
  for (int i = 0; i < value.length(); i++){
    handleChar(value.charAt(i));
  }
}


void verify(String label, boolean passed){
  println("verify: " + label + " -> " + (passed ? "OK" : "FALHOU"));
}


String screenName(){
  if (screen == SCREEN_INIT) return "menu_init";
  if (screen == SCREEN_VIGNETTE) return "vinheta";
  if (screen == SCREEN_COMMAND) return "sala_comando";
  if (screen == SCREEN_ENERGY) return "sala_energia";
  if (screen == SCREEN_DEPOT) return "deposito";
  if (screen == SCREEN_DORMITORY) return "dormitorio";
  if (screen == SCREEN_VICTORY) return "vitoria";
  if (screen == SCREEN_GAME_OVER) return "derrota";
  return "desconhecida";
}
