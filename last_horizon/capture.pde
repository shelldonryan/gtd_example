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
boolean checks_failed = false;
boolean rule_checks_started = false;
boolean rule_checks_finished = false;
boolean campaign_checks_running = false;
int campaign_phase = 0;
int campaign_strategy = 0;
int[] campaign_sequence = new int[5];
int[] campaign_next_candidate = new int[5];
int campaign_depth = 0;
int campaign_used = 0;
boolean campaign_permutation_ready = false;
int capture_campaign_wins = 0;
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
  "survivor_rescued", "pause", "defeat", "victory", "dense_night_forecast",
  "day_3_night_modal", "help_panel", "day_2_free_dormitory", "earth_transmission"
};
/* The harness lives only in the repository sketch: the delivered copy leaves
   this tab out. It installs its hooks in the main tab's extension points and
   returns false outside the verification modes, letting the game draw. */
boolean harness_installed = installHarness();


boolean installHarness(){
  harness_setup = () -> {
    readArgs();
    if (hit_test_mode){
      surface.setSize(1400, 900);
    }
  };
  harness_update = () -> updateCapture();
  harness_scene = (target) -> harnessDrawScene(target);
  return true;
}


PImage[] door_art_saved;
boolean door_art_cleared = false;


/* Os testes de portal assumem a travessia instantânea: o bloco limpa a arte da
   porta e devolve o estado anterior no fim. */
void clearDoorArt(){
  if (!door_art_cleared){
    door_art_saved = art_door_frames;
    door_art_cleared = true;
  }

  art_door_frames = new PImage[2];
}


void restoreDoorArt(){
  if (door_art_cleared){
    art_door_frames = door_art_saved;
    door_art_saved = null;
    door_art_cleared = false;
  }
}


boolean harnessDrawScene(PGraphics target){
  if (pipeline_test_mode){
    drawPipelineProbe(target);
    return true;
  }

  if (capture_mode && capture_step >= capture_label.length && campaign_checks_running){
    drawCaptureCheckScreen(target);
    return true;
  }

  return false;
}


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
    if (!rule_checks_started){
      rule_checks_started = true;
      runRuleChecks();
    }

    if (checks_failed){
      reportQuestCheck();
      exit();
      return;
    }

    if (campaign_checks_running){
      advanceCampaignChecks();
      return;
    }

    if (!rule_checks_finished){
      rule_checks_finished = true;
      reportQuestCheck();
      exit();
    }
    return;
  }

  saveCanvas(capture_step);
  runCaptureStep(capture_step);
  capture_step++;
  capture_next_frame = frameCount + CAPTURE_FRAME_GAP;
}
void drawCaptureCheckScreen(PGraphics g){
  drawStars(g);
  textCentered(g, "VERIFICAÇÃO DO SKETCH", BASE_W / 2.0, 96, 24, COL_CYAN);
  drawPanel(g, 126, 130, 388, 112, COL_BORDER);
  textCentered(g, "A JANELA CONTINUA RESPONSIVA", BASE_W / 2.0, 148, 16, COL_TEXT);

  String status = campaign_phase < 2
    ? "VALIDANDO CAMPANHAS REPRESENTATIVAS"
    : "VALIDANDO TODAS AS PERMUTAÇÕES";
  textCentered(g, status, BASE_W / 2.0, 180, 16, COL_MUTED);

  if (campaign_phase >= 2){
    textCentered(g, capture_campaign_wins + " / 2520 CAMPANHAS", BASE_W / 2.0, 208, 16, COL_GREEN);
  } else {
    textCentered(g, "RECURSOS DA PARTIDA NÃO SÃO EXIBIDOS", BASE_W / 2.0, 208, 16, COL_GREEN);
  }
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
    verify("transmissão da Terra precede o incidente", transmission_open);
    closeTopModal();
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
  else if (step == 30){
    closeTopModal();
    clickAction(ACTION_OPEN_HELP);
  } else if (step == 31){
    verify("ajuda abre pelo botão do rodapé", help_open && !paused);
    handleEscape();
  } else if (step == 32){
    resetRun();
    day = 2;
    incident_sequence[0] = PROBLEM_ENGINE;
    enterRoom(SCREEN_DORMITORY);
    openDay();
  } else if (step == 33){
    verify("dia com falha do motor abre pela transmissão da Terra",
      transmission_open && event_open && transmission_text.indexOf("O MOTOR FALHOU") >= 0);
    closeTopModal();
    verify("fechar a transmissão revela o cartão do incidente", !transmission_open && event_open);
  }
}

void captureStartDay(int target){
  resetRun();
  day = target;
  /* deterministico: o sorteio podia repetir o motor no dia 4 e aceitar a
     solucao do problema anterior, quebrando a assercao de prioridade */
  int[] capture_sequence = {PROBLEM_ENGINE, PROBLEM_HULL, PROBLEM_FOOD,
    PROBLEM_CONFLICT, PROBLEM_LIFE_SUPPORT};
  arrayCopy(capture_sequence, incident_sequence);
  enterRoom(target == 1 ? SCREEN_COMMAND : SCREEN_DORMITORY);
  openDay();
  transmission_open = false;
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
  if (quest_stage == QUEST_COLLECT){
    captureInteract(quest_origin[q]); pressEnter();
  }
  captureInteract(quest_destination[q]); pressEnter();
}

void captureAcceptPreventive(int choice){
  choosePreventive(choice);
  captureInteract(crew_point[quest_owner[selected_order]]);
  pressEnter();
}

void checkNpcDialogue(){
  captureStartDay(1);
  int owner = quest_owner[daily_offers[0]];
  int other = (owner + 1) % CREW_COUNT;

  while (!crew_alive[other]) other = (other + 1) % CREW_COUNT;

  captureInteract(crew_point[owner]);
  verify("oferta do dia aparece na fala do responsável",
    dialog_open && !technical_open && dialog_text.indexOf("MINHA OFERTA") >= 0);
  closeTopModal();

  choosePreventive(0);
  captureInteract(crew_point[owner]);
  verify("responsável pede confirmação presencial",
    dialog_open && pending_quest_action == ACTION_ACCEPT_ORDER && active_quest < 0);
  pressEnter();
  verify("confirmação presencial aceita a ordem",
    active_quest == daily_offers[0] && quest_stage == QUEST_COLLECT);

  captureInteract(crew_point[owner]);
  verify("responsável com quest ativa orienta a etapa",
    dialog_open && dialog_text.indexOf("SIGA A ORDEM") >= 0);
  closeTopModal();

  captureInteract(crew_point[other]);
  verify("terceiro informa a ordem ativa sem retrato",
    technical_open && !dialog_open && technical_text.indexOf("ORDEM ATIVA COM") >= 0);
  closeTopModal();

  captureCompleteQuest();
  captureInteract(crew_point[owner]);
  verify("quest concluída encerra a conversa",
    dialog_open && dialog_text.indexOf("TRABALHO CONCLUÍDO") >= 0);
  closeTopModal();

  crew_alive[owner] = false;
  verify("sobrevivente morto não interage", !pointIsAvailable(crew_point[owner]));
  crew_alive[owner] = true;
}


void checkTransmissionMessages(){
  resetRun();
  day = 2;
  incident_sequence[0] = PROBLEM_ENGINE;
  enterRoom(SCREEN_DORMITORY);
  openDay();
  verify("falha do motor traz transmissão da Terra",
    transmission_open && event_open && transmission_text.indexOf("O MOTOR FALHOU") >= 0);
  closeTopModal();
  day = 4;
  opened_day = 0;
  incident_sequence[1] = PROBLEM_ENGINE;
  openDay();
  verify("transmissão do motor dispara uma vez por partida", !transmission_open && event_open);
  closeTopModal();

  resetRun();
  day = 2;
  incident_sequence[0] = PROBLEM_HULL;
  enterRoom(SCREEN_DORMITORY);
  openDay();
  verify("chuva de meteoros traz transmissão do casco",
    transmission_open && transmission_text.indexOf("CHUVA DE METEOROS") >= 0);
  closeTopModal();

  resetRun();
  day = 3;
  enterRoom(SCREEN_DORMITORY);
  putSurvivorAtRisk(PROBLEM_FOOD);
  processSurvivorRisks();
  verify("risco sem socorro ainda não transmite", !transmission_open);
  processSurvivorRisks();
  verify("primeira perda transmite e reduz a bordo",
    transmission_open && survivors == CREW_START - 1 && transmission_text.indexOf("UMA VIDA FOI PERDIDA") >= 0);

  resetRun();
  verify("vitória com todos vivos usa a variação dos quatro",
    marsMessage().indexOf("OS QUATRO SOBREVIVENTES") >= 0);
  survivors = CREW_START - 1;
  crew_alive[CREW_VERA] = false;
  verify("vitória com perdas usa a variação dos que restaram",
    marsMessage().indexOf("OS SOBREVIVENTES QUE RESTARAM") >= 0
    && survivorsSummary().indexOf("BENTO") >= 0 && survivorsSummary().indexOf("VERA") < 0);
  engine_repaired_at_limit = true;
  verify("reparo no limite prevalece quando há perdas",
    marsMessage().indexOf("NO LIMITE") >= 0);
  resetRun();
}


void runRuleChecks(){
  checkConnectedDoors();
  if (!checks_failed) checkDoorTraversalArt();
  if (!checks_failed) checkNpcDialogue();
  if (!checks_failed) checkPlayerFacing();
  if (!checks_failed) checkPlayerAnimationLoop();
  if (!checks_failed) checkPlayerRun();
  if (!checks_failed) checkOrdersBadge();
  if (!checks_failed) checkQuestCatalogue();
  if (!checks_failed) checkQuestBoundaries();
  if (!checks_failed) checkNightConsequences();
  if (!checks_failed) checkRetryPriority();
  if (!checks_failed) checkCrewRules();
  if (!checks_failed) checkHullDamageLocation();
  if (!checks_failed) checkTransmissionMessages();
  if (!checks_failed) startCampaignChecks();
}


void reportQuestCheck(){
  println(checks_failed ? "QUEST CHECK: FALHOU" : "QUEST CHECK: PASS");
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
  captureStartDay(3);
  choosePreventive(0);
  captureInteract(POINT_VERA); pressEnter();
  verify("aceite de preventiva do responsável entrega em mãos",
    active_quest == 1 && quest_stage == QUEST_DELIVER && held_item == 2 && nextQuestPoint() == POINT_ROUTE && pointIsAvailable(POINT_ROUTE));
  captureInteract(POINT_VERA);
  verify("responsável pós-entrega orienta a rota no destino",
    dialog_open && dialog_text.indexOf("JÁ ENTREGUEI") >= 0);
  closeTopModal();
  captureInteract(POINT_ROUTE); pressEnter();
  verify("entrega conclui preventiva direta", quest_completed && held_item == ITEM_NONE);

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
    transmission_open = false;
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

void startCampaignChecks(){
  campaign_checks_running = true;
  campaign_phase = 0;
  campaign_strategy = 0;
  campaign_sequence[0] = PROBLEM_ENGINE;
  campaign_sequence[1] = PROBLEM_FOOD;
  campaign_sequence[2] = PROBLEM_CONFLICT;
  campaign_sequence[3] = PROBLEM_HULL;
  campaign_sequence[4] = PROBLEM_LIFE_SUPPORT;
  capture_campaign_wins = 0;
  campaign_depth = 0;
  campaign_used = 0;
  campaign_permutation_ready = false;
  for (int i = 0; i < campaign_next_candidate.length; i++) campaign_next_candidate[i] = 0;
}


boolean nextCampaignPermutation(){
  while (campaign_depth >= 0){
    boolean descended = false;
    while (campaign_next_candidate[campaign_depth] < PROBLEM_COUNT){
      int candidate = campaign_next_candidate[campaign_depth]++;
      if ((campaign_used & (1 << candidate)) != 0) continue;

      campaign_sequence[campaign_depth] = candidate;
      campaign_used |= 1 << candidate;
      campaign_depth++;
      if (campaign_depth == campaign_sequence.length) return true;
      campaign_next_candidate[campaign_depth] = 0;
      descended = true;
      break;
    }

    if (descended) continue;
    campaign_depth--;
    if (campaign_depth >= 0){
      campaign_used &= ~(1 << campaign_sequence[campaign_depth]);
    }
  }

  return false;
}


void advanceCampaignPermutation(){
  int last = campaign_sequence.length - 1;
  campaign_depth = last;
  campaign_used &= ~(1 << campaign_sequence[last]);
}


void advanceCampaignChecks(){
  if (campaign_phase == 0){
    playCaptureCampaign(campaign_sequence, campaign_strategy);
    verify("estratégia " + campaign_strategy + " vence campanha completa",
      screen == SCREEN_VICTORY && day == 10);
    campaign_strategy++;
    if (campaign_strategy == 3) campaign_phase = 1;
    return;
  }

  if (campaign_phase == 1){
    playCaptureCampaign(campaign_sequence, 3);
    verify("omissão perde por motor destruído",
      screen == SCREEN_GAME_OVER && game_over_reason == REASON_ENGINE);
    campaign_phase = 2;
    return;
  }

  if (campaign_phase == 2){
    if (!campaign_permutation_ready){
      if (!nextCampaignPermutation()){
        verify("reserva de peças vence " + capture_campaign_wins + "/2520 no sketch",
          capture_campaign_wins == 2520);
        campaign_checks_running = false;
        campaign_phase = 3;
        return;
      }
      campaign_permutation_ready = true;
    }

    playCaptureCampaign(campaign_sequence, 1);
    if (screen != SCREEN_VICTORY){
      verify("campanha " + join(nf(campaign_sequence, 1), ",") + " chega a Marte",
        false);
      campaign_checks_running = false;
      return;
    }

    capture_campaign_wins++;
    campaign_permutation_ready = false;
    advanceCampaignPermutation();
  }
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
  clearDoorArt();
  enterRoom(SCREEN_MACHINES);
  placePlayerAtDoor(doorInRoomLeadingTo(SCREEN_MACHINES, SCREEN_COMMAND));
  useNearbyDoor();
  verify("retorno ao hub olha para a esquerda",
    screen == SCREEN_COMMAND && player_facing == -1);
  restoreDoorArt();
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


/* Compara dois quadros pixel a pixel: prova que a faixa carregada não é a de
   outro movimento da mesma spritesheet. */
boolean samePixels(PImage a, PImage b){
  if (a == null || b == null || a.width != b.width || a.height != b.height){
    return false;
  }

  a.loadPixels();
  b.loadPixels();

  for (int i = 0; i < a.pixels.length; i++){
    if (a.pixels[i] != b.pixels[i]){
      return false;
    }
  }

  return true;
}


/* A corrida é decisão de convés: acelera o passo, anima a faixa de run do LPC
   e não invade escada nem ar (D-153). A spritesheet sem a faixa é uma
   configuração válida: nesse caso o teste cobra o passo acelerado com a
   caminhada, e não a faixa que não existe. */
void checkPlayerRun(){
  if (!player_assets_loaded){
    verify("spritesheet do jogador carregada", false);
    return;
  }

  resetRun();
  event_open = false;
  enterRoom(SCREEN_COMMAND);
  move_right_held = true;

  float start_x = player_x;
  updatePlayerOnDeck();
  float walk_step = player_x - start_x;

  player_x = start_x;
  run_held = true;
  updatePlayerOnDeck();
  float run_step = player_x - start_x;

  verify("shift acelera o passo no convés",
    abs(walk_step - PLAYER_SPEED) <= 0.001 && abs(run_step - PLAYER_RUN_SPEED) <= 0.001);

  player_x = start_x;
  player_has_run = false;
  updatePlayerOnDeck();
  verify("sem faixa de corrida o passo acelera do mesmo jeito",
    abs((player_x - start_x) - PLAYER_RUN_SPEED) <= 0.001
      && playerCurrentAnimationState() == PLAYER_ANIM_WALK);
  player_has_run = true;

  player_x = start_x;
  player_anim_state = -1;
  int start_frame = playerCurrentFrame();
  verify("corrida anima a faixa carregada",
    playerCurrentAnimationState() == PLAYER_ANIM_RUN
      && start_frame == player_run_start
      && player_run_end - player_run_start == 7);

  player_animation_started_at = millis() - 76;
  verify("a corrida avança um quadro a cada 75 ms",
    playerCurrentFrame() == player_run_start + 1);

  player_animation_started_at = millis() - 600;
  verify("a corrida fecha o ciclo de 8 quadros",
    playerCurrentFrame() == player_run_start);

  if (player_sheet != null && player_sheet.height >= 42 * 64){
    verify("a faixa de corrida sai dos 8 quadros da linha 41",
      samePixels(player_frame_images[player_run_start], player_sheet.get(0, 41 * 64, 64, 64))
        && !samePixels(player_frame_images[player_run_start], player_sheet.get(0, 11 * 64, 64, 64)));
  }

  run_held = false;
  player_anim_state = -1;
  player_animation_started_at = millis() - 1000;
  int walk_frame = playerCurrentFrame();
  verify("soltar o shift volta para a caminhada",
    playerCurrentAnimationState() == PLAYER_ANIM_WALK
      && walk_frame >= player_walk_start && walk_frame <= player_walk_end);

  run_held = true;
  move_right_held = false;
  player_anim_state = -1;
  verify("shift parado não corre no lugar", playerCurrentAnimationState() == PLAYER_ANIM_IDLE);

  move_right_held = true;
  player_on_ladder = true;
  player_grounded = false;
  player_anim_state = -1;
  verify("shift não interfere na escada",
    playerCurrentAnimationState() == (player_has_climb ? PLAYER_ANIM_CLIMB : PLAYER_ANIM_WALK));
  player_on_ladder = false;

  player_anim_state = -1;
  verify("shift não troca a animação do pulo",
    playerCurrentAnimationState() == (player_has_jump ? PLAYER_ANIM_JUMP : PLAYER_ANIM_WALK));

  player_grounded = true;
  player_x = start_x;
  jump_queued = true;
  updatePlayerOnDeck();
  verify("no quadro da decolagem o passo já é o do ar",
    abs((player_x - start_x) - PLAYER_SPEED) <= 0.001
      && playerCurrentAnimationState() == (player_has_jump ? PLAYER_ANIM_JUMP : PLAYER_ANIM_WALK));

  jump_queued = false;
  move_right_held = false;
  resetRun();
  event_open = false;
}


/* A travessia em dois quadros só existe quando há arte de porta: o teste
   instala um par de quadros e confere abrir -> trocar de sala -> fechar. */
void checkDoorTraversalArt(){
  int door = doorInRoomLeadingTo(SCREEN_COMMAND, SCREEN_MACHINES);
  clearDoorArt();
  resetRun();
  event_open = false;
  enterRoom(SCREEN_COMMAND);
  placePlayerAtDoor(door);
  art_door_frames[0] = createGraphics(64, 128);
  art_door_frames[1] = createGraphics(64, 128);

  verify("arte da porta assume a travessia em dois quadros",
    doorFrame(door) != null && useNearbyDoor()
    && screen == SCREEN_COMMAND && doorTransitionActive());

  door_transition_started = millis() - ART_DOOR_PHASE_MS - 1;
  updateRoom();
  verify("travessia troca de sala com o quadro aberto",
    screen == SCREEN_MACHINES && doorTransitionActive());

  door_transition_started = millis() - ART_DOOR_PHASE_MS - 1;
  updateRoom();
  verify("travessia fecha o quadro ao chegar",
    !doorTransitionActive() && screen == SCREEN_MACHINES);

  restoreDoorArt();
}


void checkConnectedDoors(){
  clearDoorArt();

  for (int door = 0; door < DOOR_COUNT; door++){
    resetRun();
    event_open = false;
    enterRoom(door_room[door]);
    placePlayerAtDoor(door);
    int target = door_target[door];
    verify("porta " + door + " reconhece o limiar configurado",
      doorInRange(door));
    verify("porta " + door + " leva a " + roomTitle(target),
      useNearbyDoor() && screen == target);
    verify("chegada usa coordenada e direção configuradas",
      abs(player_x + PLAYER_W / 2.0 - door_arrival_x[door]) <= 0.1
      && abs(player_y + PLAYER_H - door_arrival_y[door]) <= 0.1
      && player_facing == door_arrival_facing[door]);
  }

  int outbound = doorInRoomLeadingTo(SCREEN_COMMAND, SCREEN_MACHINES);
  int inbound = doorInRoomLeadingTo(SCREEN_MACHINES, SCREEN_COMMAND);
  resetRun();
  enterRoom(SCREEN_COMMAND);
  placePlayerAtDoor(outbound);
  float entered_center_x = player_x + PLAYER_W / 2.0;
  float entered_feet_y = player_y + PLAYER_H;
  verify("porta de Máquinas abre a sala correta",
    useNearbyDoor() && screen == SCREEN_MACHINES);
  placePlayerAtDoor(inbound);
  verify("retorno da porta usa a posição de entrada",
    useNearbyDoor() && screen == SCREEN_COMMAND
    && abs(player_x + PLAYER_W / 2.0 - entered_center_x) <= 0.1
    && abs(player_y + PLAYER_H - entered_feet_y) <= 0.1);

  checkDoorAnywhere();
  restoreDoorArt();
}




void placePlayerAtDoor(int door){
  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  player_x = door_x[door] - PLAYER_W / 2.0;
  player_y = door_y[door] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = isDeckSurface(door_y[door]);
  player_on_ladder = false;
}


void checkDoorAnywhere(){
  clearDoorArt();
  final int door = 1;
  float saved_x = door_x[door];
  float saved_y = door_y[door];
  int saved_deck = door_deck[door];
  int saved_target = door_target[door];
  float saved_arrival_x = door_arrival_x[door];
  float saved_arrival_y = door_arrival_y[door];
  int saved_arrival_facing = door_arrival_facing[door];
  float test_x = 320;
  float test_y = deck_y[1] - 20;
  float test_arrival_x = ROOM_RIGHT - 40;
  float test_arrival_y = deck_y[0];

  door_x[door] = test_x;
  door_y[door] = test_y;
  door_deck[door] = DOOR_DECK_NONE;
  door_target[door] = SCREEN_DORMITORY;
  door_arrival_x[door] = test_arrival_x;
  door_arrival_y[door] = test_arrival_y;
  door_arrival_facing[door] = -1;

  resetRun();
  event_open = false;
  enterRoom(door_room[door]);
  placePlayerAtDoor(door);
  verify("porta em abertura fora de deck interage no limiar",
    doorInRange(door) && useNearbyDoor() && screen == door_target[door]);
  verify("chegada independente coloca no canto configurado",
    abs(player_x + PLAYER_W / 2.0 - test_arrival_x) <= 0.1
    && abs(player_y + PLAYER_H - test_arrival_y) <= 0.1
    && player_facing == -1);

  resetRun();
  event_open = false;
  enterRoom(door_room[door]);
  player_x = test_x - PLAYER_W / 2.0;
  player_y = test_y - PLAYER_H + DOOR_VERTICAL_RANGE + 1;
  player_velocity_y = 0;
  player_grounded = false;
  verify("distância vertical fora do limiar não abre a porta",
    !doorInRange(door));

  int saved_hull_room = point_room[POINT_HULL];
  float saved_hull_x = point_x[POINT_HULL];
  float saved_hull_y = point_y[POINT_HULL];
  int saved_active_quest = active_quest;
  int saved_quest_stage = quest_stage;
  int saved_held_item = held_item;
  boolean saved_quest_completed = quest_completed;
  boolean saved_technical_open = technical_open;
  int saved_pending_action = pending_quest_action;

  resetRun();
  point_room[POINT_HULL] = SCREEN_COMMAND;
  point_x[POINT_HULL] = door_x[2];
  point_y[POINT_HULL] = door_y[2];
  active_quest = PREVENTIVE_COUNT + PROBLEM_HULL * 2;
  quest_stage = QUEST_DELIVER;
  held_item = active_quest + 1;
  enterRoom(SCREEN_COMMAND);
  setCapturePlayerAtPoint(POINT_HULL);
  interact_queued = true;
  updateRoom();
  verify("ponto de quest vence portal coincidente",
    screen == SCREEN_COMMAND && technical_open
    && pending_quest_action == ACTION_DELIVER_QUEST);

  point_room[POINT_HULL] = saved_hull_room;
  point_x[POINT_HULL] = saved_hull_x;
  point_y[POINT_HULL] = saved_hull_y;
  active_quest = saved_active_quest;
  quest_stage = saved_quest_stage;
  held_item = saved_held_item;
  quest_completed = saved_quest_completed;
  technical_open = saved_technical_open;
  pending_quest_action = saved_pending_action;
  door_x[door] = saved_x;
  door_y[door] = saved_y;
  door_deck[door] = saved_deck;
  door_target[door] = saved_target;
  door_arrival_x[door] = saved_arrival_x;
  door_arrival_y[door] = saved_arrival_y;
  door_arrival_facing[door] = saved_arrival_facing;
  restoreDoorArt();
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
  float ladder_player_x = ladderX(SCREEN_MACHINES, 0) - PLAYER_W / 2.0;
  testLadderLateralExit(middle_y, ladder_player_x);
  testLadderCrossingExit(middle_y, ladder_player_x);
  testLadderStableExit(middle_y);
  drawBase();
  base.save(sketchPath("output/ladder_middle_exit.png"));
  testLadderReleaseRearms();
  testLadderIdleSnap(middle_y, ladder_player_x);
  checkLadderAnywhere();
  exit();
}


void checkLadderAnywhere(){
  int index = -1;

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] == SCREEN_MACHINES && index < 0) index = i;
  }

  float saved_x = ladder_x[index];
  float test_x = 320;
  ladder_x[index] = test_x;
  enterRoom(SCREEN_MACHINES);
  player_x = test_x - PLAYER_W / 2.0;
  player_y = deck_y[1] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  move_down_held = true;
  updatePlayerOnDeck();
  move_down_held = false;
  verify("escada fora das posições fixas é reconhecida",
    player_on_ladder && abs(player_x - (test_x - PLAYER_W / 2.0)) < 0.01);
  ladder_x[index] = saved_x;
  enterRoom(SCREEN_MACHINES);
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
  if (!passed){
    checks_failed = true;
    exit();
  }
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
