final int ROOM_COUNT = 4;
final float MAP_ROOM_Y = 88;
final float MAP_ROOM_W = 120;
final float MAP_ROOM_H = 72;

String[] room_label = {"COMANDO", "MÁQUINAS", "DEPÓSITO", "DORMITÓRIO"};
float[] room_x = {60, 184, 308, 432};
int[] room_screen = {SCREEN_COMMAND, SCREEN_MACHINES, SCREEN_DEPOT, SCREEN_DORMITORY};
int[] room_action = {
  ACTION_INSPECT_COMMAND, ACTION_INSPECT_MACHINES,
  ACTION_INSPECT_DEPOT, ACTION_INSPECT_DORMITORY
};

final int DECK_COUNT = 3;
float[] deck_y = {128, 202, 278};
final int LADDER_COUNT = 2;
float[] ladder_x = {190, 445};

final int POINT_READ = 0;
final int POINT_COLLECT = 1;
final int POINT_NPC = 2;
final int POINT_SWITCH = 3;
final int POINT_COMPLETE = 4;
final int POINT_END_DAY = 5;

final int POINT_VERA = 0;
final int POINT_ROUTE = 1;
final int POINT_STATUS = 2;
final int POINT_ANTENNA = 3;
final int POINT_ENGINE_BENCH = 4;
final int POINT_SILVIA = 5;
final int POINT_DISTRIBUTION = 6;
final int POINT_REACTOR = 7;
final int POINT_LIFE_SUPPORT = 8;
final int POINT_SEAL_KIT = 9;
final int POINT_FUSE = 10;
final int POINT_BENTO = 11;
final int POINT_RATIONING = 12;
final int POINT_RESERVE = 13;
final int POINT_STOCK = 14;
final int POINT_RISK_BUNK = 15;
final int POINT_NEUSA = 16;
final int POINT_CONFLICT = 17;
final int POINT_COMMON_TABLE = 18;
final int POINT_TECH_BUNK = 19;
final int POINT_HULL = 20;
final int POINT_COUNT = 21;

int[] point_room = {
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND,
  SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_MACHINES,
  SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT,
  SCREEN_DORMITORY, SCREEN_DORMITORY, SCREEN_DORMITORY, SCREEN_DORMITORY,
  SCREEN_DORMITORY, SCREEN_NONE
};

float[] point_x = {
  540, 260, 100, 400,
  90, 540, 90, 520, 80,
  80, 150, 310, 220, 510, 420,
  100, 330, 470, 500, 120, 530
};

float[] point_y = {
  128, 202, 278, 128,
  278, 202, 202, 128, 128,
  278, 278, 202, 202, 128, 128,
  278, 202, 202, 128, 128, 278
};

String[] point_label = {
  "VERA", "ROTA", "SITUAÇÃO", "ANTENA",
  "BANCADA", "SÍLVIA", "DISTRIBUIÇÃO", "REATOR", "SUPORTE",
  "KIT", "FUSÍVEL", "BENTO", "RACIONAMENTO", "RESERVA", "ESTOQUE",
  "SOCORRO", "NEUSA", "CONFLITO", "MESA COMUM", "SEU BELICHE", "CASCO"
};

int[] point_kind = {
  POINT_NPC, POINT_COMPLETE, POINT_READ, POINT_COMPLETE,
  POINT_COMPLETE, POINT_NPC, POINT_SWITCH, POINT_READ, POINT_COMPLETE,
  POINT_COLLECT, POINT_COLLECT, POINT_NPC, POINT_SWITCH, POINT_READ, POINT_COMPLETE,
  POINT_COMPLETE, POINT_NPC, POINT_COMPLETE, POINT_COMPLETE, POINT_END_DAY,
  POINT_COMPLETE
};


void placeHullDamage(){
  int hull_room = room_screen[int(random(ROOM_COUNT))];
  int available_slots = 0;

  for (int deck = 0; deck < DECK_COUNT; deck++){
    for (float x = ROOM_LEFT + 40; x <= ROOM_RIGHT - 40; x += 32){
      if (hullPointClear(hull_room, deck_y[deck], x)){
        available_slots++;
      }
    }
  }

  int selected_slot = int(random(available_slots));

  for (int deck = 0; deck < DECK_COUNT; deck++){
    for (float x = ROOM_LEFT + 40; x <= ROOM_RIGHT - 40; x += 32){
      if (!hullPointClear(hull_room, deck_y[deck], x)){
        continue;
      }

      if (selected_slot == 0){
        point_room[POINT_HULL] = hull_room;
        point_x[POINT_HULL] = x;
        point_y[POINT_HULL] = deck_y[deck];
        return;
      }

      selected_slot--;
    }
  }
}


void clearHullDamage(){
  point_room[POINT_HULL] = SCREEN_NONE;
}


boolean hullPointClear(int room, float y, float x){
  for (int point = 0; point < POINT_COUNT; point++){
    if (point == POINT_HULL || point_room[point] != room
      || abs(point_y[point] - y) > 3){
      continue;
    }

    if (abs(point_x[point] - x) <= INTERACTION_RANGE * 2){
      return false;
    }
  }

  return true;
}


void drawShipArea(PGraphics g){
  g.noStroke();
  g.fill(COL_ROOM);
  g.rect(0, ROOM_TOP, BASE_W, OBJECTIVE_Y - ROOM_TOP);
  drawStars(g);
  drawRoom(g);
}


void drawMapOverlay(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 34, 44, 572, 282, COL_CYAN);
  text(g, "MAPA DA NAVE", 50, 54, 16, COL_CYAN);
  text(g, "CLIQUE PARA CONSULTAR. O MAPA NÃO MOVE O TÉCNICO.", 50, 74, 16, COL_MUTED);

  for (int i = 0; i < ROOM_COUNT; i++){
    drawMapRoomCard(g, i);
  }

  drawMapRoomDetails(g);
  drawButton(g, 478, 296, 124, 22, "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
}




void drawMapRoomCard(PGraphics g, int index){
  boolean hover = uiLayer() == LAYER_MODAL
    && isHovering(room_x[index], MAP_ROOM_Y, MAP_ROOM_W, MAP_ROOM_H);
  boolean selected = map_selected_room == index;
  int border = selected ? COL_CYAN : (hover ? COL_CYAN : COL_BORDER);

  drawPanel(g, room_x[index], MAP_ROOM_Y, MAP_ROOM_W, MAP_ROOM_H, border);
  textCentered(g, room_label[index], room_x[index] + MAP_ROOM_W / 2.0,
    MAP_ROOM_Y + 8, 16, selected ? COL_CYAN : COL_TEXT);
  textCentered(g, roomProblemCount(room_screen[index]) + " PROBLEMA(S)",
    room_x[index] + MAP_ROOM_W / 2.0, MAP_ROOM_Y + 28, 16, COL_MUTED);

  if (room_screen[index] == screen){
    textCentered(g, "VOCÊ ESTÁ AQUI", room_x[index] + MAP_ROOM_W / 2.0,
      MAP_ROOM_Y + 48, 16, COL_ORANGE);
  }

  addButton(room_x[index], MAP_ROOM_Y, MAP_ROOM_W, MAP_ROOM_H,
    room_action[index], true);
}
int roomIndex(int room_id){
  for (int i = 0; i < ROOM_COUNT; i++){
    if (room_screen[i] == room_id){
      return i;
    }
  }

  return 0;
}


void drawMapRoomDetails(PGraphics g){
  int index = constrain(map_selected_room, 0, ROOM_COUNT - 1);
  int selected_room = room_screen[index];
  String detail = roomOccupant(index) + " | " + roomSystems(index);
  if (selected_room == screen) detail += " | VOCÊ ESTÁ AQUI";
  text(g, detail, 50, 172, 16, COL_TEXT);
  text(g, "PROBLEMAS: PERDA POR DIA, PRAZO E CRISE", 50, 194, 16, COL_MUTED);

  float y = 212;
  int shown = 0;
  for (int problem = 0; problem < PROBLEM_COUNT; problem++){
    if (!problem_active[problem] || problem_room[problem] != selected_room) continue;
    if (y + 36 > 296){
      text(g, "E MAIS " + (roomProblemCount(selected_room) - shown) + " PROBLEMA(S).",
        50, y, 16, COL_MUTED);
      break;
    }
    y = drawTextWrapped(g, problemMapLine(problem), 50, y, 420, 16, 18, COL_TEXT);
    shown++;
  }
  if (shown == 0) text(g, "SEM PROBLEMAS ATIVOS.", 50, y, 16, COL_MUTED);
}


String roomOccupant(int index){
  String[] occupants = {"VERA", "SÍLVIA", "BENTO", "NEUSA"};
  return occupants[index];
}


String roomSystems(int index){
  String[] systems = {"ROTA E COMUNICAÇÕES", "MOTOR, ENERGIA E SUPORTE",
    "ESTOQUES E COMPONENTES", "DESCANSO, SAÚDE E MORAL"};
  return systems[index];
}


void drawRoom(PGraphics g){
  drawBackdrop(g, ROOM_LEFT, ROOM_TOP, ROOM_RIGHT - ROOM_LEFT, ROOM_BOTTOM - ROOM_TOP);
  drawRoomTitle(g);
  drawDecks(g);
  drawLadders(g);
  drawDoors(g);

  for (int i = 0; i < POINT_COUNT; i++){
    if (point_room[i] == screen){
      drawRoomPoint(g, i);
    }
  }

  drawPlayer(g);
  drawHeldItem(g);
}


void drawRoomTitle(PGraphics g){
  String title = roomTitle(screen);
  text(g, title, ROOM_LEFT + 10, ROOM_TOP + 6, 16, COL_CYAN);
}


String roomTitle(int room_screen){
  if (room_screen == SCREEN_COMMAND) return "SALA DE COMANDO";
  if (room_screen == SCREEN_MACHINES) return "SALA DE MÁQUINAS";
  if (room_screen == SCREEN_DEPOT) return "DEPÓSITO";
  return "DORMITÓRIO";
}



void drawDecks(PGraphics g){
  g.stroke(COL_BORDER);
  g.strokeWeight(2);

  for (int i = 0; i < DECK_COUNT; i++){
    g.fill(i == DECK_COUNT - 1 ? COL_PANEL_2 : COL_PANEL);
    g.line(ROOM_LEFT + 4, deck_y[i], ROOM_RIGHT - 4, deck_y[i]);
    g.rect(ROOM_LEFT + 4, deck_y[i], ROOM_RIGHT - ROOM_LEFT - 8, 4);
  }

  g.strokeWeight(1);
}


void drawLadders(PGraphics g){
  g.stroke(COL_ORANGE);
  g.strokeWeight(2);

  for (int i = 0; i < LADDER_COUNT; i++){
    float x = ladder_x[i];
    g.line(x - 5, deck_y[0], x - 5, deck_y[DECK_COUNT - 1]);
    g.line(x + 5, deck_y[0], x + 5, deck_y[DECK_COUNT - 1]);

    for (float y = deck_y[0] + 8; y < deck_y[DECK_COUNT - 1]; y += 8){
      g.line(x - 5, y, x + 5, y);
    }
  }

  g.strokeWeight(1);
}
void drawDoors(PGraphics g){
  if (screen == SCREEN_COMMAND){
    drawHubDoor(g, 0, SCREEN_DORMITORY);
    drawHubDoor(g, 1, SCREEN_DEPOT);
    drawHubDoor(g, 2, SCREEN_MACHINES);
    return;
  }
  drawPeripheralDoor(g, roomDoorDeck(screen));
}

void drawHubDoor(PGraphics g, int deck, int destination){
  float x = ROOM_RIGHT - 17;
  float y = deck_y[deck];
  boolean nearby = doorInRange(1, deck);
  g.fill(nearby ? COL_CYAN_DARK : COL_PANEL_2);
  g.stroke(nearby ? COL_CYAN : COL_BORDER);
  g.rect(x, y - 38, 12, 38);
  if (nearby) text(g, "E - " + roomTitle(destination), x - 210, y - 58, 16, COL_CYAN);
}

void drawPeripheralDoor(PGraphics g, int deck){
  float x = ROOM_LEFT + 5;
  float y = deck_y[deck];
  boolean nearby = doorInRange(-1, deck);
  g.fill(nearby ? COL_CYAN_DARK : COL_PANEL_2);
  g.stroke(nearby ? COL_CYAN : COL_BORDER);
  g.rect(x, y - 38, 12, 38);
  if (nearby) text(g, "E - SALA DE COMANDO", x + 18, y - 58, 16, COL_CYAN);
}


void drawRoomPoint(PGraphics g, int point){
  boolean available = pointIsAvailable(point);
  boolean nearby = available && isPointInRange(point);
  int colour = nearby ? COL_CYAN : (available ? COL_TEXT : COL_DIM);
  float x = point_x[point];
  float y = point_y[point];

  g.stroke(nearby ? COL_CYAN : COL_BORDER);
  g.fill(nearby ? COL_CYAN_DARK : COL_PANEL);
  g.rect(x - 12, y - 22, 24, 18, 2);
  text(g, str(pointMarker(point_kind[point])), x - 3, y - 22, 16, colour);
  textCentered(g, pointDisplayLabel(point), x, y - 44, 16, colour);

  if (nearby){
    g.noFill();
    g.stroke(COL_CYAN);
    g.rect(x - 16, y - 26, 32, 26, 2);
    text(g, "E", x - 3, y + 6, 16, COL_CYAN);
  }

  if (point_kind[point] == POINT_NPC){
    drawNpc(g, x, y, point_label[point], nearby);
  }
}


char pointMarker(int kind){
  if (kind == POINT_READ){
    return '?';
  }

  if (kind == POINT_COLLECT){
    return '+';
  }

  if (kind == POINT_NPC){
    return 'N';
  }

  if (kind == POINT_SWITCH){
    return 'S';
  }

  if (kind == POINT_END_DAY){
    return 'Z';
  }

  return '!';
}


void drawNpc(PGraphics g, float x, float y, String name, boolean nearby){
  g.noStroke();
  g.fill(nearby ? COL_CYAN : COL_ORANGE);
  g.rect(x - PLAYER_W / 2.0, y - PLAYER_H, PLAYER_W, PLAYER_H);
  g.fill(COL_TEXT);
  g.rect(x - 4, y - 19, 2, 2);
  g.rect(x + 2, y - 19, 2, 2);
}


void drawPlayer(PGraphics g){
  if (!player_assets_loaded){
    drawPlayerFallback(g);
    return;
  }

  int frame = playerCurrentFrame();
  updatePlayerFrameLayer(frame);
  g.imageMode(CENTER);
  g.image(player_frame_layer,
    player_x + PLAYER_W / 2.0,
    player_y + PLAYER_H / 2.0,
    PLAYER_DRAW_W,
    PLAYER_DRAW_H
  );
}


void drawPlayerFallback(PGraphics g){
  g.noStroke();
  g.fill(player_on_ladder ? COL_CYAN : COL_ORANGE);
  g.rect(player_x, player_y, PLAYER_W, PLAYER_H);
  g.fill(COL_BG);
  g.rect(player_x + 4, player_y + 5, 2, 2);
  g.rect(player_x + 10, player_y + 5, 2, 2);
  g.rect(player_x + 4, player_y + 17, 8, 2);
}


void loadPlayerAssets(){
  player_sheet = loadImage(PLAYER_SHEET_FILE);
  player_sheet_data = loadJSONObject(PLAYER_SHEET_DATA_FILE);

  if (player_sheet == null || player_sheet_data == null){
    println("player: assets not loaded");
    return;
  }

  player_sheet_frames = player_sheet_data.getJSONArray("frames");
  if (player_sheet_frames == null || player_sheet_frames.size() == 0){
    println("player: no frames in JSON");
    return;
  }

  int frame_count = player_sheet_frames.size();
  player_frame_images = new PImage[frame_count];
  player_frame_durations = new int[frame_count];

  for (int i = 0; i < frame_count; i++){
    JSONObject frame_data = player_sheet_frames.getJSONObject(i);
    JSONObject frame_rect = frame_data.getJSONObject("frame");
    player_frame_images[i] = player_sheet.get(
      frame_rect.getInt("x"),
      frame_rect.getInt("y"),
      frame_rect.getInt("w"),
      frame_rect.getInt("h")
    );
    player_frame_durations[i] = max(1, frame_data.getInt("duration"));
  }

  player_idle_start = 0;
  player_idle_end = 0;
  player_walk_start = 0;
  player_walk_end = frame_count - 1;

  JSONObject meta = player_sheet_data.getJSONObject("meta");
  if (meta != null && meta.hasKey("frameTags")){
    JSONArray tags = meta.getJSONArray("frameTags");
    for (int i = 0; i < tags.size(); i++){
      JSONObject tag = tags.getJSONObject(i);
      String name = tag.getString("name");
      if (name.equals("idle")){
        player_idle_start = tag.getInt("from");
        player_idle_end = tag.getInt("to");
      } else if (name.equals("walk")){
        player_walk_start = tag.getInt("from");
        player_walk_end = tag.getInt("to");
      }
    }
  }

  player_frame_layer = createGraphics(
    PLAYER_DRAW_W * RENDER_SCALE,
    PLAYER_DRAW_H * RENDER_SCALE
  );
  player_frame_layer.noSmooth();
  player_animation_started_at = millis();
  player_assets_loaded = true;
}


void updatePlayerFacing(){
  if (move_left_held && !move_right_held){
    player_facing = -1;
  } else if (move_right_held && !move_left_held){
    player_facing = 1;
  }
}


boolean playerIsMoving(){
  return move_left_held || move_right_held || move_up_held || move_down_held;
}


int playerCurrentFrame(){
  if (!player_assets_loaded){
    return 0;
  }

  boolean moving = playerIsMoving();
  if (moving != player_animation_moving){
    player_animation_moving = moving;
    player_animation_started_at = millis();
  }

  int first = moving ? player_walk_start : player_idle_start;
  int last = moving ? player_walk_end : player_idle_end;
  int total_duration = 0;

  for (int index = first; index <= last; index++){
    total_duration += max(1, player_frame_durations[index]);
  }

  int frame = first;
  int elapsed = total_duration > 0
    ? max(0, millis() - player_animation_started_at) % total_duration
    : 0;

  while (frame < last){
    int duration = max(1, player_frame_durations[frame]);
    if (elapsed < duration){
      break;
    }
    elapsed -= duration;
    frame++;
  }

  return frame;
}


void updatePlayerFrameLayer(int frame){
  if (player_frame_layer == null
    || frame == player_rendered_frame
    && player_facing == player_rendered_facing){
    return;
  }

  player_frame_layer.beginDraw();
  player_frame_layer.clear();
  player_frame_layer.imageMode(CENTER);
  player_frame_layer.pushMatrix();
  player_frame_layer.translate(
    PLAYER_DRAW_W * RENDER_SCALE / 2.0,
    PLAYER_DRAW_H * RENDER_SCALE / 2.0
  );
  player_frame_layer.scale(player_facing, 1);
  player_frame_layer.image(
    player_frame_images[frame],
    0,
    0,
    PLAYER_DRAW_W * RENDER_SCALE,
    PLAYER_DRAW_H * RENDER_SCALE
  );
  player_frame_layer.popMatrix();
  player_frame_layer.endDraw();

  player_rendered_frame = frame;
  player_rendered_facing = player_facing;
}


void drawHeldItem(PGraphics g){
  if (held_item == ITEM_NONE){
    return;
  }

  text(g, "NA MÃO: " + heldItemLabel(), ROOM_LEFT + 170, ROOM_TOP + 6, 16, COL_ORANGE);
}


void enterRoom(int next_screen){
  enterRoomAtDeck(next_screen, roomDoorDeck(next_screen), -1);
}

void enterRoomAtDeck(int next_screen, int deck, int entry_side){
  screen = next_screen;
  current_room = next_screen;
  player_facing = entry_side > 0 ? -1 : 1;
  player_x = entry_side > 0 ? ROOM_RIGHT - 28 - PLAYER_W : ROOM_LEFT + 28;
  player_y = deck_y[deck] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  ladder_vertical_release_required = false;
  jump_queued = false;
  interact_queued = false;
}


void resetRoomState(){
  current_room = SCREEN_COMMAND;
  player_facing = 1;
  player_x = ROOM_LEFT + 28;
  player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  ladder_vertical_release_required = false;
  jump_queued = false;
  interact_queued = false;
  held_item = ITEM_NONE;
  map_open = false;
  dialog_open = false;
  technical_open = false;
  pending_switch_point = -1;
  pending_intervention_point = -1;
  pending_collect_point = -1;
  end_day_open = false;
}


int roomDoorDeck(int room_id){
  if (room_id == SCREEN_DORMITORY) return 0;
  if (room_id == SCREEN_DEPOT) return 1;
  return 2;
}

boolean doorInRange(int direction, int deck){
  float center = player_x + PLAYER_W / 2.0;
  float bottom = player_y + PLAYER_H;
  boolean on_deck = abs(bottom - deck_y[deck]) <= 3;
  return on_deck && (direction < 0
    ? center <= ROOM_LEFT + 38 : center >= ROOM_RIGHT - 38);
}

boolean useNearbyDoor(){
  if (screen == SCREEN_COMMAND){
    for (int deck = 0; deck < DECK_COUNT; deck++){
      if (!doorInRange(1, deck)) continue;
      int destination = deck == 0 ? SCREEN_DORMITORY
        : deck == 1 ? SCREEN_DEPOT : SCREEN_MACHINES;
      enterRoomAtDeck(destination, deck, -1);
      return true;
    }
    return false;
  }

  int deck = roomDoorDeck(screen);
  if (doorInRange(-1, deck)){
    enterRoomAtDeck(SCREEN_COMMAND, deck, 1);
    return true;
  }
  return false;
}


void updateRoom(){
  if (paused || event_open || map_open || technical_open || end_day_open){
    jump_queued = false;
    interact_queued = false;
    return;
  }


  if (dialog_open){
    if (interact_queued){
      interact_queued = false;
      dialog_open = false;
    }
    jump_queued = false;
    return;
  }

  if (interact_queued){
    interact_queued = false;

    if (!useNearbyDoor()){
      interactNearby();
    }
  }

  updatePlayerFacing();
  if (player_on_ladder){
    updatePlayerOnLadder();
  } else {
    updatePlayerOnDeck();
  }

  jump_queued = false;
}


void updatePlayerOnDeck(){
  float horizontal = 0;

  if (move_left_held){
    horizontal -= PLAYER_SPEED;
  }

  if (move_right_held){
    horizontal += PLAYER_SPEED;
  }

  player_x = constrain(player_x + horizontal, ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);

  if (jump_queued && player_grounded){
    player_velocity_y = -sqrt(2 * GRAVITY * JUMP_HEIGHT);
    player_grounded = false;
  }

  float old_bottom = player_y + PLAYER_H;
  player_velocity_y += GRAVITY;
  float next_y = player_y + player_velocity_y;
  player_grounded = false;

  for (int i = 0; i < DECK_COUNT; i++){
    if (player_velocity_y < 0){
      continue;
    }

    boolean crossing = old_bottom <= deck_y[i] && next_y + PLAYER_H >= deck_y[i];
    boolean overlaps = player_x + PLAYER_W > ROOM_LEFT && player_x < ROOM_RIGHT;

    if (crossing && overlaps){
      next_y = deck_y[i] - PLAYER_H;
      player_velocity_y = 0;
      player_grounded = true;
      break;
    }
  }

  player_y = min(next_y, deck_y[DECK_COUNT - 1] - PLAYER_H);

  boolean vertical_input = move_up_held || move_down_held;
  boolean horizontal_input = move_left_held || move_right_held;

  if (!vertical_input){
    ladder_vertical_release_required = false;
  }

  if (vertical_input && !horizontal_input && !ladder_vertical_release_required
    && player_grounded){
    int ladder = nearestLadder();

    if (ladder >= 0){
      player_on_ladder = true;
      player_grounded = false;
      player_x = ladder_x[ladder] - PLAYER_W / 2.0;
      player_velocity_y = 0;
      updatePlayerOnLadder();
    }
  }
}


void updatePlayerOnLadder(){
  int vertical = 0;

  if (move_up_held){
    vertical -= 1;
  }

  if (move_down_held){
    vertical += 1;
  }

  int horizontal = 0;

  if (move_left_held){
    horizontal -= 1;
  }

  if (move_right_held){
    horizontal += 1;
  }

  float old_y = player_y;
  player_y += vertical * LADDER_SPEED;
  float top = deck_y[0] - PLAYER_H;
  float bottom = deck_y[DECK_COUNT - 1] - PLAYER_H;
  player_y = constrain(player_y, top, bottom);

  boolean wants_deck = horizontal != 0 || vertical == 0;
  int deck = ladderDeckAt(old_y, player_y, wants_deck);

  if (deck >= 0 && wants_deck){
    leaveLadderAtDeck(deck, horizontal);
    return;
  }

  if (player_y <= top || player_y >= bottom){
    int end_deck = player_y <= top ? 0 : DECK_COUNT - 1;
    leaveLadderAtDeck(end_deck, horizontal);
  }
}


int ladderDeckAt(float old_y, float new_y, boolean allow_nearby){
  final float snap_distance = 4;
  int nearest = -1;
  float nearest_distance = snap_distance + 1;

  for (int i = 0; i < DECK_COUNT; i++){
    float target_y = deck_y[i] - PLAYER_H;
    boolean crossed = (old_y <= target_y && new_y >= target_y)
      || (old_y >= target_y && new_y <= target_y);

    if (crossed){
      return i;
    }

    float distance = abs(new_y - target_y);

    if (allow_nearby && distance <= snap_distance && distance < nearest_distance){
      nearest = i;
      nearest_distance = distance;
    }
  }

  return nearest;
}


void leaveLadderAtDeck(int deck, int horizontal){
  player_y = deck_y[deck] - PLAYER_H;
  player_x = constrain(player_x + horizontal * PLAYER_SPEED,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
  player_on_ladder = false;
  player_grounded = true;
  player_velocity_y = 0;
  ladder_vertical_release_required = move_up_held || move_down_held;
}



int nearestLadder(){
  if (!player_grounded){
    return -1;
  }

  float center_x = player_x + PLAYER_W / 2.0;
  float bottom = player_y + PLAYER_H;

  if (!isDeckSurface(bottom)){
    return -1;
  }

  int result = -1;
  float best_distance = INTERACTION_RANGE + 1;

  for (int i = 0; i < LADDER_COUNT; i++){
    float distance = abs(center_x - ladder_x[i]);

    if (distance <= INTERACTION_RANGE && distance < best_distance){
      result = i;
      best_distance = distance;
    }
  }

  return result;
}


boolean isDeckSurface(float bottom){
  for (int i = 0; i < DECK_COUNT; i++){
    if (abs(bottom - deck_y[i]) < 1.1){
      return true;
    }
  }

  return false;
}


void interactNearby(){
  int point = nearestInteractablePoint();

  if (point >= 0){
    interactPoint(point);
  }
}


int nearestInteractablePoint(){
  int result = -1;
  float best_distance = INTERACTION_RANGE + 1;

  for (int i = 0; i < POINT_COUNT; i++){
    if (point_room[i] != screen || !pointIsInteractable(i) || !isPointInRange(i)){
      continue;
    }

    float distance = abs(player_x + PLAYER_W / 2.0 - point_x[i]);

    if (distance < best_distance){
      result = i;
      best_distance = distance;
    }
  }

  return result;
}


boolean isPointInRange(int point){
  float player_center_x = player_x + PLAYER_W / 2.0;
  float player_bottom = player_y + PLAYER_H;
  return abs(player_center_x - point_x[point]) <= INTERACTION_RANGE
    && abs(player_bottom - point_y[point]) <= 3;
}
