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

final String QUEST_REASON_NONE = "";
final String QUEST_REASON_RESOURCE_INSUFFICIENT = "resource_insufficient";
final String QUEST_REASON_CONFIRMATION_PENDING = "confirmation_pending";
final String QUEST_REASON_WRONG_NPC = "wrong_npc";
final String QUEST_REASON_WRONG_POINT = "wrong_point";
final String QUEST_REASON_WRONG_DISTANCE = "wrong_distance";
final String QUEST_REASON_STALE_STATE = "stale_state";
final String QUEST_REASON_DAILY_LIMIT = "daily_limit";
final String QUEST_REASON_INCIDENT_BLOCKED = "incident_blocked";
final String QUEST_REASON_NO_RISK = "no_risk";

class QuestActionReason {
  String kind;
  int resource_id = RESOURCE_NONE;
  float available = 0;
  float required = 0;
  int expected_npc_id = -1;
  int expected_room_id = SCREEN_NONE;
  int expected_point_id = -1;
  int expected_action = ACTION_NONE;
  int current_action = ACTION_NONE;
  int incident_id = PROBLEM_NONE;

  QuestActionReason(String reason_kind){
    kind = reason_kind;
  }

  boolean isClear(){
    return QUEST_REASON_NONE.equals(kind);
  }
}

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
String[] quest_object_file = {
  "bobina_transmissao", "cartao_rota", "caixa_provisoes", "chave_torque",
  "filtro_agua", "cartoes_mediacao", "modulo_rele", "cartucho_oxigenio",
  "chave_torque", "atuador_motor", "kit_vedacao", "placa_blindagem",
  "caixa_provisoes", "selante_estoque", "cartoes_mediacao", "refeicao_quente",
  "cartucho_oxigenio", "filtro_co2", "fusivel_potencia", "modulo_rele",
  "bobina_transmissao", "celula_sinal"
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
int selected_preventive_id = -1;
int active_quest = -1;
int quest_stage = 0;
boolean quest_completed = false;
boolean preventive_committed = false;
boolean orders_open = false;
int orders_page = -1;
boolean orders_details_open = false;
int quest_review = -1;
int pending_quest_action = ACTION_NONE;
int pending_retry = -1;
int pending_retry_problem = PROBLEM_NONE;
int pending_retry_solution = -1;
boolean pending_retry_problem_active = false;
int pending_retry_deadline = -1;
int pending_retry_consequence_resource = RESOURCE_NONE;
int pending_retry_consequence_value = -1;

void clearRetryState(){
  pending_retry = -1;
  pending_retry_problem = PROBLEM_NONE;
  pending_retry_solution = -1;
  pending_retry_problem_active = false;
  pending_retry_deadline = -1;
  pending_retry_consequence_resource = RESOURCE_NONE;
  pending_retry_consequence_value = -1;
}

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
  resetEditorialMemory();
  for (int crew = 0; crew < CREW_COUNT; crew++){
    crew_alive[crew] = true;
    crew_risk_deadline[crew] = 0;
  }
}

void resetDailyQuest(){
  invalidateNightPreview();
  daily_offers[0] = daily_offers[1] = -1;
  selected_preventive_id = active_quest = quest_review = -1;
  clearRetryState();
  held_item = ITEM_NONE;
  quest_stage = 0;
  quest_completed = preventive_committed = orders_open = false;
  orders_page = -1;
  orders_details_open = false;
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
    recordEditorialRisk(crew);
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

boolean validQuestId(int q){
  return q >= 0 && q < quest_id.length;
}

boolean isPreventiveOffer(int q){
  return q >= 0 && (daily_offers[0] == q || daily_offers[1] == q);
}

boolean hasNewIncident(){
  return incidentForDay(day) != PROBLEM_NONE;
}

boolean pointExists(int point){
  return point >= 0 && point < point_room.length;
}

QuestActionReason clearQuestReason(){
  return new QuestActionReason(QUEST_REASON_NONE);
}

QuestActionReason staleQuestReason(int expected_action){
  QuestActionReason reason = new QuestActionReason(QUEST_REASON_STALE_STATE);
  reason.expected_action = expected_action;
  reason.current_action = currentQuestAction();
  return reason;
}

QuestActionReason confirmationPendingReason(int quest_id_value){
  QuestActionReason reason = new QuestActionReason(QUEST_REASON_CONFIRMATION_PENDING);
  if (!validQuestId(quest_id_value) || quest_id_value >= PREVENTIVE_COUNT){
    return staleQuestReason(ACTION_ACCEPT_ORDER);
  }

  int owner = quest_owner[quest_id_value];
  reason.expected_npc_id = owner;
  if (owner >= 0 && owner < CREW_COUNT && pointExists(crew_point[owner])){
    reason.expected_room_id = point_room[crew_point[owner]];
  }
  return reason;
}

int currentQuestAction(){
  if (selected_preventive_id >= 0) return ACTION_ACCEPT_ORDER;
  if (active_quest >= 0){
    return quest_stage == QUEST_COLLECT ? ACTION_COLLECT_QUEST : ACTION_DELIVER_QUEST;
  }
  if (urgentRisk() >= 0) return ACTION_RESCUE;
  return ACTION_NONE;
}

boolean choosePreventive(int quest_id_value){
  if (!dailyQuestFree() || hasNewIncident() || event_open || !validQuestId(quest_id_value)
    || quest_id_value >= PREVENTIVE_COUNT || !isPreventiveOffer(quest_id_value)
    || !crew_alive[quest_owner[quest_id_value]]) return false;
  selected_preventive_id = quest_id_value;
  return true;
}

QuestActionReason preventiveActionReason(){
  int q = selected_preventive_id;
  if (!validQuestId(q) || q >= PREVENTIVE_COUNT) return staleQuestReason(ACTION_ACCEPT_ORDER);
  if (hasNewIncident() || event_open){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_INCIDENT_BLOCKED);
    reason.incident_id = incidentForDay(day);
    return reason;
  }
  if (!dailyQuestFree()) return new QuestActionReason(QUEST_REASON_DAILY_LIMIT);
  if (held_item != ITEM_NONE || quest_stage != 0) return staleQuestReason(ACTION_ACCEPT_ORDER);
  if (!isPreventiveOffer(q)) return staleQuestReason(ACTION_ACCEPT_ORDER);

  int owner = quest_owner[q];
  int expected_point = owner >= 0 && owner < CREW_COUNT ? crew_point[owner] : -1;
  QuestActionReason reason;
  if (owner < 0 || owner >= CREW_COUNT || !crew_alive[owner]){
    reason = new QuestActionReason(QUEST_REASON_WRONG_NPC);
    reason.expected_npc_id = owner;
    reason.expected_room_id = pointExists(expected_point) ? point_room[expected_point] : SCREEN_NONE;
    return reason;
  }
  if (!pointExists(expected_point) || point_room[expected_point] != screen){
    reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = expected_point;
    return reason;
  }
  if (dialog_crew >= 0 && dialog_crew != owner){
    reason = new QuestActionReason(QUEST_REASON_WRONG_NPC);
    reason.expected_npc_id = owner;
    reason.expected_room_id = point_room[expected_point];
    return reason;
  }
  if (!isPointInRange(expected_point)){
    reason = new QuestActionReason(QUEST_REASON_WRONG_DISTANCE);
    reason.expected_point_id = expected_point;
    return reason;
  }
  if (!pointIsAvailable(expected_point)){
    reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = expected_point;
    return reason;
  }
  return clearQuestReason();
}

void acceptPreventive(){
  QuestActionReason reason = preventiveActionReason();
  if (!reason.isClear()){
    system_message = questReasonText(reason);
    return;
  }
  int q = selected_preventive_id;
  int owner = quest_owner[q];
  active_quest = q;
  selected_preventive_id = -1;
  preventive_committed = true;
  dialog_open = false;
  pending_quest_action = ACTION_NONE;
  if (quest_origin[q] == crew_point[owner]){
    held_item = active_quest + 1;
    quest_stage = QUEST_DELIVER;
    system_message = "ORDEM CONFIRMADA. " + crew_name[owner] + " ENTREGOU " + quest_object[q] + ".";
  } else {
    held_item = ITEM_NONE;
    quest_stage = QUEST_COLLECT;
    system_message = "ORDEM CONFIRMADA. COLETE " + quest_object[q] + ".";
  }
}

void acceptSolution(int q){
  int problem = validQuestId(q) ? questProblem(q) : PROBLEM_NONE;
  boolean resuming = pending_retry >= 0
    || (!event_open && q >= PREVENTIVE_COUNT && problem >= 0 && problem < PROBLEM_COUNT
      && problem_active[problem] && problem_solution[problem] == q);
  if (resuming){
    QuestActionReason retry_reason = pending_retry >= 0 ? retryActionReason() : retryActionReasonFor(q);
    if (!retry_reason.isClear()){
      system_message = questReasonText(retry_reason);
      return;
    }
  }
  if (!dailyQuestFree() || selected_preventive_id >= 0 || held_item != ITEM_NONE
    || quest_stage != 0 || !validQuestId(q) || q < PREVENTIVE_COUNT) return;
  problem = questProblem(q);
  if (event_open){
    if (problem != event_index || problem_active[problem]) return;
  } else if (hasNewIncident() || !problem_active[problem] || problem_solution[problem] != q
    || active_quest >= 0 || held_item != ITEM_NONE || quest_stage != 0){
    return;
  }
  activateProblem(problem, problem_initial_deadline[problem]);
  problem_solution[problem] = q;
  active_quest = q;
  quest_stage = QUEST_COLLECT;
  event_open = orders_open = technical_open = false;
  quest_review = -1;
  clearRetryState();
  pending_quest_action = ACTION_NONE;
  system_message = "SOLUÇÃO CONFIRMADA. COLETE " + quest_object[q] + ".";
}

boolean atQuestPoint(int point){ return pointExists(point) && point_room[point] == screen && isPointInRange(point); }

void collectQuestObject(){
  QuestActionReason reason = collectActionReason();
  if (!reason.isClear()){
    system_message = questReasonText(reason);
    return;
  }
  held_item = active_quest + 1;
  quest_stage = QUEST_DELIVER;
  system_message = quest_object[active_quest] + " COLETADO. LEVE AO DESTINO.";
}

QuestActionReason collectActionReason(){
  int q = active_quest;
  if (!validQuestId(q) || quest_stage != QUEST_COLLECT || held_item != ITEM_NONE)
    return staleQuestReason(ACTION_COLLECT_QUEST);
  if (q < PREVENTIVE_COUNT){
    if (!preventive_committed) return staleQuestReason(ACTION_COLLECT_QUEST);
  } else {
    int problem = questProblem(q);
    if (problem < 0 || problem >= PROBLEM_COUNT || !problem_active[problem]
      || problem_solution[problem] != q) return staleQuestReason(ACTION_COLLECT_QUEST);
  }
  int origin = quest_origin[q];
  if (!pointExists(origin) || point_room[origin] != screen){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = origin;
    return reason;
  }
  if (!isPointInRange(origin)){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_DISTANCE);
    reason.expected_point_id = origin;
    return reason;
  }
  if (!pointIsAvailable(origin)){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = origin;
    return reason;
  }
  return clearQuestReason();
}

QuestActionReason deliverActionReason(){
  int q = active_quest;
  if (!validQuestId(q) || quest_completed || quest_stage != QUEST_DELIVER)
    return staleQuestReason(ACTION_DELIVER_QUEST);
  if (q < PREVENTIVE_COUNT && !preventive_committed)
    return staleQuestReason(ACTION_DELIVER_QUEST);
  if (held_item != q + 1) return staleQuestReason(ACTION_DELIVER_QUEST);
  int destination = quest_destination[q];
  if (!pointExists(destination) || point_room[destination] != screen){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = destination;
    return reason;
  }
  if (!isPointInRange(destination)){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_DISTANCE);
    reason.expected_point_id = destination;
    return reason;
  }
  if (!pointIsAvailable(destination)){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = destination;
    return reason;
  }
  if (q >= PREVENTIVE_COUNT){
    int problem = questProblem(q);
    int solution = problem >= 0 && problem < PROBLEM_COUNT ? problem_solution[problem] : -1;
    if (!problem_active[problem] || solution != q) return staleQuestReason(ACTION_DELIVER_QUEST);
    int i = q - PREVENTIVE_COUNT;
    if (!canPayResource(solution_resource[i], solution_cost[i])){
      QuestActionReason reason = new QuestActionReason(QUEST_REASON_RESOURCE_INSUFFICIENT);
      reason.resource_id = solution_resource[i];
      reason.available = resourceValue(solution_resource[i]);
      reason.required = solution_cost[i];
      return reason;
    }
  }
  return clearQuestReason();
}

void deliverQuest(){
  QuestActionReason reason = deliverActionReason();
  if (!reason.isClear()){
    system_message = questReasonText(reason);
    return;
  }
  int q = active_quest;
  if (q >= PREVENTIVE_COUNT){
    int i = q - PREVENTIVE_COUNT;
    payResource(solution_resource[i], solution_cost[i]);
    if (questProblem(q) == PROBLEM_ENGINE && problem_deadline[PROBLEM_ENGINE] == 1) engine_repaired_at_limit = true;
    clearProblem(questProblem(q));
    system_message = "SOLUÇÃO CONCLUÍDA: " + quest_title[q] + ".";
    recordEditorialResult(q, EDITORIAL_RESULT_HELP);
  } else {
    payResource(preventive_resource[q], -preventiveReward(q));
    system_message = "ORDEM CONCLUÍDA: +" + preventiveReward(q) + " " + resourceName(preventive_resource[q]) + ".";
    recordEditorialResult(q, EDITORIAL_RESULT_HELP);
  }
  active_quest = -1;
  quest_stage = 0;
  held_item = ITEM_NONE;
  quest_completed = true;
  clampResources();
  checkEndConditions();
}

boolean rescueUrgentSurvivor(){
  QuestActionReason reason = rescueActionReason();
  if (!reason.isClear()){
    system_message = questReasonText(reason);
    return false;
  }
  int crew = urgentRisk();
  water -= 8;
  food -= 2;
  crew_risk_deadline[crew] = 0;
  quest_completed = true;
  clearEditorialRisk(crew);
  int rescue_quest = editorialQuestForCrew(crew);
  if (rescue_quest >= 0) recordEditorialResult(rescue_quest, EDITORIAL_RESULT_RESCUE);
  else recordEditorialCrewResult(crew, EDITORIAL_RESULT_RESCUE);
  system_message = crew_name[crew] + " FOI ESTABILIZADO(A).";
  return true;
}

QuestActionReason rescueActionReason(){
  int crew = urgentRisk();
  if (crew < 0) return new QuestActionReason(QUEST_REASON_NO_RISK);
  if (event_open || hasNewIncident()){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_INCIDENT_BLOCKED);
    reason.incident_id = event_open ? event_index : incidentForDay(day);
    return reason;
  }
  if (quest_completed || active_quest >= 0) return new QuestActionReason(QUEST_REASON_DAILY_LIMIT);
  if (held_item != ITEM_NONE || quest_stage != 0) return staleQuestReason(ACTION_RESCUE);
  if (selected_preventive_id >= 0){
    return confirmationPendingReason(selected_preventive_id);
  }
  if (point_room[POINT_RISK_BUNK] != screen){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_POINT);
    reason.expected_point_id = POINT_RISK_BUNK;
    return reason;
  }
  if (!isPointInRange(POINT_RISK_BUNK)){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_WRONG_DISTANCE);
    reason.expected_point_id = POINT_RISK_BUNK;
    return reason;
  }
  if (water < 8){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_RESOURCE_INSUFFICIENT);
    reason.resource_id = RESOURCE_WATER;
    reason.available = water;
    reason.required = 8;
    return reason;
  }
  if (food < 2){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_RESOURCE_INSUFFICIENT);
    reason.resource_id = RESOURCE_FOOD;
    reason.available = food;
    reason.required = 2;
    return reason;
  }
  return clearQuestReason();
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
  return selected_preventive_id >= 0 ? crew_point[quest_owner[selected_preventive_id]] : -1;
}

String pointDisplayLabel(int point){
  if (!pointExists(point)) return "ponto esperado";
  if (point == POINT_RISK_BUNK){
    int crew = urgentRisk();
    return crew < 0 ? "SOCORRO" : "SOCORRER " + crew_name[crew] + " (" + crew_risk_deadline[crew] + "D)";
  }
  return point_label[point];
}

int crewAtPoint(int point){
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (crew_point[crew] == point && crew_alive[crew]) return crew;
  }

  return -1;
}


boolean pointIsAvailable(int point){
  if (point == POINT_TECH_BUNK) return true;
  if (point == POINT_RISK_BUNK)
    return urgentRisk() >= 0;
  if (point_kind[point] == POINT_NPC) return crewAtPoint(point) >= 0;
  int crew = crewAtPoint(point);
  if (crew >= 0) return crew_alive[crew];
  return point == nextQuestPoint();
}

boolean ordersAvailable(){
  if (!dailyQuestFree() || selected_preventive_id >= 0 || event_open || hasNewIncident()) return false;
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
    openEndDayPanel();
  } else if (point_kind[point] == POINT_NPC){
    interactNpc(point);
  } else if (point == POINT_RISK_BUNK){
    openRescuePanel();
  }
}

void openEndDayPanel(){
  end_day_open = true;
  projectNight();
}

void closeEndDayPanel(){
  end_day_open = false;
}

NightProjection recalculateEndDayPanel(){
  return projectNight();
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

  if (selected_preventive_id >= 0 && quest_owner[selected_preventive_id] == owner && dailyQuestFree()){
    beginNpcConversation(owner);
    dialog_result = editorialQuestResult(selected_preventive_id) + " Depois de aceita, a ordem não pode ser cancelada.";
    pending_quest_action = ACTION_ACCEPT_ORDER;
    return;
  }

  if (selected_preventive_id >= 0){
    beginNpcConversation(owner);
    return;
  }

  if (active_quest >= 0 && quest_owner[active_quest] == owner){
    beginNpcConversation(owner);
    dialog_result = editorialQuestResult(active_quest);
    return;
  }

  if (active_quest >= 0){
    beginNpcConversation(owner);
    return;
  }

  if (quest_completed){
    beginNpcConversation(owner);
    return;
  }

  int offer = offerOf(owner);
  if (offer >= 0){
    beginNpcConversation(owner);
    dialog_result = "Compare as duas opções em Ordens.";
    return;
  }

  beginNpcConversation(owner);
}

void openQuestStepPanel(){
  int q = active_quest;
  boolean collecting = quest_stage == QUEST_COLLECT;
  String verb = collecting ? "Pegar" : "Levar";
  String cost_str = questCostLabel(q).equals("nenhum") ? "" : " · Custo: " + questCostLabel(q);
  String result = collecting
    ? "Resultado: o objeto fica com você até a entrega." + cost_str
    : questBenefitLabel(q) + cost_str + ".";
  String failure_str = questFailure(q);
  if (failure_str.startsWith("SE FALHAR: ")){
    failure_str = "Se falhar: " + failure_str.substring(11);
  }
  if (!failure_str.endsWith(".")) failure_str += ".";

  String content = "Destino: " + pointLocation(quest_destination[q]) + "\n"
    + result + "\n"
    + failure_str + "\n\n"
    + "\"" + questMotivation(q) + "\"";

  openTechnical(verb + " " + quest_object[q] + "?", content);
  pending_quest_action = collecting ? ACTION_COLLECT_QUEST : ACTION_DELIVER_QUEST;
}

void openRescuePanel(){
  if (urgentRisk() < 0) return;
  int crew = urgentRisk();
  openTechnical("SOCORRER " + crew_name[crew] + " — " + crew_risk_deadline[crew] + " NOITE(S)",
    "Custo do socorro: -8 ÁGUA e -2 COMIDA.\n"
    + "Efeito: estabiliza " + crewDisplayName(crew) + " e consome a conclusão do dia.\n"
    + "Sem socorro: a pessoa morre quando o prazo zerar.\n"
    + "Nota: em dia preventivo, as perdas por negligência continuam.");
  pending_quest_action = ACTION_RESCUE;
}

boolean pendingQuestEnabled(){
  return pendingQuestReason().isClear();
}

String questCostLabel(int q){
  if (q < PREVENTIVE_COUNT) return "nenhum";
  int index = q - PREVENTIVE_COUNT;
  return "-" + solution_cost[index] + " " + resourceName(solution_resource[index]);
}

String questBenefitLabel(int q){
  if (q < PREVENTIVE_COUNT){
    return "Benefício: +" + preventiveReward(q) + " " + resourceName(preventive_resource[q]);
  }
  int problem = questProblem(q);
  return "Benefício: " + problem_title[problem] + " resolvido";
}

QuestActionReason pendingQuestReason(){
  if (pending_quest_action == ACTION_ACCEPT_ORDER) return preventiveActionReason();
  if (pending_quest_action == ACTION_COLLECT_QUEST) return collectActionReason();
  if (pending_quest_action == ACTION_DELIVER_QUEST) return deliverActionReason();
  if (pending_quest_action == ACTION_RESCUE) return rescueActionReason();
  if (pending_quest_action == ACTION_RETRY_QUEST) return retryActionReason();
  return staleQuestReason(pending_quest_action);
}

QuestActionReason retryActionReason(){
  return retryActionReasonFor(pending_retry);
}

QuestActionReason retryActionReasonFor(int q){
  if (!validQuestId(q) || q < PREVENTIVE_COUNT) return staleQuestReason(ACTION_RETRY_QUEST);
  if (event_open || hasNewIncident()){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_INCIDENT_BLOCKED);
    reason.incident_id = event_open ? event_index : incidentForDay(day);
    return reason;
  }
  if (!dailyQuestFree()) return new QuestActionReason(QUEST_REASON_DAILY_LIMIT);
  if (selected_preventive_id >= 0) return confirmationPendingReason(selected_preventive_id);
  int problem = questProblem(q);
  if (problem < 0 || problem >= PROBLEM_COUNT || !problem_active[problem]
    || problem_solution[problem] != q){
    return staleQuestReason(ACTION_RETRY_QUEST);
  }
  boolean has_retry_snapshot = pending_retry >= 0 && pending_retry == q && pending_retry_problem != PROBLEM_NONE;
  if (has_retry_snapshot
    && (pending_retry_problem != problem || pending_retry_solution != q
      || pending_retry_problem_active != problem_active[problem]
      || pending_retry_deadline != problem_deadline[problem]
      || pending_retry_consequence_resource != problem_loss_resource[problem]
      || pending_retry_consequence_value != problem_loss_value[problem])){
    return staleQuestReason(ACTION_RETRY_QUEST);
  }
  if (active_quest >= 0 || held_item != ITEM_NONE || quest_stage != 0){
    return staleQuestReason(ACTION_RETRY_QUEST);
  }
  int solution_index = q - PREVENTIVE_COUNT;
  if (!canPayResource(solution_resource[solution_index], solution_cost[solution_index])){
    QuestActionReason reason = new QuestActionReason(QUEST_REASON_RESOURCE_INSUFFICIENT);
    reason.resource_id = solution_resource[solution_index];
    reason.available = resourceValue(solution_resource[solution_index]);
    reason.required = solution_cost[solution_index];
    return reason;
  }
  return clearQuestReason();
}

String questReasonText(QuestActionReason reason){
  if (reason == null || reason.isClear()) return "";
  if (QUEST_REASON_RESOURCE_INSUFFICIENT.equals(reason.kind)){
    return "Falta " + resourceName(reason.resource_id) + ". Você tem "
      + int(reason.available) + " de " + int(reason.required) + ".";
  }
  if (QUEST_REASON_CONFIRMATION_PENDING.equals(reason.kind)
    || QUEST_REASON_WRONG_NPC.equals(reason.kind)){
    String name = reason.expected_npc_id >= 0 && reason.expected_npc_id < CREW_COUNT
      ? crew_name[reason.expected_npc_id] : "responsável";
    String room = reason.expected_room_id == SCREEN_NONE ? "sua sala"
      : roomTitle(reason.expected_room_id);
    return "Confirme com " + name + " em " + room + ".";
  }
  if (QUEST_REASON_WRONG_POINT.equals(reason.kind)){
    return "Local incorreto. Vá até " + pointDisplayLabel(reason.expected_point_id) + ".";
  }
  if (QUEST_REASON_WRONG_DISTANCE.equals(reason.kind)){
    return "Aproxime-se de " + pointDisplayLabel(reason.expected_point_id) + ".";
  }
  if (QUEST_REASON_DAILY_LIMIT.equals(reason.kind)) return "A conclusão de hoje já foi usada.";
  if (QUEST_REASON_INCIDENT_BLOCKED.equals(reason.kind)) return "Resolva o incidente antes de concluir esta ação.";
  if (QUEST_REASON_NO_RISK.equals(reason.kind)) return "Não há pessoa em risco.";
  if (QUEST_REASON_STALE_STATE.equals(reason.kind)) return "A ação mudou. Revise o painel.";
  return "Ação indisponível. Revise o estado atual.";
}

void applyQuestAction(){
  if (!pendingQuestEnabled()){
    system_message = questReasonText(pendingQuestReason());
    return;
  }
  int action = pending_quest_action;
  technical_open = false;
  if (action == ACTION_ACCEPT_ORDER) acceptPreventive();
  else if (action == ACTION_COLLECT_QUEST) collectQuestObject();
  else if (action == ACTION_DELIVER_QUEST) deliverQuest();
  else if (action == ACTION_RESCUE) rescueUrgentSurvivor();
  else if (action == ACTION_RETRY_QUEST) acceptSolution(pending_retry);
  pending_quest_action = ACTION_NONE;
}

String pointLocation(int point){
  if (!pointExists(point) || point_room[point] == SCREEN_NONE) return "Local indisponível";
  int room = roomIndexOrInvalid(point_room[point]);
  if (room < 0) return "Local indisponível";
  return point_label[point] + " (" + room_label[room] + ")";
}

String questEffect(int q){
  if (q < PREVENTIVE_COUNT) return "RECOMPENSA: +" + preventiveReward(q) + " " + resourceName(preventive_resource[q]);
  int i = q - PREVENTIVE_COUNT;
  return "CUSTO: -" + solution_cost[i] + " " + resourceName(solution_resource[i]);
}

String questFailure(int q){
  if (q < PREVENTIVE_COUNT) return "SE FALHAR: -" + preventiveFailure(q) + " " + resourceName(preventive_resource[q]);
  int p = questProblem(q);
  int deadline = problem_active[p] ? problem_deadline[p] : problem_initial_deadline[p];
  return "SE FALHAR: " + problemLossLabel(p) + "; CRISE EM " + deadline + " DIAS: " + problem_crisis[p]
    + (p == PROBLEM_ENGINE ? "." : "; REINICIA EM 2 DIAS.");
}

String questDetails(int q){
  return "Responsável: " + crewDisplayName(quest_owner[q]) + ". Coleta: "
    + pointLocation(quest_origin[q]) + ". Entrega: " + pointLocation(quest_destination[q])
    + ". " + questEffect(q) + ". " + questFailure(q);
}

String activeProblemSummary(){
  int urgent = urgentProblem();
  return urgent < 0 ? "NENHUM PROBLEMA ATIVO." : activeProblemCount() + " ATIVO(S). MAIS URGENTE: " + problemMapLine(urgent);
}

String problemLossLabel(int problem){ return resourceName(problem_loss_resource[problem]) + " -" + problem_loss_value[problem] + " por dia"; }
String problemMapLine(int problem){
  return problem_short[problem] + " | " + problemLossLabel(problem) + " | CRISE EM "
    + problem_deadline[problem] + " DIAS: " + problem_crisis[problem];
}

void drawQuestCard(PGraphics g, int q, float x, float y, float w, int action, boolean enabled){
  drawQuestCard(g, q, x, y, w, action, enabled, false);
}

void drawQuestCard(PGraphics g, int q, float x, float y, float w, int action, boolean enabled,
  boolean expanded){
  float card_height = 190;
  drawPanel(g, x, y, w, card_height, q == selected_preventive_id ? COL_CYAN : COL_BORDER);
  text(g, questVisibleTitle(q), x + 10, y + 10, 16, COL_CYAN);
  if (expanded){
    text(g, "Responsável: " + crewDisplayName(quest_owner[q]), x + 10, y + 28, 16, COL_TEXT);
    text(g, "Objeto: " + quest_object[q], x + 10, y + 48, 16, COL_TEXT);
    text(g, "Coleta: " + pointLocation(quest_origin[q]), x + 10, y + 68, 16, COL_CYAN);
    text(g, "Entrega: " + pointLocation(quest_destination[q]), x + 10, y + 88, 16, COL_CYAN);
    text(g, questBenefitLabel(q), x + 10, y + 108, 16, COL_GREEN);
    drawTextWrapped(g, questCardConsequence(q), x + 10, y + 128, w - 20, 16, 17, COL_ORANGE);
    if (action != ACTION_NONE){
      String action_label = q < PREVENTIVE_COUNT
        ? "ESCOLHER · FALAR COM " + crewDisplayName(quest_owner[q])
        : action == ACTION_CONFIRM_QUEST ? "RETOMAR SOLUÇÃO" : "VERIFICAR SOLUÇÃO";
      drawButton(g, x + 10, y + 158, w - 20, 23, action_label, action, enabled);
    }
    return;
  }
  drawTextWrapped(g, crewDisplayName(quest_owner[q]) + " · " + questMotivation(q),
    x + 10, y + 28, w - 20, 16, 17, COL_MUTED);
  text(g, questBenefitLabel(q), x + 10, y + 84, 16, COL_GREEN);
  drawTextWrapped(g, questCardConsequence(q), x + 10, y + 116, w - 20, 16, 17, COL_ORANGE);
  if (action != ACTION_NONE){
    String action_label = q < PREVENTIVE_COUNT
      ? "ESCOLHER · FALAR COM " + crewDisplayName(quest_owner[q])
      : action == ACTION_CONFIRM_QUEST ? "RETOMAR SOLUÇÃO" : "VERIFICAR SOLUÇÃO";
    drawButton(g, x + 10, y + 158, w - 20, 23,
      action_label, action, enabled);
  }
}

String questCardConsequence(int q){
  if (q < PREVENTIVE_COUNT){
    return "Consequência: falha custa " + preventiveFailure(q) + " "
      + resourceName(preventive_resource[q]) + ".";
  }

  int problem = questProblem(q);
  int deadline = problem_active[problem] ? problem_deadline[problem] : problem_initial_deadline[problem];
  return "Consequência: " + problemLossLabel(problem) + " · crise em " + deadline
    + " dias: " + problem_crisis[problem] + ".";
}

void drawOrdersPanel(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 16, 79, 608, 252, COL_CYAN);
  text(g, "ORDENS — DIA " + day + " | UMA CONCLUSÃO POR DIA", 28, 88, 16, COL_CYAN);
  if (active_quest >= 0){
    drawQuestCard(g, active_quest, 28, 105, 582, ACTION_NONE, false);
    text(g, quest_stage == QUEST_COLLECT ? "ETAPA: COLETAR" : "ETAPA: ENTREGAR", 40, 305, 16, COL_GREEN);
  } else if (quest_completed){
    text(g, "QUEST CONCLUÍDA. RETORNE AO SEU BELICHE.", 34, 109, 16, COL_GREEN);
    drawTextWrapped(g, questNightSummary(), 34, 133, 572, 16, 18, COL_ORANGE);
  } else if (orders_page >= 0){
    int retry_action = pending_quest_action == ACTION_RETRY_QUEST
      ? ACTION_CONFIRM_QUEST : ACTION_RETRY_QUEST;
    drawQuestCard(g, problem_solution[orders_page], 28, 105, 582, retry_action,
      selected_preventive_id < 0, orders_details_open);
  } else {
    for (int i = 0; i < 2; i++) if (daily_offers[i] >= 0)
      drawQuestCard(g, daily_offers[i], 28 + i * 294, 105, 288,
        i == 0 ? ACTION_ORDER_A : ACTION_ORDER_B, true, orders_details_open);
  }
  if (active_quest < 0 && !quest_completed){
    drawButton(g, 28, 303, orders_page >= 0 ? 220 : 242, 20,
      orders_details_open ? "OCULTAR DETALHES" : "VER DETALHES", ACTION_TOGGLE_ORDER_DETAILS, true);
  }
  int pending_count = pendingQuestCount();
  if (dailyQuestFree() && incidentForDay(day) == PROBLEM_NONE && pending_count > 0){
    drawModalFooter(g, 303, "PENDÊNCIAS (" + pending_count + ")", ACTION_NEXT_RETRY, true,
      "FECHAR (ESC)", ACTION_CLOSE_MODAL, true, 28, 610);
  } else {
    drawModalFooter(g, 303, "", ACTION_NONE, false,
      "FECHAR (ESC)", ACTION_CLOSE_MODAL, true, 28, 610);
  }
}

int pendingQuestCount(){
  int count = 0;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (problem_active[problem] && problem_solution[problem] >= PREVENTIVE_COUNT) count++;
  }
  return count;
}

void cycleRetry(){
  if (hasNewIncident() || event_open) return;
  for (int p = orders_page + 1; p < PROBLEM_COUNT; p++){
    if (problem_active[p] && problem_solution[p] >= 0){ orders_page = p; return; }
  }
  orders_page = -1;
}

void reviewRetry(){
  if (orders_page < 0 || !dailyQuestFree() || selected_preventive_id >= 0
    || hasNewIncident() || event_open) return;
  int q = problem_solution[orders_page];
  int problem = questProblem(q);
  if (!validQuestId(q) || problem < 0 || problem >= PROBLEM_COUNT
    || !problem_active[problem] || problem_solution[problem] != q) return;
  orders_details_open = true;
  pending_retry = q;
  pending_retry_problem = problem;
  pending_retry_solution = q;
  pending_retry_problem_active = problem_active[problem];
  pending_retry_deadline = problem_deadline[problem];
  pending_retry_consequence_resource = problem_loss_resource[problem];
  pending_retry_consequence_value = problem_loss_value[problem];
  pending_quest_action = ACTION_RETRY_QUEST;
}
