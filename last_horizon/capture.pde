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
  "menu_init", "vignette_1", "vignette_2", "vignette_3", "preventive_offers",
  "preventive_selected", "preventive_confirmation", "quest_collect_route", "quest_map",
  "quest_collect_confirmation", "quest_carrying", "quest_delivery_confirmation", "preventive_reward",
  "night_forecast", "incident_choices", "incident_confirmation", "urgent_collect",
  "urgent_carrying", "urgent_delivery", "urgent_solved", "preventive_failure",
  "preventive_neglect", "urgent_retry", "survivor_risk", "rescue_confirmation",
  "survivor_rescued", "pause", "defeat", "victory", "dense_night_forecast"
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
  if (step == 0){ typeText("TECNICO"); clickAction(ACTION_START_GAME); }
  else if (step >= 1 && step <= 3) clickAction(ACTION_VIGNETTE_NEXT);
  else if (step == 4){
    verify("dia 1 começa livre com ofertas disponíveis", day == 1 && screen == SCREEN_COMMAND && !modalOpen() && ordersAvailable());
    clickAction(ACTION_OPEN_ORDERS);
    base.save(sketchPath("output/preventive_offers_manual.png"));
    clickAction(ACTION_ORDER_A);
  } else if (step == 5){
    captureInteract(POINT_VERA);
  } else if (step == 6){
    verify("escolha remota não aceita ordem", active_quest < 0 && dialog_open);
    pressEnter();
    verify("aceite presencial habilita coleta", active_quest == 0 && quest_stage == QUEST_COLLECT);
  } else if (step == 7){ clickAction(ACTION_OPEN_MAP); }
  else if (step == 8){
    float before = player_x;
    int before_room = screen;
    clickAction(ACTION_INSPECT_DEPOT);
    verify("mapa não transporta", screen == before_room && player_x == before);
    clickAction(ACTION_CLOSE_MODAL);
    captureInteract(POINT_RESERVE);
  } else if (step == 9){
    verify("coleta aguarda confirmação", held_item == ITEM_NONE && technical_open);
    pressEnter();
  } else if (step == 10){ captureInteract(POINT_ANTENNA); }
  else if (step == 11){
    verify("entrega aguarda confirmação", morale == 80 && held_item != ITEM_NONE);
    pressEnter();
    verify("preventiva recompensa e conclui", morale == 88 && quest_completed && held_item == ITEM_NONE);
  } else if (step == 12){ captureInteract(POINT_TECH_BUNK); }
  else if (step == 13){
    incident_sequence[0] = PROBLEM_ENGINE;
    pressEnter();
    verify("dormir aplica consumo e abre incidente", day == 2 && event_open && energy == 73 && morale == 86);
  } else if (step == 14){ clickAction(ACTION_EVENT_A); }
  else if (step == 15){
    verify("solução exige confirmação", event_open && active_quest < 0);
    pressEnter();
  } else if (step == 16){ captureInteract(POINT_ROUTE); pressEnter(); }
  else if (step == 17){ captureInteract(POINT_ENGINE_BENCH); }
  else if (step == 18){
    pressEnter();
    verify("entrega urgente paga e remove problema", parts == 2 && !problem_active[PROBLEM_ENGINE] && quest_completed);
  } else if (step == 19){
    captureSleep();
    verify("dia tranquilo não abre ordens automaticamente", !orders_open && ordersAvailable());
    clickAction(ACTION_OPEN_ORDERS);
    clickAction(ACTION_ORDER_A);
    captureInteract(POINT_VERA); pressEnter();
    captureInteract(POINT_TECH_BUNK);
  } else if (step == 20){
    verify("previsão mostra falha aceita", preventiveNightLoss(RESOURCE_ENERGY) == 3);
    closeTopModal();
    captureStartDay(3);
    captureInteract(POINT_TECH_BUNK);
  } else if (step == 21){
    verify("previsão mostra duas perdas", preventiveNightLoss(RESOURCE_ENERGY) == 4 && preventiveNightLoss(RESOURCE_WATER) == 4);
    captureStartDay(2);
    applyEventChoice(0); pressEnter(); captureSleep();
    clickAction(ACTION_OPEN_ORDERS);
    clickAction(ACTION_NEXT_RETRY);
  } else if (step == 22){
    verify("retomada mantém solução e prazo", orders_page == PROBLEM_ENGINE && problem_deadline[PROBLEM_ENGINE] == 2);
    closeTopModal();
    putSurvivorAtRisk(PROBLEM_CONFLICT);
    enterRoom(SCREEN_DORMITORY);
  } else if (step == 23){ captureInteract(POINT_RISK_BUNK); }
  else if (step == 24){
    pressEnter();
    verify("socorro usa quest sem cancelar negligência", urgentRisk() < 0 && quest_completed && preventiveNightLoss(RESOURCE_ENERGY) == 4);
  } else if (step == 25){ handleEscape(); }
  else if (step == 26){ clickAction(ACTION_RESUME); oxygen = 0; checkEndConditions(); }
  else if (step == 27){
    captureStartDay(9); day = TRIP_DAYS; resetDailyQuest(); captureSleep();
  } else if (step == 28){
    captureStartDay(3);
    for (int p = 0; p < PROBLEM_COUNT; p++) activateProblem(p, 1);
    putSurvivorAtRisk(PROBLEM_FOOD);
    captureInteract(POINT_TECH_BUNK);
  }
}

void captureStartDay(int target){
  resetRun();
  day = target;
  incident_sequence[0] = PROBLEM_ENGINE;
  enterRoom(target == 1 ? SCREEN_COMMAND : SCREEN_DORMITORY);
  openDay();
  if (orders_open) closeTopModal();
}

void captureInteract(int point){
  enterRoom(point_room[point]);
  setCapturePlayerAtPoint(point);
  interact_queued = true;
  updateRoom();
}

void captureSleep(){
  if (orders_open) closeTopModal();
  captureInteract(POINT_TECH_BUNK);
  pressEnter();
}

void captureCompleteQuest(){
  int q = active_quest;
  captureInteract(quest_origin[q]); pressEnter();
  captureInteract(quest_destination[q]); pressEnter();
}

void captureAcceptPreventive(int choice){
  choosePreventive(choice);
  captureInteract(crew_point[quest_owner[selected_order]]);
  pressEnter();
}

void runRuleChecks(){
  checkConnectedDoors();
  checkPlayerFacing();
  checkPlayerAnimationLoop();
  checkOrdersBadge();
  checkQuestCatalogue();
  checkQuestBoundaries();
  checkNightConsequences();
  checkRetryPriority();
  checkCrewRules();
  checkHullDamageLocation();
  checkCampaigns();
  println("QUEST CHECK: PASS");
}

float[] badgeInkBox(PGraphics g, float cx, float cy, float radius){
  g.loadPixels();
  int x0 = max(0, int((cx - radius) * RENDER_SCALE));
  int y0 = max(0, int((cy - radius) * RENDER_SCALE));
  int x1 = min(g.width, int((cx + radius) * RENDER_SCALE));
  int y1 = min(g.height, int((cy + radius) * RENDER_SCALE));
  float inset = radius - 1;
  float[] box = {0, 0, 0, 0};

  for (int y = y0; y < y1; y++){
    for (int x = x0; x < x1; x++){
      float lx = (x + 0.5) / RENDER_SCALE;
      float ly = (y + 0.5) / RENDER_SCALE;
      float dx = lx - cx;
      float dy = ly - cy;
      if (dx * dx + dy * dy > inset * inset) continue;
      if (((g.pixels[y * g.width + x] >> 8) & 0xFF) >= 150) continue;
      if (box[0] == 0 || lx < box[0]) box[0] = lx;
      if (box[1] == 0 || ly < box[1]) box[1] = ly;
      box[2] = max(box[2], lx);
      box[3] = max(box[3], ly);
    }
  }

  return box;
}

void checkOrdersBadge(){
  base.beginDraw();
  base.resetMatrix();
  base.scale(RENDER_SCALE);
  base.background(COL_BG);
  base.textFont(ui_font);
  base.textAlign(LEFT, TOP);
  drawOrdersBadge(base, 70, 100, 0);
  drawOrdersBadge(base, 130, 100, 1);
  base.endDraw();
  float[] small = badgeInkBox(base, 70, 100, 4);
  float[] large = badgeInkBox(base, 130, 100, 5.5);
  float small_h = small[3] - small[1];
  float large_h = large[3] - large[1];
  float dx = (large[0] + large[2]) / 2 - 130;
  float dy = (large[1] + large[3]) / 2 - 100;
  base.save(sketchPath("output/orders_badge_pulse.png"));
  println("verify: selo de ordens, tinta " + nf(small_h, 1, 2) + " -> " + nf(large_h, 1, 2)
    + " px; centro deslocado " + nf(dx, 1, 2) + "," + nf(dy, 1, 2));
  verify("exclamação pulsa junto com o círculo", small_h > 0 && large_h > small_h * 1.25);
  verify("exclamação centralizada no círculo", abs(dx) <= 0.5 && abs(dy) <= 0.5);
}

void checkQuestCatalogue(){
  for (int q = 0; q < quest_id.length; q++){
    captureStartDay(q < PREVENTIVE_COUNT ? 1 : 2);
    if (q < PREVENTIVE_COUNT){
      daily_offers[0] = q;
      captureAcceptPreventive(0);
    } else {
      event_index = questProblem(q);
      if (event_index == PROBLEM_HULL){ placeHullDamage(); problem_room[event_index] = point_room[POINT_HULL]; }
      drawBase();
      base.save(sketchPath("output/catalogue_" + quest_id[q] + "_options.png"));
      applyEventChoice((q - PREVENTIVE_COUNT) % 2);
      pressEnter();
    }
    int resource = q < PREVENTIVE_COUNT ? preventive_resource[q] : solution_resource[q - PREVENTIVE_COUNT];
    float before = resourceValue(resource);
    int delta = q < PREVENTIVE_COUNT ? preventiveReward(q) : -solution_cost[q - PREVENTIVE_COUNT];
    drawBase();
    base.save(sketchPath("output/catalogue_" + quest_id[q] + "_hud.png"));
    captureCompleteQuest();
    verify(quest_id[q] + " coleta, entrega e efeito no recurso", quest_completed && active_quest < 0
      && held_item == ITEM_NONE && resourceValue(resource) == before + delta
      && (q < PREVENTIVE_COUNT || !problem_active[questProblem(q)]));
  }
}

void checkQuestBoundaries(){
  captureStartDay(1);
  endDay();
  verify("dormir exige o beliche físico", day == 1);
  captureInteract(POINT_ANTENNA);
  verify("antena sem ordem não abre painel", !modalOpen() && !pointIsAvailable(POINT_ANTENNA));
  captureInteract(POINT_RESERVE); pressEnter();
  verify("reserva sem ordem não permite interação", !modalOpen() && held_item == ITEM_NONE && !quest_completed);
  choosePreventive(0);
  acceptPreventive();
  verify("aceite distante é recusado", active_quest < 0);
  enterRoom(SCREEN_COMMAND);
  setCapturePlayerAtPoint(POINT_VERA);
  float before_modal_x = player_x;
  move_right_held = true;
  interact_queued = true;
  updateRoom();
  move_right_held = false;
  verify("abrir modal bloqueia movimento no mesmo quadro", player_x == before_modal_x);
  interact_queued = true; updateRoom();
  verify("E não confirma a ordem", dialog_open && active_quest < 0);
  pressEnter();
  choosePreventive(1);
  verify("aceite impede trocar de ordem", active_quest == 0 && selected_order < 0);
  verify("coleta habilita só a origem", pointIsAvailable(POINT_RESERVE) && !pointIsAvailable(POINT_ANTENNA) && !ordersAvailable());
  collectQuestObject();
  verify("coleta distante é recusada", held_item == ITEM_NONE);
  captureInteract(POINT_RESERVE);
  handleEscape();
  verify("cancelar painel não cancela ordem", active_quest == 0 && held_item == ITEM_NONE);
  captureInteract(POINT_RESERVE); pressEnter();
  verify("coleta desabilita origem e habilita destino", !pointIsAvailable(POINT_RESERVE) && pointIsAvailable(POINT_ANTENNA));
  deliverQuest();
  verify("entrega distante é recusada", active_quest == 0 && !quest_completed);
  captureInteract(POINT_ANTENNA); pressEnter();
  verify("entrega desabilita ponto concluído", !pointIsAvailable(POINT_ANTENNA) && !ordersAvailable());
  choosePreventive(1);
  putSurvivorAtRisk(PROBLEM_FOOD);
  captureInteract(POINT_RISK_BUNK); pressEnter();
  verify("segunda quest e socorro bloqueados", active_quest < 0 && quest_completed && urgentRisk() >= 0);
  closeTopModal();

  captureStartDay(2);
  parts = 0; energy = 1;
  applyEventChoice(0); pressEnter();
  captureCompleteQuest();
  verify("custo inviável preserva item e não causa overdraft", parts == 0 && energy == 1 && !quest_completed
    && held_item != ITEM_NONE && problem_active[PROBLEM_ENGINE]);
  closeTopModal();
  handleEscape();
  pressEnter();
  verify("ENTER em pausa não entrega", paused && parts == 0 && !quest_completed);
  handleEscape();
}

void checkNightConsequences(){
  captureStartDay(1); captureSleep();
  verify("negligência cobra ambos recursos além do consumo", morale == 74 && food == 60 && energy == 73 && oxygen == 81 && water == 74);
  captureStartDay(1); captureAcceptPreventive(0);
  captureInteract(POINT_RESERVE); pressEnter(); captureSleep();
  verify("falha aceita menor que negligência e limpa item", morale == 75 && food == 64 && held_item == ITEM_NONE);
  captureStartDay(1); captureAcceptPreventive(0); captureCompleteQuest(); captureSleep();
  verify("sucesso recebe recompensa sem anular consumo", morale == 86 && energy == 73 && food == 64);
  captureStartDay(5); daily_offers[0] = 3; captureAcceptPreventive(0);
  parts = 100; captureCompleteQuest();
  verify("peças não são limitadas a cem", parts == 102);
  captureStartDay(1); morale = 99; captureAcceptPreventive(0); captureCompleteQuest();
  verify("barras são limitadas a cem", morale == 100);
}

void checkRetryPriority(){
  captureStartDay(2); applyEventChoice(1); pressEnter();
  captureSleep();
  verify("falha urgente só cobra consumo e perda ativa", energy == 69 && problem_deadline[PROBLEM_ENGINE] == 2 && problem_solution[PROBLEM_ENGINE] == 9);
  closeTopModal(); acceptSolution(8);
  verify("retomada não permite trocar solução", active_quest < 0);
  clickAction(ACTION_OPEN_ORDERS);
  clickAction(ACTION_NEXT_RETRY);
  clickAction(ACTION_RETRY_QUEST);
  verify("retomada exibe confirmação sem aceitar", technical_open && active_quest < 0);
  pressEnter();
  verify("ENTER retoma a solução escolhida", active_quest == 9 && problem_deadline[PROBLEM_ENGINE] == 2);
  captureCompleteQuest(); captureSleep();
  verify("retomada remove problema e preserva negligência", !problem_active[PROBLEM_ENGINE] && energy == 50 && water == 64);
  captureStartDay(2); applyEventChoice(0); pressEnter(); captureSleep();
  closeTopModal(); captureSleep();
  verify("incidente novo tem prioridade", day == 4 && event_open);
  acceptSolution(8);
  verify("problema anterior não substitui incidente novo", event_open && active_quest < 0);
}

void checkCrewRules(){
  captureStartDay(3);
  putSurvivorAtRisk(PROBLEM_FOOD);
  putSurvivorAtRisk(PROBLEM_LIFE_SUPPORT);
  int risks = 0;
  for (int deadline : crew_risk_deadline) if (deadline > 0) risks++;
  verify("crises simultâneas mantêm um único risco", risks == 1 && urgentRisk() == CREW_VERA);
  captureInteract(POINT_RISK_BUNK); pressEnter(); captureSleep();
  verify("socorro custa 8 água e 2 comida e mantém negligência", water == 62 && food == 62 && urgentRisk() < 0);
  captureStartDay(3); putSurvivorAtRisk(PROBLEM_FOOD);
  processSurvivorRisks(); processSurvivorRisks();
  verify("duas noites sem socorro causam morte", survivors == 3 && !crew_alive[CREW_VERA] && urgentRisk() < 0);
  for (int mask = 1; mask < 16; mask++){
    resetRun(); day = 3;
    for (int crew = 0; crew < CREW_COUNT; crew++) crew_alive[crew] = (mask & (1 << crew)) != 0;
    selectPreventiveOffers();
    verify("pool vivo e distinto, máscara " + mask, daily_offers[0] >= 0 && daily_offers[1] >= 0
      && crew_alive[quest_owner[daily_offers[0]]] && crew_alive[quest_owner[daily_offers[1]]]
      && preventive_resource[daily_offers[0]] != preventive_resource[daily_offers[1]]);
  }
  captureStartDay(2); crew_alive[CREW_SILVIA] = false; survivors--;
  applyEventChoice(0); pressEnter(); captureCompleteQuest();
  verify("morte não altera custo nem bloqueia solução", parts == 2 && !problem_active[PROBLEM_ENGINE]);
  captureStartDay(3); activateProblem(PROBLEM_FOOD, 1); captureSleep();
  verify("risco criado pela crise ganha duas noites inteiras", urgentRisk() >= 0 && crew_risk_deadline[urgentRisk()] == 2);
}

void checkHullDamageLocation(){
  captureStartDay(1);
  boolean reachable = true;
  boolean varied = false;
  int first_room = SCREEN_NONE;
  randomSeed(97031);
  for (int sample = 0; sample < 32; sample++){
    clearProblem(PROBLEM_HULL); activateProblem(PROBLEM_HULL, 3);
    int room = point_room[POINT_HULL];
    reachable &= isDeckSurface(point_y[POINT_HULL]) && hullPointClear(room, point_y[POINT_HULL], point_x[POINT_HULL]);
    if (sample == 0) first_room = room;
    else varied |= room != first_room;
  }
  verify("casco sorteado alcançável e sem sobreposição", reachable && varied);
  clearProblem(PROBLEM_HULL);
  verify("resolver casco remove ponto físico", point_room[POINT_HULL] == SCREEN_NONE);
}

float capturePressure(int q){
  int resource = preventive_resource[q];
  if (resource == RESOURCE_PARTS) return parts == 0 ? 1 : 0;
  int[] consumption = {7, 4, 6, 6, 2};
  return (100 - resourceValue(resource)) / consumption[resource];
}

void playCaptureCampaign(int[] sequence, int strategy){
  resetRun(); arrayCopy(sequence, incident_sequence);
  enterRoom(SCREEN_COMMAND); openDay();
  while (isRoomScreen()){
    if (event_open){
      int q = PREVENTIVE_COUNT + event_index * 2;
      int i = q - PREVENTIVE_COUNT;
      boolean first = canPayResource(solution_resource[i], solution_cost[i]);
      boolean second = canPayResource(solution_resource[i + 1], solution_cost[i + 1]);
      int choice = first ? 0 : second ? 1 : 0;
      if (strategy == 0 && first && second){
        float a = solution_cost[i] / max(1.0, resourceValue(solution_resource[i]));
        float b = solution_cost[i + 1] / max(1.0, resourceValue(solution_resource[i + 1]));
        choice = b < a ? 1 : 0;
      }
      applyEventChoice(choice); pressEnter();
      if (strategy != 3) captureCompleteQuest();
    } else if (strategy != 3){
      if (orders_open) closeTopModal();
      int choice = capturePressure(daily_offers[1]) > capturePressure(daily_offers[0]) ? 1 : 0;
      if (strategy == 1){
        for (int i = 0; i < 2; i++) if (preventive_resource[daily_offers[i]] == RESOURCE_PARTS) choice = i;
      }
      captureAcceptPreventive(choice); captureCompleteQuest();
    }
    if (technical_open) closeTopModal();
    captureSleep();
  }
}

int capture_campaign_wins = 0;
void permuteCaptureCampaigns(int[] sequence, int depth, int used){
  if (depth == sequence.length){
    playCaptureCampaign(sequence, 1);
    if (screen == SCREEN_VICTORY) capture_campaign_wins++;
    else throw new RuntimeException("campanha derrotada: " + join(nf(sequence, 1), ","));
    return;
  }
  for (int p = 0; p < PROBLEM_COUNT; p++){
    if ((used & (1 << p)) != 0) continue;
    sequence[depth] = p;
    permuteCaptureCampaigns(sequence, depth + 1, used | (1 << p));
  }
}

void checkCampaigns(){
  int[] sequence = {PROBLEM_ENGINE, PROBLEM_FOOD, PROBLEM_CONFLICT, PROBLEM_HULL, PROBLEM_LIFE_SUPPORT};
  for (int strategy = 0; strategy < 3; strategy++){
    playCaptureCampaign(sequence, strategy);
    verify("estratégia " + strategy + " vence campanha completa", screen == SCREEN_VICTORY && day == 10);
  }
  playCaptureCampaign(sequence, 3);
  verify("omissão perde por motor destruído", screen == SCREEN_GAME_OVER && game_over_reason == REASON_ENGINE);
  capture_campaign_wins = 0;
  permuteCaptureCampaigns(new int[5], 0, 0);
  verify("reserva de peças vence 2520/2520 no sketch", capture_campaign_wins == 2520);
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
  if (!passed) exit();
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
