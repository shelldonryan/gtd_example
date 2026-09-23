
final int NIGHT_OUTCOME_ONGOING = 0;
final int NIGHT_OUTCOME_VICTORY = 1;
final int NIGHT_OUTCOME_DEFEAT = 2;


class NightSnapshot {
  String player_name;
  int day;
  int opened_day;
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
  boolean paused;
  boolean map_open;
  boolean dialog_open;
  boolean technical_open;
  boolean end_day_open;
  boolean help_open;
  boolean orders_open;
  int quest_review;
  int pending_quest_action;
  boolean engine_repaired_at_limit;
  boolean earth_loss_sent;
  boolean earth_engine_sent;
  boolean earth_hull_sent;
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
  int[] editorial_last_result = new int[CREW_COUNT];
  int[] editorial_last_result_day = new int[CREW_COUNT];
  int[] editorial_last_seen_day = new int[CREW_COUNT];
  boolean[] editorial_was_presented = new boolean[CREW_COUNT];
  int[] editorial_last_risk_day = new int[CREW_COUNT];
  boolean[] editorial_risk_was_presented = new boolean[CREW_COUNT];
  int[] editorial_conversation_count = new int[CREW_COUNT];

  NightSnapshot(){ }

  NightSnapshot(NightSnapshot source){
    player_name = source.player_name;
    day = source.day;
    opened_day = source.opened_day;
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
    paused = source.paused;
    map_open = source.map_open;
    dialog_open = source.dialog_open;
    technical_open = source.technical_open;
    end_day_open = source.end_day_open;
    help_open = source.help_open;
    orders_open = source.orders_open;
    quest_review = source.quest_review;
    pending_quest_action = source.pending_quest_action;
    engine_repaired_at_limit = source.engine_repaired_at_limit;
    earth_loss_sent = source.earth_loss_sent;
    earth_engine_sent = source.earth_engine_sent;
    earth_hull_sent = source.earth_hull_sent;
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
    arrayCopy(source.editorial_last_result, editorial_last_result);
    arrayCopy(source.editorial_last_result_day, editorial_last_result_day);
    arrayCopy(source.editorial_last_seen_day, editorial_last_seen_day);
    arrayCopy(source.editorial_was_presented, editorial_was_presented);
    arrayCopy(source.editorial_last_risk_day, editorial_last_risk_day);
    arrayCopy(source.editorial_risk_was_presented, editorial_risk_was_presented);
    arrayCopy(source.editorial_conversation_count, editorial_conversation_count);
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
  NightSnapshot source_state;
  NightSnapshot projected_state;
  String source_signature = "";
  String projected_signature = "";
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


NightProjection night_preview;


void invalidateNightPreview(){
  night_preview = null;
}


NightSnapshot captureNightSnapshot(){
  NightSnapshot snapshot = new NightSnapshot();
  snapshot.player_name = player_name;
  snapshot.day = day;
  snapshot.opened_day = opened_day;
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
  snapshot.paused = paused;
  snapshot.map_open = map_open;
  snapshot.dialog_open = dialog_open;
  snapshot.technical_open = technical_open;
  snapshot.end_day_open = end_day_open;
  snapshot.help_open = help_open;
  snapshot.orders_open = orders_open;
  snapshot.quest_review = quest_review;
  snapshot.pending_quest_action = pending_quest_action;
  snapshot.engine_repaired_at_limit = engine_repaired_at_limit;
  snapshot.earth_loss_sent = earth_loss_sent;
  snapshot.earth_engine_sent = earth_engine_sent;
  snapshot.earth_hull_sent = earth_hull_sent;
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
  if (editorial_last_result != null){
    arrayCopy(editorial_last_result, snapshot.editorial_last_result);
    arrayCopy(editorial_last_result_day, snapshot.editorial_last_result_day);
    arrayCopy(editorial_last_seen_day, snapshot.editorial_last_seen_day);
    arrayCopy(editorial_was_presented, snapshot.editorial_was_presented);
    arrayCopy(editorial_last_risk_day, snapshot.editorial_last_risk_day);
    arrayCopy(editorial_risk_was_presented, snapshot.editorial_risk_was_presented);
    arrayCopy(editorial_conversation_count, snapshot.editorial_conversation_count);
  }
  snapshot.game_outcome = screen == SCREEN_VICTORY ? NIGHT_OUTCOME_VICTORY
    : screen == SCREEN_GAME_OVER ? NIGHT_OUTCOME_DEFEAT : NIGHT_OUTCOME_ONGOING;
  return snapshot;
}


NightProjection simulateNightTransition(){
  NightSnapshot night_snapshot = captureNightSnapshot();
  return simulateNightTransition(night_snapshot);
}


NightProjection simulateNightTransition(NightSnapshot input){
  NightProjection night_projection = new NightProjection();
  NightSnapshot before = new NightSnapshot(input);
  NightSnapshot state = new NightSnapshot(input);
  night_projection.source_state = before;
  night_projection.source_signature = nightPreviewSignature(before);
  night_projection.projected_state = state;

  if (state.game_outcome != NIGHT_OUTCOME_ONGOING){
    night_projection.game_outcome = state.game_outcome;
    night_projection.game_over_reason = state.game_over_reason;
    calculateNightDeltas(night_projection, before);
    buildNightDisplay(night_projection);
    night_projection.projected_signature = nightProjectionSignature(night_projection);
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
  night_projection.projected_signature = nightProjectionSignature(night_projection);
  return night_projection;
}


NightProjection projectNight(){
  NightSnapshot current = captureNightSnapshot();
  String current_signature = nightPreviewSignature(current);
  if (night_preview != null && !night_preview.applied
    && night_preview.source_signature.equals(current_signature)){
    return night_preview;
  }

  night_preview = simulateNightTransition(current);
  return night_preview;
}


String nightSnapshotSignature(NightSnapshot state){
  return nightStateSignature(state, true);
}


String nightPreviewSignature(NightSnapshot state){
  return nightStateSignature(state, false);
}


String nightStateSignature(NightSnapshot state, boolean include_ui_state){
  String signature = state.player_name + "|";
  signature += state.day + "|" + state.opened_day + "|" + state.trip_days + "|";
  signature += state.energy + "|" + state.oxygen + "|" + state.water + "|";
  signature += state.food + "|" + state.morale + "|" + state.parts + "|";
  signature += state.engine_state + "|" + state.survivors + "|";
  signature += state.game_over_reason + "|" + state.screen + "|" + state.current_room + "|";
  signature += state.risk_history_count + "|" + state.problem_order_counter + "|";
  signature += state.event_index + "|" + state.selected_preventive_id + "|";
  signature += state.active_quest + "|" + state.quest_stage + "|" + state.held_item + "|";
  signature += state.quest_completed + "|" + state.preventive_committed + "|";
  signature += state.event_open + "|" + state.transmission_open + "|";
  if (include_ui_state){
    signature += state.paused + "|" + state.map_open + "|" + state.dialog_open + "|";
    signature += state.technical_open + "|" + state.end_day_open + "|";
    signature += state.help_open + "|" + state.orders_open + "|";
    signature += state.quest_review + "|" + state.pending_quest_action + "|";
  }
  signature += state.engine_repaired_at_limit + "|" + state.earth_loss_sent + "|";
  signature += state.earth_engine_sent + "|" + state.earth_hull_sent + "|";
  signature += state.transmission_text + "|" + state.system_message + "|";
  signature += state.game_outcome + "|";
  signature += nightIntArraySignature(state.incident_sequence);
  signature += nightIntArraySignature(state.daily_offers);
  signature += nightBooleanArraySignature(state.crew_alive);
  signature += nightIntArraySignature(state.crew_risk_deadline);
  signature += nightBooleanArraySignature(state.problem_active);
  signature += nightIntArraySignature(state.problem_deadline);
  signature += nightIntArraySignature(state.problem_activated_order);
  signature += nightIntArraySignature(state.problem_solution);
  signature += nightIntArraySignature(state.problem_room);
  signature += nightIntArraySignature(state.editorial_last_result);
  signature += nightIntArraySignature(state.editorial_last_result_day);
  signature += nightIntArraySignature(state.editorial_last_seen_day);
  signature += nightBooleanArraySignature(state.editorial_was_presented);
  signature += nightIntArraySignature(state.editorial_last_risk_day);
  signature += nightBooleanArraySignature(state.editorial_risk_was_presented);
  signature += nightIntArraySignature(state.editorial_conversation_count);
  return signature;
}


String nightIntArraySignature(int[] values){
  String signature = "[";
  for (int value : values) signature += value + ",";
  return signature + "]";
}


String nightBooleanArraySignature(boolean[] values){
  String signature = "[";
  for (boolean value : values) signature += value + ",";
  return signature + "]";
}


String nightStringArraySignature(String[] values){
  String signature = "[";
  for (String value : values){
    String safe = value == null ? "<null>" : value;
    signature += safe.length() + ":" + safe + ",";
  }
  return signature + "]";
}


String nightFloatArraySignature(float[] values){
  String signature = "[";
  for (float value : values) signature += value + ",";
  return signature + "]";
}


String nightProjectionSignature(NightProjection projection){
  String signature = nightPreviewSignature(projection.projected_state);
  signature += "|outcome=" + projection.game_outcome;
  signature += "|reason=" + projection.game_over_reason;
  signature += "|survivor_loss=" + projection.survivor_loss;
  signature += "|quest_summary=" + projection.quest_summary;
  signature += "|resource_a=" + projection.resource_line_a;
  signature += "|resource_b=" + projection.resource_line_b;
  signature += "|risk_line=" + projection.risk_line;
  signature += "|outcome_line=" + projection.outcome_line;
  signature += "|effects=" + nightStringArraySignature(projection.effects);
  signature += "|fatal=" + nightStringArraySignature(projection.fatal_conditions);
  signature += "|editorial_count=" + projection.editorial_result_count;
  signature += "|editorial_ids=" + nightIntArraySignature(projection.editorial_quest_ids);
  signature += "|editorial_results=" + nightIntArraySignature(projection.editorial_quest_results);
  if (projection.deltas != null){
    signature += "|delta_resources=" + nightFloatArraySignature(projection.deltas.resources);
    signature += "|delta_survivors=" + projection.deltas.survivors;
    signature += "|delta_engine=" + projection.deltas.engine_state;
    signature += "|delta_risk_deadlines="
      + nightIntArraySignature(projection.deltas.crew_risk_deadline);
    signature += "|delta_problem_deadlines="
      + nightIntArraySignature(projection.deltas.problem_deadline);
  }
  return signature;
}


void applyNightQuestConsequences(NightSnapshot state, NightProjection projection){
  boolean omitted_offers = !state.preventive_committed && state.daily_offers[0] >= 0;
  projection.quest_summary = nightQuestSummary(state);
  state.system_message = projection.quest_summary;
  if (projection.quest_summary.length() > 0){
    projection.effects = nightAppend(projection.effects, projection.quest_summary);
  }

  if (state.active_quest >= 0 && !state.quest_completed){
    addNightEditorialResult(projection, state.active_quest, EDITORIAL_RESULT_FAILURE);
    applyNightEditorialResult(state, state.active_quest, EDITORIAL_RESULT_FAILURE);
  }
  if (omitted_offers){
    for (int i = 0; i < state.daily_offers.length; i++){
      if (state.daily_offers[i] >= 0){
        addNightEditorialResult(projection, state.daily_offers[i], EDITORIAL_RESULT_OMISSION);
        applyNightEditorialResult(state, state.daily_offers[i], EDITORIAL_RESULT_OMISSION);
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
  if (!state.earth_loss_sent){
    state.earth_loss_sent = true;
    state.transmission_text = "TERRA: " + state.player_name
      + ", UMA VIDA FOI PERDIDA. LEVE OS OUTROS ATÉ MARTE.";
    state.transmission_open = true;
  }
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
    state.editorial_last_risk_day[crew] = state.day;
    state.editorial_risk_was_presented[crew] = false;
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


void applyNightEditorialResult(NightSnapshot state, int quest, int result){
  if (quest < 0 || quest >= quest_owner.length || result == EDITORIAL_RESULT_NONE) return;
  int crew = quest_owner[quest];
  if (crew < 0 || crew >= CREW_COUNT || !state.crew_alive[crew]) return;
  if (state.editorial_last_result_day[crew] == state.day
    && editorialResultPriority(state.editorial_last_result[crew]) >= editorialResultPriority(result)) return;
  state.editorial_last_result[crew] = result;
  state.editorial_last_result_day[crew] = state.day;
  state.editorial_last_seen_day[crew] = 0;
  state.editorial_was_presented[crew] = false;
}


boolean applyNightProjection(NightProjection projection){
  if (projection == null || projection.source_state == null || projection.projected_state == null
    || projection.applied) return false;

  NightSnapshot current = captureNightSnapshot();
  if (!projection.source_signature.equals(nightPreviewSignature(current))
    || !projection.projected_signature.equals(nightProjectionSignature(projection))){
    return false;
  }

  NightSnapshot state = projection.projected_state;

  day = state.day;
  opened_day = state.opened_day;
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
  paused = state.paused;
  map_open = state.map_open;
  dialog_open = state.dialog_open;
  technical_open = state.technical_open;
  end_day_open = state.end_day_open;
  help_open = state.help_open;
  orders_open = state.orders_open;
  quest_review = state.quest_review;
  pending_quest_action = state.pending_quest_action;
  transmission_text = state.transmission_text;
  engine_repaired_at_limit = state.engine_repaired_at_limit;
  earth_loss_sent = state.earth_loss_sent;
  earth_engine_sent = state.earth_engine_sent;
  earth_hull_sent = state.earth_hull_sent;
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
  arrayCopy(state.editorial_last_result, editorial_last_result);
  arrayCopy(state.editorial_last_result_day, editorial_last_result_day);
  arrayCopy(state.editorial_last_seen_day, editorial_last_seen_day);
  arrayCopy(state.editorial_was_presented, editorial_was_presented);
  arrayCopy(state.editorial_last_risk_day, editorial_last_risk_day);
  arrayCopy(state.editorial_risk_was_presented, editorial_risk_was_presented);
  arrayCopy(state.editorial_conversation_count, editorial_conversation_count);

  projection.applied = true;
  return true;
}
