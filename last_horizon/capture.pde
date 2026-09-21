boolean capture_mode = false;
boolean hit_test_mode = false;
boolean ladder_test_mode = false;
boolean pipeline_test_mode = false;
boolean performance_mode = false;
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
final int PERFORMANCE_WARMUP_FRAMES = 120;
final int PERFORMANCE_SAMPLE_COUNT = 3;
final long PERFORMANCE_SAMPLE_NANOS = 30000000000L;
final int PERFORMANCE_MAX_FRAMES = 4096;

int performance_warmup_frames = 0;
int performance_sample_index = 0;
int performance_sample_frames = 0;
long performance_last_frame_nanos = 0;
long performance_sample_started_nanos = 0;
long performance_sample_start_memory = 0;
long performance_sample_peak_memory = 0;
int performance_sample_resource_builds = 0;
int performance_sample_deck_builds = 0;
int performance_sample_invalidations = 0;
float[] performance_frame_times = new float[PERFORMANCE_MAX_FRAMES];
java.io.PrintWriter performance_metrics_writer;

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
    captureVerificationBaseline();
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

/*
 * Verification fixtures may replace configuration tables and art references.
 * Keep one post-load baseline and restore it at fixture boundaries and before
 * an assertion aborts the sketch. The game state itself is reset through the
 * normal resetRun() path, so this seam remains isolated from the runtime.
 */
boolean verification_baseline_ready = false;
int[] verification_baseline_incident_sequence = new int[5];
float[] verification_baseline_ladder_x;
float[] verification_baseline_door_x;
float[] verification_baseline_door_y;
int[] verification_baseline_door_deck;
int[] verification_baseline_door_target;
float[] verification_baseline_door_arrival_x;
float[] verification_baseline_door_arrival_y;
int[] verification_baseline_door_arrival_facing;
int[] verification_baseline_point_room;
float[] verification_baseline_point_x;
float[] verification_baseline_point_y;
PImage[] verification_baseline_door_art;

void captureVerificationBaseline(){
  if (verification_baseline_ready) return;

  verification_baseline_ladder_x = new float[LADDER_COUNT];
  verification_baseline_door_x = new float[DOOR_COUNT];
  verification_baseline_door_y = new float[DOOR_COUNT];
  verification_baseline_door_deck = new int[DOOR_COUNT];
  verification_baseline_door_target = new int[DOOR_COUNT];
  verification_baseline_door_arrival_x = new float[DOOR_COUNT];
  verification_baseline_door_arrival_y = new float[DOOR_COUNT];
  verification_baseline_door_arrival_facing = new int[DOOR_COUNT];
  verification_baseline_point_room = new int[POINT_COUNT];
  verification_baseline_point_x = new float[POINT_COUNT];
  verification_baseline_point_y = new float[POINT_COUNT];

  arrayCopy(incident_sequence, verification_baseline_incident_sequence);
  arrayCopy(ladder_x, verification_baseline_ladder_x);
  arrayCopy(door_x, verification_baseline_door_x);
  arrayCopy(door_y, verification_baseline_door_y);
  arrayCopy(door_deck, verification_baseline_door_deck);
  arrayCopy(door_target, verification_baseline_door_target);
  arrayCopy(door_arrival_x, verification_baseline_door_arrival_x);
  arrayCopy(door_arrival_y, verification_baseline_door_arrival_y);
  arrayCopy(door_arrival_facing, verification_baseline_door_arrival_facing);
  arrayCopy(point_room, verification_baseline_point_room);
  arrayCopy(point_x, verification_baseline_point_x);
  arrayCopy(point_y, verification_baseline_point_y);
  verification_baseline_door_art = art_door_frames;
  verification_baseline_ready = true;
}

void restoreVerificationTables(){
  if (!verification_baseline_ready) return;

  arrayCopy(verification_baseline_incident_sequence, incident_sequence);
  arrayCopy(verification_baseline_ladder_x, ladder_x);
  arrayCopy(verification_baseline_door_x, door_x);
  arrayCopy(verification_baseline_door_y, door_y);
  arrayCopy(verification_baseline_door_deck, door_deck);
  arrayCopy(verification_baseline_door_target, door_target);
  arrayCopy(verification_baseline_door_arrival_x, door_arrival_x);
  arrayCopy(verification_baseline_door_arrival_y, door_arrival_y);
  arrayCopy(verification_baseline_door_arrival_facing, door_arrival_facing);
  arrayCopy(verification_baseline_point_room, point_room);
  arrayCopy(verification_baseline_point_x, point_x);
  arrayCopy(verification_baseline_point_y, point_y);
  art_door_frames = verification_baseline_door_art;
  door_art_saved = null;
  door_art_cleared = false;
}

void restoreVerificationFixture(){
  if (!verification_baseline_ready) return;

  resetRun();
  restoreVerificationTables();
  move_left_held = false;
  move_right_held = false;
  move_up_held = false;
  move_down_held = false;
  run_held = false;
  mouse_pressed = false;
  esc_pressed = false;
  enter_pressed = false;
  backspace_pressed = false;
  key_char_pressed = false;
  door_transition_door = -1;
  door_transition_phase = DOOR_PHASE_CLOSED;
  door_transition_started = 0;
  door_transition_target = SCREEN_NONE;
  door_transition_return_door = -1;
  door_transition_arrival_x = 0;
  door_transition_arrival_y = 0;
  door_transition_facing = 1;
  screen = SCREEN_COMMAND;
  current_room = SCREEN_COMMAND;
}

void beginVerificationFixture(){
  captureVerificationBaseline();
  restoreVerificationFixture();
  randomSeed(20260919);
  resetRun();
  restoreVerificationTables();

  int[] deterministic_sequence = {
    PROBLEM_ENGINE, PROBLEM_FOOD, PROBLEM_CONFLICT, PROBLEM_HULL, PROBLEM_LIFE_SUPPORT
  };
  arrayCopy(deterministic_sequence, incident_sequence);
  screen = SCREEN_COMMAND;
  current_room = SCREEN_COMMAND;
}

void endVerificationFixture(){
  restoreVerificationFixture();
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
    performance_mode |= args[i].equals("--metrics");
  }

  if (pipeline_test_mode){
    pipeline_probe_image = loadImage(PIPELINE_PROBE_FILE);
    preparePipelineProbe();
  }

  if (capture_mode || ladder_test_mode || pipeline_test_mode || performance_mode){
    new File(sketchPath("output")).mkdirs();
  }

  if (performance_mode){
    performance_metrics_writer = createWriter(sketchPath("output/performance__metricas.csv"));
    performance_metrics_writer.println(
      "sample,duration_s,frames,frame_median_ms,frame_p95_ms,load_ms,"
      + "memory_additional_bytes,resource_icon_builds,deck_strip_builds,cache_invalidations"
    );
    performance_metrics_writer.flush();
  }
}


long performanceUsedMemory(){
  Runtime runtime = Runtime.getRuntime();
  return runtime.totalMemory() - runtime.freeMemory();
}


void beginPerformanceSample(long started_nanos){
  performance_sample_frames = 0;
  performance_sample_started_nanos = started_nanos;
  performance_last_frame_nanos = started_nanos;
  performance_sample_start_memory = performanceUsedMemory();
  performance_sample_peak_memory = performance_sample_start_memory;
  performance_sample_resource_builds = resource_icon_builds;
  performance_sample_deck_builds = deck_strip_builds;
  performance_sample_invalidations = cache_invalidations;
}


float performancePercentile(float[] values, int count, float percentile){
  if (count <= 0) return 0;

  float[] sorted = new float[count];
  arrayCopy(values, sorted, count);
  java.util.Arrays.sort(sorted);
  int index = int(ceil(count * percentile)) - 1;
  index = constrain(index, 0, count - 1);
  return sorted[index];
}


void finishPerformanceSample(long ended_nanos){
  float duration_seconds = (ended_nanos - performance_sample_started_nanos) / 1000000000.0f;
  float median_ms = performancePercentile(performance_frame_times, performance_sample_frames, 0.50);
  float p95_ms = performancePercentile(performance_frame_times, performance_sample_frames, 0.95);
  long additional_memory = java.lang.Math.max(0L,
    performance_sample_peak_memory - performance_sample_start_memory);

  performance_metrics_writer.println(
    (performance_sample_index + 1) + ","
      + Float.toString(duration_seconds) + ","
      + performance_sample_frames + ","
      + Float.toString(median_ms) + ","
      + Float.toString(p95_ms) + ","
      + art_load_ms + ","
      + additional_memory + ","
      + (resource_icon_builds - performance_sample_resource_builds) + ","
      + (deck_strip_builds - performance_sample_deck_builds) + ","
      + (cache_invalidations - performance_sample_invalidations)
  );
  performance_metrics_writer.flush();
  println("metrics: amostra " + (performance_sample_index + 1)
    + " | mediana " + Float.toString(median_ms)
    + " ms | p95 " + Float.toString(p95_ms) + " ms"
    + " | memória adicional " + additional_memory + " bytes");

  performance_sample_index++;
  if (performance_sample_index >= PERFORMANCE_SAMPLE_COUNT){
    performance_metrics_writer.close();
    println("METRICS CHECK: PASS");
    exit();
    return;
  }

  beginPerformanceSample(ended_nanos);
}


void updatePerformanceMetrics(){
  long now_nanos = System.nanoTime();
  if (performance_last_frame_nanos == 0){
    performance_last_frame_nanos = now_nanos;
    return;
  }

  if (performance_warmup_frames < PERFORMANCE_WARMUP_FRAMES){
    performance_warmup_frames++;
    performance_last_frame_nanos = now_nanos;
    if (performance_warmup_frames == PERFORMANCE_WARMUP_FRAMES){
      beginPerformanceSample(now_nanos);
    }
    return;
  }

  float frame_ms = (now_nanos - performance_last_frame_nanos) / 1000000.0f;
  if (performance_sample_frames < performance_frame_times.length){
    performance_frame_times[performance_sample_frames] = frame_ms;
  }
  performance_sample_frames++;
  performance_sample_peak_memory = java.lang.Math.max(performance_sample_peak_memory,
    performanceUsedMemory());
  performance_last_frame_nanos = now_nanos;

  if (now_nanos - performance_sample_started_nanos >= PERFORMANCE_SAMPLE_NANOS){
    int measured_frames = min(performance_sample_frames, performance_frame_times.length);
    performance_sample_frames = measured_frames;
    finishPerformanceSample(now_nanos);
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
  if (performance_mode){
    updatePerformanceMetrics();
    return;
  }

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
      restoreVerificationFixture();
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

  base.save(verificationOutputPath("pipeline", "probe", RENDER_W, RENDER_H));
  saveFrame(verificationOutputPath("pipeline_window", "probe", width, height));

  if (loaded){
    println("pipeline: OK - " + PIPELINE_PROBE_FILE
      + " carregado via loadImage()");
  } else {
    println("pipeline: FALHOU - " + PIPELINE_PROBE_FILE
      + " não foi carregado");
  }

  restoreVerificationFixture();
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
  base.save(verificationOutputPath("capture", capture_label[step], RENDER_W, RENDER_H));
  saveFrame(verificationOutputPath("capture_window", capture_label[step], width, height));
  println("capture: " + capture_label[step] + " -> " + screenName());
}

String verificationOutputPath(String stage, String state, int viewport_w, int viewport_h){
  return sketchPath("output/" + stage + "__" + state + "__"
    + viewport_w + "x" + viewport_h + ".png");
}


void runCaptureStep(int step){
  if (step == 0){ typeText("TECNICO"); clickAction(ACTION_START_GAME); }
  else if (step >= 1 && step <= 3) clickAction(ACTION_VIGNETTE_NEXT);
  else if (step == 4){
    verify("dia 1 começa livre com ofertas disponíveis", day == 1 && screen == SCREEN_COMMAND && !modalOpen() && ordersAvailable());
    clickAction(ACTION_OPEN_ORDERS);
    base.save(verificationOutputPath("manual", "preventive_offers", RENDER_W, RENDER_H));
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
    verify("mapa gráfico não transporta", map_open
      && screen == before_room && player_x == before);
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
  int selected_offer = choice >= 0 && choice < 2 ? daily_offers[choice] : choice;
  choosePreventive(selected_offer);
  if (selected_preventive_id < 0) return;
  captureInteract(crew_point[quest_owner[selected_preventive_id]]);
  pressEnter();
}

void checkNpcDialogue(){
  captureStartDay(1);
  int owner = quest_owner[daily_offers[0]];
  int other = (owner + 1) % CREW_COUNT;

  while (!crew_alive[other]) other = (other + 1) % CREW_COUNT;

  captureInteract(crew_point[owner]);
  verify("oferta do dia aparece na fala do responsável",
    dialog_open && !technical_open && dialog_text.indexOf("Minha oferta") >= 0);
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
    dialog_open && dialog_result.length() > 0 && dialog_text.indexOf("etapa atual") >= 0);
  closeTopModal();

  captureInteract(crew_point[other]);
  verify("terceiro orienta o próximo passo sem repetir a quest",
    dialog_open && !technical_open && dialog_text.indexOf(crewDisplayName(owner)) >= 0
    && dialog_text.indexOf(editorialSentenceCase(quest_object[active_quest])) >= 0);
  closeTopModal();

  captureCompleteQuest();
  captureInteract(crew_point[owner]);
  verify("quest concluída encerra a conversa",
    dialog_open && (dialog_text.indexOf("Rota conferida") >= 0
      || dialog_text.indexOf("trabalho de hoje acabou") >= 0));
  closeTopModal();

  crew_alive[owner] = false;
  verify("sobrevivente morto não interage", !pointIsAvailable(crew_point[owner]));
  crew_alive[owner] = true;
}


void checkEditorialContract(){
  verify("catálogo editorial cobre 22 IDs únicos", editorialCatalogValid());

  String saved_motivation = editorial_catalog[0][EDITORIAL_SHORT_MOTIVATION];
  editorial_catalog[0][EDITORIAL_SHORT_MOTIVATION] = "";
  String fallback = questMotivation(0);
  editorial_catalog[0][EDITORIAL_SHORT_MOTIVATION] = saved_motivation;
  verify("entrada editorial inválida usa fallback factual",
    fallback.length() > 0 && fallback.indexOf(quest_id[0]) < 0);

  int crew = CREW_VERA;
  int saved_day = day;
  boolean saved_alive = crew_alive[crew];
  resetEditorialMemory();
  crew_alive[crew] = true;
  day = 1;
  recordEditorialResult(0, EDITORIAL_RESULT_HELP);
  int count_before = editorial_conversation_count[crew];
  boolean presented_before = editorial_was_presented[crew];
  String phase_a = editorialPhaseLine(crew);
  String phase_b = editorialPhaseLine(crew);
  verify("consultas editoriais são puras",
    phase_a.equals(phase_b) && editorial_conversation_count[crew] == count_before
    && editorial_was_presented[crew] == presented_before);
  String recognition = editorialRecognition(crew);
  verify("reconhecimento fica disponível no dia do resultado", recognition.length() > 0);
  String context = editorialContextLine(crew);
  verify("contexto não marca apresentação", context.length() > 0 && !editorial_was_presented[crew]);
  beginNpcConversation(crew);
  verify("abertura incrementa uma conversa e apresenta reconhecimento",
    editorial_conversation_count[crew] == count_before + 1 && editorial_was_presented[crew]);
  closeTopModal();

  resetEditorialMemory();
  day = 1;
  recordEditorialResult(0, EDITORIAL_RESULT_HELP);
  day = 2;
  verify("reconhecimento sobrevive ao dia seguinte", editorialRecognition(crew).length() > 0);
  day = 3;
  verify("reconhecimento envelhece depois do dia seguinte", editorialRecognition(crew).length() == 0);

  resetEditorialMemory();
  day = 1;
  recordEditorialResult(0, EDITORIAL_RESULT_HELP);
  recordEditorialRisk(crew);
  verify("risco não sobrescreve resultado editorial",
    editorial_last_result[crew] == EDITORIAL_RESULT_HELP
    && editorial_last_risk_day[crew] == day);
  editorial_last_result[crew] = EDITORIAL_RESULT_OMISSION;
  recordEditorialResult(0, EDITORIAL_RESULT_FAILURE);
  recordEditorialResult(0, EDITORIAL_RESULT_RESCUE);
  verify("prioridade de resultado é socorro, ajuda, falha, omissão",
    editorial_last_result[crew] == EDITORIAL_RESULT_RESCUE);

  resetEditorialMemory();
  day = saved_day;
  crew_alive[crew] = saved_alive;
}


void checkCacheContract(){
  boolean six_sources_available = art_icon != null && art_icon.length == 6;
  for (int icon = 0; icon < 6 && six_sources_available; icon++){
    six_sources_available &= art_icon[icon] != null;
  }
  verify("seis fontes de ícone constroem seis caches", six_sources_available
    && resource_icon_builds == 6
    && resource_icon_entries.size() == 6);

  int icon_builds_before = resource_icon_builds;
  PImage icon_zero_before = resource_icon_cache[0];
  prepareResourceIconCache();
  verify("ícones estabilizam sem buffer por quadro",
    resource_icon_builds == icon_builds_before
    && resource_icon_cache[0] == icon_zero_before);

  boolean shared_floor_source = true;
  boolean shared_floor_bitmap = true;
  for (int deck = 1; deck < DECK_COUNT; deck++){
    shared_floor_source &= deck_strip_sources[deck] == deck_strip_sources[0];
    shared_floor_bitmap &= art_deck_strip[deck] == art_deck_strip[0];
  }
  verify("faixas de piso idênticas compartilham uma entrada imutável",
    shared_floor_source && shared_floor_bitmap && deck_strip_builds == 1);

  PImage saved_icon = art_icon[0];
  PImage alternate_icon = art_icon[1];
  PImage unaffected_cache = resource_icon_cache[1];
  int unaffected_builds = resource_icon_builds_by_icon[1];
  int invalidations_before = cache_invalidations;
  art_icon[0] = alternate_icon;
  ensureResourceIconCache(0);
  boolean selective = resource_icon_cache[1] == unaffected_cache
    && resource_icon_builds_by_icon[1] == unaffected_builds
    && cache_invalidations == invalidations_before + 1;
  art_icon[0] = saved_icon;
  ensureResourceIconCache(0);
  verify("invalidação reconstrói somente a fonte alterada", selective);
}

void checkNpcFacingDuringJump(){
  resetRun();
  float npc_x = 200;
  float npc_y = deck_y[DECK_COUNT - 1];

  player_x = npc_x - PLAYER_W - 4;
  player_y = npc_y - PLAYER_H;
  player_grounded = true;
  player_on_ladder = false;
  verify("NPC olha para o jogador no convés",
    npcFacingForPlayer(npc_x, npc_y) == -1);

  player_grounded = false;
  player_y -= JUMP_HEIGHT / 2.0;
  verify("NPC mantém a direção durante o pulo",
    npcFacingForPlayer(npc_x, npc_y) == -1);

  player_x = npc_x + 4;
  verify("NPC acompanha o jogador no ar",
    npcFacingForPlayer(npc_x, npc_y) == 1);

  resetRun();
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
  beginVerificationFixture();
  checkCacheContract();
  endVerificationFixture();
  beginVerificationFixture();
  checkConnectedDoors();
  endVerificationFixture();
  if (!checks_failed){ beginVerificationFixture(); checkDoorTraversalArt(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkEditorialContract(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNpcDialogue(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNpcFacingDuringJump(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerFacing(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerAnimationLoop(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerRun(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkPlayerFootsteps(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkOrdersBadge(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkQuestCatalogue(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkQuestBoundaries(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNightConsequences(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkNightProjection(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkRetryPriority(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkCrewRules(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkHullDamageLocation(); endVerificationFixture(); }
  if (!checks_failed){ beginVerificationFixture(); checkTransmissionMessages(); endVerificationFixture(); }
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
  base.save(verificationOutputPath("rules", "orders_badge_pulse", RENDER_W, RENDER_H));
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
      base.save(verificationOutputPath("catalogue", quest_id[q] + "_options", RENDER_W, RENDER_H));
      applyEventChoice((q - PREVENTIVE_COUNT) % 2);
      pressEnter();
    }
    int resource = q < PREVENTIVE_COUNT ? preventive_resource[q] : solution_resource[q - PREVENTIVE_COUNT];
    float before = resourceValue(resource);
    int delta = q < PREVENTIVE_COUNT ? preventiveReward(q) : -solution_cost[q - PREVENTIVE_COUNT];
    drawBase();
    base.save(verificationOutputPath("catalogue", quest_id[q] + "_hud", RENDER_W, RENDER_H));
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
  verify("aceite impede trocar de ordem", active_quest == 0 && selected_preventive_id < 0);
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
  choosePreventive(daily_offers[0]);
  captureInteract(POINT_VERA); pressEnter();
  verify("aceite de preventiva do responsável entrega em mãos",
    active_quest == 1 && quest_stage == QUEST_DELIVER && held_item == 2 && nextQuestPoint() == POINT_ROUTE && pointIsAvailable(POINT_ROUTE));
  captureInteract(POINT_VERA);
  verify("responsável pós-entrega orienta a rota no destino",
    dialog_open && dialog_text.indexOf("Já entreguei") >= 0);
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


void checkNightProjection(){
  captureStartDay(1);
  float saved_energy = energy;
  float saved_oxygen = oxygen;
  float saved_food = food;
  int saved_deadline = problem_deadline[PROBLEM_ENGINE];
  int saved_risk_day = editorial_last_risk_day[CREW_VERA];

  randomSeed(817);
  random(1000);
  float expected_random = random(1000);
  randomSeed(817);
  random(1000);
  NightProjection preview = projectNight();
  float actual_random = random(1000);
  verify("preview não consome RNG nem altera globais",
    abs(expected_random - actual_random) < 0.001
      && energy == saved_energy && oxygen == saved_oxygen && food == saved_food
      && problem_deadline[PROBLEM_ENGINE] == saved_deadline
      && editorial_last_risk_day[CREW_VERA] == saved_risk_day);
  NightProjection second_preview = projectNight();
  verify("recalcular preview é determinístico",
    preview.projected_state.energy == second_preview.projected_state.energy
      && preview.projected_state.food == second_preview.projected_state.food
      && preview.game_outcome == second_preview.game_outcome);

  NightSnapshot snapshot = captureNightSnapshot();
  snapshot.crew_alive[CREW_VERA] = false;
  snapshot.incident_sequence[0] = PROBLEM_COMMS;
  verify("snapshot não compartilha arrays com o estado real",
    crew_alive[CREW_VERA] && incident_sequence[0] != PROBLEM_COMMS);

  NightProjection applied = processNight();
  verify("aplicação usa o mesmo resultado do preview",
    energy == applied.projected_state.energy && oxygen == applied.projected_state.oxygen
      && food == applied.projected_state.food && morale == applied.projected_state.morale
      && survivors == applied.projected_state.survivors && day == 1);

  captureStartDay(3);
  activateProblem(PROBLEM_FOOD, 1);
  NightProjection crisis_preview = projectNight();
  verify("preview inclui perda, crise e risco sem processar globais",
    crisis_preview.projected_state.food < food
      && crisis_preview.projected_state.problem_deadline[PROBLEM_FOOD] == 2
      && urgentRisk() < 0 && problem_deadline[PROBLEM_FOOD] == 1);
  processNight();
  verify("crise e risco são aplicados uma única vez",
    problem_deadline[PROBLEM_FOOD] == 2 && urgentRisk() == CREW_VERA);

  captureStartDay(9);
  day = TRIP_DAYS;
  opened_day = TRIP_DAYS;
  resetDailyQuest();
  NightProjection final_preview = projectNight();
  verify("noite do dia 10 projeta vitória",
    final_preview.game_outcome == NIGHT_OUTCOME_VICTORY
      && final_preview.fatal_conditions.length == 0);

  captureStartDay(3);
  for (int crew = 0; crew < CREW_COUNT; crew++) crew_alive[crew] = false;
  survivors = 0;
  NightProjection defeat_preview = projectNight();
  boolean crew_fatal = false;
  for (String condition : defeat_preview.fatal_conditions){
    if (condition.equals("nenhum sobrevivente vivo")) crew_fatal = true;
  }
  verify("morte individual só derrota quando não resta sobrevivente",
    defeat_preview.game_outcome == NIGHT_OUTCOME_DEFEAT && crew_fatal);
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
  verify("retomada exibe detalhes no painel de ordens sem aceitar",
    orders_open && orders_details_open && !technical_open
      && pending_quest_action == ACTION_RETRY_QUEST && active_quest < 0);
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
  enterRoom(SCREEN_DEPOT);
  placePlayerAtDoor(doorInRoomLeadingTo(SCREEN_DEPOT, SCREEN_COMMAND));
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



void checkPlayerFootsteps(){
  resetRun();
  enterRoom(SCREEN_COMMAND);
  move_right_held = true;
  verify("caminhada usa take de ataque único",
    sound_walk_step[0] != null && sound_run_step[0] != null
      && sound_walk_step[0].getMicrosecondLength() <= 15000
      && sound_run_step[0].getMicrosecondLength() > sound_walk_step[0].getMicrosecondLength());

  int before_walk = sound_step_play_count;
  updatePlayerOnDeck();
  verify("caminhada toca o primeiro passo",
    sound_step_play_count == before_walk + 1);
  player_animation_started_at = millis() - (WALK_STEP_HALF_CYCLE_MS - 50);
  updatePlayerOnDeck();
  verify("caminhada não antecipa o contato do pé",
    sound_step_play_count == before_walk + 1);
  player_animation_started_at = millis() - (WALK_STEP_HALF_CYCLE_MS + 50);
  updatePlayerOnDeck();
  verify("caminhada toca no meio do ciclo visual",
    sound_step_play_count == before_walk + 2);

  resetRun();
  enterRoom(SCREEN_COMMAND);
  move_right_held = true;
  run_held = true;
  int before_run = sound_step_play_count;
  updatePlayerOnDeck();
  for (int frame = 0; frame < 11; frame++){
    updatePlayerOnDeck();
  }
  verify("corrida acelera a cadência dos passos",
    sound_step_play_count == before_run + 2);

  resetRun();
  enterRoom(SCREEN_COMMAND);
  move_right_held = false;
  int before_jump = sound_step_play_count;
  jump_queued = true;
  updatePlayerOnDeck();
  jump_queued = false;
  verify("pulo toca a decolagem",
    sound_step_play_count == before_jump + 1);

  for (int frame = 0; frame < 64 && !player_grounded; frame++){
    updatePlayerOnDeck();
  }
  verify("pulo toca a aterrissagem",
    player_grounded && sound_step_play_count == before_jump + 2);

  resetRun();
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
  player_x = constrain(door_x[door] - PLAYER_W / 2.0,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
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
    float room_cx = room_x[i] + room_w[i] / 2.0;
    float room_cy = room_y[i] + room_h[i] / 2.0;
    mouseX = int(room_cx * RENDER_SCALE * view_scale + view_offset_x);
    mouseY = int(room_cy * RENDER_SCALE * view_scale + view_offset_y);
    mouse_pressed = true;
    updateInput();
    verify("hit-test imagem inerte " + room_label[i],
      screen == before_screen && map_open);
  }

  mouseX = 4;
  mouseY = 4;
  mouse_pressed = true;
  updateInput();
  verify("hit-test letterbox preserva mapa", map_open && screen == SCREEN_COMMAND);
  restoreVerificationFixture();
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
  base.save(verificationOutputPath("ladder", "middle_exit", RENDER_W, RENDER_H));
  testLadderReleaseRearms();
  testLadderIdleSnap(middle_y, ladder_player_x);
  checkLadderAnywhere();
  restoreVerificationFixture();
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
    restoreVerificationFixture();
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
