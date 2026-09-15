boolean capture_mode = false;
boolean hit_test_mode = false;
boolean ladder_test_mode = false;
boolean pipeline_test_mode = false;
PImage pipeline_probe_image;
PGraphics pipeline_probe_layer;
final int PIPELINE_TEST_FRAME = 4;
final int PIPELINE_PROBE_SIZE = 16;
final String PIPELINE_PROBE_FILE = "pipeline_probe_frame_1.png";

int capture_step = 0;
int capture_next_frame = 0;
final int CAPTURE_FIRST_FRAME = 4;
final int CAPTURE_FRAME_GAP = 3;
final int HIT_TEST_FRAME = 5;

String[] capture_label = {
  "menu_init", "vignette_1", "vignette_2", "vignette_3",
  "incident_day_1", "problem_persistent", "map_position", "map_problems",
  "command_hub", "machines_entry", "problem_repaired", "dormitory",
  "end_day_summary", "end_day_cancelled", "day_2", "survivor_at_risk",
  "survivor_rescued", "pause", "game_over", "victory",
  "distribution_panel", "risk_visible", "dense_end_day"
};


void readArgs(){
  if (args == null){
    return;
  }

  for (int i = 0; i < args.length; i++){
    capture_mode |= args[i].equals("--capture");
    hit_test_mode |= args[i].equals("--hit-test");
    ladder_test_mode |= args[i].equals("--ladder-test");
    pipeline_test_mode |= args[i].equals("--asset-pipeline-test");
  }

  if (pipeline_test_mode){
    pipeline_probe_image = loadImage(PIPELINE_PROBE_FILE);
    preparePipelineProbe();
  }

  if (capture_mode || ladder_test_mode || pipeline_test_mode){
    new File(sketchPath("output")).mkdirs();
  }
}

void preparePipelineProbe(){
  pipeline_probe_layer = createGraphics(
    PIPELINE_PROBE_SIZE * RENDER_SCALE,
    PIPELINE_PROBE_SIZE * RENDER_SCALE
  );
  pipeline_probe_layer.noSmooth();
  pipeline_probe_layer.beginDraw();
  pipeline_probe_layer.clear();
  pipeline_probe_layer.imageMode(CENTER);
  if (pipeline_probe_image != null){
    pipeline_probe_layer.image(
      pipeline_probe_image,
      PIPELINE_PROBE_SIZE * RENDER_SCALE / 2,
      PIPELINE_PROBE_SIZE * RENDER_SCALE / 2,
      PIPELINE_PROBE_SIZE * RENDER_SCALE,
      PIPELINE_PROBE_SIZE * RENDER_SCALE
    );
  }
  pipeline_probe_layer.endDraw();
}



void updateCapture(){
  if (pipeline_test_mode && frameCount == PIPELINE_TEST_FRAME){
    runPipelineProbe();
    return;
  }

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


void runPipelineProbe(){
  boolean loaded = pipeline_probe_image != null
    && pipeline_probe_image.width == PIPELINE_PROBE_SIZE
    && pipeline_probe_image.height == PIPELINE_PROBE_SIZE;

  base.save(sketchPath("output/pipeline_probe.png"));
  saveFrame(sketchPath("output/pipeline_probe_window.png"));

  if (loaded){
    println("pipeline: OK - " + PIPELINE_PROBE_FILE
      + " carregado via loadImage()");
  } else {
    println("pipeline: FALHOU - " + PIPELINE_PROBE_FILE
      + " não foi carregado");
  }

  exit();
}


void drawPipelineProbe(PGraphics target){
  target.background(COL_BG);
  target.fill(COL_CYAN);
  target.textSize(16);
  target.text("ASSET PIPELINE", 24, 24);
  target.fill(COL_TEXT);
  target.textSize(12);
  target.text("ASEPRITE -> PNG -> loadImage()", 24, 48);

  target.fill(COL_PANEL);
  target.rect(244, 96, 152, 152);
  if (pipeline_probe_layer != null){
    target.image(pipeline_probe_layer, BASE_W / 2, 172,
      PIPELINE_PROBE_SIZE, PIPELINE_PROBE_SIZE);
  }

  target.fill(COL_TEXT);
  target.text("16 x 16 PNG / render lógico 2x", 24, 278);
  target.fill(COL_MUTED);
  target.text("pixel art sem interpolação", 24, 300);
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
    verify("incidente surge no dia 1", day == 1 && event_open);
    verify("comida inicial 70", food == FOOD_START && FOOD_START == 70);
    clickAction(eventChoiceOn(0) ? ACTION_EVENT_A : ACTION_EVENT_B);
  } else if (step == 5){
    verify("contenção mantém problema persistente",
      problem_active[event_index] && !intervention_used);
    clickAction(ACTION_OPEN_MAP);
  } else if (step == 6){
    float before_x = player_x;
    int before_screen = screen;
    clickAction(ACTION_INSPECT_COMMAND + roomIndex(problem_room[event_index]));
    verify("mapa não transporta o técnico", screen == before_screen && player_x == before_x);
  } else if (step == 7){
    verify("mapa seleciona sala com problema",
      map_open && room_screen[map_selected_room] == problem_room[event_index]);
    clickAction(ACTION_CLOSE_MODAL);
    enterRoomAtDeck(SCREEN_COMMAND, 2, -1);
  } else if (step == 8){
    player_x = ROOM_RIGHT - 28 - PLAYER_W;
    verify("hub abre Máquinas pelo convés inferior",
      useNearbyDoor() && screen == SCREEN_MACHINES);
  } else if (step == 9){
    activateProblem(PROBLEM_ENGINE, 3);
    setCapturePlayerAtPoint(POINT_ENGINE_BENCH);
    interactPoint(POINT_ENGINE_BENCH);
  } else if (step == 10){
    verify("correção remove problema e usa intervenção",
      !problem_active[PROBLEM_ENGINE] && intervention_used);
    enterRoom(SCREEN_DORMITORY);
  } else if (step == 11){
    setCapturePlayerAtPoint(POINT_TECH_BUNK);
    interactPoint(POINT_TECH_BUNK);
  } else if (step == 12){
    verify("beliche mostra resumo", end_day_open);
    clickAction(ACTION_CLOSE_MODAL);
  } else if (step == 13){
    verify("cancelar resumo preserva o dia", day == 1 && !end_day_open);
    interactPoint(POINT_TECH_BUNK);
    clickAction(ACTION_END_DAY);
  } else if (step == 14){
    verify("dia sem incidente começa no Dormitório",
      day == 2 && screen == SCREEN_DORMITORY && !event_open);
    putSurvivorAtRisk(PROBLEM_CONFLICT);
  } else if (step == 15){
    setCapturePlayerAtPoint(POINT_RISK_BUNK);
    interactPoint(POINT_RISK_BUNK);
  } else if (step == 16){
    verify("socorro estabiliza pessoa e usa intervenção",
      riskCount() == 0 && intervention_used);
    handleEscape();
  } else if (step == 17){
    clickAction(ACTION_RESUME);
    oxygen = 0;
    checkEndConditions();
  } else if (step == 18){
    resetRun();
    event_open = false;
    resetProblemState();
    day = TRIP_DAYS;
    enterRoom(SCREEN_DORMITORY);
    endDay();
  } else if (step == 19){
    resetRun();
    event_open = false;
    resetProblemState();
    day = 3;
    activateProblem(PROBLEM_POWER, 4);
    held_item = ITEM_FUSE;
    enterRoom(SCREEN_MACHINES);
    setCapturePlayerAtPoint(POINT_DISTRIBUTION);
    interactPoint(POINT_DISTRIBUTION);
  } else if (step == 20){
    verify("painel de distribuição reúne reparo e economia",
      technical_open && pending_panel_choice == POINT_DISTRIBUTION);
    applyPanelRepair();
    putSurvivorAtRisk(PROBLEM_CONFLICT);
    enterRoom(SCREEN_DORMITORY);
  } else if (step == 21){
    verify("risco aparece na faixa do HUD", urgentRisk() >= 0
      && pointDisplayLabel(POINT_RISK_BUNK).indexOf("2D") > 0);
    activateProblem(PROBLEM_CONFLICT, 3);
    activateProblem(PROBLEM_LIFE_SUPPORT, 4);
    activateProblem(PROBLEM_FOOD, 4);
    activateProblem(PROBLEM_HULL, 2);
    setCapturePlayerAtPoint(POINT_TECH_BUNK);
    interactPoint(POINT_TECH_BUNK);
  } else if (step == 22){
    verify("resumo lista os problemas ativos", end_day_open
      && activeProblemCount() == 4);
    clickAction(ACTION_CLOSE_MODAL);
  }
}


void runRuleChecks(){
  checkConnectedDoors();
  checkMapState();
  checkTaskRules();
  checkPlayerFacing();
  checkPlayerAnimationLoop();
  checkKeyboardModalButtons();
  checkEndDayForecast();
  checkFailureRules();
  checkHullDamageLocation();
  checkInterventionRules();
  checkCrewRules();
}

void checkPlayerFacing(){
  resetRun();
  move_left_held = true;
  updatePlayerFacing();
  verify("jogador olha para a esquerda", player_facing == -1);

  move_left_held = false;
  move_right_held = true;
  updatePlayerFacing();
  verify("jogador olha para a direita", player_facing == 1);

  move_right_held = false;
  enterRoomAtDeck(SCREEN_MACHINES, roomDoorDeck(SCREEN_MACHINES), -1);
  player_x = ROOM_LEFT + 20;
  useNearbyDoor();
  verify("retorno ao hub olha para a esquerda",
    screen == SCREEN_COMMAND && player_facing == -1);
}

void checkPlayerAnimationLoop(){
  if (!player_assets_loaded){
    verify("spritesheet do jogador carregada", false);
    return;
  }

  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  player_animation_moving = false;
  player_animation_started_at = millis() - 1000;
  verify("idle entra em loop", playerCurrentFrame() == player_idle_start);

  move_right_held = true;
  player_animation_moving = true;
  player_animation_started_at = millis() - 800;
  verify("walk entra em loop", playerCurrentFrame() == player_walk_start);
  move_right_held = false;
}


void checkConnectedDoors(){
  int[] destinations = {SCREEN_DORMITORY, SCREEN_DEPOT, SCREEN_MACHINES};
  for (int deck = 0; deck < DECK_COUNT; deck++){
    resetRun();
    event_open = false;
    enterRoomAtDeck(SCREEN_COMMAND, deck, -1);
    player_x = ROOM_RIGHT - 28 - PLAYER_W;
    verify("hub abre porta do convés " + deck,
      useNearbyDoor() && screen == destinations[deck]);
    player_x = ROOM_LEFT + 20;
    verify("sala periférica retorna ao mesmo convés",
      useNearbyDoor() && screen == SCREEN_COMMAND
      && abs(player_y + PLAYER_H - deck_y[deck]) <= 3);
  }
}


void checkMapState(){
  resetRun();
  event_open = false;
  activateProblem(PROBLEM_FOOD, 4);
  enterRoom(SCREEN_DEPOT);
  held_item = ITEM_SEAL_KIT;
  float before_x = player_x;
  int before_room = screen;
  int before_item = held_item;
  map_open = true;
  map_selected_room = 0;
  map_open = false;
  verify("mapa preserva sala posição e componente", screen == before_room
    && player_x == before_x && held_item == before_item);
  verify("mapa agrupa problema pela sala",
    roomProblemCount(SCREEN_DEPOT) == 1 && problem_room[PROBLEM_FOOD] == SCREEN_DEPOT);

  resetProblemState();
  activateProblem(PROBLEM_ENGINE, 3);
  activateProblem(PROBLEM_LIFE_SUPPORT, 4);
  activateProblem(PROBLEM_POWER, 2);
  activateProblem(PROBLEM_HULL, 3);
  problem_room[PROBLEM_HULL] = SCREEN_MACHINES;
  enterRoom(SCREEN_MACHINES);
  map_open = true;
  map_selected_room = roomIndex(SCREEN_MACHINES);
  drawBase();
  base.save(sketchPath("output/map_dense.png"));
  verify("mapa comporta a sala mais carregada", roomProblemCount(SCREEN_MACHINES) == 4);
}
void checkEndDayForecast(){
  resetRun();
  event_open = false;
  resetProblemState();
  saving_on = true;
  rationing_on = true;
  activateProblem(PROBLEM_HULL, 3);
  float before_energy = energy;
  float before_oxygen = oxygen;
  float before_water = water;
  float before_food = food;
  float before_morale = morale;
  endDay();
  verify("dormir processa políticas consumo e perdas na ordem",
    energy == before_energy - 3
    && oxygen == before_oxygen - 5 - 5
    && water == before_water - 4
    && food == before_food - 3
    && morale == before_morale - 2 - 2);
}




void checkTaskRules(){
  resetRun();
  openDay();
  verify("dia 1 abre incidente", event_open && day == 1);
  int problem = event_index;
  applyEventChoice(0);
  verify("contenção cria problema persistente",
    !event_open && problem_active[problem] && problem_deadline[problem] > 0);
  verify("problema nasce sem intervenção usada", !intervention_used);

  intervention_used = true;
  verify("segunda intervenção é bloqueada", !canUseMainIntervention());
}


void checkKeyboardModalButtons(){
  resetRun();
  event_open = false;
  resetProblemState();
  enterRoom(SCREEN_MACHINES);
  setCapturePlayerAtPoint(POINT_DISTRIBUTION);
  interactPoint(POINT_DISTRIBUTION);
  verify("distribuição alterna economia sem falha ativa", technical_open
    && pending_switch_point == POINT_DISTRIBUTION);
  pressEnter();
  verify("ENTER confirma economia", !technical_open && saving_on);

  activateProblem(PROBLEM_POWER, 4);
  held_item = ITEM_FUSE;
  int before_parts = parts;
  interactPoint(POINT_DISTRIBUTION);
  verify("distribuição oferece reparo e economia juntos",
    technical_open && pending_panel_choice == POINT_DISTRIBUTION && canRepairPower());
  pressEnter();
  verify("ENTER repara a energia no painel",
    !technical_open && !problem_active[PROBLEM_POWER]
    && held_item == ITEM_NONE && parts == before_parts - 1);

  enterRoom(SCREEN_DORMITORY);
  setCapturePlayerAtPoint(POINT_TECH_BUNK);
  interactPoint(POINT_TECH_BUNK);
  verify("beliche abre encerramento", end_day_open);
  pressEnter();
  verify("ENTER encerra o dia", !end_day_open && day == 2);
}

void checkFailureRules(){
  resetRun();
  boolean distinct = true;
  for (int i = 0; i < incident_sequence.length; i++){
    for (int j = i + 1; j < incident_sequence.length; j++){
      if (incident_sequence[i] == incident_sequence[j]) distinct = false;
    }
  }
  verify("cinco incidentes não repetem", distinct);
  verify("incidentes usam dias alternados", incidentForDay(1) != PROBLEM_NONE
    && incidentForDay(2) == PROBLEM_NONE && incidentForDay(9) != PROBLEM_NONE);

  resetProblemState();
  incident_sequence[0] = PROBLEM_ENGINE;
  day = 1;
  energy = 4;
  morale = 1;
  openDay();
  verify("contenção impagável causa crise imediata",
    engine_state == ENGINE_DESTROYED && !event_open);

  resetRun();
  event_open = false;
  resetProblemState();
  activateProblem(PROBLEM_FOOD, 2);
  activateProblem(PROBLEM_CONFLICT, 2);
  verify("empate prioriza problema mais antigo", urgentProblem() == PROBLEM_FOOD);
}


void checkHullDamageLocation(){
  boolean reachable = true;
  boolean varied_room = false;
  int first_room = SCREEN_NONE;
  resetRun();
  event_open = false;
  boolean hidden_when_inactive = point_room[POINT_HULL] == SCREEN_NONE;
  randomSeed(97031);

  for (int sample = 0; sample < 32; sample++){
    clearProblem(PROBLEM_HULL);
    activateProblem(PROBLEM_HULL, 2);
    int hull_room = point_room[POINT_HULL];
    boolean known_room = hull_room == SCREEN_COMMAND || hull_room == SCREEN_MACHINES
      || hull_room == SCREEN_DEPOT || hull_room == SCREEN_DORMITORY;
    boolean known_deck = isDeckSurface(point_y[POINT_HULL]);
    boolean inside_room = point_x[POINT_HULL] >= ROOM_LEFT + 28
      && point_x[POINT_HULL] <= ROOM_RIGHT - 28;
    reachable &= known_room && known_deck && inside_room
      && problem_room[PROBLEM_HULL] == hull_room;
    if (sample == 0) first_room = hull_room;
    else if (hull_room != first_room) varied_room = true;
  }

  verify("dano no casco fica oculto sem problema", hidden_when_inactive);
  verify("dano no casco surge em ponto alcançável", reachable);
  verify("dano no casco varia entre cômodos", varied_room);
  held_item = ITEM_SEAL_KIT;
  parts = 2;
  intervention_used = false;
  tryRepairProblem(PROBLEM_HULL);
  verify("reparo remove o ponto do casco",
    !problem_active[PROBLEM_HULL] && point_room[POINT_HULL] == SCREEN_NONE);
}

void checkInterventionRules(){
  resetRun();
  event_open = false;
  resetProblemState();
  day = 2;
  enterRoom(SCREEN_COMMAND);
  interactPoint(POINT_ROUTE);
  verify("rota pede confirmação antes da aceleração",
    technical_open && pending_intervention_point == POINT_ROUTE && !intervention_used);
  pressEnter();
  verify("aceleração usa intervenção e marca dia eliminado",
    intervention_used && skip_next_day && energy == 90);
  endDay();
  verify("aceleração elimina consumo e incidente do próximo dia",
    day == 4 && !event_open);
}

void checkCrewRules(){
  resetRun();
  event_open = false;
  day = 1;
  putSurvivorAtRisk(PROBLEM_CONFLICT);
  verify("risco do conflito segue a ordem do modelo", crew_risk_deadline[CREW_SILVIA] == 2);
  putSurvivorAtRisk(PROBLEM_LIFE_SUPPORT);
  verify("segundo risco não repete a pessoa", riskCount() == 2
    && crew_risk_deadline[CREW_VERA] == 2);

  resetRun();
  event_open = false;
  crew_risk_deadline[CREW_VERA] = 2;
  crew_risk_order[CREW_VERA] = 1;
  crew_risk_deadline[CREW_BENTO] = 1;
  crew_risk_order[CREW_BENTO] = 2;
  verify("socorro prioriza menor prazo", urgentRisk() == CREW_BENTO);
  crew_risk_deadline[CREW_BENTO] = 2;
  verify("socorro desempata pelo risco mais antigo", urgentRisk() == CREW_VERA);

  resetRun();
  event_open = false;
  crew_risk_deadline[CREW_SILVIA] = 1;
  processSurvivorRisks();
  activateProblem(PROBLEM_ENGINE, 3);
  int before_parts = parts;
  tryRepairProblem(PROBLEM_ENGINE);
  verify("morte remove benefício sem bloquear reparo",
    !crew_alive[CREW_SILVIA] && survivors == 3
    && !problem_active[PROBLEM_ENGINE] && parts == before_parts - 3);

  resetRun();
  event_open = false;
  crew_alive[CREW_BENTO] = false;
  float before_morale = morale;
  toggleSaving();
  verify("política custa mais sem Bento", saving_on && morale == before_morale - 4);
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
    mouseX = int(room_cx * RENDER_SCALE * view_scale + view_offset_x);
    mouseY = int(room_cy * RENDER_SCALE * view_scale + view_offset_y);
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
  enterRoom(SCREEN_MACHINES);
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
void pressEnter(){
  enter_pressed = true;
  updateInput();
  if (isRoomScreen()){
    updateRoom();
  }
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
  if (screen == SCREEN_MACHINES) return "sala_maquinas";
  if (screen == SCREEN_DEPOT) return "deposito";
  if (screen == SCREEN_DORMITORY) return "dormitorio";
  if (screen == SCREEN_VICTORY) return "vitoria";
  if (screen == SCREEN_GAME_OVER) return "derrota";
  return "desconhecida";
}
