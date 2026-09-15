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

String[] crew_name = {"VERA", "BENTO", "NEUSA", "SÍLVIA"};
boolean[] crew_alive = new boolean[CREW_COUNT];
int[] crew_risk_deadline = new int[CREW_COUNT];
int[] crew_risk_order = new int[CREW_COUNT];
int risk_order_counter = 0;

String[] problem_title = {
  "FALHA NO MOTOR", "DANO NO CASCO", "FALTA DE COMIDA",
  "CONFLITO NO DORMITÓRIO", "FALHA NO SUPORTE DE VIDA",
  "FALHA NO SISTEMA DE ENERGIA", "FALHA NAS COMUNICAÇÕES"
};
String[] problem_short = {
  "MOTOR", "CASCO", "COMIDA", "CONFLITO", "SUPORTE", "ENERGIA", "COMUNICAÇÕES"
};
String[] problem_crisis = {
  "MOTOR DESTRUÍDO", "OXIGÊNIO -15", "COMIDA -8 E PESSOA EM RISCO",
  "MORAL -8 E PESSOA EM RISCO", "OXIGÊNIO -12 E PESSOA EM RISCO",
  "ENERGIA -12 E ECONOMIA DESLIGADA", "MORAL -10"
};
int[] problem_room = {
  SCREEN_MACHINES, SCREEN_NONE, SCREEN_DEPOT, SCREEN_DORMITORY,
  SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_COMMAND
};
int[] problem_loss_resource = {
  RESOURCE_ENERGY, RESOURCE_OXYGEN, RESOURCE_FOOD, RESOURCE_MORALE,
  RESOURCE_OXYGEN, RESOURCE_ENERGY, RESOURCE_MORALE
};
int[] problem_loss_value = {4, 5, 3, 4, 4, 3, 2};
int[] problem_crisis_reset = {0, 2, 3, 3, 3, 3, 3};
int[] problem_specialist = {
  CREW_SILVIA, CREW_SILVIA, CREW_BENTO, CREW_NEUSA,
  CREW_SILVIA, CREW_SILVIA, CREW_VERA
};
int[] problem_cost_with = {2, 1, 0, 0, 1, 1, 1};
int[] problem_cost_without = {3, 2, 3, 3, 2, 2, 2};
int[] problem_cost_resource = {
  RESOURCE_PARTS, RESOURCE_PARTS, RESOURCE_FOOD, RESOURCE_WATER,
  RESOURCE_PARTS, RESOURCE_PARTS, RESOURCE_PARTS
};
int[] problem_component = {
  ITEM_NONE, ITEM_SEAL_KIT, ITEM_NONE, ITEM_NONE,
  ITEM_NONE, ITEM_FUSE, ITEM_NONE
};
/* Mesma ordem de declaração dos problemas no modelo aprovado. */
int[] problem_risk_offset = {0, 1, 5, 6, 2, 3, 4};

String[][] containment_label = {
  {"REDUZIR ROTAÇÃO", "MANTER IMPULSO"},
  {"SELAR ANTEPARAS", "ISOLAR O SETOR"},
  {"ABRIR A RESERVA", "REDUZIR PORÇÕES"},
  {"SEPARAR O GRUPO", "DEIXAR ESFRIAR"},
  {"USAR REDUNDÂNCIA", "RECIRCULAR O AR"},
  {"DESLIGAR CIRCUITOS", "DISTRIBUIR SOBRECARGA"},
  {"MANTER ESCUTA", "DESLIGAR TRANSMISSOR"}
};
int[][] containment_resource = {
  {RESOURCE_ENERGY, RESOURCE_MORALE},
  {RESOURCE_ENERGY, RESOURCE_OXYGEN},
  {RESOURCE_FOOD, RESOURCE_MORALE},
  {RESOURCE_WATER, RESOURCE_MORALE},
  {RESOURCE_ENERGY, RESOURCE_OXYGEN},
  {RESOURCE_ENERGY, RESOURCE_MORALE},
  {RESOURCE_ENERGY, RESOURCE_MORALE}
};
int[][] containment_cost = {
  {5, 2}, {5, 4}, {4, 4}, {4, 3}, {4, 3}, {4, 4}, {3, 3}
};
int[][] containment_deadline = {
  {3, 2}, {3, 2}, {4, 2}, {4, 2}, {4, 2}, {4, 2}, {4, 2}
};

boolean[] problem_active = new boolean[PROBLEM_COUNT];
int[] problem_deadline = new int[PROBLEM_COUNT];
int[] problem_activated_order = new int[PROBLEM_COUNT];
int[] incident_sequence = new int[5];
int problem_order_counter = 0;
boolean intervention_used = false;
boolean skip_next_day = false;

void resetProblemState(){
  for (int i = 0; i < PROBLEM_COUNT; i++){
    problem_active[i] = false;
    problem_deadline[i] = 0;
    problem_activated_order[i] = 0;
  }
  problem_room[PROBLEM_HULL] = SCREEN_NONE;
  clearHullDamage();
  problem_order_counter = 0;
  intervention_used = false;
  skip_next_day = false;
  shuffleIncidentSequence();
}

void resetCrewState(){
  survivors = CREW_COUNT;
  risk_order_counter = 0;
  for (int i = 0; i < CREW_COUNT; i++){
    crew_alive[i] = true;
    crew_risk_deadline[i] = 0;
    crew_risk_order[i] = 0;
  }
}

void shuffleIncidentSequence(){
  int[] pool = new int[PROBLEM_COUNT];
  for (int i = 0; i < PROBLEM_COUNT; i++) pool[i] = i;
  for (int i = PROBLEM_COUNT - 1; i > 0; i--){
    int swap = int(random(i + 1));
    int value = pool[i];
    pool[i] = pool[swap];
    pool[swap] = value;
  }
  for (int i = 0; i < incident_sequence.length; i++) incident_sequence[i] = pool[i];
}

boolean specialistAlive(int crew){
  return crew >= 0 && crew < CREW_COUNT && crew_alive[crew];
}

int urgentProblem(){
  int urgent = PROBLEM_NONE;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (!problem_active[problem]) continue;
    if (urgent == PROBLEM_NONE || problem_deadline[problem] < problem_deadline[urgent]
      || problem_deadline[problem] == problem_deadline[urgent]
      && problem_activated_order[problem] < problem_activated_order[urgent]){
      urgent = problem;
    }
  }
  return urgent;
}

int urgentRisk(){
  int urgent = -1;
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (!crew_alive[crew] || crew_risk_deadline[crew] <= 0) continue;
    if (urgent < 0 || crew_risk_deadline[crew] < crew_risk_deadline[urgent]
      || crew_risk_deadline[crew] == crew_risk_deadline[urgent]
      && crew_risk_order[crew] < crew_risk_order[urgent]){
      urgent = crew;
    }
  }
  return urgent;
}

int activeProblemCount(){
  int count = 0;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (problem_active[problem]) count++;
  }
  return count;
}

int roomProblemCount(int room){
  int count = 0;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (problem_active[problem] && problem_room[problem] == room) count++;
  }
  return count;
}

void activateProblem(int problem, int deadline){
  if (!problem_active[problem]){
    problem_order_counter++;
    problem_activated_order[problem] = problem_order_counter;
  }
  problem_active[problem] = true;
  problem_deadline[problem] = deadline;
  if (problem == PROBLEM_HULL && problem_room[problem] == SCREEN_NONE){
    placeHullDamage();
    problem_room[problem] = point_room[POINT_HULL];
  }
}

void clearProblem(int problem){
  problem_active[problem] = false;
  problem_deadline[problem] = 0;
  if (problem == PROBLEM_HULL){
    clearHullDamage();
    problem_room[problem] = SCREEN_NONE;
  }
}

void putSurvivorAtRisk(int sourceProblem){
  int[] candidates = new int[CREW_COUNT];
  int count = 0;
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (crew_alive[crew] && crew_risk_deadline[crew] <= 0) candidates[count++] = crew;
  }
  if (count == 0) return;
  int selected = candidates[(day + problem_risk_offset[sourceProblem]) % count];
  risk_order_counter++;
  crew_risk_deadline[selected] = 2;
  crew_risk_order[selected] = risk_order_counter;
}

void applyProblemCrisis(int problem){
  if (problem == PROBLEM_ENGINE){
    engine_state = ENGINE_DESTROYED;
  } else if (problem == PROBLEM_HULL){
    oxygen -= 15;
  } else if (problem == PROBLEM_FOOD){
    food -= 8;
    putSurvivorAtRisk(problem);
  } else if (problem == PROBLEM_CONFLICT){
    morale -= 8;
    putSurvivorAtRisk(problem);
  } else if (problem == PROBLEM_LIFE_SUPPORT){
    oxygen -= 12;
    putSurvivorAtRisk(problem);
  } else if (problem == PROBLEM_POWER){
    energy -= 12;
    saving_on = false;
  } else if (problem == PROBLEM_COMMS){
    morale -= 10;
  }
  if (problem_crisis_reset[problem] > 0){
    problem_deadline[problem] = problem_crisis_reset[problem];
  }
  system_message = "CRISE: " + problem_crisis[problem] + ".";
}

boolean canUseMainIntervention(){
  return !intervention_used;
}

boolean canPayResource(int resource, int amount){
  return resourceValue(resource) >= amount;
}

float resourceValue(int resource){
  if (resource == RESOURCE_ENERGY) return energy;
  if (resource == RESOURCE_OXYGEN) return oxygen;
  if (resource == RESOURCE_WATER) return water;
  if (resource == RESOURCE_FOOD) return food;
  if (resource == RESOURCE_MORALE) return morale;
  if (resource == RESOURCE_PARTS) return parts;
  return 0;
}

void payResource(int resource, int amount){
  if (resource == RESOURCE_ENERGY) energy -= amount;
  else if (resource == RESOURCE_OXYGEN) oxygen -= amount;
  else if (resource == RESOURCE_WATER) water -= amount;
  else if (resource == RESOURCE_FOOD) food -= amount;
  else if (resource == RESOURCE_MORALE) morale -= amount;
  else if (resource == RESOURCE_PARTS) parts -= amount;
}

boolean tryRepairProblem(int problem){
  if (!problem_active[problem]){
    system_message = "NÃO HÁ " + problem_short[problem] + " PARA CORRIGIR.";
    return false;
  }
  if (!canUseMainIntervention()){
    system_message = "A INTERVENÇÃO PRINCIPAL DO DIA JÁ FOI USADA.";
    return false;
  }
  int component = problem_component[problem];
  if (component != ITEM_NONE && held_item != component){
    system_message = component == ITEM_SEAL_KIT ? "FALTA O KIT DE VEDAÇÃO." : "FALTA O FUSÍVEL DE POTÊNCIA.";
    return false;
  }
  int cost = repairCost(problem);
  int resource = problem_cost_resource[problem];
  if (!canPayResource(resource, cost)){
    system_message = "RECURSO INSUFICIENTE PARA A CORREÇÃO.";
    return false;
  }
  payResource(resource, cost);
  if (component != ITEM_NONE) held_item = ITEM_NONE;
  clearProblem(problem);
  intervention_used = true;
  system_message = problem_short[problem] + " CORRIGIDO.";
  clampResources();
  checkEndConditions();
  return true;
}

boolean tryBoost(){
  if (!canUseMainIntervention()){
    system_message = "A INTERVENÇÃO PRINCIPAL DO DIA JÁ FOI USADA.";
    return false;
  }
  int cost = specialistAlive(CREW_VERA) ? 10 : 15;
  if (energy < cost){
    system_message = "ENERGIA INSUFICIENTE PARA AUMENTAR POTÊNCIA.";
    return false;
  }
  energy -= cost;
  intervention_used = true;
  skip_next_day = true;
  boost_count++;
  system_message = "POTÊNCIA AUMENTADA: O PRÓXIMO DIA SERÁ ELIMINADO.";
  checkEndConditions();
  return true;
}

boolean careForGroup(){
  if (!canUseMainIntervention()){
    system_message = "A INTERVENÇÃO PRINCIPAL DO DIA JÁ FOI USADA.";
    return false;
  }
  if (water < careWaterCost() || food < careFoodCost()){
    system_message = "ÁGUA OU COMIDA INSUFICIENTE PARA CUIDAR DO GRUPO.";
    return false;
  }
  water -= careWaterCost();
  food -= careFoodCost();
  morale += careMoraleGain();
  intervention_used = true;
  system_message = "GRUPO CUIDADO.";
  clampResources();
  return true;
}

boolean rescueUrgentSurvivor(){
  int crew = urgentRisk();
  if (crew < 0){
    system_message = "NINGUÉM ESTÁ EM RISCO.";
    return false;
  }
  if (!canUseMainIntervention()){
    system_message = "A INTERVENÇÃO PRINCIPAL DO DIA JÁ FOI USADA.";
    return false;
  }
  int waterCost = rescueWaterCost();
  int foodCost = rescueFoodCost();
  if (water < waterCost || food < foodCost){
    system_message = "RECURSOS INSUFICIENTES PARA O SOCORRO.";
    return false;
  }
  water -= waterCost;
  food -= foodCost;
  crew_risk_deadline[crew] = 0;
  crew_risk_order[crew] = 0;
  intervention_used = true;
  system_message = crew_name[crew] + " FOI ESTABILIZADO(A).";
  clampResources();
  return true;
}

int repairCost(int problem){
  return specialistAlive(problem_specialist[problem])
    ? problem_cost_with[problem] : problem_cost_without[problem];
}

String repairRequirement(int problem){
  int cost = repairCost(problem);
  String component = problem_component[problem] == ITEM_SEAL_KIT ? "KIT DE VEDAÇÃO + "
    : problem_component[problem] == ITEM_FUSE ? "FUSÍVEL DE POTÊNCIA + " : "";
  if (cost == 0) return component + "SEM CUSTO COM O BENEFÍCIO DE "
    + crew_name[problem_specialist[problem]];
  if (problem_cost_resource[problem] == RESOURCE_PARTS){
    return component + cost + (cost == 1 ? " PEÇA" : " PEÇAS");
  }
  return component + resourceName(problem_cost_resource[problem]) + " -" + cost;
}

int careWaterCost(){ return 3; }
int careFoodCost(){ return 2; }
int careMoraleGain(){ return specialistAlive(CREW_NEUSA) ? 20 : 12; }
int rescueWaterCost(){ return specialistAlive(CREW_NEUSA) ? 6 : 9; }
int rescueFoodCost(){ return specialistAlive(CREW_NEUSA) ? 2 : 3; }

String interventionBlockedSuffix(){
  return canUseMainIntervention() ? "" : " INTERVENÇÃO DO DIA JÁ USADA.";
}

String paymentSuffix(int resource, int cost){
  return canPayResource(resource, cost) ? "" : " RECURSO INSUFICIENTE.";
}

String missingComponentSuffix(int problem){
  int component = problem_component[problem];
  if (component == ITEM_NONE || held_item == component) return "";
  return component == ITEM_SEAL_KIT
    ? " FALTA O KIT DE VEDAÇÃO NA MÃO." : " FALTA O FUSÍVEL DE POTÊNCIA NA MÃO.";
}

void openRepairPanel(int point, int problem){
  openTechnical(pointDisplayLabel(point), problemMapLine(problem)
    + ". REPARO: " + repairRequirement(problem) + "."
    + missingComponentSuffix(problem) + interventionBlockedSuffix()
    + paymentSuffix(problem_cost_resource[problem], repairCost(problem)));
  pending_intervention_point = point;
}

void openCarePanel(){
  String blocked = water < careWaterCost() || food < careFoodCost()
    ? " ÁGUA OU COMIDA INSUFICIENTE." : "";
  openTechnical(pointDisplayLabel(POINT_COMMON_TABLE), "CUIDAR DO GRUPO: ÁGUA -"
    + careWaterCost() + ", COMIDA -" + careFoodCost() + ". MORAL +" + careMoraleGain()
    + "." + interventionBlockedSuffix() + blocked);
  pending_intervention_point = POINT_COMMON_TABLE;
}

void openRescuePanel(){
  String blocked = water < rescueWaterCost() || food < rescueFoodCost()
    ? " RECURSOS INSUFICIENTES PARA O SOCORRO." : "";
  openTechnical(pointDisplayLabel(POINT_RISK_BUNK), "SOCORRO: ÁGUA -"
    + rescueWaterCost() + ", COMIDA -" + rescueFoodCost()
    + "." + interventionBlockedSuffix() + blocked);
  pending_intervention_point = POINT_RISK_BUNK;
}

void openCollectPanel(int point, int item){
  int problem = item == ITEM_SEAL_KIT ? PROBLEM_HULL : PROBLEM_POWER;
  String carrying = held_item == ITEM_NONE || held_item == item
    ? " VOCÊ CARREGA UM COMPONENTE POR VEZ."
    : " NA MÃO: " + componentName(held_item) + " — SERÁ TROCADO.";
  openTechnical(componentName(item), collectPurpose(item)
    + " O REPARO EXIGE " + repairRequirement(problem) + "."
    + collectTargetSuffix(item) + carrying);
  pending_collect_point = point;
}

void applyPendingCollect(){
  int point = pending_collect_point;
  pending_collect_point = -1;
  technical_open = false;
  if (point == POINT_SEAL_KIT){
    collectSpecialComponent(ITEM_SEAL_KIT);
  } else if (point == POINT_FUSE){
    collectSpecialComponent(ITEM_FUSE);
  }
}

void collectSpecialComponent(int item){
  held_item = item;
  system_message = item == ITEM_SEAL_KIT
    ? "KIT DE VEDAÇÃO COLETADO." : "FUSÍVEL DE POTÊNCIA COLETADO.";
}

void toggleSaving(){
  boolean enabling = !saving_on;
  int cost = specialistAlive(CREW_BENTO) ? 2 : 4;
  if (enabling && morale < cost){
    system_message = "MORAL INSUFICIENTE PARA ATIVAR ECONOMIA.";
    return;
  }
  if (enabling) morale -= cost;
  saving_on = enabling;
  system_message = saving_on ? "MODO ECONOMIA LIGADO." : "MODO ECONOMIA DESLIGADO.";
  clampResources();
  checkEndConditions();
}

void toggleRationing(){
  boolean enabling = !rationing_on;
  int cost = specialistAlive(CREW_BENTO) ? 2 : 4;
  if (enabling && morale < cost){
    system_message = "MORAL INSUFICIENTE PARA ATIVAR RACIONAMENTO.";
    return;
  }
  if (enabling) morale -= cost;
  rationing_on = enabling;
  system_message = rationing_on ? "RACIONAMENTO LIGADO." : "RACIONAMENTO DESLIGADO.";
  clampResources();
  checkEndConditions();
}

String pointDisplayLabel(int point){
  if (point == POINT_RISK_BUNK){
    int crew = urgentRisk();
    return crew < 0 ? "SOCORRO"
      : "SOCORRER " + crew_name[crew] + " (" + crew_risk_deadline[crew] + "D)";
  }
  return point_label[point];
}

boolean pointIsAvailable(int point){
  if (point == POINT_ENGINE_BENCH) return problem_active[PROBLEM_ENGINE];
  if (point == POINT_HULL) return problem_active[PROBLEM_HULL];
  if (point == POINT_LIFE_SUPPORT) return problem_active[PROBLEM_LIFE_SUPPORT];
  if (point == POINT_ANTENNA) return problem_active[PROBLEM_COMMS];
  if (point == POINT_STOCK) return problem_active[PROBLEM_FOOD];
  if (point == POINT_CONFLICT) return problem_active[PROBLEM_CONFLICT];
  if (point == POINT_RISK_BUNK) return urgentRisk() >= 0;
  return true;
}

boolean pointIsInteractable(int point){
  return pointIsAvailable(point);
}

void interactPoint(int point){
  if (point == POINT_TECH_BUNK){
    end_day_open = true;
  } else if (point == POINT_ROUTE){
    openTechnical("CONSOLE DA ROTA", "DIA " + day + " DE " + TRIP_DAYS
      + ". RESTAM " + max(0, TRIP_DAYS - day) + " DIA(S). CONSUMO PREVISTO: ENERGIA -"
      + dailyEnergyCost() + ", OXIGÊNIO -" + dailyOxygenCost()
      + ". AUMENTAR POTÊNCIA CUSTA " + (specialistAlive(CREW_VERA) ? 10 : 15)
      + " DE ENERGIA E ELIMINA O PRÓXIMO DIA COMPLETO.");
    pending_intervention_point = point;
  } else if (point == POINT_STATUS){
    openTechnical("STATUS DA NAVE", activeProblemSummary());
  } else if (point == POINT_REACTOR){
    openTechnical("REATOR", "POTÊNCIA DISPONÍVEL. A ACELERAÇÃO É FEITA NO CONSOLE DA ROTA.");
  } else if (point == POINT_RESERVE){
    openTechnical("RESERVA", parts + " PEÇAS; COMPONENTE NA MÃO: " + heldItemLabel() + ".");
  } else if (point == POINT_DISTRIBUTION){
    openDistributionPanel();
  } else if (point == POINT_RATIONING){
    switchPoint(point);
  } else if (point == POINT_SEAL_KIT){
    openCollectPanel(point, ITEM_SEAL_KIT);
  } else if (point == POINT_FUSE){
    openCollectPanel(point, ITEM_FUSE);
  } else if (point == POINT_ENGINE_BENCH){
    openRepairPanel(point, PROBLEM_ENGINE);
  } else if (point == POINT_HULL){
    openRepairPanel(point, PROBLEM_HULL);
  } else if (point == POINT_LIFE_SUPPORT){
    openRepairPanel(point, PROBLEM_LIFE_SUPPORT);
  } else if (point == POINT_ANTENNA){
    openRepairPanel(point, PROBLEM_COMMS);
  } else if (point == POINT_STOCK){
    openRepairPanel(point, PROBLEM_FOOD);
  } else if (point == POINT_CONFLICT){
    openRepairPanel(point, PROBLEM_CONFLICT);
  } else if (point == POINT_COMMON_TABLE){
    openCarePanel();
  } else if (point == POINT_RISK_BUNK){
    openRescuePanel();
  } else if (point_kind[point] == POINT_NPC){
    interactNpc(point);
  }
}

void applyPendingIntervention(){
  int point = pending_intervention_point;
  pending_intervention_point = -1;
  technical_open = false;
  if (point == POINT_ROUTE){
    tryBoost();
  } else if (point == POINT_ENGINE_BENCH){
    tryRepairProblem(PROBLEM_ENGINE);
  } else if (point == POINT_HULL){
    tryRepairProblem(PROBLEM_HULL);
  } else if (point == POINT_LIFE_SUPPORT){
    tryRepairProblem(PROBLEM_LIFE_SUPPORT);
  } else if (point == POINT_ANTENNA){
    tryRepairProblem(PROBLEM_COMMS);
  } else if (point == POINT_STOCK){
    tryRepairProblem(PROBLEM_FOOD);
  } else if (point == POINT_CONFLICT){
    tryRepairProblem(PROBLEM_CONFLICT);
  } else if (point == POINT_COMMON_TABLE){
    careForGroup();
  } else if (point == POINT_RISK_BUNK){
    rescueUrgentSurvivor();
  }
}

boolean canRepairPower(){
  if (!problem_active[PROBLEM_POWER] || !canUseMainIntervention()) return false;
  if (problem_component[PROBLEM_POWER] != ITEM_NONE
    && held_item != problem_component[PROBLEM_POWER]) return false;
  return canPayResource(problem_cost_resource[PROBLEM_POWER], repairCost(PROBLEM_POWER));
}

void openDistributionPanel(){
  if (!problem_active[PROBLEM_POWER]){
    switchPoint(POINT_DISTRIBUTION);
    return;
  }

  String blocked = interventionBlockedSuffix();

  openTechnical("PAINEL DE DISTRIBUIÇÃO", problemMapLine(PROBLEM_POWER)
    + ". REPARO: " + repairRequirement(PROBLEM_POWER) + "."
    + missingComponentSuffix(PROBLEM_POWER) + blocked
    + paymentSuffix(RESOURCE_PARTS, repairCost(PROBLEM_POWER))
    + " ECONOMIA: " + (saving_on ? "LIGADA" : "DESLIGADA")
    + " (ENERGIA " + ENERGY_PER_DAY_SAVING + "/DIA, MORAL -"
    + (specialistAlive(CREW_BENTO) ? 1 : 2) + "/DIA).");
  pending_panel_choice = POINT_DISTRIBUTION;
}

void applyPanelRepair(){
  pending_panel_choice = -1;
  technical_open = false;
  tryRepairProblem(PROBLEM_POWER);
}

void applyPanelEconomy(){
  pending_panel_choice = -1;
  technical_open = false;
  toggleSaving();
}

void interactNpc(int point){
  if (point == POINT_VERA){
    openDialogue("VERA", "ROTA SOB CONTROLE. AUMENTAR POTÊNCIA NO CONSOLE ELIMINA O PRÓXIMO DIA.");
  } else if (point == POINT_SILVIA){
    openDialogue("SÍLVIA", "MOTOR, ENERGIA E SUPORTE RESPONDEM NAS ESTAÇÕES DA SALA.");
  } else if (point == POINT_BENTO){
    openDialogue("BENTO", "PEÇAS: " + parts + ". KIT E FUSÍVEL FICAM NO DEPÓSITO.");
  } else {
    openDialogue("NEUSA", "MORAL " + int(morale) + ". PESSOAS EM RISCO: " + riskCount() + ".");
  }
}

int riskCount(){
  int count = 0;
  for (int crew = 0; crew < CREW_COUNT; crew++) if (crew_risk_deadline[crew] > 0) count++;
  return count;
}

String componentName(int item){
  if (item == ITEM_SEAL_KIT) return "KIT DE VEDAÇÃO";
  if (item == ITEM_FUSE) return "FUSÍVEL DE POTÊNCIA";
  return "NENHUM";
}

String collectPurpose(int item){
  return item == ITEM_SEAL_KIT
    ? "SERVE PARA REPARAR O DANO NO CASCO."
    : "SERVE PARA REPARAR O SISTEMA DE ENERGIA.";
}

String collectTargetSuffix(int item){
  int problem = item == ITEM_SEAL_KIT ? PROBLEM_HULL : PROBLEM_POWER;
  return problem_active[problem]
    ? " PROBLEMA ATIVO AGORA: " + problem_title[problem] + "."
    : " SEM " + problem_title[problem] + " AGORA.";
}

String heldItemLabel(){
  return componentName(held_item);
}

void switchPoint(int point){
  pending_switch_point = point;
  technical_open = true;
  if (point == POINT_DISTRIBUTION){
    technical_title = saving_on ? "DESATIVAR ECONOMIA" : "ATIVAR ECONOMIA";
    technical_text = saving_on
      ? "O CONSUMO VOLTA A 6 DE ENERGIA POR DIA."
      : "ENERGIA CAI PARA 3/DIA. CUSTO MORAL AO ATIVAR E A CADA NOITE.";
  } else {
    technical_title = rationing_on ? "DESATIVAR RACIONAMENTO" : "ATIVAR RACIONAMENTO";
    technical_text = rationing_on
      ? "ÁGUA E COMIDA VOLTAM AO CONSUMO NORMAL."
      : "ÁGUA CAI PARA 4/DIA E COMIDA PARA 3/DIA. HÁ CUSTO DE MORAL.";
  }
}

void applySwitchPoint(){
  int point = pending_switch_point;
  pending_switch_point = -1;
  technical_open = false;
  if (point == POINT_DISTRIBUTION) toggleSaving();
  else if (point == POINT_RATIONING) toggleRationing();
}

String activeProblemSummary(){
  int count = activeProblemCount();
  if (count == 0) return "NENHUM PROBLEMA ATIVO.";
  int urgent = urgentProblem();
  return count + " ATIVO(S). MAIS URGENTE: " + problem_short[urgent]
    + " — " + problem_deadline[urgent] + " DIA(S).";
}

String problemLossLabel(int problem){
  String resource = problem_loss_resource[problem] == RESOURCE_ENERGY ? "ENERGIA"
    : problem_loss_resource[problem] == RESOURCE_OXYGEN ? "OXIGÊNIO"
    : problem_loss_resource[problem] == RESOURCE_FOOD ? "COMIDA" : "MORAL";
  return resource + " -" + problem_loss_value[problem] + "/DIA";
}

String problemMapLine(int problem){
  return problem_short[problem] + " | " + problemLossLabel(problem)
    + " | PRAZO " + problem_deadline[problem] + " | " + problem_crisis[problem];
}
