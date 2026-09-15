int event_index = -1;
boolean event_open = false;

String[] event_body = {
  "O MOTOR PERDEU RENDIMENTO. ESCOLHA COMO CONTER A FALHA.",
  "O CASCO FOI ATINGIDO. ESCOLHA COMO CONTER A PERDA.",
  "O ESTOQUE NÃO SUSTENTA O RITMO ATUAL.",
  "UMA DISCUSSÃO DIVIDE OS SOBREVIVENTES.",
  "O SUPORTE DE VIDA PERDEU ESTABILIDADE.",
  "A REDE ELÉTRICA OPERA EM SOBRECARGA.",
  "O TRANSMISSOR PERDEU O CONTATO COM A TERRA."
};

void startGame(){
  resetRun();
  vignette_page = 0;
  screen = SCREEN_VIGNETTE;
}

void resetRun(){
  player_name = player_name.trim();
  if (player_name.length() == 0) player_name = "Técnico";

  day = 1;
  trip_days = TRIP_DAYS;
  energy = STOCK_START;
  oxygen = STOCK_START;
  water = STOCK_START;
  food = FOOD_START;
  morale = STOCK_START;
  parts = PARTS_START;
  engine_state = ENGINE_WORKING;
  saving_on = false;
  rationing_on = false;
  boost_count = 0;
  game_over_reason = REASON_NONE;
  paused = false;
  system_message = "";
  last_system_message = "";
  event_index = PROBLEM_NONE;
  event_open = false;
  resetCrewState();
  resetRoomState();
  resetProblemState();
}

void openDay(){
  intervention_used = false;
  skip_next_day = false;
  event_open = false;
  event_index = incidentForDay(day);
  if (event_index == PROBLEM_NONE) return;

  event_open = true;
  if (!eventChoiceOn(0) && !eventChoiceOn(1)){
    activateProblem(event_index, containment_deadline[event_index][1]);
    applyProblemCrisis(event_index);
    event_open = false;
    clampResources();
    checkEndConditions();
  }
}

int incidentForDay(int value){
  if (value < 1 || value > 9 || value % 2 == 0) return PROBLEM_NONE;
  int index = (value - 1) / 2;
  return index < incident_sequence.length ? incident_sequence[index] : PROBLEM_NONE;
}

boolean eventChoiceOn(int choice){
  if (event_index < 0 || event_index >= PROBLEM_COUNT || choice < 0 || choice > 1) return false;
  return canPayResource(containment_resource[event_index][choice], containment_cost[event_index][choice]);
}

void applyEventChoice(int choice){
  if (!event_open || !eventChoiceOn(choice)) return;
  int problem = event_index;
  payResource(containment_resource[problem][choice], containment_cost[problem][choice]);
  activateProblem(problem, containment_deadline[problem][choice]);
  event_open = false;
  system_message = problem_short[problem] + " CONTIDO; A CAUSA SEGUE ATIVA.";
  clampResources();
  checkEndConditions();
}

void endDay(){
  if (event_open) return;

  int policy_cost = specialistAlive(CREW_BENTO) ? 1 : 2;
  if (saving_on) morale -= policy_cost;
  if (rationing_on) morale -= policy_cost;

  energy -= dailyEnergyCost();
  oxygen -= energy < RESOURCE_LOW_ENERGY ? OXYGEN_PER_DAY_LOW_ENERGY : OXYGEN_PER_DAY;
  water -= dailyWaterCost();
  food -= dailyFoodCost();

  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (problem_active[problem]) payResource(problem_loss_resource[problem], problem_loss_value[problem]);
  }

  int red = 0;
  if (isRed(energy)) red++;
  if (isRed(oxygen)) red++;
  if (isRed(water)) red++;
  if (isRed(food)) red++;
  morale -= MORALE_PER_DAY + red * MORALE_PER_RED_RESOURCE;

  processSurvivorRisks();
  processProblemDeadlines();
  clampResources();

  if (checkEndConditions()) return;

  int next_day = day + (skip_next_day ? 2 : 1);
  if (next_day > TRIP_DAYS){
    screen = SCREEN_VICTORY;
    event_open = false;
    return;
  }

  day = next_day;
  enterRoom(SCREEN_DORMITORY);
  openDay();
}

void processSurvivorRisks(){
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (!crew_alive[crew] || crew_risk_deadline[crew] <= 0) continue;
    crew_risk_deadline[crew]--;
    if (crew_risk_deadline[crew] <= 0){
      crew_alive[crew] = false;
      survivors--;
      system_message = crew_name[crew] + " NÃO RESISTIU.";
    }
  }
}

void processProblemDeadlines(){
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (!problem_active[problem]) continue;
    problem_deadline[problem]--;
    if (problem_deadline[problem] <= 0) applyProblemCrisis(problem);
  }
}

int dailyEnergyCost(){
  return saving_on ? ENERGY_PER_DAY_SAVING : ENERGY_PER_DAY;
}

int dailyOxygenCost(){
  float after_energy = energy - dailyEnergyCost();
  return after_energy < RESOURCE_LOW_ENERGY ? OXYGEN_PER_DAY_LOW_ENERGY : OXYGEN_PER_DAY;
}

int dailyWaterCost(){
  return rationing_on ? WATER_PER_DAY_RATIONING : WATER_PER_DAY;
}

int dailyFoodCost(){
  return rationing_on ? FOOD_PER_DAY_RATIONING : FOOD_PER_DAY;
}

int dailyPolicyMoraleCost(){
  int each = specialistAlive(CREW_BENTO) ? 1 : 2;
  return (saving_on ? each : 0) + (rationing_on ? each : 0);
}

int dailyProblemLoss(int resource){
  int total = 0;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (problem_active[problem] && problem_loss_resource[problem] == resource){
      total += problem_loss_value[problem];
    }
  }
  return total;
}

boolean isRed(float value){
  return value > 0 && value < RESOURCE_RED;
}

int resourceColour(float value){
  if (value <= 0 || value < RESOURCE_RED) return COL_RED;
  if (value < RESOURCE_GREEN) return COL_YELLOW;
  return COL_GREEN;
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
  event_open = false;
  paused = false;
  screen = SCREEN_GAME_OVER;
  return true;
}

String engineStateLabel(){
  return engine_state == ENGINE_DESTROYED ? "DESTRUÍDO" : "OPERANTE";
}

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
  drawPanel(g, 42, 60, 556, 240, COL_ORANGE);
  text(g, "INCIDENTE — DIA " + day, 60, 74, 16, COL_ORANGE);
  text(g, problem_title[event_index], 60, 102, 16, COL_TEXT);
  drawTextWrapped(g, event_body[event_index], 60, 128, 520, 16, 18, COL_MUTED);
  drawEventOption(g, 60, 190, 250, containment_label[event_index][0],
    containmentEffect(event_index, 0), ACTION_EVENT_A, eventChoiceOn(0));
  drawEventOption(g, 330, 190, 250, containment_label[event_index][1],
    containmentEffect(event_index, 1), ACTION_EVENT_B, eventChoiceOn(1));
}

String containmentEffect(int problem, int choice){
  return resourceName(containment_resource[problem][choice]) + " -"
    + containment_cost[problem][choice] + "; PRAZO "
    + containment_deadline[problem][choice] + ". CAUSA SEGUE ATIVA.";
}

String resourceName(int resource){
  if (resource == RESOURCE_ENERGY) return "ENERGIA";
  if (resource == RESOURCE_OXYGEN) return "OXIGÊNIO";
  if (resource == RESOURCE_WATER) return "ÁGUA";
  if (resource == RESOURCE_FOOD) return "COMIDA";
  if (resource == RESOURCE_MORALE) return "MORAL";
  return "PEÇAS";
}

void drawEventOption(PGraphics g, float x, float y, float w, String label,
  String effect, int action, boolean on){
  boolean hover = on && uiLayer() == LAYER_MODAL && isHovering(x, y, w, 82);
  int border = on ? (hover ? COL_CYAN : COL_BORDER) : COL_DIM;
  drawPanel(g, x, y, w, 82, border);
  text(g, label, x + 10, y + 8, 16, on ? COL_TEXT : COL_DIM);
  drawTextWrapped(g, effect, x + 10, y + 34, w - 20, 16, 18, on ? COL_CYAN : COL_DIM);
  addButton(x, y, w, 82, action, on);
}

String dayTaskSummary(){
  return intervention_used ? "INTERVENÇÃO CONCLUÍDA" : "SEM INTERVENÇÃO";
}
