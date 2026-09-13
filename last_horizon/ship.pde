/* nave e salas - vista lateral com os 4 comodos clicaveis (interface/FLOW.md)
   Tudo aqui e lugar-comum geometrico: nenhum sprite entra antes do ticket de arte. */

final int ROOM_COUNT = 4;
final float ROOM_Y = 108;
final float ROOM_W = 96;
final float ROOM_H = 88;

String[] room_label = {"COMANDO", "ENERGIA", "DEPÓSITO", "DORMITÓRIO"};
float[] room_x = {52, 152, 252, 352};
int[] room_screen = {SCREEN_COMMAND, SCREEN_ENERGY, SCREEN_DEPOT, SCREEN_DORMITORY};
int[] room_action = {ACTION_OPEN_COMMAND, ACTION_OPEN_ENERGY, ACTION_OPEN_DEPOT, ACTION_OPEN_DORMITORY};

final int DECK_COUNT = 3;
float[] deck_y = {164, 232, 300};
final int LADDER_COUNT = 2;
float[] ladder_x = {150, 330};

final int POINT_READ = 0;
final int POINT_COLLECT = 1;
final int POINT_NPC = 2;
final int POINT_SWITCH = 3;
final int POINT_COMPLETE = 4;

final int POINT_COMMAND_BRIEFING = 0;
final int POINT_VERA = 1;
final int POINT_ROUTE = 2;
final int POINT_STATUS = 3;
final int POINT_ENGINE_BENCH = 4;
final int POINT_SILVIA = 5;
final int POINT_DISTRIBUTION = 6;
final int POINT_REACTOR = 7;
final int POINT_SEAL_KIT = 8;
final int POINT_HULL = 9;
final int POINT_BENTO = 10;
final int POINT_RATIONING = 11;
final int POINT_RESERVE = 12;
final int POINT_BUNK = 13;
final int POINT_NEUSA = 14;
final int POINT_COMMON_TABLE = 15;
final int POINT_LIFE_SUPPORT = 16;
final int POINT_ANTENNA = 17;
final int POINT_COUNT = 18;

int[] point_room = {
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND,
  SCREEN_ENERGY, SCREEN_ENERGY, SCREEN_ENERGY, SCREEN_ENERGY,
  SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT,
  SCREEN_DORMITORY, SCREEN_DORMITORY, SCREEN_DORMITORY,
  SCREEN_ENERGY, SCREEN_COMMAND
};

float[] point_x = {
  76, 360, 230, 100,
  76, 340, 210, 360,
  76, 360, 230, 120, 360,
  100, 320, 235,
  76, 210
};

float[] point_y = {
  164, 164, 232, 300,
  300, 232, 232, 164,
  300, 300, 232, 232, 164,
  300, 232, 164,
  164, 164
};

String[] point_label = {
  "BRIEFING", "VERA", "ROTA", "STATUS",
  "BANCADA", "SÍLVIA", "DISTRIBUIÇÃO", "REATOR",
  "KIT", "CASCO", "BENTO", "RACIONAMENTO", "RESERVA",
  "BELICHE", "NEUSA", "MESA COMUM",
  "SUPORTE", "ANTENA"
};

int[] point_kind = {
  POINT_READ, POINT_NPC, POINT_READ, POINT_READ,
  POINT_COMPLETE, POINT_NPC, POINT_SWITCH, POINT_COMPLETE,
  POINT_COLLECT, POINT_COMPLETE, POINT_NPC, POINT_SWITCH, POINT_READ,
  POINT_COMPLETE, POINT_NPC, POINT_COMPLETE,
  POINT_COMPLETE, POINT_COMPLETE
};


void drawShipArea(PGraphics g){
  g.noStroke();
  g.fill(COL_ROOM);
  g.rect(0, SIDE_Y, SIDE_X, SIDE_H);

  drawStars(g);

  if (isRoomScreen()){
    drawRoom(g);
  } else {
    drawShip(g);
  }

  if (event_open){
    drawEventLockNotice(g);
  }
}
void drawEventLockNotice(PGraphics g){
  drawPanel(g, 64, 226, SIDE_X - 128, 42, COL_ORANGE);
  textCentered(g, "EVENTO PENDENTE", SIDE_X / 2.0, 232, 12, COL_ORANGE);
  textCentered(g, "RESPONDA O EVENTO PARA CONTINUAR", SIDE_X / 2.0, 250, 10, COL_TEXT);
}


void drawShip(PGraphics g){
  drawHull(g);

  for (int i = 0; i < ROOM_COUNT; i++){
    drawRoomDoor(g, i);
  }

  textCentered(g, "CLIQUE EM UM CÔMODO PARA ENTRAR", SIDE_X / 2.0, 254, 9, COL_DIM);
  textCentered(g, "TÉCNICO: " + player_name, SIDE_X / 2.0, 272, 9, COL_MUTED);
}


void drawHull(PGraphics g){
  g.noStroke();
  g.fill(COL_CYAN_DARK);
  g.rect(12, 128, 30, 44);

  g.fill(COL_ORANGE);
  g.triangle(12, 138, 2, 150, 12, 162);

  g.fill(COL_PANEL_2);
  g.beginShape();
  g.vertex(46, 150);
  g.vertex(78, 100);
  g.vertex(440, 100);
  g.vertex(462, 150);
  g.vertex(440, 200);
  g.vertex(78, 200);
  g.endShape(CLOSE);

  g.stroke(COL_BORDER);
  g.noFill();
  g.line(78, 150, 440, 150);
}


void drawRoomDoor(PGraphics g, int index){
  boolean scene_controls_on = !event_open && !paused;
  boolean hover = scene_controls_on && uiLayer() == LAYER_SCENE && isHovering(room_x[index], ROOM_Y, ROOM_W, ROOM_H);
  int border = scene_controls_on ? (hover ? COL_CYAN : COL_BORDER) : COL_DIM;
  int label_colour = scene_controls_on ? (hover ? COL_CYAN : COL_TEXT) : COL_DIM;
  int status_colour = scene_controls_on ? COL_MUTED : COL_DIM;

  drawPanel(g, room_x[index], ROOM_Y, ROOM_W, ROOM_H, border);
  textCentered(g, room_label[index], room_x[index] + ROOM_W / 2.0, ROOM_Y + 26, 9, label_colour);
  textCentered(g, roomStatus(index), room_x[index] + ROOM_W / 2.0, ROOM_Y + 46, 8, status_colour);

  addButton(room_x[index], ROOM_Y, ROOM_W, ROOM_H, room_action[index], scene_controls_on);
}


String roomStatus(int index){
  if (index == 0){
    return "DIA " + day + " DE " + trip_days;
  }

  if (index == 1){
    return "MOTOR " + engineStateLabel();
  }

  if (index == 2){
    return "PEÇAS " + parts;
  }

  return "MORAL " + str(int(morale));
}


void drawRoom(PGraphics g){
  drawBackdrop(g, ROOM_LEFT, ROOM_TOP, ROOM_RIGHT - ROOM_LEFT, ROOM_BOTTOM - ROOM_TOP);
  drawRoomTitle(g);
  if (screen == SCREEN_COMMAND){
    drawCommandBriefing(g);
  }
  drawDecks(g);
  drawLadders(g);

  for (int i = 0; i < POINT_COUNT; i++){
    if (point_room[i] == screen){
      drawRoomPoint(g, i);
    }
  }

  drawPlayer(g);
  drawHeldItem(g);

  if (task_choice_open){
    drawTaskChoice(g);
  }
}


void drawRoomTitle(PGraphics g){
  String title = roomTitle(screen);
  g.fill(COL_CYAN);
  g.textSize(12);
  g.text(title, ROOM_LEFT + 10, ROOM_TOP + 6);
}


String roomTitle(int room_screen){
  if (room_screen == SCREEN_COMMAND){
    return "SALA DE COMANDO";
  }

  if (room_screen == SCREEN_ENERGY){
    return "SALA DE ENERGIA";
  }

  if (room_screen == SCREEN_DEPOT){
    return "DEPÓSITO";
  }

  return "DORMITÓRIO";
}

void drawCommandBriefing(PGraphics g){
  int suggestion = suggestedTask();
  g.fill(COL_PANEL);
  g.stroke(COL_CYAN_DARK);
  g.rect(ROOM_LEFT + 8, ROOM_TOP + 28, ROOM_RIGHT - ROOM_LEFT - 16, 34, 2);
  g.fill(COL_TEXT);
  g.textSize(10);
  g.text("BRIEFING DO DIA: " + task_label[suggestion], ROOM_LEFT + 16, ROOM_TOP + 36);

  if (day == 1 && !first_interaction_done){
    g.textSize(10);
    g.text("ANDAR  A/D   ESCADA  W/S   PULAR  ESPAÇO   INTERAGIR  E", ROOM_LEFT + 16, ROOM_TOP + 50);
  }
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


void drawRoomPoint(PGraphics g, int point){
  boolean available = pointIsAvailable(point);
  boolean nearby = available && isPointInRange(point);
  int colour = nearby ? COL_CYAN : (available ? COL_TEXT : COL_DIM);
  float x = point_x[point];
  float y = point_y[point];

  g.stroke(nearby ? COL_CYAN : COL_BORDER);
  g.fill(nearby ? COL_CYAN_DARK : COL_PANEL);
  g.rect(x - 12, y - 22, 24, 18, 2);
  g.fill(colour);
  g.textSize(12);
  g.text(pointMarker(point_kind[point]), x - 4, y - 20);

  g.fill(colour);
  g.textSize(10);
  g.text(point_label[point], x - min(32, g.textWidth(point_label[point]) / 2.0), y - 38);

  if (nearby){
    g.noFill();
    g.stroke(COL_CYAN);
    g.rect(x - 16, y - 26, 32, 26, 2);
    g.fill(COL_CYAN);
    g.textSize(10);
    g.text("E", x - 3, y + 6);
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
  g.noStroke();
  g.fill(player_on_ladder ? COL_CYAN : COL_ORANGE);
  g.rect(player_x, player_y, PLAYER_W, PLAYER_H);
  g.fill(COL_BG);
  g.rect(player_x + 4, player_y + 5, 2, 2);
  g.rect(player_x + 10, player_y + 5, 2, 2);
  g.rect(player_x + 4, player_y + 17, 8, 2);
}


void drawHeldItem(PGraphics g){
  if (held_item == ITEM_NONE){
    return;
  }

  g.fill(COL_ORANGE);
  g.textSize(10);
  g.text("NA MÃO: " + heldItemLabel(), ROOM_LEFT + 8, ROOM_TOP + 24);
}


void enterRoom(int next_screen){
  screen = next_screen;
  current_room = next_screen;
  resetPlayerPosition();
  task_choice_open = false;
  jump_queued = false;
  interact_queued = false;
}


void leaveRoom(){
  screen = SCREEN_SHIP;
  current_room = SCREEN_SHIP;
  player_on_ladder = false;
  ladder_vertical_release_required = false;
  task_choice_open = false;
  jump_queued = false;
  interact_queued = false;
}


void resetRoomState(){
  current_room = SCREEN_SHIP;
  player_x = ROOM_LEFT + 24;
  player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  ladder_vertical_release_required = false;
  jump_queued = false;
  interact_queued = false;
  held_item = ITEM_NONE;
}


void resetPlayerPosition(){
  player_x = ROOM_LEFT + 24;
  player_y = deck_y[DECK_COUNT - 1] - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = true;
  player_on_ladder = false;
  ladder_vertical_release_required = false;
}


void updateRoom(){
  if (event_open || paused){
    jump_queued = false;
    interact_queued = false;
    return;
  }

  if (task_choice_open){
    updateTaskChoice();
    return;
  }

  if (interact_queued){
    interact_queued = false;
    interactNearby();
  }

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
