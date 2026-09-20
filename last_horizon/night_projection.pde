/*
 * A noite é uma fronteira de estado: tudo até o fim dos efeitos noturnos é
 * calculado sobre uma cópia e só a confirmação do jogador escreve nos globais.
 * O arquivo não consulta random(), não abre modais e não toca na memória
 * editorial. Isso mantém o preview e a aplicação real no mesmo caminho.
 */

final int NIGHT_OUTCOME_ONGOING = 0;
final int NIGHT_OUTCOME_VICTORY = 1;
final int NIGHT_OUTCOME_DEFEAT = 2;


class NightSnapshot {
  int day;
  int trip_days;
  float energy;
  float oxygen;
  float water;
  float food;
  float morale;
  int parts;
  int engine_state;
  int survivors;
  int game_over_reason;
  int screen;
  int current_room;
  int risk_history_count;
  int problem_order_counter;
  int event_index;
  int selected_preventive_id;
  int active_quest;
  int quest_stage;
  int held_item;
  boolean quest_completed;
  boolean preventive_committed;
  boolean event_open;
  boolean transmission_open;
  boolean engine_repaired_at_limit;
  boolean earth_loss_sent;
  String transmission_text;
  String system_message;
  int[] incident_sequence = new int[5];
  int[] daily_offers = new int[2];
  boolean[] crew_alive = new boolean[CREW_COUNT];
  int[] crew_risk_deadline = new int[CREW_COUNT];
  boolean[] problem_active = new boolean[PROBLEM_COUNT];
  int[] problem_deadline = new int[PROBLEM_COUNT];
  int[] problem_activated_order = new int[PROBLEM_COUNT];
  int[] problem_solution = new int[PROBLEM_COUNT];
  int[] problem_room = new int[PROBLEM_COUNT];
  int game_outcome = NIGHT_OUTCOME_ONGOING;

  NightSnapshot(){ }

  NightSnapshot(NightSnapshot source){
    day = source.day;
    trip_days = source.trip_days;
    energy = source.energy;
    oxygen = source.oxygen;
    water = source.water;
    food = source.food;
    morale = source.morale;
    parts = source.parts;
    engine_state = source.engine_state;
    survivors = source.survivors;
    game_over_reason = source.game_over_reason;
    screen = source.screen;
    current_room = source.current_room;
    risk_history_count = source.risk_history_count;
    problem_order_counter = source.problem_order_counter;
    event_index = source.event_index;
    selected_preventive_id = source.selected_preventive_id;
    active_quest = source.active_quest;
    quest_stage = source.quest_stage;
    held_item = source.held_item;
    quest_completed = source.quest_completed;
    preventive_committed = source.preventive_committed;
    event_open = source.event_open;
    transmission_open = source.transmission_open;
    engine_repaired_at_limit = source.engine_repaired_at_limit;
    earth_loss_sent = source.earth_loss_sent;
    transmission_text = source.transmission_text;
    system_message = source.system_message;
    arrayCopy(source.incident_sequence, incident_sequence);
    arrayCopy(source.daily_offers, daily_offers);
    arrayCopy(source.crew_alive, crew_alive);
    arrayCopy(source.crew_risk_deadline, crew_risk_deadline);
    arrayCopy(source.problem_active, problem_active);
    arrayCopy(source.problem_deadline, problem_deadline);
    arrayCopy(source.problem_activated_order, problem_activated_order);
    arrayCopy(source.problem_solution, problem_solution);
    arrayCopy(source.problem_room, problem_room);
    game_outcome = source.game_outcome;
  }
}


class NightDeltas {
  float[] resources = new float[RESOURCE_PARTS + 1];
  int survivors;
  int engine_state;
  int[] crew_risk_deadline = new int[CREW_COUNT];
  int[] problem_deadline = new int[PROBLEM_COUNT];
}


class NightProjection {
  NightSnapshot projected_state;
  NightDeltas deltas;
  boolean applied;
  String[] effects = new String[0];
  String[] fatal_conditions = new String[0];
  int game_outcome = NIGHT_OUTCOME_ONGOING;
  int game_over_reason = REASON_NONE;
  String quest_summary = "";
  String resource_line_a = "";
  String resource_line_b = "";
  String risk_line = "";
  String outcome_line = "";
  boolean survivor_loss;
  int[] editorial_quest_ids = new int[3];
  int[] editorial_quest_results = new int[3];
  int editorial_result_count;
}


NightSnapshot captureNightSnapshot(){
  NightSnapshot snapshot = new NightSnapshot();
  snapshot.day = day;
  snapshot.trip_days = trip_days;
  snapshot.energy = energy;
  snapshot.oxygen = oxygen;
  snapshot.water = water;
  snapshot.food = food;
  snapshot.morale = morale;
  snapshot.parts = parts;
  snapshot.engine_state = engine_state;
  snapshot.survivors = survivors;
  snapshot.game_over_reason = game_over_reason;
  snapshot.screen = screen;
  snapshot.current_room = current_room;
  snapshot.risk_history_count = risk_history_count;
  snapshot.problem_order_counter = problem_order_counter;
  snapshot.event_index = event_index;
  snapshot.selected_preventive_id = selected_preventive_id;
  snapshot.active_quest = active_quest;
  snapshot.quest_stage = quest_stage;
  snapshot.held_item = held_item;
  snapshot.quest_completed = quest_completed;
  snapshot.preventive_committed = preventive_committed;
  snapshot.event_open = event_open;
  snapshot.transmission_open = transmission_open;
  snapshot.engine_repaired_at_limit = engine_repaired_at_limit;
  snapshot.earth_loss_sent = earth_loss_sent;
  snapshot.transmission_text = transmission_text;
  snapshot.system_message = system_message;
  arrayCopy(incident_sequence, snapshot.incident_sequence);
  arrayCopy(daily_offers, snapshot.daily_offers);
  arrayCopy(crew_alive, snapshot.crew_alive);
  arrayCopy(crew_risk_deadline, snapshot.crew_risk_deadline);
  arrayCopy(problem_active, snapshot.problem_active);
  arrayCopy(problem_deadline, snapshot.problem_deadline);
  arrayCopy(problem_activated_order, snapshot.problem_activated_order);
  arrayCopy(problem_solution, snapshot.problem_solution);
  arrayCopy(problem_room, snapshot.problem_room);
  snapshot.game_outcome = screen == SCREEN_VICTORY ? NIGHT_OUTCOME_VICTORY
    : screen == SCREEN_GAME_OVER ? NIGHT_OUTCOME_DEFEAT : NIGHT_OUTCOME_ONGOING;
  return snapshot;
}


/* Pure entry point used by both the preview and the confirmed transition. */
NightProjection simulateNightTransition(){
  NightSnapshot night_snapshot = captureNightSnapshot();
  return simulateNightTransition(night_snapshot);
}


NightProjection simulateNightTransition(NightSnapshot input){
  NightProjection night_projection = new NightProjection();
  NightSnapshot before = new NightSnapshot(input);
  NightSnapshot state = new NightSnapshot(input);
  night_projection.projected_state = state;

  if (state.game_outcome != NIGHT_OUTCOME_ONGOING){
    night_projection.game_outcome = state.game_outcome;
    night_projection.game_over_reason = state.game_over_reason;
    calculateNightDeltas(night_projection, before);
    buildNightDisplay(night_projection);
    return night_projection;
  }

  applyNightQuestConsequences(state, night_projection);
  applyNightConsumption(state, night_projection);
  applyNightProblemLosses(state, night_projection);
  applyNightRisk(state, night_projection);
  applyNightProblemDeadlines(state, night_projection);
  clampNightState(state);
  checkNightEndConditions(state, night_projection);
  calculateNightDeltas(night_projection, before);
  buildNightDisplay(night_projection);
  return night_projection;
}


/* The UI-facing adapter is intentionally only this pure simulation call. */
NightProjection projectNight(){
  NightProjection night_projection = simulateNightTransition();
  return night_projection;
}


void applyNightQuestConsequences(NightSnapshot state, NightProjection projection){
  boolean omitted_offers = !state.preventive_committed && state.daily_offers[0] >= 0;
  projection.quest_summary = nightQuestSummary(state);
  state.system_message = projection.quest_summary;

  if (state.active_quest >= 0 && !state.quest_completed){
    addNightEditorialResult(projection, state.active_quest, EDITORIAL_RESULT_FAILURE);
  }
  if (omitted_offers){
    for (int i = 0; i < state.daily_offers.length; i++){
      if (state.daily_offers[i] >= 0){
        addNightEditorialResult(projection, state.daily_offers[i], EDITORIAL_RESULT_OMISSION);
      }
    }
  }

  for (int resource = RESOURCE_ENERGY; resource <= RESOURCE_PARTS; resource++){
    payNightResource(state, resource, preventiveNightLoss(state, resource));
  }
  state.active_quest = -1;
  state.selected_preventive_id = -1;
  state.held_item = ITEM_NONE;
  state.quest_stage = 0;
}


int preventiveNightLoss(NightSnapshot state, int resource){
  if (state.preventive_committed){
    if (state.active_quest >= 0 && state.active_quest < PREVENTIVE_COUNT
      && preventive_resource[state.active_quest] == resource){
      return preventiveFailure(state.active_quest);
    }
    return 0;
  }
  int loss = 0;
  for (int q : state.daily_offers){
    if (q >= 0 && preventive_resource[q] == resource){
      loss = max(loss, preventiveNeglect(q));
    }
  }
  return loss;
}


String nightQuestSummary(NightSnapshot state){
  if (state.preventive_committed){
    if (state.quest_completed) return "ORDEM CONCLUÍDA. RECOMPENSA JÁ RECEBIDA.";
    if (state.active_quest >= 0 && state.active_quest < PREVENTIVE_COUNT){
      return "ORDEM NÃO CONCLUÍDA: -" + preventiveFailure(state.active_quest) + " "
        + resourceName(preventive_resource[state.active_quest]) + ". O OBJETO VOLTA À ORIGEM.";
    }
    return "ORDEM NÃO CONCLUÍDA.";
  }
  String result = state.active_quest >= PREVENTIVE_COUNT
    ? "SOLUÇÃO NÃO CONCLUÍDA. PROBLEMA PERMANECE ATIVO. " : "";
  if (state.daily_offers[0] >= 0){
    result += "NENHUMA ORDEM ACEITA: ";
    for (int i = 0; i < state.daily_offers.length; i++){
      int q = state.daily_offers[i];
      if (q >= 0){
        result += (i == 0 ? "" : " E ") + "-" + preventiveNeglect(q) + " "
          + resourceName(preventive_resource[q]);
      }
    }
  }
  return result.length() > 0 ? result : "QUEST DO DIA CONCLUÍDA.";
}


void applyNightConsumption(NightSnapshot state, NightProjection projection){
  payNightResource(state, RESOURCE_ENERGY, ENERGY_PER_DAY);
  payNightResource(state, RESOURCE_OXYGEN, OXYGEN_PER_DAY);
  payNightResource(state, RESOURCE_WATER, WATER_PER_DAY);
  payNightResource(state, RESOURCE_FOOD, FOOD_PER_DAY);
  payNightResource(state, RESOURCE_MORALE, MORALE_PER_DAY);
  projection.effects = nightAppend(projection.effects, "CONSUMO DIÁRIO APLICADO UMA VEZ.");
}


void applyNightProblemLosses(NightSnapshot state, NightProjection projection){
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (state.problem_active[problem]){
      payNightResource(state, problem_loss_resource[problem], problem_loss_value[problem]);
    }
  }
  if (activeProblemCount(state) > 0){
    projection.effects = nightAppend(projection.effects, "PERDAS DOS PROBLEMAS ATIVOS APLICADAS UMA VEZ.");
  }
}


void applyNightRisk(NightSnapshot state, NightProjection projection){
  int crew = urgentNightRisk(state);
  if (crew < 0) return;
  state.crew_risk_deadline[crew]--;
  if (state.crew_risk_deadline[crew] > 0) return;

  state.crew_risk_deadline[crew] = 0;
  state.crew_alive[crew] = false;
  state.survivors = max(0, state.survivors - 1);
  projection.survivor_loss = true;
  state.system_message = crew_name[crew] + " NÃO RESISTIU.";
  projection.effects = nightAppend(projection.effects, state.system_message);
}


void applyNightProblemDeadlines(NightSnapshot state, NightProjection projection){
  for (int order = 1; order <= state.problem_order_counter; order++){
    for (int problem = 0; problem < PROBLEM_COUNT; problem++){
      if (!state.problem_active[problem] || state.problem_activated_order[problem] != order) continue;
      state.problem_deadline[problem]--;
      if (state.problem_deadline[problem] <= 0){
        applyNightCrisis(state, projection, problem);
      }
    }
  }
}


void applyNightCrisis(NightSnapshot state, NightProjection projection, int problem){
  if (problem == PROBLEM_ENGINE) state.engine_state = ENGINE_DESTROYED;
  else if (problem == PROBLEM_HULL) payNightResource(state, RESOURCE_OXYGEN, 12);
  else if (problem == PROBLEM_FOOD) payNightResource(state, RESOURCE_FOOD, 8);
  else if (problem == PROBLEM_CONFLICT || problem == PROBLEM_COMMS)
    payNightResource(state, RESOURCE_MORALE, 8);
  else if (problem == PROBLEM_LIFE_SUPPORT) payNightResource(state, RESOURCE_OXYGEN, 10);
  else if (problem == PROBLEM_POWER) payNightResource(state, RESOURCE_ENERGY, 10);

  if (problem == PROBLEM_FOOD || problem == PROBLEM_CONFLICT || problem == PROBLEM_LIFE_SUPPORT){
    putNightSurvivorAtRisk(state, problem, projection);
  }
  state.problem_deadline[problem] = problem == PROBLEM_ENGINE ? 0 : 2;
  state.system_message = "CRISE: " + problem_crisis[problem] + ".";
  projection.effects = nightAppend(projection.effects, state.system_message);
}


void putNightSurvivorAtRisk(NightSnapshot state, int source_problem, NightProjection projection){
  if (urgentNightRisk(state) >= 0 || state.survivors <= 0) return;
  int slot = state.risk_history_count % state.survivors;
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (!state.crew_alive[crew]) continue;
    if (slot-- != 0) continue;
    state.crew_risk_deadline[crew] = 2;
    state.risk_history_count++;
    projection.effects = nightAppend(projection.effects,
      crew_name[crew] + " ENTROU EM RISCO (" + problem_short[source_problem] + ").");
    return;
  }
}


int urgentNightRisk(NightSnapshot state){
  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (state.crew_alive[crew] && state.crew_risk_deadline[crew] > 0) return crew;
  }
  return -1;
}


int activeProblemCount(NightSnapshot state){
  int count = 0;
  for (boolean active : state.problem_active) if (active) count++;
  return count;
}


void payNightResource(NightSnapshot state, int resource, int amount){
  if (resource == RESOURCE_ENERGY) state.energy -= amount;
  else if (resource == RESOURCE_OXYGEN) state.oxygen -= amount;
  else if (resource == RESOURCE_WATER) state.water -= amount;
  else if (resource == RESOURCE_FOOD) state.food -= amount;
  else if (resource == RESOURCE_MORALE) state.morale -= amount;
  else if (resource == RESOURCE_PARTS) state.parts -= amount;
}


void clampNightState(NightSnapshot state){
  state.energy = constrain(state.energy, 0, RESOURCE_MAX);
  state.oxygen = constrain(state.oxygen, 0, RESOURCE_MAX);
  state.water = constrain(state.water, 0, RESOURCE_MAX);
  state.food = constrain(state.food, 0, RESOURCE_MAX);
  state.morale = constrain(state.morale, 0, RESOURCE_MAX);
  state.parts = max(state.parts, 0);
}


void checkNightEndConditions(NightSnapshot state, NightProjection projection){
  state.game_over_reason = REASON_NONE;
  addNightFatalCondition(state.energy <= 0, projection, "energia chegou a zero", REASON_ENERGY);
  addNightFatalCondition(state.oxygen <= 0, projection, "oxigênio chegou a zero", REASON_OXYGEN);
  addNightFatalCondition(state.morale <= 0, projection, "moral chegou a zero", REASON_MORALE);
  addNightFatalCondition(state.engine_state == ENGINE_DESTROYED, projection, "motor destruído", REASON_ENGINE);
  addNightFatalCondition(state.survivors <= 0, projection, "nenhum sobrevivente vivo", REASON_CREW);

  if (projection.fatal_conditions.length > 0){
    projection.game_outcome = NIGHT_OUTCOME_DEFEAT;
    state.game_over_reason = projection.game_over_reason;
    state.game_outcome = NIGHT_OUTCOME_DEFEAT;
    return;
  }

  if (state.day >= state.trip_days){
    projection.game_outcome = NIGHT_OUTCOME_VICTORY;
    projection.game_over_reason = REASON_NONE;
    state.game_outcome = NIGHT_OUTCOME_VICTORY;
    projection.effects = nightAppend(projection.effects, "A NOITE FINALIZOU A VIAGEM.");
  } else {
    projection.game_outcome = NIGHT_OUTCOME_ONGOING;
    projection.game_over_reason = REASON_NONE;
    state.game_outcome = NIGHT_OUTCOME_ONGOING;
  }
}


void addNightFatalCondition(boolean condition, NightProjection projection, String message, int reason){
  if (!condition) return;
  projection.fatal_conditions = nightAppend(projection.fatal_conditions, message);
  if (projection.game_over_reason == REASON_NONE){
    projection.game_over_reason = reason;
  }
}


void calculateNightDeltas(NightProjection projection, NightSnapshot before){
  NightSnapshot after = projection.projected_state;
  NightDeltas deltas = new NightDeltas();
  deltas.resources[RESOURCE_ENERGY] = after.energy - before.energy;
  deltas.resources[RESOURCE_OXYGEN] = after.oxygen - before.oxygen;
  deltas.resources[RESOURCE_WATER] = after.water - before.water;
  deltas.resources[RESOURCE_FOOD] = after.food - before.food;
  deltas.resources[RESOURCE_MORALE] = after.morale - before.morale;
  deltas.resources[RESOURCE_PARTS] = after.parts - before.parts;
  deltas.survivors = after.survivors - before.survivors;
  deltas.engine_state = after.engine_state;
  arrayCopy(after.crew_risk_deadline, deltas.crew_risk_deadline);
  arrayCopy(after.problem_deadline, deltas.problem_deadline);
  projection.deltas = deltas;
}


void buildNightDisplay(NightProjection projection){
  NightSnapshot state = projection.projected_state;
  NightDeltas deltas = projection.deltas;
  projection.resource_line_a = "ENERGIA " + nightValueDelta(state.energy, deltas.resources[RESOURCE_ENERGY])
    + " | OXIGÊNIO " + nightValueDelta(state.oxygen, deltas.resources[RESOURCE_OXYGEN])
    + " | ÁGUA " + nightValueDelta(state.water, deltas.resources[RESOURCE_WATER]);
  projection.resource_line_b = "COMIDA " + nightValueDelta(state.food, deltas.resources[RESOURCE_FOOD])
    + " | MORAL " + nightValueDelta(state.morale, deltas.resources[RESOURCE_MORALE])
    + " | PEÇAS " + nightValueDelta(state.parts, deltas.resources[RESOURCE_PARTS]);
  if (urgentNightRisk(state) >= 0){
    int crew = urgentNightRisk(state);
    projection.risk_line = crew_name[crew] + " EM RISCO — " + state.crew_risk_deadline[crew] + " NOITE(S)";
  } else if (deltas.survivors < 0){
    projection.risk_line = "UMA PESSOA NÃO RESISTIU. SOBREVIVENTES: " + state.survivors;
  } else {
    projection.risk_line = "SEM RISCO INDIVIDUAL APÓS A NOITE";
  }
  projection.outcome_line = projection.game_outcome == NIGHT_OUTCOME_VICTORY
    ? "VITÓRIA — A NAVE CHEGA A MARTE."
    : projection.game_outcome == NIGHT_OUTCOME_DEFEAT
    ? "DERROTA — " + nightReasonLabel(projection.game_over_reason) + "."
    : "DIA " + state.day + " TERMINA SEM DESFECHO.";
}


String nightValueDelta(float value, float delta){
  String sign = delta > 0 ? "+" : "";
  return sign + str(int(delta)) + " → " + str(int(value));
}


String nightReasonLabel(int reason){
  if (reason == REASON_ENERGY) return "energia chegou a zero";
  if (reason == REASON_OXYGEN) return "oxigênio chegou a zero";
  if (reason == REASON_MORALE) return "moral chegou a zero";
  if (reason == REASON_ENGINE) return "motor destruído";
  if (reason == REASON_CREW) return "nenhum sobrevivente vivo";
  return "condição fatal";
}


String[] nightAppend(String[] values, String value){
  String[] next = new String[values.length + 1];
  arrayCopy(values, next);
  next[values.length] = value;
  return next;
}


void addNightEditorialResult(NightProjection projection, int quest, int result){
  if (projection.editorial_result_count >= projection.editorial_quest_ids.length) return;
  projection.editorial_quest_ids[projection.editorial_result_count] = quest;
  projection.editorial_quest_results[projection.editorial_result_count] = result;
  projection.editorial_result_count++;
}


void applyNightProjection(NightProjection projection){
  if (projection == null || projection.projected_state == null || projection.applied) return;
  NightSnapshot state = projection.projected_state;

  boolean[] new_risk = new boolean[CREW_COUNT];
  for (int crew = 0; crew < CREW_COUNT; crew++){
    new_risk[crew] = crew_risk_deadline[crew] <= 0 && state.crew_risk_deadline[crew] > 0;
  }

  day = state.day;
  trip_days = state.trip_days;
  energy = state.energy;
  oxygen = state.oxygen;
  water = state.water;
  food = state.food;
  morale = state.morale;
  parts = state.parts;
  engine_state = state.engine_state;
  survivors = state.survivors;
  game_over_reason = projection.game_over_reason;
  screen = state.screen;
  current_room = state.current_room;
  risk_history_count = state.risk_history_count;
  problem_order_counter = state.problem_order_counter;
  event_index = state.event_index;
  selected_preventive_id = state.selected_preventive_id;
  active_quest = state.active_quest;
  quest_stage = state.quest_stage;
  held_item = state.held_item;
  quest_completed = state.quest_completed;
  preventive_committed = state.preventive_committed;
  event_open = state.event_open;
  transmission_open = state.transmission_open;
  transmission_text = state.transmission_text;
  engine_repaired_at_limit = state.engine_repaired_at_limit;
  earth_loss_sent = state.earth_loss_sent;
  system_message = state.system_message;
  arrayCopy(state.incident_sequence, incident_sequence);
  arrayCopy(state.daily_offers, daily_offers);
  arrayCopy(state.crew_alive, crew_alive);
  arrayCopy(state.crew_risk_deadline, crew_risk_deadline);
  arrayCopy(state.problem_active, problem_active);
  arrayCopy(state.problem_deadline, problem_deadline);
  arrayCopy(state.problem_activated_order, problem_activated_order);
  arrayCopy(state.problem_solution, problem_solution);
  arrayCopy(state.problem_room, problem_room);

  for (int crew = 0; crew < CREW_COUNT; crew++){
    if (new_risk[crew]) recordEditorialRisk(crew);
  }
  for (int i = 0; i < projection.editorial_result_count; i++){
    recordEditorialResult(projection.editorial_quest_ids[i], projection.editorial_quest_results[i]);
  }

  if (projection.survivor_loss && !earth_loss_sent){
    earth_loss_sent = true;
    openTransmission("TERRA: " + player_name + ", UMA VIDA FOI PERDIDA. LEVE OS OUTROS ATÉ MARTE.");
  }

  projection.applied = true;
}
