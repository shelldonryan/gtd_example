final int EVENT_NONE = -1;
final int EVENT_ENGINE = 0;
final int EVENT_METEOR = 1;
final int EVENT_FOOD = 2;
final int EVENT_CONFLICT = 3;
final int EVENT_LIFE_SUPPORT = 4;
final int EVENT_POWER = 5;
final int EVENT_COMMS = 6;
final int EVENT_COUNT = 7;

String[] event_title = {
  "FALHA NO MOTOR",
  "CHUVA DE METEOROS",
  "ESTOQUE CRÍTICO",
  "CONFLITO A BORDO",
  "FALHA NO SUPORTE DE VIDA",
  "FALHA NO SISTEMA DE ENERGIA",
  "FALHA NAS COMUNICAÇÕES"
};

String[] event_body = {
  "O MOTOR PERDEU RENDIMENTO. A VIAGEM ESTÁ EM RISCO.",
  "IMPACTO IMINENTE: O CASCO PODE CEDER.",
  "A COMIDA ESTÁ ACABANDO E OS SOBREVIVENTES PERCEBERAM.",
  "UMA DISCUSSÃO DIVIDE OS SOBREVIVENTES.",
  "O SUPORTE PERDEU ESTABILIDADE. A NAVE CONSOME MAIS OXIGÊNIO.",
  "A REDE PERDEU ESTABILIDADE E OPERA EM CARGA FORÇADA.",
  "O TRANSMISSOR PERDEU O CONTATO COM A TERRA."
};

String[] event_a_label = {
  "REPARAR (2 PEÇAS)",
  "ATIVAR ESCUDOS (15)",
  "MANTER AS PORÇÕES",
  "IGNORAR",
  "REPARAR (2 PEÇAS)",
  "FORÇAR A REDE (ENERGIA -10)",
  "REPARAR (1 PEÇA)"
};

String[] event_b_label = {
  "SEGUIR DANIFICADO",
  "ABSORVER O IMPACTO",
  "RACIONAR (MORAL -8)",
  "INTERVIR (ENERGIA -10)",
  "EMERGÊNCIA (ENERGIA -10)",
  "DESLIGAR SETORES (MORAL -10)",
  "SILÊNCIO (MORAL -1/DIA)"
};
String[] event_a_effect = {
  "MOTOR OPERANTE; -2 PEÇAS",
  "CASCO PROTEGIDO; -15 ENERGIA",
  "CONSUMO NORMAL",
  "MORAL -10",
  "SUPORTE ESTÁVEL; -2 PEÇAS",
  "FALHA ATIVA; ENERGIA -10",
  "CONTATO RESTAURADO; -1 PEÇA"
};

String[] event_b_effect = {
  "MOTOR DANIFICADO; VIAGEM +1 DIA",
  "OXIGÊNIO -15; VAZAMENTO -3/DIA",
  "MORAL -8; CONSUMO REDUZIDO",
  "MORAL +10; ENERGIA -10",
  "ENERGIA -10; OXIGÊNIO -3/DIA",
  "FALHA ATIVA; MORAL -10",
  "MORAL -1/DIA; SEM TERRA"
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
  food = FOOD_START;
  morale = STOCK_START;
  parts = PARTS_START;
  engine_state = ENGINE_WORKING;
  engine_damaged_days = 0;
  leak_on = false;
  saving_on = false;
  rationing_on = false;
  life_support_emergency = false;
  power_fault_on = false;
  comms_silent = false;
  power_variant = POWER_VARIANT_NONE;
  action_used = false;

  for (int i = 0; i < POWER_VARIANT_COUNT; i++){
    power_variant_used[i] = false;
  }

  boost_count = 0;
  game_over_reason = REASON_NONE;
  event_index = EVENT_NONE;
  last_event = EVENT_NONE;
  event_open = false;
  paused = false;
  system_message = "";
  resetRoomState();
  resetTaskState();
}


void openDay(){
  event_open = false;

  if (day > 1){
    event_index = pickEvent();
    event_open = event_index != EVENT_NONE;
  }
}


boolean eventAllowed(int event){
  if (event == EVENT_ENGINE){
    return engine_state != ENGINE_DAMAGED;
  }

  if (event == EVENT_LIFE_SUPPORT){
    return !life_support_emergency;
  }

  if (event == EVENT_POWER){
    boolean variantsExhausted = powerVariantsUsed() == POWER_VARIANT_COUNT;
    return !power_fault_on && !variantsExhausted;
  }

  if (event == EVENT_COMMS){
    return !comms_silent;
  }

  return true;
}


/* Active failures leave the uniform draw until repaired. */
int pickEvent(){
  int[] candidates = new int[EVENT_COUNT];
  int total = 0;

  for (int i = 0; i < EVENT_COUNT; i++){
    if (eventAllowed(i) && i != last_event){
      candidates[total] = i;
      total++;
    }
  }

  if (total == 0){
    for (int i = 0; i < EVENT_COUNT; i++){
      if (eventAllowed(i)){
        candidates[total] = i;
        total++;
      }
    }
  }

  if (total == 0){
    return EVENT_NONE;
  }

  int next = candidates[int(random(total))];
  last_event = next;
  return next;
}


void endDay(){
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
  enterRoom(SCREEN_DORMITORY);
  openDay();
}


int dailyEnergyCost(){
  return (saving_on ? ENERGY_PER_DAY_SAVING : ENERGY_PER_DAY)
    + (power_fault_on ? ENERGY_PER_DAY_POWER_FAULT : 0);
}


int dailyOxygenCost(){
  return (energy < RESOURCE_LOW_ENERGY ? OXYGEN_PER_DAY_LOW_ENERGY : OXYGEN_PER_DAY)
    + (leak_on ? LEAK_PER_DAY : 0)
    + (life_support_emergency ? OXYGEN_PER_DAY_EMERGENCY : 0);
}


int dailyWaterCost(){
  return rationing_on ? WATER_PER_DAY_RATIONING : WATER_PER_DAY;
}


int dailyFoodCost(){
  return rationing_on ? FOOD_PER_DAY_RATIONING : FOOD_PER_DAY;
}


int dailyMoraleCost(){
  float next_energy = max(0, energy - dailyEnergyCost());
  float next_oxygen = max(0, oxygen - dailyOxygenCost());
  float next_water = max(0, water - dailyWaterCost());
  float next_food = max(0, food - dailyFoodCost());
  int red = 0;

  if (isRed(next_energy)) red++;
  if (isRed(next_oxygen)) red++;
  if (isRed(next_water)) red++;
  if (isRed(next_food)) red++;

  return MORALE_PER_DAY + red * MORALE_PER_RED_RESOURCE
    + (saving_on ? MORALE_PER_DAY_SAVING : 0)
    + (rationing_on ? MORALE_PER_DAY_RATIONING : 0)
    + (comms_silent ? MORALE_PER_DAY_NO_COMMS : 0);
}


void consumeResources(){
  int energy_cost = dailyEnergyCost();
  int oxygen_cost = dailyOxygenCost();
  int water_cost = dailyWaterCost();
  int food_cost = dailyFoodCost();
  int morale_cost = dailyMoraleCost();

  energy -= energy_cost;
  oxygen -= oxygen_cost;
  water -= water_cost;
  food -= food_cost;
  morale -= morale_cost;
  clampResources();
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

  if (event_index == EVENT_LIFE_SUPPORT){
    return (choice == 0) ? parts >= EVENT_LIFE_PARTS : true;
  }

  if (event_index == EVENT_POWER){
    return (choice == 0) ? energy >= EVENT_POWER_ENERGY : true;
  }

  if (event_index == EVENT_COMMS){
    return (choice == 0) ? parts >= EVENT_COMMS_PARTS : true;
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
  } else if (event_index == EVENT_LIFE_SUPPORT){
    if (choice == 0){
      parts -= EVENT_LIFE_PARTS;
      life_support_emergency = false;
      system_message = "SUPORTE DE VIDA REPARADO.";
    } else {
      energy -= EVENT_LIFE_ENERGY;
      life_support_emergency = true;
      system_message = "SUPORTE EM EMERGÊNCIA: +3 DE OXIGÊNIO POR DIA.";
    }
  } else if (event_index == EVENT_POWER){
    if (choice == 0){
      energy -= EVENT_POWER_ENERGY;
      system_message = "REDE FORÇADA: A FALHA CONTINUA ATIVA.";
    } else {
      morale -= EVENT_POWER_MORALE;
      system_message = "SETORES DESLIGADOS: A FALHA CONTINUA ATIVA.";
    }

    power_fault_on = true;
  } else if (event_index == EVENT_COMMS){
    if (choice == 0){
      parts -= EVENT_COMMS_PARTS;
      comms_silent = false;
      system_message = "COMUNICAÇÕES RESTAURADAS.";
    } else {
      comms_silent = true;
      system_message = "SILÊNCIO: -1 DE MORAL POR DIA.";
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
    return "SOBREVIVENTES PERDIDOS";
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
    return "OS SOBREVIVENTES PERDERAM A CONFIANÇA NA MISSÃO.";
  }

  if (game_over_reason == REASON_CREW){
    return "NENHUM SOBREVIVENTE CHEGOU A MARTE.";
  }

  return "O MOTOR NÃO SUPORTOU A VIAGEM ATÉ MARTE.";
}


void drawEventCard(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 42, 60, 556, 240, COL_ORANGE);
  text(g, "EVENTO DO DIA", 60, 74, 16, COL_ORANGE);
  text(g, event_title[event_index], 60, 102, 16, COL_TEXT);
  drawTextWrapped(g, event_body[event_index], 60, 128, 520, 16, 18, COL_MUTED);
  drawEventOption(g, 60, 190, 250, event_a_label[event_index],
    event_a_effect[event_index], ACTION_EVENT_A, eventChoiceOn(0));
  drawEventOption(g, 330, 190, 250, event_b_label[event_index],
    event_b_effect[event_index], ACTION_EVENT_B, eventChoiceOn(1));
}


void drawEventOption(PGraphics g, float x, float y, float w, String label,
  String effect, int action, boolean on){
  boolean hover = on && uiLayer() == LAYER_MODAL && isHovering(x, y, w, 82);
  int border = on ? (hover ? COL_CYAN : COL_BORDER) : COL_DIM;
  drawPanel(g, x, y, w, 82, border);
  text(g, label, x + 10, y + 8, 16, on ? COL_TEXT : COL_DIM);
  drawTextWrapped(g, effect, x + 10, y + 34, w - 20, 16, 18,
    on ? COL_CYAN : COL_DIM);
  addButton(x, y, w, 82, action, on);
}


String activeStateSummary(){
  String value = "";
  if (engine_state == ENGINE_DAMAGED) value += "MOTOR ";
  if (leak_on) value += "VAZAMENTO ";
  if (life_support_emergency) value += "SUPORTE ";
  if (power_fault_on) value += "ENERGIA ";
  if (comms_silent) value += "COMUNICAÇÕES ";
  if (saving_on) value += "ECONOMIA ";
  if (rationing_on) value += "RACIONAMENTO ";
  return value.length() == 0 ? "NENHUM" : value.trim();
}


String dayTaskSummary(){
  if (action_used){
    return "CONCLUÍDA";
  }

  if (active_task != TASK_NONE){
    return "PENDENTE - " + task_label[active_task];
  }

  return "NÃO ESCOLHIDA";
}
