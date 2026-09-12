/* jogo - recursos, acoes das salas, ciclo do dia e eventos
   Todos os valores vem de mechanics/ACTIONS.md. */

final int EVENT_NONE = -1;
final int EVENT_ENGINE = 0;
final int EVENT_METEOR = 1;
final int EVENT_FOOD = 2;
final int EVENT_CONFLICT = 3;
final int EVENT_COUNT = 4;

String[] event_title = {
  "FALHA NO MOTOR",
  "CHUVA DE METEOROS",
  "ESTOQUE CRÍTICO",
  "CONFLITO A BORDO"
};

String[] event_body = {
  "O MOTOR PERDEU RENDIMENTO. A VIAGEM ESTÁ EM RISCO.",
  "IMPACTO IMINENTE: O CASCO PODE CEDER.",
  "A COMIDA ESTÁ ACABANDO E A TRIPULAÇÃO PERCEBEU.",
  "UMA DISCUSSÃO DIVIDE OS SOBREVIVENTES."
};

String[] event_a_label = {
  "REPARAR (2 PEÇAS)",
  "ATIVAR ESCUDOS (15)",
  "MANTER AS PORÇÕES",
  "IGNORAR"
};

String[] event_b_label = {
  "SEGUIR DANIFICADO",
  "ABSORVER O IMPACTO",
  "RACIONAR (MORAL -8)",
  "INTERVIR (ENERGIA -10)"
};

int event_index = EVENT_NONE;
int last_event = EVENT_NONE;
boolean event_open = false;


void startGame(){
  resetRun();
  vignette_page = 0;
  screen = SCREEN_VIGNETTE;
}


void resetRun(){
  player_name = player_name.trim();

  if (player_name.length() == 0){
    player_name = "Técnico";
  }

  day = 1;
  trip_days = TRIP_DAYS;
  survivors = CREW_START;
  energy = STOCK_START;
  oxygen = STOCK_START;
  water = STOCK_START;
  food = STOCK_START;
  morale = STOCK_START;
  parts = PARTS_START;
  engine_state = ENGINE_WORKING;
  engine_damaged_days = 0;
  leak_on = false;
  saving_on = false;
  rationing_on = false;
  action_used = false;
  boost_count = 0;
  game_over_reason = REASON_NONE;
  event_index = EVENT_NONE;
  last_event = EVENT_NONE;
  event_open = false;
  paused = false;
  system_message = "";
}


void openDay(){
  event_open = false;

  if (day > 1){
    event_index = pickEvent();
    event_open = true;
  }
}


int pickEvent(){
  int next = int(random(EVENT_COUNT));

  if (next == last_event){
    next = (next + 1) % EVENT_COUNT;
  }

  last_event = next;
  return next;
}


void passDay(){
  consumeResources();

  if (food <= 0 && survivors > 0){
    survivors--;
    morale -= STARVING_MORALE_LOSS;
    system_message = "SEM COMIDA: UM SOBREVIVENTE NÃO RESISTIU.";
    clampResources();
  }

  if (engine_state == ENGINE_DAMAGED){
    engine_damaged_days++;

    if (engine_damaged_days >= ENGINE_DAMAGED_LIMIT_DAYS){
      engine_state = ENGINE_DESTROYED;
      system_message = "O MOTOR CEDEU DEPOIS DE 3 DIAS DANIFICADO.";
    }
  }

  if (checkEndConditions()){
    return;
  }

  if (day >= trip_days){
    if (engine_state != ENGINE_WORKING){
      game_over_reason = REASON_ENGINE;
      screen = SCREEN_GAME_OVER;
      return;
    }

    screen = SCREEN_VICTORY;
    return;
  }

  day++;
  action_used = false;
  openDay();
  screen = SCREEN_SHIP;
}


void consumeResources(){
  boolean low_energy = energy < RESOURCE_LOW_ENERGY;

  energy -= saving_on ? ENERGY_PER_DAY_SAVING : ENERGY_PER_DAY;
  oxygen -= low_energy ? OXYGEN_PER_DAY_LOW_ENERGY : OXYGEN_PER_DAY;
  water -= rationing_on ? WATER_PER_DAY_RATIONING : WATER_PER_DAY;
  food -= rationing_on ? FOOD_PER_DAY_RATIONING : FOOD_PER_DAY;

  if (leak_on){
    oxygen -= LEAK_PER_DAY;
  }

  clampResources();

  morale -= MORALE_PER_DAY + redResourceCount() * MORALE_PER_RED_RESOURCE;

  if (saving_on){
    morale -= MORALE_PER_DAY_SAVING;
  }

  if (rationing_on){
    morale -= MORALE_PER_DAY_RATIONING;
  }

  clampResources();
}


int redResourceCount(){
  int total = 0;

  if (isRed(energy)){
    total++;
  }

  if (isRed(oxygen)){
    total++;
  }

  if (isRed(water)){
    total++;
  }

  if (isRed(food)){
    total++;
  }

  return total;
}


boolean isRed(float value){
  return value > 0 && value < RESOURCE_RED;
}


int resourceColour(float value){
  if (value <= 0){
    return COL_RED;
  }

  if (value < RESOURCE_RED){
    return COL_RED;
  }

  if (value < RESOURCE_GREEN){
    return COL_YELLOW;
  }

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

  if (oxygen <= 0){
    game_over_reason = REASON_OXYGEN;
  } else if (energy <= 0){
    game_over_reason = REASON_ENERGY;
  } else if (morale <= 0){
    game_over_reason = REASON_MORALE;
  } else if (engine_state == ENGINE_DESTROYED){
    game_over_reason = REASON_ENGINE;
  } else if (survivors <= 0){
    game_over_reason = REASON_CREW;
  }

  if (game_over_reason == REASON_NONE){
    return false;
  }

  event_open = false;
  paused = false;
  screen = SCREEN_GAME_OVER;
  return true;
}


void repairEngine(){
  engine_state = ENGINE_WORKING;
  engine_damaged_days = 0;
  system_message = "MOTOR REPARADO.";
}


void damageEngine(){
  if (engine_state == ENGINE_DAMAGED){
    system_message = "O MOTOR SEGUE DANIFICADO E A VIAGEM ATRASADA.";
    return;
  }

  engine_state = ENGINE_DAMAGED;
  engine_damaged_days = 0;
  trip_days++;
  system_message = "MOTOR DANIFICADO: A VIAGEM GANHOU 1 DIA.";
}


boolean canRepairEngine(){
  return !action_used && engine_state == ENGINE_DAMAGED && parts >= REPAIR_ENGINE_PARTS;
}


boolean canBoostEngine(){
  return !action_used && energy >= BOOST_ENERGY_COST && boost_count < BOOST_LIMIT;
}


boolean canRepairHull(){
  return !action_used && leak_on && parts >= REPAIR_HULL_PARTS;
}


boolean canRestCrew(){
  return !action_used && energy >= REST_ENERGY_COST;
}


void repairEngineWithParts(){
  if (!canRepairEngine()){
    return;
  }

  parts -= REPAIR_ENGINE_PARTS;
  action_used = true;
  repairEngine();
}


void toggleSaving(){
  saving_on = !saving_on;

  if (saving_on){
    morale -= SAVING_MORALE_COST;
    system_message = "MODO ECONOMIA LIGADO: -1 DE MORAL POR DIA.";
  } else {
    system_message = "MODO ECONOMIA DESLIGADO.";
  }

  clampResources();
  checkEndConditions();
}


void toggleRationing(){
  rationing_on = !rationing_on;

  if (rationing_on){
    morale -= RATIONING_MORALE_COST;
    system_message = "RACIONAMENTO LIGADO: -1 DE MORAL POR DIA.";
  } else {
    system_message = "RACIONAMENTO DESLIGADO.";
  }

  clampResources();
  checkEndConditions();
}


void boostEngine(){
  if (!canBoostEngine()){
    return;
  }

  energy -= BOOST_ENERGY_COST;
  boost_count++;
  trip_days = max(trip_days - 1, 1);
  action_used = true;
  system_message = "POTÊNCIA EXTRA: A VIAGEM ENCURTOU 1 DIA.";
  clampResources();
  checkEndConditions();
}


void repairHull(){
  if (!canRepairHull()){
    return;
  }

  parts -= REPAIR_HULL_PARTS;
  leak_on = false;
  action_used = true;
  system_message = "CASCO REPARADO: O VAZAMENTO PAROU.";
  clampResources();
  checkEndConditions();
}


void restCrew(){
  if (!canRestCrew()){
    return;
  }

  energy -= REST_ENERGY_COST;
  morale += REST_MORALE_GAIN;
  action_used = true;
  system_message = "TRIPULAÇÃO DESCANSOU E SE ORGANIZOU.";
  clampResources();
  checkEndConditions();
}


boolean eventChoiceOn(int choice){
  if (event_index == EVENT_ENGINE){
    return (choice == 0) ? parts >= EVENT_REPAIR_PARTS : true;
  }

  if (event_index == EVENT_METEOR){
    return (choice == 0) ? energy >= EVENT_METEOR_ENERGY : true;
  }

  if (event_index == EVENT_CONFLICT){
    return (choice == 0) ? true : energy >= EVENT_CONFLICT_ENERGY;
  }

  if (event_index == EVENT_FOOD){
    return true;
  }

  return false;
}


void applyEventChoice(int choice){
  if (event_index == EVENT_ENGINE){
    if (choice == 0){
      parts -= EVENT_REPAIR_PARTS;
      repairEngine();
    } else {
      damageEngine();
    }
  } else if (event_index == EVENT_METEOR){
    if (choice == 0){
      energy -= EVENT_METEOR_ENERGY;
      system_message = "ESCUDOS SEGURARAM O IMPACTO.";
    } else {
      oxygen -= EVENT_METEOR_OXYGEN;
      leak_on = true;
      system_message = "CASCO ROMPIDO: -3 DE OXIGÊNIO POR DIA.";
    }
  } else if (event_index == EVENT_FOOD){
    if (choice == 0){
      system_message = "PORÇÕES NORMAIS MANTIDAS.";
    } else {
      rationing_on = true;
      morale -= EVENT_RATIONING_MORALE;
      system_message = "RACIONAMENTO LIGADO: MORAL EM QUEDA.";
    }
  } else if (event_index == EVENT_CONFLICT){
    if (choice == 0){
      morale -= EVENT_CONFLICT_MORALE_LOSS;
      system_message = "O CONFLITO CONTINUA A BORDO.";
    } else {
      morale += EVENT_CONFLICT_MORALE_GAIN;
      energy -= EVENT_CONFLICT_ENERGY;
      system_message = "GRUPO UNIDO DE NOVO.";
    }
  }

  clampResources();
  event_open = false;
  checkEndConditions();
}


String engineStateLabel(){
  if (engine_state == ENGINE_DAMAGED){
    return "DANIFICADO";
  }

  if (engine_state == ENGINE_DESTROYED){
    return "DESTRUÍDO";
  }

  return "OPERANTE";
}


String gameOverTitle(){
  if (game_over_reason == REASON_OXYGEN){
    return "OXIGÊNIO ZERO";
  }

  if (game_over_reason == REASON_ENERGY){
    return "ENERGIA ZERO";
  }

  if (game_over_reason == REASON_MORALE){
    return "MORAL ZERO";
  }

  if (game_over_reason == REASON_CREW){
    return "TRIPULAÇÃO PERDIDA";
  }

  return "MOTOR PERDIDO";
}


String gameOverMessage(){
  if (game_over_reason == REASON_OXYGEN){
    return "O OXIGÊNIO ACABOU ANTES DA CHEGADA.";
  }

  if (game_over_reason == REASON_ENERGY){
    return "SEM ENERGIA A NAVE NÃO SEGUIU VIAGEM.";
  }

  if (game_over_reason == REASON_MORALE){
    return "A TRIPULAÇÃO PERDEU A CONFIANÇA NA MISSÃO.";
  }

  if (game_over_reason == REASON_CREW){
    return "NENHUM SOBREVIVENTE CHEGOU A MARTE.";
  }

  return "O MOTOR NÃO SUPORTOU A VIAGEM ATÉ MARTE.";
}


void drawEventCard(PGraphics g){
  drawPanel(g, SIDE_X, SIDE_Y, SIDE_W, SIDE_H, COL_ORANGE);
  text(g, "EVENTO DO DIA", SIDE_X + 8, SIDE_Y + 7, 9, COL_ORANGE);
  drawTextWrapped(g, event_title[event_index], SIDE_X + 8, SIDE_Y + 24, SIDE_W - 16, 11, 14, COL_TEXT);
  drawTextWrapped(g, event_body[event_index], SIDE_X + 8, SIDE_Y + 52, SIDE_W - 16, 9, 12, COL_MUTED);

  text(g, "ESCOLHA UMA ALTERNATIVA", SIDE_X + 8, SIDE_Y + SIDE_H - 86, 9, COL_CYAN);

  drawButton(g, SIDE_X + 8, SIDE_Y + SIDE_H - 66, SIDE_W - 16, 26, event_a_label[event_index], ACTION_EVENT_A, eventChoiceOn(0));
  drawButton(g, SIDE_X + 8, SIDE_Y + SIDE_H - 36, SIDE_W - 16, 26, event_b_label[event_index], ACTION_EVENT_B, eventChoiceOn(1));
}
