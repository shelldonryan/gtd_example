/* tasks - tabela declarativa e despachante de efeitos (interface/ROOMS.md) */

final int TASK_NONE = -1;
final int TASK_REPAIR_ENGINE = 0;
final int TASK_BOOST_ENGINE = 1;
final int TASK_REPAIR_HULL = 2;
final int TASK_REST_CREW = 3;
final int TASK_RESCUE_SURVIVOR = 4;
final int TASK_COUNT = 5;

final int GATE_ENGINE_DAMAGED = 0;
final int GATE_BOOST_AVAILABLE = 1;
final int GATE_HULL_LEAK = 2;
final int GATE_ALWAYS = 3;
final int GATE_RESOURCE_RED = 4;

final int COST_NONE = 0;
final int COST_PARTS = 1;
final int COST_ENERGY = 2;
final int COST_WATER = 3;

String[] task_label = {
  "REPARAR MOTOR",
  "AUMENTAR POTENCIA",
  "REPARAR CASCO",
  "DESCANSO E ORGANIZAÇÃO",
  "SOCORRER SOBREVIVENTE"
};

int[] task_gate = {
  GATE_ENGINE_DAMAGED,
  GATE_BOOST_AVAILABLE,
  GATE_HULL_LEAK,
  GATE_ALWAYS,
  GATE_RESOURCE_RED
};

int[] task_completion_room = {
  SCREEN_ENERGY,
  SCREEN_ENERGY,
  SCREEN_DEPOT,
  SCREEN_DORMITORY,
  SCREEN_DORMITORY
};

int[] task_completion_point = {
  POINT_ENGINE_BENCH,
  POINT_REACTOR,
  POINT_HULL,
  POINT_COMMON_TABLE,
  POINT_BUNK
};

int[] task_cost_type = {
  COST_PARTS,
  COST_ENERGY,
  COST_PARTS,
  COST_ENERGY,
  COST_WATER
};

int[] task_cost_value = {
  2,
  20,
  1,
  8,
  5
};

String[] task_effect = {
  "MOTOR VOLTA A OPERANTE",
  "VIAGEM ENCURTA 1 DIA",
  "VAZAMENTO ESTANCADO",
  "MORAL +15",
  "MORAL +10"
};

int[] task_step_count = {2, 1, 2, 1, 1};

int[][] task_step_room = {
  {SCREEN_ENERGY, SCREEN_DEPOT},
  {SCREEN_COMMAND},
  {SCREEN_DORMITORY, SCREEN_DEPOT},
  {SCREEN_DORMITORY},
  {SCREEN_DEPOT}
};

int[][] task_step_point = {
  {POINT_SILVIA, POINT_BENTO},
  {POINT_VERA},
  {POINT_NEUSA, POINT_SEAL_KIT},
  {POINT_NEUSA},
  {POINT_BENTO}
};

String[][] task_step_label = {
  {"DIAGNÓSTICO DA SÍLVIA", "PEÇAS DO BENTO"},
  {"ROTA RECALCULADA PELA VERA"},
  {"VAZAMENTO APONTADO PELA NEUSA", "KIT DE VEDAÇÃO"},
  {"SITUAÇÃO DO GRUPO COM A NEUSA"},
  {"ÁGUA LIBERADA PELO BENTO"}
};

int active_task = TASK_NONE;
int task_step_index = 0;
int task_choice_last_frame = -30;


void resetTaskState(){
  active_task = TASK_NONE;
  task_step_index = 0;
  task_choice_open = false;
  task_choice_cursor = 0;
  task_choice_count = 0;
  task_choice_last_frame = -30;
  first_interaction_done = false;
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

  return true;
}


boolean taskCostAvailable(int task){
  if (task_cost_type[task] == COST_PARTS){
    return parts >= task_cost_value[task];
  }

  if (task_cost_type[task] == COST_ENERGY){
    return energy >= task_cost_value[task];
  }

  if (task_cost_type[task] == COST_WATER){
    return water >= task_cost_value[task];
  }

  return true;
}


int suggestedTask(){
  if (taskIsAvailable(TASK_REPAIR_ENGINE)){
    return TASK_REPAIR_ENGINE;
  }

  if (taskIsAvailable(TASK_REPAIR_HULL)){
    return TASK_REPAIR_HULL;
  }

  if (taskIsAvailable(TASK_RESCUE_SURVIVOR)){
    return TASK_RESCUE_SURVIVOR;
  }

  if (taskIsAvailable(TASK_REST_CREW)){
    return TASK_REST_CREW;
  }

  return TASK_BOOST_ENGINE;
}


String taskStatusLabel(){
  if (active_task == TASK_NONE){
    return "NENHUMA TAREFA ATIVA";
  }

  if (task_step_index < task_step_count[active_task]){
    return task_label[active_task] + " | PASSO " + (task_step_index + 1)
      + "/" + task_step_count[active_task];
  }

  return task_label[active_task] + " | IR AO PONTO FINAL";
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

  return "NADA";
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
  first_interaction_done = true;
  if (point_kind[point] == POINT_READ){
    readPoint(point);
    return;
  }

  if (point_kind[point] == POINT_SWITCH){
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


void readPoint(int point){
  if (point == POINT_COMMAND_BRIEFING){
    int suggestion = suggestedTask();
    system_message = "BRIEFING: SUGESTÃO - " + task_label[suggestion] + ".";
  } else if (point == POINT_ROUTE){
    system_message = "ROTA: DIA " + day + " DE " + trip_days + ".";
  } else if (point == POINT_STATUS){
    system_message = "STATUS: MOTOR " + engineStateLabel() + ".";
  } else if (point == POINT_RESERVE){
    system_message = "RESERVA: " + parts + " PEÇAS DISPONÍVEIS.";
  }
}


void switchPoint(int point){
  if (point == POINT_SAVING){
    toggleSaving();
  } else if (point == POINT_RATIONING){
    toggleRationing();
  }
}


void interactNpc(int point){
  if (active_task != TASK_NONE && taskPointIsExpected(point)){
    advanceTaskStep(point);
    return;
  }

  if (active_task != TASK_NONE){
    system_message = "TAREFA: " + taskStatusLabel() + ".";
    return;
  }

  task_choice_count = 0;

  for (int task = 0; task < TASK_COUNT; task++){
    if (!taskIsAvailable(task) || task_step_room[task][0] != screen
      || task_step_point[task][0] != point){
      continue;
    }

    task_choice_indices[task_choice_count] = task;
    task_choice_count++;
  }

  if (task_choice_count == 0){
    system_message = "NENHUMA TAREFA DISPONÍVEL AQUI.";
    return;
  }

  if (task_choice_count == 1){
    beginTask(task_choice_indices[0]);
    return;
  }

  task_choice_cursor = 0;
  task_choice_open = true;
  task_choice_last_frame = frameCount;
}


void beginTask(int task){
  if (!taskIsAvailable(task)){
    return;
  }

  active_task = task;
  task_step_index = 0;
  system_message = "TAREFA INICIADA: " + task_label[task] + ".";
  advanceTaskStep(task_step_point[task][0]);
}


void advanceTaskStep(int point){
  if (active_task == TASK_NONE || !taskPointIsExpected(point)){
    system_message = "ESTAÇÃO FORA DA TAREFA ATUAL.";
    return;
  }

  int item = itemForStep(active_task, task_step_index);

  if (item != ITEM_NONE){
    held_item = item;
  }

  task_step_index++;

  if (task_step_index >= task_step_count[active_task]){
    system_message = "PASSOS LIVRES CONCLUÍDOS: " + task_label[active_task]
      + ". VÁ AO PONTO FINAL.";
  } else {
    system_message = "PASSO CONCLUÍDO: " + task_step_label[active_task][task_step_index - 1]
      + ".";
  }
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

  return ITEM_NONE;
}


void completeTask(int point){
  if (active_task == TASK_NONE || !taskPointIsExpected(point)){
    system_message = "NENHUMA TAREFA PRONTA PARA CONCLUIR.";
    return;
  }

  if (!taskCostAvailable(active_task)){
    system_message = "RECURSO INSUFICIENTE PARA CONCLUIR.";
    return;
  }

  if (!taskItemAvailable(active_task)){
    system_message = "ITEM ERRADO NA MÃO DO TÉCNICO.";
    return;
  }

  consumeTaskCost(active_task);
  applyTaskEffect(active_task);
  action_used = true;
  system_message = "TAREFA CONCLUÍDA: " + task_label[active_task] + " - "
    + task_effect[active_task] + ".";
  held_item = ITEM_NONE;
  active_task = TASK_NONE;
  task_step_index = 0;
  clampResources();
  checkEndConditions();
}


boolean taskItemAvailable(int task){
  if (task == TASK_REPAIR_ENGINE){
    return held_item == ITEM_ENGINE_PARTS;
  }

  if (task == TASK_REPAIR_HULL){
    return held_item == ITEM_SEAL_KIT;
  }

  if (task == TASK_RESCUE_SURVIVOR){
    return held_item == ITEM_WATER;
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
  drawPanel(g, 40, 98, 390, 120, COL_CYAN);
  g.fill(COL_CYAN);
  g.textSize(12);
  g.text("ESCOLHA A TAREFA", 56, 108);

  for (int i = 0; i < task_choice_count; i++){
    int task = task_choice_indices[i];
    g.fill(i == task_choice_cursor ? COL_CYAN : COL_TEXT);
    g.textSize(10);
    g.text((i == task_choice_cursor ? "> " : "  ") + task_label[task], 62, 132 + i * 18);
  }

  g.fill(COL_MUTED);
  g.textSize(10);
  g.text("SETAS: ESCOLHER   E: CONFIRMAR", 56, 202);
}
