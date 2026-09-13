final int TASK_NONE = -1;
final int TASK_REPAIR_ENGINE = 0;
final int TASK_BOOST_ENGINE = 1;
final int TASK_REPAIR_HULL = 2;
final int TASK_REST_CREW = 3;
final int TASK_RESCUE_SURVIVOR = 4;
final int TASK_LIFE_SUPPORT = 5;
final int TASK_POWER = 6;
final int TASK_COMMS = 7;
final int TASK_COUNT = 8;

final int GATE_ENGINE_DAMAGED = 0;
final int GATE_BOOST_AVAILABLE = 1;
final int GATE_HULL_LEAK = 2;
final int GATE_ALWAYS = 3;
final int GATE_RESOURCE_RED = 4;
final int GATE_LIFE_SUPPORT_EMERGENCY = 5;
final int GATE_POWER_FAULT = 6;
final int GATE_COMMS_SILENT = 7;

final int COST_NONE = 0;
final int COST_PARTS = 1;
final int COST_ENERGY = 2;
final int COST_WATER = 3;

String[] task_label = {
  "REPARAR MOTOR",
  "AUMENTAR POTENCIA",
  "REPARAR CASCO",
  "DESCANSO E ORGANIZAÇÃO",
  "SOCORRER SOBREVIVENTE",
  "REPARAR SUPORTE DE VIDA",
  "REPARAR SISTEMA DE ENERGIA",
  "REPARAR COMUNICAÇÕES"
};

int[] task_gate = {
  GATE_ENGINE_DAMAGED,
  GATE_BOOST_AVAILABLE,
  GATE_HULL_LEAK,
  GATE_ALWAYS,
  GATE_RESOURCE_RED,
  GATE_LIFE_SUPPORT_EMERGENCY,
  GATE_POWER_FAULT,
  GATE_COMMS_SILENT
};

int[] task_completion_room = {
  SCREEN_ENERGY,
  SCREEN_ENERGY,
  SCREEN_DEPOT,
  SCREEN_DORMITORY,
  SCREEN_DORMITORY,
  SCREEN_ENERGY,
  SCREEN_ENERGY,
  SCREEN_COMMAND
};

int[] task_completion_point = {
  POINT_ENGINE_BENCH,
  POINT_REACTOR,
  POINT_HULL,
  POINT_COMMON_TABLE,
  POINT_BUNK,
  POINT_LIFE_SUPPORT,
  POINT_DISTRIBUTION,
  POINT_ANTENNA
};

int[] task_cost_type = {
  COST_PARTS,
  COST_ENERGY,
  COST_PARTS,
  COST_ENERGY,
  COST_WATER,
  COST_PARTS,
  COST_PARTS,
  COST_PARTS
};

int[] task_cost_value = {
  2,
  20,
  1,
  8,
  5,
  2,
  1,
  1
};

String[] task_effect = {
  "MOTOR VOLTA A OPERANTE",
  "VIAGEM ENCURTA 1 DIA",
  "VAZAMENTO ESTANCADO",
  "MORAL +15",
  "MORAL +10",
  "SUPORTE DE VOLTA AO NORMAL",
  "FALHA DE ENERGIA ENCERRADA",
  "TRANSMISSÕES RESTAURADAS"
};

int[] task_step_count = {2, 1, 2, 1, 1, 2, 2, 2};

int[][] task_step_room = {
  {SCREEN_ENERGY, SCREEN_DEPOT},
  {SCREEN_COMMAND},
  {SCREEN_DORMITORY, SCREEN_DEPOT},
  {SCREEN_DORMITORY},
  {SCREEN_DEPOT},
  {SCREEN_ENERGY, SCREEN_DEPOT},
  {SCREEN_ENERGY, SCREEN_DEPOT},
  {SCREEN_COMMAND, SCREEN_DEPOT}
};

int[][] task_step_point = {
  {POINT_SILVIA, POINT_BENTO},
  {POINT_VERA},
  {POINT_NEUSA, POINT_SEAL_KIT},
  {POINT_NEUSA},
  {POINT_BENTO},
  {POINT_SILVIA, POINT_BENTO},
  {POINT_SILVIA, POINT_BENTO},
  {POINT_VERA, POINT_BENTO}
};


/* power repair variants */
int[] variant_item = {ITEM_FUSE, ITEM_CABLE, ITEM_COOLANT};
int[] variant_room = {SCREEN_DEPOT, SCREEN_COMMAND, SCREEN_DORMITORY};
int[] variant_point = {POINT_BENTO, POINT_VERA, POINT_NEUSA};
int[] variant_cost_type = {COST_PARTS, COST_ENERGY, COST_WATER};
int[] variant_cost_value = {1, 10, 5};
int[] variant_completion_point = {POINT_DISTRIBUTION, POINT_REACTOR, POINT_ENGINE_BENCH};


int active_task = TASK_NONE;
int task_step_index = 0;

boolean task_choice_open = false;
int task_choice_cursor = 0;
int task_choice_count = 0;
int task_choice_last_frame = -30;
int[] task_choice_indices = new int[TASK_COUNT];


void resetTaskState(){
  active_task = TASK_NONE;
  task_step_index = 0;
  task_choice_open = false;
  task_choice_cursor = 0;
  task_choice_count = 0;
  task_choice_last_frame = -30;
}


boolean taskIsAvailable(int task){
  if (task < 0 || task >= TASK_COUNT){
    return false;
  }

  if (task_gate[task] == GATE_ENGINE_DAMAGED){
    return engine_state == ENGINE_DAMAGED;
  }

  if (task_gate[task] == GATE_BOOST_AVAILABLE){
    return boost_count < BOOST_LIMIT;
  }

  if (task_gate[task] == GATE_HULL_LEAK){
    return leak_on;
  }

  if (task_gate[task] == GATE_RESOURCE_RED){
    return isRed(oxygen) || isRed(morale);
  }

  if (task_gate[task] == GATE_LIFE_SUPPORT_EMERGENCY){
    return life_support_emergency;
  }

  if (task_gate[task] == GATE_POWER_FAULT){
    return powerTaskAvailable();
  }

  if (task_gate[task] == GATE_COMMS_SILENT){
    return comms_silent;
  }

  return true;
}


boolean taskCostAvailable(int task){
  if (task == TASK_POWER && power_variant == POWER_VARIANT_NONE){
    return powerVariantPayable();
  }

  return costAvailable(task_cost_type[task], task_cost_value[task]);
}

boolean costAvailable(int type, int value){
  if (type == COST_PARTS){
    return parts >= value;
  }

  if (type == COST_ENERGY){
    return energy >= value;
  }

  if (type == COST_WATER){
    return water >= value;
  }

  return true;
}


/* Only unused, affordable power variants can be selected. */
int powerVariantsUsed(){
  int total = 0;

  for (int i = 0; i < POWER_VARIANT_COUNT; i++){
    if (power_variant_used[i]){
      total++;
    }
  }

  return total;
}


boolean powerVariantPayable(){
  for (int i = 0; i < POWER_VARIANT_COUNT; i++){
    if (!power_variant_used[i] && costAvailable(variant_cost_type[i], variant_cost_value[i])){
      return true;
    }
  }

  return false;
}


boolean powerTaskAvailable(){
  if (!power_fault_on){
    return false;
  }

  if (power_variant != POWER_VARIANT_NONE){
    return true;
  }

  return powerVariantPayable();
}


int drawPowerVariant(){
  int[] options = new int[POWER_VARIANT_COUNT];
  int total = 0;

  for (int i = 0; i < POWER_VARIANT_COUNT; i++){
    if (!power_variant_used[i] && costAvailable(variant_cost_type[i], variant_cost_value[i])){
      options[total] = i;
      total++;
    }
  }

  if (total == 0){
    return POWER_VARIANT_NONE;
  }

  int variant = options[int(random(total))];
  power_variant = variant;
  power_variant_used[variant] = true;
  task_cost_type[TASK_POWER] = variant_cost_type[variant];
  task_cost_value[TASK_POWER] = variant_cost_value[variant];
  task_completion_point[TASK_POWER] = variant_completion_point[variant];
  task_step_room[TASK_POWER][1] = variant_room[variant];
  task_step_point[TASK_POWER][1] = variant_point[variant];
  return variant;
}




String taskStatusLabel(){
  if (active_task == TASK_NONE){
    return action_used ? "TAREFA DO DIA CONCLUÍDA" : "ESCOLHA UMA TAREFA NO COMANDO";
  }

  return task_label[active_task] + " | " + taskNextInstruction();
}


String heldItemLabel(){
  if (held_item == ITEM_ENGINE_PARTS){
    return "2 PEÇAS";
  }

  if (held_item == ITEM_WATER){
    return "ÁGUA";
  }

  if (held_item == ITEM_SEAL_KIT){
    return "KIT DE VEDAÇÃO";
  }

  if (held_item == ITEM_SPARE_PART){
    return "1 PEÇA";
  }

  if (held_item == ITEM_FUSE){
    return "FUSÍVEL";
  }

  if (held_item == ITEM_CABLE){
    return "CABO";
  }

  if (held_item == ITEM_COOLANT){
    return "CARTUCHO";
  }

  return "NADA";
}
String taskNextInstruction(){
  if (active_task == TASK_NONE){
    return action_used
      ? "VÁ AO SEU BELICHE - DORMITÓRIO"
      : "USE O CONSOLE DE BRIEFING - SALA DE COMANDO";
  }

  if (task_step_index < task_step_count[active_task]){
    int point = task_step_point[active_task][task_step_index];
    int room = task_step_room[active_task][task_step_index];
    return pointActionLabel(point) + " - " + roomTitle(room);
  }

  int point = task_completion_point[active_task];
  return pointActionLabel(point) + " - " + roomTitle(task_completion_room[active_task]);
}


String pointActionLabel(int point){
  if (point_kind[point] == POINT_NPC){
    return "FALE COM " + point_label[point];
  }

  if (point_kind[point] == POINT_COLLECT){
    return "PEGUE " + point_label[point];
  }

  return "USE " + point_label[point];
}


boolean taskVisitsRoom(int room){
  if (active_task == TASK_NONE){
    return false;
  }

  if (task_completion_room[active_task] == room){
    return true;
  }

  for (int i = task_step_index; i < task_step_count[active_task]; i++){
    if (task_step_room[active_task][i] == room){
      return true;
    }
  }

  return false;
}


String taskCostLabel(int task){
  String resource = task_cost_type[task] == COST_PARTS ? "PEÇAS"
    : task_cost_type[task] == COST_ENERGY ? "ENERGIA"
    : task_cost_type[task] == COST_WATER ? "ÁGUA" : "SEM CUSTO";
  return task_cost_type[task] == COST_NONE
    ? resource : task_cost_value[task] + " " + resource;
}


String taskRouteLabel(int task){
  String route = "";
  int previous_room = SCREEN_NONE;

  for (int i = 0; i < task_step_count[task]; i++){
    int room = task_step_room[task][i];

    if (room != previous_room){
      route += (route.length() == 0 ? "" : " > ") + roomTitle(room);
      previous_room = room;
    }
  }

  int final_room = task_completion_room[task];
  if (final_room != previous_room){
    route += " > " + roomTitle(final_room);
  }

  return route;
}


boolean pointIsAvailable(int point){
  if (point_kind[point] == POINT_COMPLETE || point_kind[point] == POINT_COLLECT){
    return taskPointIsExpected(point);
  }

  return true;
}


boolean pointIsInteractable(int point){
  if (point_kind[point] == POINT_COMPLETE || point_kind[point] == POINT_COLLECT){
    return taskPointIsExpected(point);
  }

  return true;
}


boolean taskPointIsExpected(int point){
  if (active_task == TASK_NONE || task_step_index >= task_step_count[active_task]){
    return active_task != TASK_NONE
      && point == task_completion_point[active_task]
      && screen == task_completion_room[active_task];
  }

  return task_step_room[active_task][task_step_index] == screen
    && task_step_point[active_task][task_step_index] == point;
}


void interactPoint(int point){
  if (point_kind[point] == POINT_END_DAY){
    end_day_open = true;
    return;
  }

  if (point_kind[point] == POINT_READ){
    readPoint(point);
    return;
  }

  if (point_kind[point] == POINT_SWITCH && !pointCompletesActiveTask(point)){
    switchPoint(point);
    return;
  }

  if (point_kind[point] == POINT_NPC){
    interactNpc(point);
    return;
  }

  if (point_kind[point] == POINT_COLLECT){
    advanceTaskStep(point);
    return;
  }

  completeTask(point);
}


/* The distribution panel repairs only when the matching item is held. */
boolean pointCompletesActiveTask(int point){
  return active_task != TASK_NONE && taskPointIsExpected(point)
    && taskItemAvailable(active_task);
}


void readPoint(int point){
  if (point == POINT_COMMAND_BRIEFING){
    openTaskConsole();
  } else if (point == POINT_ROUTE){
    openTechnical("ROTA", "DIA " + day + " DE " + trip_days
      + ". RESTAM " + max(0, trip_days - day) + " DIAS.");
  } else if (point == POINT_STATUS){
    openTechnical("STATUS DA NAVE", "MOTOR " + engineStateLabel()
      + ". ESTADOS: " + activeStateSummary() + ".");
  } else if (point == POINT_RESERVE){
    openTechnical("RESERVA", parts + " PEÇAS DISPONÍVEIS.");
  }
}


void switchPoint(int point){
  pending_switch_point = point;
  technical_open = true;

  if (point == POINT_DISTRIBUTION){
    technical_title = saving_on ? "DESATIVAR ECONOMIA" : "ATIVAR ECONOMIA";
    technical_text = saving_on
      ? "O CONSUMO VOLTA A 6 DE ENERGIA POR DIA."
      : "ENERGIA -3/DIA. CUSTO INICIAL: MORAL -5; DEPOIS -1/DIA.";
  } else {
    technical_title = rationing_on ? "DESATIVAR RACIONAMENTO" : "ATIVAR RACIONAMENTO";
    technical_text = rationing_on
      ? "ÁGUA E COMIDA VOLTAM AO CONSUMO NORMAL."
      : "ÁGUA -4 E COMIDA -3/DIA. CUSTO INICIAL: MORAL -8; DEPOIS -1/DIA.";
  }
}


void applySwitchPoint(){
  int point = pending_switch_point;
  pending_switch_point = -1;
  technical_open = false;

  if (point == POINT_DISTRIBUTION){
    toggleSaving();
  } else if (point == POINT_RATIONING){
    toggleRationing();
  }
}


void openTaskConsole(){
  if (action_used){
    openTechnical("BRIEFING", "A TAREFA DE HOJE JÁ FOI CONCLUÍDA.");
    return;
  }

  if (active_task != TASK_NONE){
    openTechnical("TAREFA ATIVA", taskStatusLabel());
    return;
  }

  task_choice_count = 0;

  for (int task = 0; task < TASK_COUNT; task++){
    if (taskIsAvailable(task) && taskCostAvailable(task)){
      task_choice_indices[task_choice_count++] = task;
    }
  }

  if (task_choice_count == 0){
    openTechnical("BRIEFING", "NENHUMA TAREFA PODE SER PAGA HOJE.");
    return;
  }

  task_choice_cursor = 0;
  task_choice_open = true;
  task_choice_last_frame = frameCount;
}


void interactNpc(int point){
  String name = point_label[point];

  if (active_task != TASK_NONE && taskPointIsExpected(point)){
    advanceTaskStep(point);
    openDialogue(name, "ENTENDIDO. " + taskNextInstruction());
    return;
  }

  if (active_task != TASK_NONE){
    openDialogue(name, "SUA PRIORIDADE É: " + taskNextInstruction());
    return;
  }

  openDialogue(name, npcIdleText(point));
}


String npcIdleText(int point){
  if (point == POINT_VERA){
    return "CONSULTE O CONSOLE DE BRIEFING PARA ESCOLHER A TAREFA DE HOJE.";
  }

  if (point == POINT_SILVIA){
    return "MOTOR E SISTEMAS DE ENERGIA SOB OBSERVAÇÃO.";
  }

  if (point == POINT_BENTO){
    return "ESTOQUE CONFERIDO. PEÇAS DISPONÍVEIS: " + parts + ".";
  }

  return "O GRUPO ESTÁ COM MORAL " + int(morale) + ".";
}


void beginTask(int task){
  if (action_used || active_task != TASK_NONE || !taskIsAvailable(task)
    || !taskCostAvailable(task)){
    return;
  }

  if (task == TASK_POWER && power_variant == POWER_VARIANT_NONE){
    drawPowerVariant();
  }

  active_task = task;
  task_step_index = 0;
  system_message = "TAREFA ACEITA: " + task_label[task] + ".";
}


void advanceTaskStep(int point){
  if (active_task == TASK_NONE || !taskPointIsExpected(point)){
    system_message = "ESSA INTERAÇÃO NÃO FAZ PARTE DA TAREFA ATUAL.";
    return;
  }

  int item = itemForStep(active_task, task_step_index);

  if (item != ITEM_NONE){
    held_item = item;
  }

  task_step_index++;
  system_message = item != ITEM_NONE
    ? "ITEM OBTIDO: " + heldItemLabel() + "."
    : "ETAPA CONCLUÍDA. " + taskNextInstruction();
}


int itemForStep(int task, int step){
  if (task == TASK_REPAIR_ENGINE && step == 1){
    return ITEM_ENGINE_PARTS;
  }

  if (task == TASK_REPAIR_HULL && step == 1){
    return ITEM_SEAL_KIT;
  }

  if (task == TASK_RESCUE_SURVIVOR && step == 0){
    return ITEM_WATER;
  }

  if (task == TASK_LIFE_SUPPORT && step == 1){
    return ITEM_ENGINE_PARTS;
  }

  if (task == TASK_COMMS && step == 1){
    return ITEM_SPARE_PART;
  }

  if (task == TASK_POWER && step == 1 && power_variant != POWER_VARIANT_NONE){
    return variant_item[power_variant];
  }

  return ITEM_NONE;
}


void completeTask(int point){
  if (action_used){
    system_message = "A TAREFA DO DIA JÁ FOI CONCLUÍDA.";
    return;
  }

  if (active_task == TASK_NONE || !taskPointIsExpected(point)){
    system_message = "ESSA NÃO É A AÇÃO ATUAL.";
    return;
  }

  if (!taskCostAvailable(active_task)){
    system_message = "RECURSO INSUFICIENTE.";
    return;
  }

  if (!taskItemAvailable(active_task)){
    system_message = "FALTA O ITEM NECESSÁRIO.";
    return;
  }

  int completed_task = active_task;
  consumeTaskCost(completed_task);
  applyTaskEffect(completed_task);
  action_used = true;
  held_item = ITEM_NONE;
  active_task = TASK_NONE;
  task_step_index = 0;
  system_message = task_label[completed_task] + ": " + task_effect[completed_task] + ".";
  clampResources();
  checkEndConditions();
}


boolean taskItemAvailable(int task){
  if (task == TASK_REPAIR_ENGINE || task == TASK_LIFE_SUPPORT){
    return held_item == ITEM_ENGINE_PARTS;
  }

  if (task == TASK_REPAIR_HULL){
    return held_item == ITEM_SEAL_KIT;
  }

  if (task == TASK_RESCUE_SURVIVOR){
    return held_item == ITEM_WATER;
  }

  if (task == TASK_COMMS){
    return held_item == ITEM_SPARE_PART;
  }

  if (task == TASK_POWER){
    return power_variant != POWER_VARIANT_NONE && held_item == variant_item[power_variant];
  }

  return true;
}


void consumeTaskCost(int task){
  if (task_cost_type[task] == COST_PARTS){
    parts -= task_cost_value[task];
  } else if (task_cost_type[task] == COST_ENERGY){
    energy -= task_cost_value[task];
  } else if (task_cost_type[task] == COST_WATER){
    water -= task_cost_value[task];
  }
}


void applyTaskEffect(int task){
  if (task == TASK_REPAIR_ENGINE){
    repairEngine();
  } else if (task == TASK_BOOST_ENGINE){
    boost_count++;
    trip_days = max(trip_days - 1, 1);
  } else if (task == TASK_REPAIR_HULL){
    leak_on = false;
  } else if (task == TASK_REST_CREW){
    morale += REST_MORALE_GAIN;
  } else if (task == TASK_RESCUE_SURVIVOR){
    morale += 10;
  } else if (task == TASK_LIFE_SUPPORT){
    life_support_emergency = false;
  } else if (task == TASK_POWER){
    power_fault_on = false;
    power_variant = POWER_VARIANT_NONE;
  } else if (task == TASK_COMMS){
    comms_silent = false;
  }
}


void updateTaskChoice(){
  if (frameCount - task_choice_last_frame >= 10){
    if (move_up_held || move_left_held){
      task_choice_cursor = (task_choice_cursor + task_choice_count - 1) % task_choice_count;
      task_choice_last_frame = frameCount;
    } else if (move_down_held || move_right_held){
      task_choice_cursor = (task_choice_cursor + 1) % task_choice_count;
      task_choice_last_frame = frameCount;
    }
  }

  if (interact_queued){
    interact_queued = false;
    int selected = task_choice_indices[task_choice_cursor];
    task_choice_open = false;
    beginTask(selected);
  }
}


void drawTaskChoice(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 20, 52, 600, 260, COL_CYAN);
  text(g, "CONSOLE DE BRIEFING", 36, 64, 16, COL_CYAN);

  for (int i = 0; i < task_choice_count; i++){
    int task = task_choice_indices[i];
    text(g, (i == task_choice_cursor ? "> " : "  ") + task_label[task],
      36, 94 + i * 20, 16, i == task_choice_cursor ? COL_CYAN : COL_TEXT);
  }

  int selected = task_choice_indices[task_choice_cursor];
  drawPanel(g, 318, 88, 286, 170, COL_BORDER);
  text(g, task_label[selected], 334, 102, 16, COL_ORANGE);
  text(g, "CUSTO: " + taskCostLabel(selected), 334, 132, 16, COL_TEXT);
  drawTextWrapped(g, "EFEITO: " + task_effect[selected], 334, 158, 254, 16, 18, COL_TEXT);
  drawTextWrapped(g, "ROTA: " + taskRouteLabel(selected), 334, 204, 254, 16, 18, COL_MUTED);
  text(g, "SETAS: ESCOLHER   E: ACEITAR   ESC: VOLTAR", 36, 278, 16, COL_MUTED);
}
