final int PROBLEM_NONE = -1;
final int PROBLEM_ENGINE = 0;
final int PROBLEM_HULL = 1;
final int PROBLEM_FOOD = 2;
final int PROBLEM_CONFLICT = 3;
final int PROBLEM_LIFE_SUPPORT = 4;
final int PROBLEM_POWER = 5;
final int PROBLEM_COMMS = 6;
final int PROBLEM_COUNT = 7;
final int RESOURCE_NONE = -1;
final int RESOURCE_ENERGY = 0;
final int RESOURCE_OXYGEN = 1;
final int RESOURCE_WATER = 2;
final int RESOURCE_FOOD = 3;
final int RESOURCE_MORALE = 4;
final int RESOURCE_PARTS = 5;
final int CREW_VERA = 0;
final int CREW_BENTO = 1;
final int CREW_NEUSA = 2;
final int CREW_SILVIA = 3;
final int CREW_COUNT = 4;
final int PREVENTIVE_COUNT = 8;
final int QUEST_COLLECT = 1;
final int QUEST_DELIVER = 2;

String[] crew_name = {"VERA", "BENTO", "NEUSA", "SÍLVIA"};
int[] crew_point = {POINT_VERA, POINT_BENTO, POINT_NEUSA, POINT_SILVIA};
boolean[] crew_alive = new boolean[CREW_COUNT];
int[] crew_risk_deadline = new int[CREW_COUNT];
int risk_history_count = 0;
String[] problem_title = {
  "FALHA NO MOTOR", "DANO NO CASCO", "FALTA DE COMIDA", "CONFLITO NO DORMITÓRIO",
  "FALHA NO SUPORTE DE VIDA", "FALHA NO SISTEMA DE ENERGIA", "FALHA NAS COMUNICAÇÕES"
};
String[] problem_short = {"MOTOR", "CASCO", "COMIDA", "CONFLITO", "SUPORTE", "ENERGIA", "COMUNICAÇÕES"};
String[] problem_crisis = {
  "MOTOR DESTRUÍDO", "OXIGÊNIO -12", "COMIDA -8 E UMA PESSOA EM RISCO",
  "MORAL -8 E UMA PESSOA EM RISCO", "OXIGÊNIO -10 E UMA PESSOA EM RISCO",
  "ENERGIA -10", "MORAL -8"
};
int[] problem_room = {
  SCREEN_MACHINES, SCREEN_NONE, SCREEN_DEPOT, SCREEN_DORMITORY,
  SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_COMMAND
};
int[] problem_loss_resource = {RESOURCE_ENERGY, RESOURCE_OXYGEN, RESOURCE_FOOD,
  RESOURCE_MORALE, RESOURCE_OXYGEN, RESOURCE_ENERGY, RESOURCE_MORALE};
int[] problem_loss_value = {4, 4, 3, 3, 3, 3, 2};
int[] problem_initial_deadline = {3, 3, 3, 3, 3, 3, 4};
boolean[] problem_active = new boolean[PROBLEM_COUNT];
int[] problem_deadline = new int[PROBLEM_COUNT];
int[] problem_activated_order = new int[PROBLEM_COUNT];
int[] problem_solution = new int[PROBLEM_COUNT];
int[] incident_sequence = new int[5];
int problem_order_counter = 0;

/* Preventives first; then two solutions per problem in problem declaration order. */
String[] quest_id = {"V-01", "V-02", "B-01", "B-02", "N-01", "N-02", "S-01", "S-02",
  "ENG-A", "ENG-B", "HUL-A", "HUL-B", "FOOD-A", "FOOD-B", "CON-A", "CON-B",
  "LIFE-A", "LIFE-B", "PWR-A", "PWR-B", "COM-A", "COM-B"};
String[] quest_title = {
  "CALIBRAR A ANTENA", "ATUALIZAR A ROTA", "REFORÇAR A RESERVA", "SEPARAR PEÇAS DE EMERGÊNCIA",
  "PREPARAR ÁGUA DO GRUPO", "ABRIR ESPAÇO PARA A CONVERSA", "REGULAR A DISTRIBUIÇÃO", "TESTAR O SUPORTE DE VIDA",
  "ALINHAR O EIXO DO MOTOR", "ESTABILIZAR A ROTAÇÃO", "FECHAR A RUPTURA", "SUSTENTAR A PLACA",
  "RECOMPOR O ESTOQUE", "PROTEGER A RESERVA", "MEDIAR A CONVERSA", "REUNIR O GRUPO",
  "REPOR O CARTUCHO", "RECIRCULAR O AR", "ISOLAR O CIRCUITO", "REDISTRIBUIR A CARGA",
  "RESTABELECER O CONTATO", "MANTER A ESCUTA"
};
String[] quest_object = {
  "BOBINA DE TRANSMISSÃO", "CARTÃO DE ROTA", "CAIXA DE PROVISÕES", "CHAVE DE TORQUE",
  "FILTRO DE ÁGUA", "CARTÕES DE MEDIAÇÃO", "MÓDULO DE RELÉ", "CARTUCHO DE OXIGÊNIO",
  "CHAVE DE TORQUE", "ATUADOR DO MOTOR", "KIT DE VEDAÇÃO", "PLACA DE BLINDAGEM",
  "CAIXA DE PROVISÕES", "SELANTE DE ESTOQUE", "CARTÕES DE MEDIAÇÃO", "REFEIÇÃO QUENTE",
  "CARTUCHO DE OXIGÊNIO", "FILTRO DE CO2", "FUSÍVEL DE POTÊNCIA", "MÓDULO DE RELÉ",
  "BOBINA DE TRANSMISSÃO", "CÉLULA DE SINAL"
};
int[] quest_owner = {0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 1, 1, 2, 2, 3, 3, 3, 3, 0, 0};
int[] quest_origin = {
  POINT_RESERVE, POINT_VERA, POINT_RESERVE, POINT_RESERVE, POINT_ROUTE, POINT_NEUSA, POINT_ROUTE, POINT_ROUTE,
  POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE,
  POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE, POINT_ROUTE
};
int[] quest_destination = {
  POINT_ANTENNA, POINT_ROUTE, POINT_STOCK, POINT_BENTO, POINT_COMMON_TABLE, POINT_CONFLICT,
  POINT_DISTRIBUTION, POINT_LIFE_SUPPORT, POINT_ENGINE_BENCH, POINT_ENGINE_BENCH, POINT_HULL, POINT_HULL,
  POINT_STOCK, POINT_STOCK, POINT_CONFLICT, POINT_CONFLICT, POINT_LIFE_SUPPORT, POINT_LIFE_SUPPORT,
  POINT_DISTRIBUTION, POINT_DISTRIBUTION, POINT_ANTENNA, POINT_ANTENNA
};
int[] preventive_resource = {RESOURCE_MORALE, RESOURCE_ENERGY, RESOURCE_FOOD, RESOURCE_PARTS,
  RESOURCE_WATER, RESOURCE_MORALE, RESOURCE_ENERGY, RESOURCE_OXYGEN};
int[][] preventive_pairs = {{0, 2}, {1, 4}, {3, 7}, {5, 6}};
int[] solution_resource = {RESOURCE_PARTS, RESOURCE_ENERGY, RESOURCE_PARTS, RESOURCE_ENERGY,
  RESOURCE_PARTS, RESOURCE_MORALE, RESOURCE_MORALE, RESOURCE_FOOD,
  RESOURCE_PARTS, RESOURCE_ENERGY, RESOURCE_PARTS, RESOURCE_MORALE, RESOURCE_PARTS, RESOURCE_ENERGY};
int[] solution_cost = {2, 8, 1, 6, 1, 4, 5, 4, 1, 6, 1, 5, 1, 5};
int[] daily_offers = {-1, -1};
int selected_order = -1;
int active_quest = -1;
int quest_stage = 0;
boolean quest_completed = false;
boolean preventive_committed = false;
boolean orders_open = false;
int orders_page = -1;
int quest_review = -1;
int pending_quest_action = ACTION_NONE;
int pending_retry = -1;

void resetProblemState(){
  for (int p = 0; p < PROBLEM_COUNT; p++){
    problem_active[p] = false;
    problem_deadline[p] = 0;
    problem_activated_order[p] = 0;
    problem_solution[p] = -1;
  }
  problem_order_counter = 0;
  problem_room[PROBLEM_HULL] = SCREEN_NONE;
  clearHullDamage();
  shuffleIncidentSequence();
  resetDailyQuest();
}

void resetCrewState(){
  survivors = CREW_COUNT;
  risk_history_count = 0;
  for (int crew = 0; crew < CREW_COUNT; crew++){
    crew_alive[crew] = true;
    crew_risk_deadline[crew] = 0;
  }
}

void resetDailyQuest(){
  daily_offers[0] = daily_offers[1] = -1;
  selected_order = active_quest = quest_review = pending_retry = -1;
  held_item = ITEM_NONE;
  quest_stage = 0;
  quest_completed = preventive_committed = orders_open = false;
  orders_page = -1;
  pending_quest_action = ACTION_NONE;
}

void shuffleIncidentSequence(){
  int[] pool = {0, 1, 2, 3, 4, 5, 6};
  for (int i = PROBLEM_COUNT - 1; i > 0; i--){
    int swap = int(random(i + 1));
    int value = pool[i]; pool[i] = pool[swap]; pool[swap] = value;
  }
  arrayCopy(pool, incident_sequence, incident_sequence.length);
}

void selectPreventiveOffers(){
  int[] pair = preventive_pairs[((day - 1) / 2) % preventive_pairs.length];
  int count = 0;
  for (int q : pair) if (crew_alive[quest_owner[q]]) daily_offers[count++] = q;
  for (int q = 0; q < PREVENTIVE_COUNT && count < 2; q++){
    if (!crew_alive[quest_owner[q]] || q == daily_offers[0]) continue;
    if (count == 1 && preventive_resource[q] == preventive_resource[daily_offers[0]]) continue;
    daily_offers[count++] = q;
  }
}

int urgentProblem(){
  int urgent = PROBLEM_NONE;
  for (int p = 0; p < PROBLEM_COUNT; p++){
    if (!problem_active[p]) continue;
    if (urgent < 0 || problem_deadline[p] < problem_deadline[urgent]
      || problem_deadline[p] == problem_deadline[urgent]
      && problem_activated_order[p] < problem_activated_order[urgent]) urgent = p;
  }
  return urgent;
}

int urgentRisk(){
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (crew_alive[crew] && crew_risk_deadline[crew] > 0) return crew;
  }
  return -1;
}

int activeProblemCount(){
  int count = 0;
  for (boolean active : problem_active) if (active) count++;
  return count;
}

int roomProblemCount(int room){
  int count = 0;
  for (int p = 0; p < PROBLEM_COUNT; p++) if (problem_active[p] && problem_room[p] == room) count++;
  return count;
}

void activateProblem(int problem, int deadline){
  if (problem_active[problem]) return;
  problem_activated_order[problem] = ++problem_order_counter;
  problem_active[problem] = true;
  problem_deadline[problem] = deadline;
  if (problem == PROBLEM_HULL){
    if (point_room[POINT_HULL] == SCREEN_NONE) placeHullDamage();
    problem_room[problem] = point_room[POINT_HULL];
  }
}

void clearProblem(int problem){
  problem_active[problem] = false;
  problem_deadline[problem] = 0;
  problem_solution[problem] = -1;
  if (problem == PROBLEM_HULL){
    clearHullDamage();
    problem_room[problem] = SCREEN_NONE;
  }
}

void putSurvivorAtRisk(int sourceProblem){
  if (urgentRisk() >= 0 || survivors == 0) return;
  int slot = risk_history_count % survivors;
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (!crew_alive[crew]) continue;
    if (slot-- != 0) continue;
    crew_risk_deadline[crew] = 2;
    risk_history_count++;
    return;
  }
}

void applyProblemCrisis(int problem){
  if (problem == PROBLEM_ENGINE) engine_state = ENGINE_DESTROYED;
  else if (problem == PROBLEM_HULL) oxygen -= 12;
  else if (problem == PROBLEM_FOOD) food -= 8;
  else if (problem == PROBLEM_CONFLICT || problem == PROBLEM_COMMS) morale -= 8;
  else if (problem == PROBLEM_LIFE_SUPPORT) oxygen -= 10;
  else if (problem == PROBLEM_POWER) energy -= 10;
  if (problem == PROBLEM_FOOD || problem == PROBLEM_CONFLICT || problem == PROBLEM_LIFE_SUPPORT){
    putSurvivorAtRisk(problem);
  }
  problem_deadline[problem] = problem == PROBLEM_ENGINE ? 0 : 2;
  system_message = "CRISE: " + problem_crisis[problem] + ".";
}

boolean canPayResource(int resource, int amount){ return resourceValue(resource) >= amount; }

float resourceValue(int resource){
  if (resource == RESOURCE_ENERGY) return energy;
  if (resource == RESOURCE_OXYGEN) return oxygen;
  if (resource == RESOURCE_WATER) return water;
  if (resource == RESOURCE_FOOD) return food;
  if (resource == RESOURCE_MORALE) return morale;
  return resource == RESOURCE_PARTS ? parts : 0;
}

void payResource(int resource, int amount){
  if (resource == RESOURCE_ENERGY) energy -= amount;
  else if (resource == RESOURCE_OXYGEN) oxygen -= amount;
  else if (resource == RESOURCE_WATER) water -= amount;
  else if (resource == RESOURCE_FOOD) food -= amount;
  else if (resource == RESOURCE_MORALE) morale -= amount;
  else if (resource == RESOURCE_PARTS) parts -= amount;
}

boolean dailyQuestFree(){ return active_quest < 0 && !quest_completed; }
int questProblem(int q){ return q < PREVENTIVE_COUNT ? PROBLEM_NONE : (q - PREVENTIVE_COUNT) / 2; }
int preventiveReward(int q){ return preventive_resource[q] == RESOURCE_PARTS ? 2 : 8; }
int preventiveFailure(int q){ return preventive_resource[q] == RESOURCE_PARTS ? 1 : 3; }
int preventiveNeglect(int q){ return preventive_resource[q] == RESOURCE_PARTS ? 2 : 4; }

void choosePreventive(int choice){
  if (!dailyQuestFree() || event_open || choice < 0 || choice > 1) return;
  int q = daily_offers[choice];
  if (q < 0 || !crew_alive[quest_owner[q]]) return;
  selected_order = q;
  orders_open = false;
  system_message = "CONFIRME COM " + crew_name[quest_owner[q]] + " EM "
    + roomTitle(point_room[crew_point[quest_owner[q]]]) + ".";
}

void acceptPreventive(){
  int q = selected_order;
  if (q < 0 || !dailyQuestFree() || event_open || !crew_alive[quest_owner[q]]) return;
  if (!atQuestPoint(crew_point[quest_owner[q]])) return;
  active_quest = q;
  selected_order = -1;
  preventive_committed = true;
  quest_stage = QUEST_COLLECT;
  dialog_open = false;
  pending_quest_action = ACTION_NONE;
  system_message = "ORDEM CONFIRMADA. COLETE " + quest_object[q] + ".";
}

void acceptSolution(int q){
  if (!dailyQuestFree() || selected_order >= 0 || q < PREVENTIVE_COUNT || q >= quest_id.length) return;
  int problem = questProblem(q);
  if (event_open){
    if (problem != event_index) return;
  } else if (incidentForDay(day) != PROBLEM_NONE || !problem_active[problem] || problem_solution[problem] != q){
    return;
  }
  activateProblem(problem, problem_initial_deadline[problem]);
  problem_solution[problem] = q;
  active_quest = q;
  quest_stage = QUEST_COLLECT;
  event_open = orders_open = technical_open = false;
  quest_review = pending_retry = -1;
  pending_quest_action = ACTION_NONE;
  system_message = "SOLUÇÃO CONFIRMADA. COLETE " + quest_object[q] + ".";
}

boolean atQuestPoint(int point){ return point_room[point] == screen && isPointInRange(point); }

void collectQuestObject(){
  if (active_quest < 0 || quest_stage != QUEST_COLLECT || held_item != ITEM_NONE) return;
  if (!atQuestPoint(quest_origin[active_quest])) return;
  held_item = active_quest + 1;
  quest_stage = QUEST_DELIVER;
  system_message = quest_object[active_quest] + " COLETADO. LEVE AO DESTINO.";
}

void deliverQuest(){
  int q = active_quest;
  if (q < 0 || quest_completed || quest_stage != QUEST_DELIVER || held_item != q + 1) return;
  if (!atQuestPoint(quest_destination[q])) return;
  if (q >= PREVENTIVE_COUNT){
    int i = q - PREVENTIVE_COUNT;
    if (!canPayResource(solution_resource[i], solution_cost[i])){
      system_message = "RECURSOS INSUFICIENTES. O OBJETO CONTINUA NA MÃO.";
      return;
    }
    payResource(solution_resource[i], solution_cost[i]);
    if (questProblem(q) == PROBLEM_ENGINE && problem_deadline[PROBLEM_ENGINE] == 1) engine_repaired_at_limit = true;
    clearProblem(questProblem(q));
    system_message = "SOLUÇÃO CONCLUÍDA: " + quest_title[q] + ".";
  } else {
    payResource(preventive_resource[q], -preventiveReward(q));
    system_message = "ORDEM CONCLUÍDA: +" + preventiveReward(q) + " " + resourceName(preventive_resource[q]) + ".";
  }
  active_quest = -1;
  quest_stage = 0;
  held_item = ITEM_NONE;
  quest_completed = true;
  clampResources();
  checkEndConditions();
}

boolean rescueUrgentSurvivor(){
  int crew = urgentRisk();
  if (crew < 0 || event_open || !dailyQuestFree() || selected_order >= 0 || !atQuestPoint(POINT_RISK_BUNK)) return false;
  if (water < 8 || food < 2){
    system_message = "SOCORRO EXIGE 8 ÁGUA E 2 COMIDA.";
    return false;
  }
  water -= 8;
  food -= 2;
  crew_risk_deadline[crew] = 0;
  quest_completed = true;
  system_message = crew_name[crew] + " FOI ESTABILIZADO(A).";
  return true;
}

int preventiveNightLoss(int resource){
  if (preventive_committed){
    return active_quest >= 0 && active_quest < PREVENTIVE_COUNT
      && preventive_resource[active_quest] == resource ? preventiveFailure(active_quest) : 0;
  }
  int loss = 0;
  for (int q : daily_offers){
    if (q >= 0 && preventive_resource[q] == resource) loss = max(loss, preventiveNeglect(q));
  }
  return loss;
}

String questNightSummary(){
  if (preventive_committed){
    if (quest_completed) return "ORDEM CONCLUÍDA. RECOMPENSA JÁ RECEBIDA.";
    return "ORDEM NÃO CONCLUÍDA: -" + preventiveFailure(active_quest) + " "
      + resourceName(preventive_resource[active_quest]) + ". O OBJETO VOLTA À ORIGEM.";
  }
  String result = active_quest >= PREVENTIVE_COUNT ? "SOLUÇÃO NÃO CONCLUÍDA. PROBLEMA PERMANECE ATIVO. " : "";
  if (daily_offers[0] >= 0){
    result += "NENHUMA ORDEM ACEITA: ";
    for (int i = 0; i < 2; i++){
      int q = daily_offers[i];
      if (q >= 0) result += (i == 0 ? "" : " E ") + "-" + preventiveNeglect(q) + " " + resourceName(preventive_resource[q]);
    }
  }
  return result.length() > 0 ? result : "QUEST DO DIA CONCLUÍDA.";
}

int nextQuestPoint(){
  if (active_quest >= 0) return quest_stage == QUEST_COLLECT ? quest_origin[active_quest] : quest_destination[active_quest];
  return selected_order >= 0 ? crew_point[quest_owner[selected_order]] : -1;
}

String pointDisplayLabel(int point){
  if (point == POINT_RISK_BUNK){
    int crew = urgentRisk();
    return crew < 0 ? "SOCORRO" : "SOCORRER " + crew_name[crew] + " (" + crew_risk_deadline[crew] + "D)";
  }
  return point_label[point];
}

int crewAtPoint(int point){
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (crew_point[crew] == point) return crew;
  }

  return -1;
}


boolean pointIsAvailable(int point){
  if (point == POINT_TECH_BUNK) return true;
  if (point == POINT_RISK_BUNK)
    return urgentRisk() >= 0 && dailyQuestFree() && selected_order < 0 && !event_open;
  int crew = crewAtPoint(point);
  if (crew >= 0) return crew_alive[crew];
  return point == nextQuestPoint();
}

boolean ordersAvailable(){
  if (!dailyQuestFree() || selected_order >= 0 || event_open) return false;
  if (daily_offers[0] >= 0 || daily_offers[1] >= 0) return true;
  for (int p = 0; p < PROBLEM_COUNT; p++)
    if (problem_active[p] && problem_solution[p] >= 0) return true;
  return false;
}

boolean pointIsInteractable(int point){ return pointIsAvailable(point); }

void interactPoint(int point){
  if (!atQuestPoint(point) || !pointIsAvailable(point) || modalOpen() || paused) return;
  if (active_quest >= 0 && nextQuestPoint() == point){
    openQuestStepPanel();
  } else if (point == POINT_TECH_BUNK){
    end_day_open = true;
  } else if (point_kind[point] == POINT_NPC){
    interactNpc(point);
  } else if (point == POINT_RISK_BUNK){
    openRescuePanel();
  }
}

int offerOf(int owner){
  for (int i = 0; i < 2; i++){
    if (daily_offers[i] >= 0 && quest_owner[daily_offers[i]] == owner) return daily_offers[i];
  }

  return -1;
}


String questStageLabel(int q){
  if (q < 0) return "SEM ORDEM";
  if (active_quest < 0) return "CONFIRMAR";
  return quest_stage == QUEST_COLLECT ? "COLETAR" : "ENTREGAR";
}


void interactNpc(int point){
  int owner = crewAtPoint(point);

  if (owner < 0 || !crew_alive[owner]) return;

  String name = crew_name[owner];

  if (selected_order >= 0 && quest_owner[selected_order] == owner && dailyQuestFree()){
    openDialogue(name, "CONFIRME A ORDEM. ELA NÃO PODE SER CANCELADA. " + questDetails(selected_order));
    pending_quest_action = ACTION_ACCEPT_ORDER;
    return;
  }

  if (selected_order >= 0){
    openDialogue(name, "DECISÃO EM ANDAMENTO. CONFIRME COM " + crew_name[quest_owner[selected_order]]
      + " EM " + pointLocation(crew_point[quest_owner[selected_order]]) + ".");
    return;
  }

  if (active_quest >= 0 && quest_owner[active_quest] == owner){
    openDialogue(name, "SIGA A ORDEM: " + questStageLabel(active_quest) + " " + quest_object[active_quest]
      + " — " + pointLocation(nextQuestPoint()) + ". " + questEffect(active_quest) + ".");
    return;
  }

  if (active_quest >= 0){
    openTechnical(name, "ORDEM ATIVA COM " + crew_name[quest_owner[active_quest]] + ": " + quest_object[active_quest]
      + " — " + pointLocation(nextQuestPoint()) + ". FALE COM " + crew_name[quest_owner[active_quest]] + ".");
    return;
  }

  if (quest_completed){
    openDialogue(name, "TRABALHO CONCLUÍDO. SEU BELICHE ENCERRA O DIA.");
    return;
  }

  int offer = offerOf(owner);
  if (offer >= 0){
    openDialogue(name, "MINHA OFERTA: " + quest_title[offer] + ". OBJETO: " + quest_object[offer]
      + ". COLETA: " + pointLocation(quest_origin[offer]) + ". ENTREGA: " + pointLocation(quest_destination[offer])
      + ". COMPARE COM A OUTRA EM ORDENS.");
    return;
  }

  int urgent = urgentProblem();
  if (urgent >= 0){
    openTechnical(name, "PROBLEMA ATIVO: " + problem_title[urgent] + ". " + problemLossLabel(urgent)
      + "; PRAZO " + problem_deadline[urgent] + ". " + (event_open
      ? "ESCOLHA UMA SOLUÇÃO NO CARTÃO." : "ESCOLHA OU RETOME UMA SOLUÇÃO EM ORDENS."));
    return;
  }

  openDialogue(name, "NADA PENDENTE COMIGO HOJE.");
}

void openQuestStepPanel(){
  int q = active_quest;
  boolean collecting = quest_stage == QUEST_COLLECT;
  openTechnical((collecting ? "COLETAR " : "ENTREGAR ") + quest_object[q] + "?",
    "SERVE PARA " + quest_title[q] + ". " + questDetails(q));
  pending_quest_action = collecting ? ACTION_COLLECT_QUEST : ACTION_DELIVER_QUEST;
}

void openRescuePanel(){
  openTechnical(pointDisplayLabel(POINT_RISK_BUNK), "SOCORRO: -8 ÁGUA E -2 COMIDA. ESTABILIZA A PESSOA E CONCLUI A QUEST DO DIA. "
    + ((!dailyQuestFree() || selected_order >= 0) ? "A QUEST DO DIA JÁ FOI ESCOLHIDA. " : "")
    + "SEM SOCORRO, MORRE QUANDO O PRAZO ZERAR. EM DIA PREVENTIVO, AS DUAS PERDAS POR NEGLIGÊNCIA CONTINUAM.");
  pending_quest_action = ACTION_RESCUE;
}

boolean pendingQuestEnabled(){
  if (pending_quest_action == ACTION_RESCUE) return dailyQuestFree() && selected_order < 0 && urgentRisk() >= 0 && water >= 8 && food >= 2;
  if (pending_quest_action == ACTION_DELIVER_QUEST && active_quest >= PREVENTIVE_COUNT){
    int i = active_quest - PREVENTIVE_COUNT;
    return canPayResource(solution_resource[i], solution_cost[i]);
  }
  return pending_quest_action != ACTION_NONE;
}

void applyQuestAction(){
  if (!pendingQuestEnabled()) return;
  int action = pending_quest_action;
  technical_open = false;
  pending_quest_action = ACTION_NONE;
  if (action == ACTION_ACCEPT_ORDER) acceptPreventive();
  else if (action == ACTION_COLLECT_QUEST) collectQuestObject();
  else if (action == ACTION_DELIVER_QUEST) deliverQuest();
  else if (action == ACTION_RESCUE) rescueUrgentSurvivor();
  else if (action == ACTION_RETRY_QUEST) acceptSolution(pending_retry);
}

String heldItemLabel(){ return held_item == ITEM_NONE ? "NENHUM" : quest_object[held_item - 1]; }
String pointLocation(int point){ return point_label[point] + " (" + room_label[roomIndex(point_room[point])] + ")"; }

String questEffect(int q){
  if (q < PREVENTIVE_COUNT) return "RECOMPENSA: +" + preventiveReward(q) + " " + resourceName(preventive_resource[q]);
  int i = q - PREVENTIVE_COUNT;
  return "CUSTO: -" + solution_cost[i] + " " + resourceName(solution_resource[i]);
}

String questFailure(int q){
  if (q < PREVENTIVE_COUNT) return "SE FALHAR: -" + preventiveFailure(q) + " " + resourceName(preventive_resource[q]);
  int p = questProblem(q);
  int deadline = problem_active[p] ? problem_deadline[p] : problem_initial_deadline[p];
  return "SE FALHAR: " + problemLossLabel(p) + "; PRAZO " + deadline + "; " + problem_crisis[p]
    + (p == PROBLEM_ENGINE ? "." : "; REINICIA EM 2 DIAS.");
}

String questDetails(int q){
  return "RESPONSÁVEL: " + crew_name[quest_owner[q]] + ". OBJETO: " + quest_object[q]
    + ". COLETA: " + pointLocation(quest_origin[q]) + ". ENTREGA: " + pointLocation(quest_destination[q])
    + ". " + questEffect(q) + ". RESULTADO: " + quest_title[q] + ". " + questFailure(q);
}

String activeProblemSummary(){
  int urgent = urgentProblem();
  return urgent < 0 ? "NENHUM PROBLEMA ATIVO." : activeProblemCount() + " ATIVO(S). MAIS URGENTE: " + problemMapLine(urgent);
}

String problemLossLabel(int problem){ return resourceName(problem_loss_resource[problem]) + " -" + problem_loss_value[problem] + "/DIA"; }
String problemMapLine(int problem){
  return problem_short[problem] + " | " + problemLossLabel(problem) + " | PRAZO " + problem_deadline[problem] + " | " + problem_crisis[problem];
}

void drawQuestCard(PGraphics g, int q, float x, float y, float w, int action, boolean enabled){
  drawPanel(g, x, y, w, 208, q == selected_order ? COL_CYAN : COL_BORDER);
  float row = drawTextWrapped(g, (q < PREVENTIVE_COUNT ? "ORDEM PREVENTIVA — " : "SOLUÇÃO — ") + quest_title[q], x + 10, y + 10, w - 20, 16, 18, COL_CYAN);
  row = drawTextWrapped(g, "RESPONSÁVEL: " + crew_name[quest_owner[q]] + " | " + quest_id[q], x + 10, row + 7, w - 20, 16, 18, COL_MUTED);
  row = drawTextWrapped(g, "OBJETO: " + quest_object[q], x + 10, row + 7, w - 20, 16, 18, COL_TEXT);
  row = drawTextWrapped(g, "COLETA: " + pointLocation(quest_origin[q]), x + 10, row + 7, w - 20, 16, 18, COL_TEXT);
  row = drawTextWrapped(g, "ENTREGA: " + pointLocation(quest_destination[q]), x + 10, row + 7, w - 20, 16, 18, COL_TEXT);
  row = drawTextWrapped(g, questEffect(q), x + 10, row + 7, w - 20, 16, 18, COL_GREEN);
  drawTextWrapped(g, questFailure(q), x + 10, row + 7, w - 20, 16, 18, COL_ORANGE);
  if (action != ACTION_NONE) drawButton(g, x + 10, y + 175, w - 20, 23,
    q < PREVENTIVE_COUNT ? "ESCOLHER; CONFIRMAR COM " + crew_name[quest_owner[q]] : "ESCOLHER SOLUÇÃO", action, enabled);
}

void drawOrdersPanel(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 22, 55, 596, 267, COL_CYAN);
  text(g, "ORDENS — DIA " + day + " | UMA CONCLUSÃO POR DIA", 34, 64, 16, COL_CYAN);
  if (active_quest >= 0){
    drawQuestCard(g, active_quest, 34, 83, 572, ACTION_NONE, false);
    text(g, quest_stage == QUEST_COLLECT ? "ETAPA: COLETAR" : "ETAPA: ENTREGAR", 46, 258, 16, COL_GREEN);
  } else if (quest_completed){
    text(g, "QUEST CONCLUÍDA. RETORNE AO SEU BELICHE.", 40, 106, 16, COL_GREEN);
    drawTextWrapped(g, questNightSummary(), 40, 132, 556, 16, 18, COL_ORANGE);
  } else if (orders_page >= 0){
    drawQuestCard(g, problem_solution[orders_page], 34, 83, 572, ACTION_RETRY_QUEST, selected_order < 0);
  } else {
    for (int i = 0; i < 2; i++) if (daily_offers[i] >= 0)
      drawQuestCard(g, daily_offers[i], 34 + i * 290, 83, 282, i == 0 ? ACTION_ORDER_A : ACTION_ORDER_B, true);
  }
  if (dailyQuestFree() && incidentForDay(day) == PROBLEM_NONE && activeProblemCount() > 0)
    drawButton(g, 34, 297, 218, 20, "OFERTAS / PRÓXIMA RETOMADA", ACTION_NEXT_RETRY, true);
  drawButton(g, 470, 297, 136, 20, "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
}

void cycleRetry(){
  for (int p = orders_page + 1; p < PROBLEM_COUNT; p++){
    if (problem_active[p] && problem_solution[p] >= 0){ orders_page = p; return; }
  }
  orders_page = -1;
}

void reviewRetry(){
  if (orders_page < 0 || !dailyQuestFree() || selected_order >= 0) return;
  int q = problem_solution[orders_page];
  orders_open = false;
  openTechnical("RETOMAR A MESMA SOLUÇÃO?", questDetails(q) + " A PREVENTIVA NÃO ACEITA CONTINUA SUJEITA À NEGLIGÊNCIA.");
  pending_retry = q;
  pending_quest_action = ACTION_RETRY_QUEST;
}
