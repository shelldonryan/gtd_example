int event_index = -1;
boolean event_open = false;
int opened_day = 0;
boolean transmission_open = false;
String transmission_text = "";
boolean earth_engine_sent = false;
boolean earth_hull_sent = false;
boolean earth_loss_sent = false;
boolean engine_repaired_at_limit = false;

void startGame(){
  resetRun();
  vignette_page = 0;
  screen = SCREEN_VIGNETTE;
}

void resetRun(){
  player_name = player_name.trim();
  day = 1;
  opened_day = 0;
  trip_days = TRIP_DAYS;
  energy = 80;
  oxygen = 85;
  water = 80;
  food = 70;
  morale = 80;
  parts = 4;
  engine_state = ENGINE_WORKING;
  game_over_reason = REASON_NONE;
  paused = false;
  system_message = last_system_message = "";
  event_index = PROBLEM_NONE;
  event_open = false;
  transmission_open = false;
  transmission_text = "";
  earth_engine_sent = false;
  earth_hull_sent = false;
  earth_loss_sent = false;
  engine_repaired_at_limit = false;
  resetCrewState();
  resetRoomState();
  resetProblemState();
}

void openDay(){
  if (opened_day == day) return;
  opened_day = day;
  resetDailyQuest();
  event_index = incidentForDay(day);
  event_open = event_index != PROBLEM_NONE;
  if (event_open){
    if (event_index == PROBLEM_HULL){
      placeHullDamage();
      problem_room[PROBLEM_HULL] = point_room[POINT_HULL];
    }
    queueEarthTransmission(event_index);
  } else {
    selectPreventiveOffers();
  }
}

/* A transmissão aparece antes do cartão do incidente; fechar revela o evento. */
void queueEarthTransmission(int problem){
  if (problem == PROBLEM_ENGINE && !earth_engine_sent){
    earth_engine_sent = true;
    openTransmission("TERRA: " + player_name + ", O MOTOR FALHOU. NÃO PAREM.");
    return;
  }

  if (problem == PROBLEM_HULL && !earth_hull_sent){
    earth_hull_sent = true;
    openTransmission("TERRA: " + player_name + ", CHUVA DE METEOROS DETECTADA. VERIFIQUEM O CASCO.");
  }
}

void openTransmission(String value){
  transmission_text = value;
  transmission_open = true;
}

String survivorsSummary(){
  if (survivors >= CREW_START) return "SOBREVIVENTES: " + survivors + " DE " + CREW_START;
  return "SOBREVIVENTES: " + survivors + " DE " + CREW_START + " — " + aliveCrewNames();
}

String aliveCrewNames(){
  String names = "";

  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (!crew_alive[crew]) continue;
    names += names.length() == 0 ? crew_name[crew] : ", " + crew_name[crew];
  }

  return names;
}

String marsMessage(){
  if (survivors < CREW_START && engine_repaired_at_limit)
    return "MARTE: " + player_name + ", RECEBEMOS A NAVE. O MOTOR CHEGOU NO LIMITE, MAS VOCÊS CONSEGUIRAM.";

  if (survivors < CREW_START)
    return "MARTE: " + player_name + ", RECEBEMOS OS SOBREVIVENTES QUE RESTARAM. A BASE ESTÁ PRONTA.";

  return "MARTE: " + player_name + ", RECEBEMOS OS QUATRO SOBREVIVENTES. A BASE ESTÁ PRONTA.";
}

void drawTransmissionCard(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 96, 140, 448, 96, COL_CYAN);
  text(g, "TRANSMISSÃO DA TERRA", 112, 150, 16, COL_CYAN);
  drawTextWrapped(g, transmission_text, 112, 172, 416, 16, 18, COL_TEXT);
  drawModalFooter(g, 208, "", ACTION_NONE, false,
    "CONTINUAR (ENTER)", ACTION_CLOSE_MODAL, true, 112, 528);
}

int incidentForDay(int value){
  if (value < 2 || value > TRIP_DAYS || value % 2 == 1) return PROBLEM_NONE;
  return incident_sequence[value / 2 - 1];
}

void applyEventChoice(int choice){
  if (!event_open || choice < 0 || choice > 1 || !dailyQuestFree()) return;
  quest_review = PREVENTIVE_COUNT + event_index * 2 + choice;
}

NightProjection processNight(){
  /* processNight and projectNight intentionally start at the same pure seam;
     the real path applies this single projection and never reruns an effect. */
  NightProjection night_projection = simulateNightTransition();
  applyNightProjection(night_projection);
  return night_projection;
}

void endDay(){
  if (event_open || paused || !isRoomScreen() || !atQuestPoint(POINT_TECH_BUNK)) return;
  NightProjection night_projection = processNight();
  end_day_open = orders_open = dialog_open = technical_open = map_open = false;
  if (night_projection.game_outcome == NIGHT_OUTCOME_DEFEAT){
    paused = false;
    screen = SCREEN_GAME_OVER;
    return;
  }
  if (night_projection.game_outcome == NIGHT_OUTCOME_VICTORY){
    paused = false;
    screen = SCREEN_VICTORY;
    return;
  }
  day++;
  enterRoom(SCREEN_DORMITORY);
  openDay();
}

void processSurvivorRisks(){
  int crew = urgentRisk();
  if (crew < 0) return;
  if (--crew_risk_deadline[crew] == 0){
    crew_alive[crew] = false;
    survivors--;
    system_message = crew_name[crew] + " NÃO RESISTIU.";
    if (!earth_loss_sent){
      earth_loss_sent = true;
      openTransmission("TERRA: " + player_name + ", UMA VIDA FOI PERDIDA. LEVE OS OUTROS ATÉ MARTE.");
    }
  }
}

void processProblemDeadlines(){
  /* Activation order also decides who receives the first simultaneous crisis risk. */
  for (int order = 1; order <= problem_order_counter; order++){
    for (int p = 0; p < PROBLEM_COUNT; p++){
      if (!problem_active[p] || problem_activated_order[p] != order) continue;
      if (--problem_deadline[p] <= 0) applyProblemCrisis(p);
    }
  }
}

int dailyProblemLoss(int resource){
  int total = 0;
  for (int p = 0; p < PROBLEM_COUNT; p++){
    if (problem_active[p] && problem_loss_resource[p] == resource) total += problem_loss_value[p];
  }
  return total;
}

int resourceColour(float value){
  if (value < RESOURCE_RED) return COL_RED;
  if (value < RESOURCE_GREEN) return COL_YELLOW;
  return COL_GREEN;
}

String nightFatalWarning(){
  for (int p = 0; p < PROBLEM_COUNT; p++){
    if (problem_active[p] && p == PROBLEM_ENGINE && problem_deadline[p] <= 1)
      return "Crise fatal: o motor será destruído esta noite";
  }
  if (energy - ENERGY_PER_DAY - dailyProblemLoss(RESOURCE_ENERGY)
    - preventiveNightLoss(RESOURCE_ENERGY) - nightCrisisLoss(RESOURCE_ENERGY) <= 0)
    return "Risco fatal: a energia pode chegar a zero esta noite";
  if (oxygen - OXYGEN_PER_DAY - dailyProblemLoss(RESOURCE_OXYGEN)
    - preventiveNightLoss(RESOURCE_OXYGEN) - nightCrisisLoss(RESOURCE_OXYGEN) <= 0)
    return "Risco fatal: o oxigênio pode chegar a zero esta noite";
  if (morale - MORALE_PER_DAY - dailyProblemLoss(RESOURCE_MORALE)
    - preventiveNightLoss(RESOURCE_MORALE) - nightCrisisLoss(RESOURCE_MORALE) <= 0)
    return "Risco fatal: a moral pode chegar a zero esta noite";
  int risk = urgentRisk();
  if (risk >= 0 && crew_risk_deadline[risk] == 1)
    return "Risco fatal: " + crewDisplayName(risk) + " pode não resistir esta noite";
  return "";
}

/* A deadline of one is consumed after the daily and active-problem losses.
   Keep these values aligned with applyNightCrisis so the HUD can warn before
   a crisis removes the last units of a fatal resource. */
int nightCrisisLoss(int resource){
  int loss = 0;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (!problem_active[problem] || problem_deadline[problem] > 1) continue;
    if (problem == PROBLEM_HULL && resource == RESOURCE_OXYGEN) loss += 12;
    else if (problem == PROBLEM_FOOD && resource == RESOURCE_FOOD) loss += 8;
    else if ((problem == PROBLEM_CONFLICT || problem == PROBLEM_COMMS)
      && resource == RESOURCE_MORALE) loss += 8;
    else if (problem == PROBLEM_LIFE_SUPPORT && resource == RESOURCE_OXYGEN) loss += 10;
    else if (problem == PROBLEM_POWER && resource == RESOURCE_ENERGY) loss += 10;
  }
  return loss;
}

void clampResources(){
  energy = constrain(energy, 0, RESOURCE_MAX);
  oxygen = constrain(oxygen, 0, RESOURCE_MAX);
  water = constrain(water, 0, RESOURCE_MAX);
  food = constrain(food, 0, RESOURCE_MAX);
  morale = constrain(morale, 0, RESOURCE_MAX);
  parts = max(parts, 0);
}

boolean checkEndConditions(){
  game_over_reason = REASON_NONE;
  if (energy <= 0) game_over_reason = REASON_ENERGY;
  else if (oxygen <= 0) game_over_reason = REASON_OXYGEN;
  else if (morale <= 0) game_over_reason = REASON_MORALE;
  else if (engine_state == ENGINE_DESTROYED) game_over_reason = REASON_ENGINE;
  else if (survivors <= 0) game_over_reason = REASON_CREW;
  if (game_over_reason == REASON_NONE) return false;
  event_open = orders_open = dialog_open = technical_open = end_day_open = map_open = help_open = false;
  paused = false;
  screen = SCREEN_GAME_OVER;
  return true;
}

String engineStateLabel(){ return engine_state == ENGINE_DESTROYED ? "DESTRUÍDO" : "OPERANTE"; }

String gameOverTitle(){
  if (game_over_reason == REASON_OXYGEN) return "OXIGÊNIO ZERO";
  if (game_over_reason == REASON_ENERGY) return "ENERGIA ZERO";
  if (game_over_reason == REASON_MORALE) return "MORAL ZERO";
  if (game_over_reason == REASON_CREW) return "SOBREVIVENTES PERDIDOS";
  return "MOTOR DESTRUÍDO";
}

String gameOverMessage(){
  if (game_over_reason == REASON_OXYGEN) return "O OXIGÊNIO ACABOU ANTES DA CHEGADA.";
  if (game_over_reason == REASON_ENERGY) return "SEM ENERGIA, A NAVE NÃO PÔDE SEGUIR.";
  if (game_over_reason == REASON_MORALE) return "A MORAL CAIU A ZERO. O GRUPO NÃO RESISTIU À VIAGEM.";
  if (game_over_reason == REASON_CREW) return "NENHUM SOBREVIVENTE RESTOU A BORDO.";
  return "O MOTOR FOI DESTRUÍDO ANTES DE MARTE.";
}

void drawEventCard(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 22, 55, 596, 267, COL_ORANGE);
  text(g, "INCIDENTE — DIA " + day + " | " + problem_title[event_index], 34, 64, 16, COL_ORANGE);
  if (quest_review >= 0){
    drawQuestCard(g, quest_review, 34, 83, 572, ACTION_NONE, false);
    text(g, "CUSTO NA ENTREGA: " + questCostLabel(quest_review), 44, 147, 14, COL_ORANGE);
    text(g, "CONFIRME A SOLUÇÃO. ELA NÃO PODE SER CANCELADA.", 46, 261, 16, COL_ORANGE);
    drawModalFooter(g, 297, "VOLTAR (ESC)", ACTION_BACK_SOLUTION, true,
      "CONFIRMAR (ENTER)", ACTION_ACCEPT_SOLUTION, true);
  } else {
    for (int i = 0; i < 2; i++){
      int q = PREVENTIVE_COUNT + event_index * 2 + i;
      float card_x = 34 + i * 290;
      drawQuestCard(g, q, card_x, 83, 282,
        i == 0 ? ACTION_EVENT_A : ACTION_EVENT_B, true);
      text(g, "CUSTO NA ENTREGA: " + questCostLabel(q), card_x + 10, 147, 14, COL_ORANGE);
    }
    text(g, "CUSTO PAGO NA ENTREGA. SEM RECURSOS, O PROBLEMA PODE PERMANECER ATIVO.", 34, 300, 16, COL_MUTED);
  }
}

String resourceName(int resource){
  if (resource == RESOURCE_ENERGY) return "ENERGIA";
  if (resource == RESOURCE_OXYGEN) return "OXIGÊNIO";
  if (resource == RESOURCE_WATER) return "ÁGUA";
  if (resource == RESOURCE_FOOD) return "COMIDA";
  if (resource == RESOURCE_MORALE) return "MORAL";
  return "PEÇAS";
}
