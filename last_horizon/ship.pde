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

float[] deck_y = {128, 202, 278};
final int LADDER_PER_ROOM = 2;
final int LADDER_COUNT = LADDER_PER_ROOM * ROOM_COUNT;
int[] ladder_room = {
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_MACHINES, SCREEN_MACHINES,
  SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DORMITORY, SCREEN_DORMITORY
};
/* Cada registro pode ocupar qualquer x; o par abaixo é o definitivo por sala. */
float[] ladder_x = {127, 532, 468, 136, 520, 130, 542, 243};
/* Escadas divididas por sala: esquerda vai do inferior ao meio; direita vai do meio ao superior */
int[] ladder_top_deck = {
  1, 0, 1, 0, 1, 0, 1, 0
};
int[] ladder_bottom_deck = {
  2, 1, 2, 1, 2, 1, 2, 1
};
int current_ladder = -1;

/* Portas são portais de dados; x/y são o centro e o limiar dos pés. */
final int DOOR_DECK_NONE = -1;
final int DOOR_COUNT = 6;
final float DOOR_W = 12;
final float DOOR_H = 38;
final float DOOR_RANGE = 18;
final float DOOR_VERTICAL_RANGE = 18;
int[] door_room = {
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND,
  SCREEN_DORMITORY, SCREEN_DEPOT, SCREEN_MACHINES
};
int[] door_target = {
  SCREEN_DORMITORY, SCREEN_DEPOT, SCREEN_MACHINES,
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND
};
/* door_deck é apenas a referência opcional do layout; -1 libera o y. */
int[] door_deck = {0, 1, 2, 0, 1, 2};
float[] door_x = {
  40, 598, 88,
  40, 45, 88
};
float[] door_y = {
  deck_y[0], deck_y[1], deck_y[2],
  deck_y[0], deck_y[1], deck_y[2]
};
/*
  door_arrival_x é o centro do jogador e door_arrival_y são seus pés na
  sala de destino. A chegada é o padrão da porta; num retorno imediato pela
  sala anterior, a posição de saída é reaproveitada.
*/
float[] door_arrival_x = {
  68,
  73,
  110,
  68,
  570,
  110
};
float[] door_arrival_y = {
  deck_y[0], deck_y[1], deck_y[2],
  deck_y[0], deck_y[1], deck_y[2]
};
int[] door_arrival_facing = {1, 1, 1, 1, -1, 1};

boolean last_portal_valid = false;
int last_portal_from_room = SCREEN_COMMAND;
int last_portal_to_room = SCREEN_COMMAND;
float last_portal_from_x = 0;
float last_portal_from_y = 0;

/* Portal data is resolved once, before either the animated or instant path
   changes the active room. The prepared record is also the seam used by the
   optional verification module. */
boolean portal_transition_prepared = false;
int portal_prepared_door = -1;
int portal_prepared_from_room = SCREEN_NONE;
int portal_prepared_target_room = SCREEN_NONE;
int portal_prepared_return_door = -1;
float portal_prepared_departure_x = 0;
float portal_prepared_departure_y = 0;
float portal_prepared_arrival_x = 0;
float portal_prepared_arrival_y = 0;
int portal_prepared_arrival_facing = 1;
boolean portal_prepared_returning = false;

final int POINT_READ = 0;
final int POINT_COLLECT = 1;
final int POINT_NPC = 2;
final int POINT_COMPLETE = 4;
final int POINT_END_DAY = 5;

final int POINT_VERA = 0;
final int POINT_ROUTE = 1;
final int POINT_ANTENNA = 2;
final int POINT_ENGINE_BENCH = 3;
final int POINT_SILVIA = 4;
final int POINT_DISTRIBUTION = 5;
final int POINT_LIFE_SUPPORT = 6;
final int POINT_BENTO = 7;
final int POINT_RESERVE = 8;
final int POINT_STOCK = 9;
final int POINT_RISK_BUNK = 10;
final int POINT_NEUSA = 11;
final int POINT_CONFLICT = 12;
final int POINT_COMMON_TABLE = 13;
final int POINT_TECH_BUNK = 14;
final int POINT_HULL = 15;
final int POINT_COUNT = 16;

int[] point_room = {
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_COMMAND,
  SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_MACHINES, SCREEN_MACHINES,
  SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DEPOT,
  SCREEN_DORMITORY, SCREEN_DORMITORY, SCREEN_DORMITORY, SCREEN_DORMITORY,
  SCREEN_DORMITORY, SCREEN_NONE
};
float[] point_x = {
  575, 260, 598,
  271, 570, 215, 454,
  310, 530, 85,
  85, 330, 440, 525, 185,
  530
};
float[] point_y = {
  128, 202, 278,
  278, 202, 202, 128,
  202, 128, 278,
  278, 202, 202, 128, 128,
  278
};
String[] point_label = {
  "VERA", "CONSOLE DA ROTA", "ANTENA",
  "BANCADA DO MOTOR", "SÍLVIA", "DISTRIBUIÇÃO", "SUPORTE",
  "BENTO", "RESERVA", "ESTOQUE DE COMIDA",
  "SOCORRO", "NEUSA", "MESA DO GRUPO", "MESA COMUM", "SEU BELICHE", "CASCO"
};
int[] point_kind = {
  POINT_NPC, POINT_READ, POINT_COMPLETE,
  POINT_COMPLETE, POINT_NPC, POINT_COMPLETE, POINT_COMPLETE,
  POINT_NPC, POINT_READ, POINT_COMPLETE,
  POINT_COMPLETE, POINT_NPC, POINT_COMPLETE, POINT_COMPLETE, POINT_END_DAY, POINT_COMPLETE
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
  calculateMapRoute();
  drawModalShade(g);
  drawPanel(g, 12, 30, 616, 298, COL_CYAN);
  text(g, "MAPA DA NAVE", 50, 54, 16, COL_CYAN);
  text(g, mapTargetKind() + " · " + mapTargetText(), 50, 72, 16, COL_TEXT);

  g.stroke(COL_BORDER);
  g.strokeWeight(2);
  for (int from = 0; from < ROOM_COUNT; from++){
    for (int to = from + 1; to < ROOM_COUNT; to++){
      drawMapConnection(g, from, to);
    }
  }
  g.strokeWeight(1);

  for (int i = 0; i < ROOM_COUNT; i++){
    drawMapRoomCard(g, i);
  }

  drawMapRoomDetails(g);
  drawButton(g, 22, 296, 86, 20, "SALA", ACTION_MAP_MY_ROOM, true);
  drawButton(g, 114, 296, 98, 20, "BELICHE", ACTION_MAP_BUNK_QUERY, true);
  drawButton(g, 218, 296, 104, 20, "SOCORRO", ACTION_MAP_RESCUE_QUERY, urgentRisk() >= 0);
  drawButton(g, 328, 296, 132, 20, "VOLTAR À ROTA", ACTION_MAP_ROUTE,
    map_target_room != SCREEN_NONE);
  drawModalFooter(g, 296, "", ACTION_NONE, false,
    "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
}


void drawMapConnection(PGraphics g, int from, int to){
  int from_screen = room_screen[from];
  int to_screen = room_screen[to];
  boolean connected = false;
  for (int door = 0; door < DOOR_COUNT; door++){
    if ((door_room[door] == from_screen && door_target[door] == to_screen)
      || (door_room[door] == to_screen && door_target[door] == from_screen)){
      connected = true;
      break;
    }
  }
  if (!connected) return;
  boolean route = false;
  for (int i = 0; i < map_route_length - 1; i++){
    int a = map_route_rooms[i];
    int b = map_route_rooms[i + 1];
    if ((a == from && b == to) || (a == to && b == from)) route = true;
  }
  g.stroke(route ? COL_CYAN : COL_DIM);
  g.line(room_x[from] + MAP_ROOM_W / 2.0, MAP_ROOM_Y + MAP_ROOM_H / 2.0,
    room_x[to] + MAP_ROOM_W / 2.0, MAP_ROOM_Y + MAP_ROOM_H / 2.0);
}




void drawMapRoomCard(PGraphics g, int index){
  boolean hover = uiLayer() == LAYER_MAP
    && isHovering(room_x[index], MAP_ROOM_Y, MAP_ROOM_W, MAP_ROOM_H);
  boolean selected = map_selected_room == index;
  boolean route = false;
  for (int i = 0; i < map_route_length; i++) if (map_route_rooms[i] == index) route = true;
  int border = selected || route ? COL_CYAN : (hover ? COL_CYAN : COL_BORDER);

  drawPanel(g, room_x[index], MAP_ROOM_Y, MAP_ROOM_W, MAP_ROOM_H, border);
  drawArtCorner(g, art_map == null ? null : art_map[index], room_x[index], MAP_ROOM_Y, ART_MAP_W, ART_MAP_H);
  g.noFill();
  g.stroke(border);
  g.rect(room_x[index], MAP_ROOM_Y, MAP_ROOM_W, MAP_ROOM_H, 3);
  textCentered(g, room_label[index], room_x[index] + MAP_ROOM_W / 2.0,
    MAP_ROOM_Y + 8, 16, selected ? COL_CYAN : COL_TEXT);
  textCentered(g, roomProblemCount(room_screen[index]) + " alerta(s)",
    room_x[index] + MAP_ROOM_W / 2.0, MAP_ROOM_Y + 28, 16, COL_MUTED);

  if (room_screen[index] == screen){
    textCentered(g, "VOCÊ ESTÁ AQUI", room_x[index] + MAP_ROOM_W / 2.0,
      MAP_ROOM_Y + 48, 16, COL_ORANGE);
  }

  if (room_screen[index] == map_target_room){
    textCentered(g, "OBJETIVO", room_x[index] + MAP_ROOM_W / 2.0,
      MAP_ROOM_Y + 61, 16, COL_GREEN);
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
  text(g, mapRouteText(), 50, 168, 16, COL_CYAN);
  float y = drawTextWrapped(g, mapNextInstruction(), 50, 186, 540, 16, 18, COL_TEXT);
  drawMapDeckPlan(g, selected_room, 50, y + 4, 238, 76);
  text(g, roomOccupant(index) + " · " + roomSystems(index), 304, 204, 16, COL_TEXT);
  y = 224;
  if (active_quest >= 0){
    int q = active_quest;
    if (quest_stage == QUEST_COLLECT && point_room[quest_origin[q]] == selected_room)
      y = drawTextWrapped(g, "Pegar: " + quest_object[q] + " · " + point_label[quest_origin[q]], 304, y, 290, 16, 18, COL_CYAN);
    if (quest_stage == QUEST_DELIVER && point_room[quest_destination[q]] == selected_room)
      y = drawTextWrapped(g, "Levar: " + point_label[quest_destination[q]] + " · " + questEffect(q), 304, y, 290, 16, 18, COL_GREEN);
  } else if (selected_preventive_id >= 0 && point_room[crew_point[quest_owner[selected_preventive_id]]] == selected_room){
    y = drawTextWrapped(g, "Falar com " + crewDisplayName(quest_owner[selected_preventive_id]), 304, y, 290, 16, 18, COL_CYAN);
  }
  for (int p = 0; p < PROBLEM_COUNT; p++){
    if (!problem_active[p] || problem_room[p] != selected_room) continue;
    y = drawTextWrapped(g, problemMapLine(p), 304, y + 6, 290, 16, 18, COL_ORANGE);
  }
  int risk = urgentRisk();
  if (selected_room == SCREEN_DORMITORY && risk >= 0){
    drawTextWrapped(g, crewDisplayName(risk) + " em risco: " + crew_risk_deadline[risk] + " noite(s). Socorro: -8 água, -2 comida.", 304, y + 6, 290, 16, 18, COL_ORANGE);
    drawButton(g, 470, 272, 124, 20, "VER SOCORRO", ACTION_OPEN_RESCUE,
      uiLayer() == LAYER_MAP);
  }
}

void drawMapDeckPlan(PGraphics g, int selected_room, float x, float y, float w, float h){
  g.noFill();
  g.stroke(COL_BORDER);
  for (int deck = 0; deck < DECK_COUNT; deck++){
    float line_y = y + 12 + deck * 24;
    g.line(x, line_y, x + w, line_y);
    text(g, deckLabel(deck), x + 4, line_y - 12, 16, COL_MUTED);
  }
  for (int ladder = 0; ladder < LADDER_COUNT; ladder++){
    if (ladder_room[ladder] != selected_room) continue;
    float lx = x + constrain(ladder_x[ladder] / BASE_W, 0, 1) * w;
    float top = y + 12 + ladder_top_deck[ladder] * 24;
    float bottom = y + 12 + ladder_bottom_deck[ladder] * 24;
    g.stroke(COL_ORANGE);
    g.line(lx, top, lx, bottom);
  }
  for (int door = 0; door < DOOR_COUNT; door++){
    if (door_room[door] != selected_room) continue;
    float dx = x + constrain(door_x[door] / BASE_W, 0, 1) * w;
    boolean has_deck = door_deck[door] >= 0 && door_deck[door] < DECK_COUNT;
    float dy = mapDeckPlanY(door_y[door], door_deck[door], y, h);
    g.stroke(door == map_next_door ? COL_CYAN : COL_DIM);
    if (has_deck){
      g.line(dx - 3, dy - 4, dx + 3, dy + 4);
    } else {
      g.line(dx - 4, dy, dx + 4, dy);
      text(g, "Abertura fora do convés", dx + 6, dy - 8, 16,
        door == map_next_door ? COL_CYAN : COL_MUTED);
    }
  }
  if (selected_room == screen){
    float px = x + constrain((player_x + PLAYER_W / 2.0) / BASE_W, 0, 1) * w;
    int deck = playerDeckForMap();
    float py = mapDeckPlanY(player_y + PLAYER_H, deck, y, h);
    g.noStroke();
    g.fill(COL_ORANGE);
    g.ellipse(px, py, 7, 7);
    text(g, deck >= 0 ? "Você" : "Você · altura livre", px + 5, py - 8, 16, COL_ORANGE);
  }
  if (map_target_room == selected_room && map_target_point >= 0){
    float tx = x + constrain(point_x[map_target_point] / BASE_W, 0, 1) * w;
    int deck = pointDeck(map_target_point);
    float ty = mapDeckPlanY(point_y[map_target_point], deck, y, h);
    g.noStroke();
    g.fill(COL_GREEN);
    g.rect(tx - 4, ty - 4, 8, 8);
    text(g, deck >= 0 ? "Objetivo" : "Objetivo · altura livre", tx + 6, ty - 8, 16, COL_GREEN);
  }
}


float mapDeckPlanY(float height, int deck, float y, float h){
  if (deck >= 0 && deck < DECK_COUNT) return y + 12 + deck * 24;
  return y + constrain((height - ROOM_TOP) / (ROOM_BOTTOM - ROOM_TOP), 0, 1) * h;
}


String roomOccupant(int index){
  int crew = index == 0 ? CREW_VERA : index == 1 ? CREW_SILVIA : index == 2 ? CREW_BENTO : CREW_NEUSA;
  return crew_name[crew] + (crew_alive[crew] ? "" : " — FALECEU");
}


String roomSystems(int index){
  String[] systems = {"ROTA E COMUNICAÇÕES", "MOTOR, ENERGIA E SUPORTE",
    "ESTOQUES E COMPONENTES", "DESCANSO, SAÚDE E MORAL"};
  return systems[index];
}


void drawRoom(PGraphics g){
  PImage backdrop = art_backdrop == null ? null : art_backdrop[roomIndex(screen)];

  if (backdrop != null){
    /* painted floor and ladders replace the geometry; collision stays in code */
    drawArtCorner(g, backdrop, 0, ART_BACKDROP_TOP, BASE_W, ART_BACKDROP_H);
  } else {
    drawBackdrop(g, ROOM_LEFT, ROOM_TOP, ROOM_RIGHT - ROOM_LEFT, ROOM_BOTTOM - ROOM_TOP);
    drawWalls(g);
    drawRoomDecor(g);
    drawDecks(g);
    drawLadders(g);
  }

  drawRoomTitle(g);
  drawDoors(g);

  for (int i = 0; i < POINT_COUNT; i++){
    if (point_room[i] == screen){
      drawRoomPoint(g, i);
    }
  }

  drawPlayer(g);
}


void drawRoomDecor(PGraphics g){
  // Asymmetric groups leave breathing room around the fixed gameplay stations.
  if (screen == SCREEN_COMMAND){
    drawRoomWindow(g, 188, 0, 0);
    drawRoomWindow(g, 242, 0, 1);
    drawRoomDetail(g, "Computer 1", 405, 0, false);
    drawRoomDetail(g, "Screen info 1", 425, 0, false);
    drawRoomDetail(g, "Wall electric pannel 1", 373, 1, false);
    drawRoomVent(g, 128, 1);
    drawRoomDetail(g, "Wall cover 3", 455, 0, false);
    drawRoomDetail(g, "Lockers 1", 373, 2, true);
    drawRoomDetail(g, "Screen info 2", 429, 2, false);
    drawRoomVent(g, 331, 2);
  } else if (screen == SCREEN_MACHINES){
    drawRoomDetail(g, "Wall electric pannel 1", 215, 0, false);
    drawRoomDetail(g, "Wall cover 3", 246, 0, false);
    drawRoomDetail(g, "Baril 1", 318, 0, true);
    drawRoomDetail(g, "Baril 2", 334, 0, true);
    drawRoomDetail(g, "Wall electric pannel 1", 373, 1, false);
    drawRoomDetail(g, "Computer 1", 401, 1, false);
    drawRoomVent(g, 55.5, 1);
    drawRoomVent(g, 229.5, 2);
    drawRoomDetail(g, "Wall cover 2", 436, 2, false);
    drawRoomDetail(g, "Small Machine 1", 558, 2, true);
    drawRoomDetail(g, "Electric wall", 110, 0, true);
    drawRoomDetail(g, "Electric wall", 511, 1, true);
  } else if (screen == SCREEN_DEPOT){
    drawRoomDetail(g, "Lockers 1", 205, 0, true);
    drawRoomDetail(g, "Lockers 1", 248, 0, true);
    drawRoomDetail(g, "Baril 2", 294, 0, true);
    drawRoomVent(g, 490.5, 0);
    drawRoomDetail(g, "Board 1", 429, 1, false);
    drawRoomDetail(g, "Wallbox 1", 453, 1, false);
    drawRoomDetail(g, "Baril 1", 180, 1, true);
    drawRoomDetail(g, "Baril 2", 197, 1, true);
    drawRoomDetail(g, "Lockers 1", 373, 2, true);
    drawRoomDetail(g, "Lockers 1", 416, 2, true);
    drawRoomDetail(g, "Baril 2", 455, 2, true);
    drawRoomDetail(g, "Wall cover 3", 109, 0, false);
    drawRoomDetail(g, "Wall cover 2", 555, 2, false);
  } else if (screen == SCREEN_DORMITORY){
    drawRoomDetail(g, "Board 1", 373, 0, false);
    drawRoomWindow(g, 418, 0, 2);
    drawRoomDetail(g, "Lockers 1", 149, 1, true);
    drawRoomWindow(g, 43, 1, 3);
    drawRoomWindow(g, 97, 1, 4);
    drawRoomDetail(g, "post it", 385, 1, false);
    drawRoomDetail(g, "Lockers 1", 405, 2, true);
    drawRoomDetail(g, "Board 1", 438, 2, false);
    drawRoomVent(g, 215, 2);
  }
  if (screen == SCREEN_DORMITORY){
    if (art_dorm_bunk != null){
      float w = art_dorm_bunk.width / (float) RENDER_SCALE;
      float h = art_dorm_bunk.height / (float) RENDER_SCALE;
      float[] d0_x = {113, 185};
      for (int i = 0; i < d0_x.length; i++){
        drawArt(g, art_dorm_bunk, d0_x[i], deck_y[0] - h / 2.0, w, h);
      }
    }
  }
}


/* Existing fittings plus the authorized window_space.png sky, composed at runtime. */
HashMap<String, PImage> room_detail_cache = new HashMap<String, PImage>();
PImage[] room_wall_surfaces = new PImage[ROOM_COUNT];

PImage roomDetail(String name){
  if (!room_detail_cache.containsKey(name)){
    String data_path = ART_DECORATION_DIR + name + ".png";
    PImage art = loadArt(data_path);
    if (art == null){
      String legacy_path = sketchPath("../assets/PNG/" + name + ".png");
      if (new File(legacy_path).isFile()){
        art = loadImage(legacy_path);
      }
    }
    room_detail_cache.put(name, art);
  }
  return room_detail_cache.get(name);
}

void drawRoomDetail(PGraphics g, String name, float x, int deck, boolean on_floor){
  PImage art = roomDetail(name);
  if (art == null) return;
  float w = art.width / (float) RENDER_SCALE;
  float h = art.height / (float) RENDER_SCALE;
  float top = deck == 0 ? ROOM_TOP : deck_y[deck - 1];
  float y = on_floor ? deck_y[deck] - h : top + 17;
  drawArt(g, art, x, y + h / 2, w, h);
}

/* Two existing pieces form a closed duct: paired housings with a continuous grille. */
PImage room_vent_strip;

void drawRoomVent(PGraphics g, float x, int deck){
  if (room_vent_strip == null){
    PImage housing = roomDetail("Wall pipes");
    PImage grille = roomDetail("Pipe2");
    if (housing == null || grille == null) return;
    int module_w = housing.width;
    int duct_h = housing.height * 2 - 4;
    PGraphics duct = createGraphics(module_w * 2, duct_h);
    duct.beginDraw();
    duct.noSmooth();
    duct.clear();
    for (int module = 0; module < 2; module++){
      int left = module * module_w;
      duct.image(housing, left, 0);
      duct.pushMatrix();
      duct.translate(left, duct_h);
      duct.scale(1, -1);
      duct.image(housing, 0, 0);
      duct.popMatrix();
      // Inset grille bridges the two halves while retaining the housing's end caps.
      for (int gx = 5; gx < module_w - 5; gx += grille.width){
        int span = min(grille.width, module_w - 5 - gx);
        duct.image(grille, left + gx, housing.height - 7, span, grille.height,
          0, 0, span, grille.height);
      }
    }
    duct.endDraw();
    room_vent_strip = duct.get();
  }
  float top = deck == 0 ? ROOM_TOP : deck_y[deck - 1];
  float w = room_vent_strip.width / (float) RENDER_SCALE;
  float h = room_vent_strip.height / (float) RENDER_SCALE;
  drawArt(g, room_vent_strip, x, top + 8 + h / 2, w, h);
}

PImage[] room_window_views = new PImage[5];

void drawRoomWindow(PGraphics g, float x, int deck, int view){
  PImage frame = roomDetail("Window 2");
  if (frame == null) return;
  if (room_window_views[view] == null){
    PImage sky = loadArt(ART_FLOOR_DIR + "window_space.png");
    PGraphics pane = createGraphics(frame.width, frame.height);
    pane.beginDraw();
    pane.noSmooth();
    pane.background(3, 7, 18);
    if (sky != null){
      int crop_w = min(480, sky.width);
      int crop_h = min(240, sky.height);
      int sx = (view * 211) % max(1, sky.width - crop_w + 1);
      int sy = (200 + view * 97) % max(1, sky.height - crop_h + 1);
      pane.image(sky, 0, 0, frame.width, frame.height, sx, sy, sx + crop_w, sy + crop_h);
    }
    pane.endDraw();
    PImage aperture = pane.get();
    aperture.loadPixels();
    // Chamfered opening sits under the original frame; exterior stays transparent.
    for (int py = 0; py < aperture.height; py++){
      for (int px = 0; px < aperture.width; px++){
        boolean inside = px >= 6 && px <= 91 && py >= 4 && py <= 42
          && px + py >= 14 && px - py <= 83
          && px + py <= 125 && py - px <= 34;
        if (!inside) aperture.pixels[py * aperture.width + px] = 0;
      }
    }
    aperture.updatePixels();
    pane.beginDraw();
    pane.clear();
    pane.image(aperture, 0, 0);
    pane.image(frame, 0, 0);
    pane.endDraw();
    room_window_views[view] = pane.get();
  }
  float top = deck == 0 ? ROOM_TOP : deck_y[deck - 1];
  float w = frame.width / (float) RENDER_SCALE;
  float h = frame.height / (float) RENDER_SCALE;
  drawArt(g, room_window_views[view], x, top + 28 + h / 2, w, h);
}

/* Lighting is continuous across panel boundaries, not baked into alternating tiles.
   Cache the static composition once per room, at the game's render resolution. */
PImage composeRoomWalls(int room){
  int w = round((ROOM_RIGHT - ROOM_LEFT - 8) * RENDER_SCALE);
  int h = round((deck_y[2] - ROOM_TOP) * RENDER_SCALE);
  PGraphics wall = createGraphics(w, h);
  wall.beginDraw();
  wall.noSmooth();
  wall.background(42, 45, 46);
  PImage panel = roomDetail(room == 3 ? "Wall 4 Light" : "Wall 3");
  PImage lamp = roomDetail(room == 3 ? "Lamp 1" : "Neon");
  float[][] lights = {
    {180, 408, 148, 368, 308, 523},
    {219, 449, 204, 391, 282, 544},
    {226, 516, 190, 433, 116, 414},
    {146, 432, 259, 491, 173, 425}
  };
  int[][] panel_spans = {
    {174, 116, 232, 174, 116, 232},
    {116, 174, 116, 232, 174, 116},
    {232, 116, 174, 232, 116, 174},
    {174, 232, 116, 174, 232, 116}
  };
  for (int deck = 0; deck < DECK_COUNT; deck++){
    int top = round(((deck == 0 ? ROOM_TOP : deck_y[deck - 1]) - ROOM_TOP) * RENDER_SCALE);
    int bottom = round((deck_y[deck] - ROOM_TOP) * RENDER_SCALE);
    int height = bottom - top;
    if (panel != null){
      int x = 0;
      int bay = deck;
      while (x < w){
        int module_w = panel_spans[room][bay % panel_spans[room].length];
        int span = min(module_w, w - x);
        int source_w = round(panel.width * span / (float) module_w);
        wall.image(panel, x, top, span, height, 0, 0, source_w, panel.height);
        x += span;
        bay++;
      }
    }
    // Soft ambient falloff is shared by the whole deck.
    wall.noStroke();
    for (int y = 0; y < height; y++){
      float edge = abs((y / (float) height) * 2 - 1);
      wall.fill(5, 12, 18, 22 + 55 * edge * edge);
      wall.rect(0, top + y, w, 1);
    }
    // Broad pools extend over several panels; every pixel has a smooth falloff.
    for (int y = 4; y < height - 4; y += 2){
      for (int x = 0; x < w; x += 2){
        float strength = 0;
        for (int light = 0; light < 2; light++){
          float cx = (lights[room][deck * 2 + light] - ROOM_LEFT - 4) * RENDER_SCALE;
          float dx = (x - cx) / 155.0;
          float dy = (y - 16) / 110.0;
          strength += exp(-(dx * dx + dy * dy) * 1.8);
        }
        if (room == 3) wall.fill(248, 203, 128, 36 * strength);
        else wall.fill(118, 216, 224, 32 * strength);
        wall.rect(x, top + y, 2, 2);
      }
    }
    // One continuous ceiling rail, rather than a frame around every panel.
    wall.fill(22, 27, 29);
    wall.rect(0, top, w, 7);
    wall.fill(77, 81, 79);
    wall.rect(0, top + 2, w, 1);
    wall.fill(18, 24, 27);
    wall.rect(0, bottom - 5, w, 5);
    if (lamp != null){
      for (int light = 0; light < 2; light++){
        float cx = (lights[room][deck * 2 + light] - ROOM_LEFT - 4) * RENDER_SCALE;
        wall.image(lamp, round(cx - lamp.width / 2.0), top + 18);
      }
    }
  }
  wall.endDraw();
  return wall.get();
}

void drawWalls(PGraphics g){
  int room = roomIndex(screen);
  if (room_wall_surfaces[room] == null) room_wall_surfaces[room] = composeRoomWalls(room);
  drawArtCorner(g, room_wall_surfaces[room], ROOM_LEFT + 4, ROOM_TOP,
    ROOM_RIGHT - ROOM_LEFT - 8, deck_y[2] - ROOM_TOP);
  g.imageMode(CENTER);
}


void drawRoomTitle(PGraphics g){
  String title = roomTitle(screen);
  float actual_size = readableTextSize(16);
  float render_size = renderTextSize(actual_size);
  g.textSize(render_size);
  float tw = g.textWidth(title);

  float card_w = max(120, tw + 20);
  float card_h = 16;
  float card_x = (ROOM_LEFT + ROOM_RIGHT) / 2.0 - card_w / 2.0;
  float card_y = 61;

  // Sombra suave e discreta para profundidade sem peso excessivo
  g.noStroke();
  g.fill(0x25000000);
  g.rect(card_x - 1, card_y + 1, card_w + 2, card_h + 1, 4);
  g.fill(0x45000000);
  g.rect(card_x, card_y + 1, card_w, card_h, 3);

  // Card com a paleta dos cards de recursos
  g.fill(COL_PANEL);
  g.stroke(COL_BORDER);
  g.strokeWeight(1);
  g.rect(card_x, card_y, card_w, card_h, 3);

  // Linha sutil de realce no topo interno
  g.stroke(COL_CYAN_DARK);
  g.line(card_x + 3, card_y + 1, card_x + card_w - 3, card_y + 1);

  // Texto do nome da sala centralizado
  float text_y = card_y + (card_h - render_size) / 2.0;
  textCentered(g, title, (ROOM_LEFT + ROOM_RIGHT) / 2.0, text_y, 16, COL_CYAN);
}


String roomTitle(int room_screen){
  if (room_screen == SCREEN_COMMAND) return "SALA DE COMANDO";
  if (room_screen == SCREEN_MACHINES) return "SALA DE MÁQUINAS";
  if (room_screen == SCREEN_DEPOT) return "DEPÓSITO";
  return "DORMITÓRIO";
}



void drawDecks(PGraphics g){
  if (!hasFloorArt()){
    g.stroke(COL_BORDER);
    g.strokeWeight(2);

    for (int i = 0; i < DECK_COUNT; i++){
      g.fill(i == DECK_COUNT - 1 ? COL_PANEL_2 : COL_PANEL);
      g.line(ROOM_LEFT + 4, deck_y[i], ROOM_RIGHT - 4, deck_y[i]);
      g.rect(ROOM_LEFT + 4, deck_y[i], ROOM_RIGHT - ROOM_LEFT - 8, 4);
    }

    g.strokeWeight(1);
    return;
  }

  g.imageMode(CORNER);
  float start_x = ROOM_LEFT + 4;
  float total_w = ROOM_RIGHT - ROOM_LEFT - 8;

  for (int i = 0; i < DECK_COUNT; i++){
    PImage strip = art_deck_strip != null ? art_deck_strip[i] : null;
    if (strip != null){
      float strip_h = strip.height / (float) RENDER_SCALE;
      g.image(strip, round(start_x), round(deck_y[i]), total_w, strip_h);
    } else {
      g.stroke(COL_BORDER);
      g.strokeWeight(2);
      g.fill(i == DECK_COUNT - 1 ? COL_PANEL_2 : COL_PANEL);
      g.line(start_x, deck_y[i], start_x + total_w, deck_y[i]);
      g.rect(start_x, deck_y[i], total_w, 4);
      g.strokeWeight(1);
    }
  }

  g.imageMode(CENTER);
}


void drawLadders(PGraphics g){
  g.stroke(COL_ORANGE);
  g.strokeWeight(2);

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != screen) continue;
    float x = ladder_x[i];
    float y_top = deck_y[ladder_top_deck[i]];
    float y_bottom = deck_y[ladder_bottom_deck[i]];

    g.line(x - 5, y_top, x - 5, y_bottom);
    g.line(x + 5, y_top, x + 5, y_bottom);

    for (float y = y_top + 8; y < y_bottom; y += 8){
      g.line(x - 5, y, x + 5, y);
    }
  }

  g.strokeWeight(1);
}
/* A structural mounting bay interrupts the wall stripe and joins the deck rails.
   Door sprite, threshold and interaction coordinates remain unchanged. */
void drawDoorSurround(PGraphics g, int door){
  float x = door_x[door];
  float feet = door_y[door];
  float head = feet - ART_DOOR_H;
  float ceiling = head - 12;
  int deck = door_deck[door];
  if (deck >= 0 && deck < DECK_COUNT){
    ceiling = (deck == 0 ? ROOM_TOP : deck_y[deck - 1]) + 6;
  }
  ceiling = min(ceiling, head - 5);
  float half_w = ART_DOOR_W / 2;
  g.pushStyle();
  g.noStroke();
  // Translucent lintel retains the wall's lighting instead of forming a dark column.
  g.fill(53, 58, 58, 175);
  g.rect(x - half_w + 3, ceiling, ART_DOOR_W - 6, head - ceiling);
  g.fill(75, 80, 78, 130);
  g.rect(x - half_w + 3, head - 2, ART_DOOR_W - 6, 0.5);
  // A narrow chamfered seat follows the sprite; the wall stays visible at its sides.
  g.fill(45, 50, 51);
  g.stroke(72, 77, 75);
  g.strokeWeight(0.5);
  g.beginShape();
  g.vertex(x - half_w + 1, feet);
  g.vertex(x - half_w + 1, head + 5);
  g.vertex(x - half_w + 7, head - 1);
  g.vertex(x + half_w - 7, head - 1);
  g.vertex(x + half_w - 1, head + 5);
  g.vertex(x + half_w - 1, feet);
  g.endShape(CLOSE);
  g.noStroke();
  g.fill(37, 43, 45);
  g.rect(x - half_w, feet - 0.5, ART_DOOR_W, 1.5);
  g.fill(92, 99, 96);
  g.rect(x - half_w + 2, feet, ART_DOOR_W - 4, 0.5);
  g.popStyle();
}

void drawDoors(PGraphics g){
  for (int i = 0; i < DOOR_COUNT; i++){
    if (door_room[i] != screen) continue;

    float x = door_x[i];
    float y = door_y[i];
    boolean nearby = doorInRange(i);
    PImage art = doorFrame(i);

    if (art != null){
      drawDoorSurround(g, i);
      if (nearby){
        PImage glow = doorGlowFrame(i);
        if (glow != null){
          drawArt(g, glow, x, y - ART_DOOR_H / 2.0, ART_DOOR_W, ART_DOOR_H);
        }
      }
      drawArt(g, art, x, y - ART_DOOR_H / 2.0, ART_DOOR_W, ART_DOOR_H);
    } else {
      g.fill(nearby ? COL_CYAN_DARK : COL_PANEL_2);
      g.stroke(nearby ? COL_CYAN : COL_BORDER);
      g.rect(x - DOOR_W / 2.0, y - DOOR_H, DOOR_W, DOOR_H);
    }

    String room_name = roomTitle(door_target[i]);
    String prompt = "Pressione E";
    float door_h = (art != null) ? ART_DOOR_H : DOOR_H;
    float prompt_x = (art != null) ? x - 1.5 : x;
    float prompt_y = (art != null) ? y - 35.0 : y - DOOR_H / 2.0 - 2.75;
    float name_y = y - door_h - 9;
    int colour = nearby ? COL_CYAN : COL_TEXT;

    float min_left = ROOM_LEFT + 6;
    float max_right = ROOM_RIGHT - 6;
    if (screen == SCREEN_COMMAND){
      if (door_deck[i] == 2){
        max_right = 118;
      } else if (door_deck[i] == 1){
        min_left = 541;
      }
    }

    float avail_w = max_right - min_left;
    float name_size = fitTextSize(g, room_name, 16, avail_w);
    g.textSize(renderTextSize(name_size));
    float name_tw = g.textWidth(room_name);
    float cx = constrain(x, min_left + name_tw / 2.0, max_right - name_tw / 2.0);

    textCenteredShadow(g, room_name, cx, name_y, name_size, colour);

    if (nearby){
      textPromptShadow(g, prompt, prompt_x, prompt_y, 11, COL_CYAN);
    }
  }
}


final int DOOR_PHASE_CLOSED = 0;
final int DOOR_PHASE_OPENING = 1;
final int DOOR_PHASE_CLOSING = 2;

int door_transition_door = -1;
int door_transition_phase = DOOR_PHASE_CLOSED;
int door_transition_started = 0;
int door_transition_target = SCREEN_NONE;
int door_transition_return_door = -1;
float door_transition_arrival_x = 0;
float door_transition_arrival_y = 0;
int door_transition_facing = 1;


/* Closed frame by default; the travelling door shows the open frame while the
   room changes. With no door art, the geometric door stays as it is. */
PImage doorFrame(int index){
  PImage closed = artFrame(art_door_frames, 0);
  PImage open = art_door_frames != null && art_door_frames.length > 1 ? art_door_frames[1] : null;

  if (open != null && door_transition_door == index && doorTransitionActive()){
    return open;
  }

  return closed;
}

PImage doorGlowFrame(int index){
  PImage closed = artFrame(art_door_glow, 0);
  PImage open = art_door_glow != null && art_door_glow.length > 1 ? art_door_glow[1] : null;

  if (open != null && door_transition_door == index && doorTransitionActive()){
    return open;
  }

  return closed;
}


boolean doorInRange(int index){
  if (index < 0 || index >= DOOR_COUNT || door_room[index] != screen){
    return false;
  }

  float player_center_x = player_x + PLAYER_W / 2.0;
  float player_feet_y = player_y + PLAYER_H;
  return abs(player_center_x - door_x[index]) <= DOOR_RANGE
    && abs(player_feet_y - door_y[index]) <= DOOR_VERTICAL_RANGE;
}


int nearbyDoor(){
  for (int i = 0; i < DOOR_COUNT; i++){
    if (door_room[i] == screen && doorInRange(i)) return i;
  }

  return -1;
}


void drawRoomPoint(PGraphics g, int point){
  if (point_kind[point] == POINT_NPC){
    for (int crew = 0; crew < CREW_COUNT; crew++)
      if (crew_point[crew] == point && !crew_alive[crew]) return;
  }
  boolean available = pointIsAvailable(point);
  boolean nearby = available && isPointInRange(point);
  boolean npc = point_kind[point] == POINT_NPC;
  int colour = nearby || nextQuestPoint() == point ? COL_CYAN : (available ? COL_TEXT : COL_DIM);
  float x = point_x[point];
  float y = point_y[point];
  int npc_crew = npc ? crewIndexForName(point_label[point]) : -1;
  int npc_facing = npc ? npcFacingForPlayer(x, y) : 0;

  boolean is_quest = (point == nextQuestPoint()) || optionalVisualOverrideActive();
  boolean has_art = drawPointArt(g, point, x, y, nearby, is_quest);
  if (!has_art){
    if (!npc){
      g.stroke(nearby ? COL_CYAN : COL_BORDER);
      g.fill(nearby ? COL_CYAN_DARK : COL_PANEL);
      g.rect(x - 12, y - 22, 24, 18, 2);
      if (available) text(g, str(pointMarker(point_kind[point])), x - 3, y - 22, 16, colour);
    }
  }
  boolean show_label = npc || available;
  if (show_label){
    float label_y = (has_art && (point == POINT_TECH_BUNK || point == POINT_ANTENNA)) ? y - 62 : y - 44;
    textCenteredShadow(g, pointDisplayLabel(point), x, label_y, 16, colour);
  }
  if (point == nextQuestPoint()){
    String step = active_quest < 0 ? "CONFIRMAR" : quest_stage == QUEST_COLLECT ? "COLETAR" : "ENTREGAR";
    float step_y = (has_art && (point == POINT_TECH_BUNK || point == POINT_ANTENNA)) ? y - 73 : y - 55;
    textCenteredShadow(g, step, x, step_y, 16, COL_CYAN);
    if (active_quest >= 0 && quest_stage == QUEST_COLLECT) drawQuestObject(g, x + 18, y - 12);
  }

  if (nearby){
    if (!npc && !has_art){
      g.noFill();
      g.stroke(COL_CYAN);
      g.rect(x - 16, y - 26, 32, 26, 2);
    }
    textPromptShadow(g, "Pressione E", x, y - 31, 11, COL_CYAN);
  }

  if (point_kind[point] == POINT_NPC){
    drawNpc(g, x, y, npc_crew, npc_facing, nearby, is_quest);
  }
}




/* Art of a station or of the hull replaces the generic rectangle; NPC sprites
   are drawn by drawNpc. Returns false when the point keeps the geometry. */
boolean drawPointArt(PGraphics g, int point, float x, float y, boolean nearby, boolean quest_target){
  if (point_kind[point] == POINT_NPC){
    return false;
  }

  PImage art = point == POINT_HULL
    ? artFrame(art_hull_frames, ART_HULL_FRAME_MS)
    : (art_station == null ? null : art_station[point]);

  if (art == null){
    return false;
  }

  float w = art.width / (float) RENDER_SCALE;
  float h = art.height / (float) RENDER_SCALE;

  if (nearby){
    PImage glow = (art_station_glow != null && point < art_station_glow.length)
      ? art_station_glow[point]
      : null;
    if (glow != null){
      drawArt(g, glow, x, y - h / 2.0, w, h);
    }
  } else if (quest_target){
    PImage glow = (art_station_glow_orange != null && point < art_station_glow_orange.length)
      ? art_station_glow_orange[point]
      : null;
    if (glow != null){
      float pulse = (1.0 - cos(TWO_PI * (millis() % 2200) / 2200.0)) * 0.5;
      float alpha = lerp(80, 240, pulse);
      g.tint(255, alpha);
      drawArt(g, glow, x, y - h / 2.0, w, h);
      g.noTint();
    }
  }

  drawArt(g, art, x, y - h / 2.0, w, h);
  return true;
}

boolean drawPointArt(PGraphics g, int point, float x, float y, boolean nearby){
  return drawPointArt(g, point, x, y, nearby, false);
}

boolean drawPointArt(PGraphics g, int point, float x, float y){
  return drawPointArt(g, point, x, y, false, false);
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

  if (kind == POINT_END_DAY){
    return 'Z';
  }

  return '!';
}


int npcFacingForPlayer(float npc_x, float npc_y){
  boolean same_deck = player_grounded
    && abs((player_y + PLAYER_H) - npc_y) < 8;
  boolean player_jumping = !player_grounded && !player_on_ladder;
  if (!same_deck && !player_jumping){
    return 0;
  }
  return (player_x + PLAYER_W / 2.0 < npc_x) ? -1 : 1;
}


void drawNpc(PGraphics g, float x, float y, int crew, int facing, boolean nearby, boolean quest_target){
  PImage[] frames = crewArtFramesFacing(crew, facing);
  PImage[] glow_frames = crewArtGlowFramesFacing(crew, facing);
  PImage[] orange_glow_frames = crewArtOrangeGlowFramesFacing(crew, facing);
  int frame_count = frames == null ? 0 : frames.length;
  int frame_index = artFrameIndex(frame_count, ART_NPC_FRAME_MS);
  PImage art = frame_count == 0 ? null : frames[frame_index];

  if (art != null){
    if (nearby && glow_frames != null && frame_index < glow_frames.length){
      drawArt(g, glow_frames[frame_index], x, y - PLAYER_H / 2.0, ART_SPRITE_DRAW, ART_SPRITE_DRAW);
    } else if (quest_target && orange_glow_frames != null && frame_index < orange_glow_frames.length){
      float pulse = (1.0 - cos(TWO_PI * (millis() % 2200) / 2200.0)) * 0.5;
      float alpha = lerp(80, 240, pulse);
      g.tint(255, alpha);
      drawArt(g, orange_glow_frames[frame_index], x, y - PLAYER_H / 2.0, ART_SPRITE_DRAW, ART_SPRITE_DRAW);
      g.noTint();
    }
    drawArt(g, art, x, y - PLAYER_H / 2.0, ART_SPRITE_DRAW, ART_SPRITE_DRAW);
    return;
  }

  g.noStroke();
  g.fill(nearby ? COL_CYAN : (quest_target ? COL_ORANGE : COL_ORANGE));
  g.rect(x - PLAYER_W / 2.0, y - PLAYER_H, PLAYER_W, PLAYER_H);
  g.fill(COL_TEXT);
  int eye_offset = facing < 0 ? -2 : (facing > 0 ? 2 : 0);
  g.rect(x - 4 + eye_offset, y - 19, 2, 2);
  g.rect(x + 2 + eye_offset, y - 19, 2, 2);
}


void drawNpc(PGraphics g, float x, float y, String name, boolean nearby, boolean quest_target){
  int crew = crewIndexForName(name);
  int facing = npcFacingForPlayer(x, y);
  drawNpc(g, x, y, crew, facing, nearby, quest_target);
}


void drawNpc(PGraphics g, float x, float y, String name, boolean nearby){
  drawNpc(g, x, y, name, nearby, false);
}



void loadPlayerAssets(){
  player_sheet = loadImage(PLAYER_SHEET_FILE);
  player_sheet_data = loadJSONObject(PLAYER_SHEET_DATA_FILE);

  if (player_sheet == null || player_sheet_data == null){
    println("player: assets not loaded");
    return;
  }

  player_has_climb = false;
  player_has_jump = false;
  player_has_run = false;
  player_climb_start = -1;
  player_climb_end = -1;
  player_jump_start = -1;
  player_jump_end = -1;
  player_run_start = -1;
  player_run_end = -1;

  if (player_sheet_data.hasKey("frames")){
    /* Formato Aseprite: tira horizontal + metadados de frames */
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
        } else if (name.equals("climb")){
          player_climb_start = tag.getInt("from");
          player_climb_end = tag.getInt("to");
          player_has_climb = true;
        } else if (name.equals("jump")){
          player_jump_start = tag.getInt("from");
          player_jump_end = tag.getInt("to");
          player_has_jump = true;
        } else if (name.equals("run")){
          player_run_start = tag.getInt("from");
          player_run_end = tag.getInt("to");
          player_has_run = true;
        }
      }
    }
  } else {
    /* Formato Universal LPC (Liberated Pixel Cup): matriz 64x64 */
    boolean can_idle = player_sheet.height >= 26 * 64;
    boolean can_walk = player_sheet.height >= 12 * 64;
    boolean can_climb = player_sheet.height >= 22 * 64;
    boolean can_jump = player_sheet.height >= 30 * 64;
    boolean can_run = player_sheet.height >= 42 * 64;

    int idle_count = can_idle ? 2 : 1;
    int walk_count = can_walk ? 8 : 1;
    int climb_count = can_climb ? 6 : 0;
    int jump_count = can_jump ? 6 : 0;
    int run_count = can_run ? 8 : 0;
    int total_frames = idle_count + walk_count + climb_count + jump_count + run_count;

    player_frame_images = new PImage[total_frames];
    player_frame_durations = new int[total_frames];

    int idx = 0;

    /* 1. Idle: linha 25 (Leste / perfil direito), 2 quadros de 500 ms */
    player_idle_start = idx;
    if (can_idle){
      for (int col = 0; col < 2; col++){
        player_frame_images[idx] = player_sheet.get(col * 64, 25 * 64, 64, 64);
        player_frame_durations[idx] = 500;
        idx++;
      }
    } else {
      player_frame_images[idx] = player_sheet.get(0, 11 * 64, 64, 64);
      player_frame_durations[idx] = 500;
      idx++;
    }
    player_idle_end = idx - 1;

    /* 2. Walk: linha 11 (Leste / perfil direito), 8 passos de 100 ms (cols 1..8) */
    player_walk_start = idx;
    if (can_walk){
      for (int col = 1; col <= 8; col++){
        player_frame_images[idx] = player_sheet.get(col * 64, 11 * 64, 64, 64);
        player_frame_durations[idx] = 100;
        idx++;
      }
    } else {
      player_frame_images[idx] = player_sheet.get(0, 0, 64, 64);
      player_frame_durations[idx] = 100;
      idx++;
    }
    player_walk_end = idx - 1;

    /* 3. Climb: linha 21 (subida de costas), 6 quadros de 140 ms (cols 0..5) */
    if (can_climb){
      player_climb_start = idx;
      for (int col = 0; col < 6; col++){
        player_frame_images[idx] = player_sheet.get(col * 64, 21 * 64, 64, 64);
        player_frame_durations[idx] = 140;
        idx++;
      }
      player_climb_end = idx - 1;
      player_has_climb = true;
    }

    /* 4. Jump: linha 29 (Leste / perfil direito), sequencia canonica LPC 0-1-2-3-4-1 (6 quadros de 75 ms) */
    if (can_jump){
      player_jump_start = idx;
      int[] jump_cols = {0, 1, 2, 3, 4, 1};
      for (int i = 0; i < jump_cols.length; i++){
        player_frame_images[idx] = player_sheet.get(jump_cols[i] * 64, 29 * 64, 64, 64);
        player_frame_durations[idx] = 75;
        idx++;
      }
      player_jump_end = idx - 1;
      player_has_jump = true;
    }

    /* 5. Run: linha 41 (Leste / perfil direito), 8 quadros de 75 ms (cols 0..7) */
    if (can_run){
      player_run_start = idx;
      for (int col = 0; col < 8; col++){
        player_frame_images[idx] = player_sheet.get(col * 64, 41 * 64, 64, 64);
        player_frame_durations[idx] = 75;
        idx++;
      }
      player_run_end = idx - 1;
      player_has_run = true;
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


/* Animation states: run falls back to walk when the sheet has no run frames
   (Aseprite without the tag), so the technician never freezes mid-sprint. */
final int PLAYER_ANIM_IDLE = 0;
final int PLAYER_ANIM_WALK = 1;
final int PLAYER_ANIM_CLIMB = 2;
final int PLAYER_ANIM_JUMP = 3;
final int PLAYER_ANIM_RUN = 4;


/* Shift only sprints on a deck, and only with one direction held: left+right
   cancels out, so running in place would be noise. */
boolean playerIsRunning(){
  return run_held && (move_left_held != move_right_held) && player_grounded && !player_on_ladder;
}


int playerCurrentAnimationState(){
  if (player_has_climb && player_on_ladder){
    return PLAYER_ANIM_CLIMB;
  }
  if (player_has_jump && !player_grounded && !player_on_ladder){
    return PLAYER_ANIM_JUMP;
  }
  if (playerIsRunning()){
    return player_has_run ? PLAYER_ANIM_RUN : PLAYER_ANIM_WALK;
  }
  if (playerIsMoving()){
    return PLAYER_ANIM_WALK;
  }
  return PLAYER_ANIM_IDLE;
}


int playerCurrentFrame(){
  if (!player_assets_loaded){
    return 0;
  }

  int state = playerCurrentAnimationState();
  boolean climb_moving = (state == PLAYER_ANIM_CLIMB && (move_up_held || move_down_held));
  if (state != player_anim_state || (state == PLAYER_ANIM_CLIMB && climb_moving != player_animation_moving)){
    player_anim_state = state;
    player_animation_moving = (state == PLAYER_ANIM_WALK || climb_moving);
    player_animation_started_at = millis();
  }

  int first = player_idle_start;
  int last = player_idle_end;

  if (state == PLAYER_ANIM_WALK){
    first = player_walk_start;
    last = player_walk_end;
  } else if (state == PLAYER_ANIM_RUN){
    first = player_run_start;
    last = player_run_end;
  } else if (state == PLAYER_ANIM_CLIMB && player_has_climb){
    first = player_climb_start;
    last = player_climb_end;
    if (!move_up_held && !move_down_held){
      return first;
    }
  } else if (state == PLAYER_ANIM_JUMP && player_has_jump){
    first = player_jump_start;
    last = player_jump_end;
  }

  int total_duration = 0;
  for (int index = first; index <= last; index++){
    total_duration += max(1, player_frame_durations[index]);
  }

  int frame = first;
  int raw_elapsed = max(0, millis() - player_animation_started_at);
  int elapsed = (state == PLAYER_ANIM_JUMP)
    ? min(raw_elapsed, total_duration - 1)
    : (total_duration > 0 ? raw_elapsed % total_duration : 0);

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



void enterRoom(int next_screen){
  int door = doorInRoomLeadingTo(SCREEN_COMMAND, next_screen);

  if (door >= 0){
    enterRoomAtPosition(
      next_screen,
      door_arrival_y[door],
      door_arrival_x[door],
      door_arrival_facing[door]
    );
    return;
  }

  enterRoomAtPosition(next_screen, deck_y[DECK_COUNT - 1], ROOM_LEFT + 28, 1);
}



int doorInRoomLeadingTo(int room_id, int target){
  for (int i = 0; i < DOOR_COUNT; i++){
    if (door_room[i] == room_id && door_target[i] == target) return i;
  }

  return -1;
}

void enterRoomThroughDoor(int door){
  if (!preparePortalTransition(door)){
    return;
  }

  playSound(sound_door);
  if (doorFrame(door) != null){
    startDoorTransition(door);
    return;
  }

  enterRoomAtPosition(
    portal_prepared_target_room,
    portal_prepared_arrival_y,
    portal_prepared_arrival_x,
    portal_prepared_arrival_facing
  );
  portal_transition_prepared = false;
}


void enterRoomAtPosition(int next_screen, float feet_y, float center_x, int facing){
  screen = next_screen;
  current_room = next_screen;
  player_facing = facing;
  float clamped_feet_y = constrain(feet_y, ROOM_TOP + PLAYER_H, ROOM_BOTTOM);
  player_x = constrain(center_x - PLAYER_W / 2.0,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
  player_y = clamped_feet_y - PLAYER_H;
  player_velocity_y = 0;
  player_grounded = isDeckSurface(clamped_feet_y);
  player_on_ladder = false;
  current_ladder = -1;
  ladder_vertical_release_required = false;
  jump_queued = false;
  player_step_accum = 0;
  walk_step_active = false;
  walk_step_phase = 0;
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
  run_held = false;
  ladder_climbing_active = false;
  ladder_steps_taken = 0;
  ladder_step_accum = 0;
  player_step_accum = 0;
  walk_step_active = false;
  walk_step_phase = 0;
  interact_queued = false;
  held_item = ITEM_NONE;
  map_open = false;
  dialog_open = false;
  dialog_result = "";
  dialog_crew = -1;
  technical_open = false;
  pending_quest_action = ACTION_NONE;
  pending_retry = -1;
  end_day_open = false;
  help_open = false;
  last_portal_valid = false;
  portal_transition_prepared = false;
  portal_prepared_door = -1;
  portal_prepared_from_room = SCREEN_NONE;
  portal_prepared_target_room = SCREEN_NONE;
  portal_prepared_return_door = -1;
  portal_prepared_returning = false;
  door_transition_door = -1;
  door_transition_phase = DOOR_PHASE_CLOSED;
  door_transition_target = SCREEN_NONE;
  door_transition_return_door = -1;
}


void updatePlayerOnDeck(){
  boolean was_airborne = !player_grounded;
  if (jump_queued && player_grounded){
    player_velocity_y = -sqrt(2 * GRAVITY * JUMP_HEIGHT);
    player_grounded = false;
    player_step_accum = 0;
    walk_step_active = false;
    playDeckStepSound(false);
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

  boolean landed = was_airborne && player_grounded;
  if (landed){
    playDeckStepSound(false);
    player_step_accum = 0;
    walk_step_active = false;
  }

  /* O passo sai do mesmo predicado da animação, e depois do convés resolver a
     gravidade: no quadro da decolagem a velocidade já é a do ar, como o quadro
     desenhado (D-153). */
  float horizontal = 0;
  float speed = playerIsRunning() ? PLAYER_RUN_SPEED : PLAYER_SPEED;

  if (move_left_held){
    horizontal -= speed;
  }

  if (move_right_held){
    horizontal += speed;
  }

  player_x = constrain(player_x + horizontal, ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);

  if (player_grounded && horizontal != 0){
    boolean running = playerIsRunning();
    if (running){
      walk_step_active = false;
      if (player_step_accum <= 0 && !landed){
        playDeckStepSound(true);
      }
      player_step_accum += abs(horizontal);
      if (player_step_accum >= RUN_STEP_SPACING){
        player_step_accum -= RUN_STEP_SPACING;
        playDeckStepSound(true);
      }
    } else {
      player_step_accum = 0;
      int phase = (max(0, millis() - player_animation_started_at)
        / WALK_STEP_HALF_CYCLE_MS) % 2;
      if (!walk_step_active){
        player_animation_started_at = millis();
        walk_step_phase = 0;
        walk_step_active = true;
        if (!landed) playDeckStepSound(false);
      } else if (phase != walk_step_phase){
        walk_step_phase = phase;
        playDeckStepSound(false);
      }
    }
  } else {
    player_step_accum = 0;
    walk_step_active = false;
  }

  boolean vertical_input = move_up_held || move_down_held;
  boolean horizontal_input = move_left_held || move_right_held;

  if (!vertical_input){
    ladder_vertical_release_required = false;
  }

  if (vertical_input && !horizontal_input && !ladder_vertical_release_required
    && player_grounded){
    int ladder = nearestLadder();

    if (ladder >= 0){
      current_ladder = ladder;
      player_on_ladder = true;
      player_grounded = false;
      player_x = ladder_x[ladder] - PLAYER_W / 2.0;
      player_velocity_y = 0;
      ladder_climbing_active = false;
      ladder_steps_taken = 0;
      ladder_step_accum = 0;
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

  if (current_ladder < 0){
    current_ladder = activeLadderIndex();
  }

  int top_deck = current_ladder >= 0 ? ladder_top_deck[current_ladder] : 0;
  int bot_deck = current_ladder >= 0 ? ladder_bottom_deck[current_ladder] : DECK_COUNT - 1;

  float old_y = player_y;
  player_y += vertical * LADDER_SPEED;
  float top = deck_y[top_deck] - PLAYER_H;
  float bottom = deck_y[bot_deck] - PLAYER_H;
  player_y = constrain(player_y, top, bottom);

  float dy = abs(player_y - old_y);
  if (dy > 0){
    if (!ladder_climbing_active){
      ladder_climbing_active = true;
      ladder_steps_taken = 0;
      ladder_step_accum = 0;
    }
    ladder_step_accum += dy;
    float threshold = (ladder_steps_taken == 0) ? LADDER_FIRST_STEP : LADDER_STEP_SPACING;
    if (ladder_step_accum >= threshold){
      ladder_step_accum = 0;
      ladder_steps_taken++;
      playLadderStepSound();
    }
  } else {
    ladder_climbing_active = false;
    ladder_steps_taken = 0;
    ladder_step_accum = 0;
  }

  boolean wants_deck = horizontal != 0 || vertical == 0;
  int deck = ladderDeckAt(old_y, player_y, wants_deck);

  if (deck >= 0 && wants_deck){
    leaveLadderAtDeck(deck, horizontal);
    return;
  }

  if (player_y <= top || player_y >= bottom){
    int end_deck = player_y <= top ? top_deck : bot_deck;
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


/* The grab sound plays when the technician leaves the ladder, never on mount:
   the climb itself is covered by the steps (#28).
   Cadence: 27 px gives a small pause between takes while staying close to the
   420 ms half-cycle (3 frames @ 140 ms) of LPC climb;
   initial step at 1 px ensures instant audio feedback upon starting to climb. */
/* Walk follows the 800 ms LPC animation: one contact every 400 ms. Run keeps
   the approved distance cadence; ladder remains independent (#28). */
final int WALK_STEP_HALF_CYCLE_MS = 400;
final float RUN_STEP_SPACING = 27;
final float LADDER_STEP_SPACING = 27;
final float LADDER_FIRST_STEP = 1;
float ladder_step_accum = 0;
int ladder_steps_taken = 0;
float player_step_accum = 0;
boolean walk_step_active = false;
int walk_step_phase = 0;
boolean ladder_climbing_active = false;


void leaveLadderAtDeck(int deck, int horizontal){
  playSound(sound_ladder);
  player_y = deck_y[deck] - PLAYER_H;
  player_x = constrain(player_x + horizontal * PLAYER_SPEED,
    ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W);
  current_ladder = -1;
  player_on_ladder = false;
  player_grounded = true;
  player_velocity_y = 0;
  ladder_vertical_release_required = move_up_held || move_down_held;
  ladder_climbing_active = false;
  ladder_steps_taken = 0;
  ladder_step_accum = 0;
  player_step_accum = 0;
  walk_step_active = false;
  walk_step_phase = 0;
}


int activeLadderIndex(){
  float center_x = player_x + PLAYER_W / 2.0;
  int best = -1;
  float best_dist = 1000;

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != screen) continue;
    float top_y = deck_y[ladder_top_deck[i]] - PLAYER_H - 2;
    float bot_y = deck_y[ladder_bottom_deck[i]] + 2;
    if (player_y < top_y || player_y > bot_y) continue;
    float dist = abs(center_x - ladder_x[i]);
    if (dist < best_dist){
      best_dist = dist;
      best = i;
    }
  }

  return best;
}


int nearestLadder(){
  if (!player_grounded){
    return -1;
  }

  float center_x = player_x + PLAYER_W / 2.0;
  float bottom = player_y + PLAYER_H;

  int current_deck = -1;
  for (int i = 0; i < DECK_COUNT; i++){
    if (abs(bottom - deck_y[i]) < 1.1){
      current_deck = i;
      break;
    }
  }

  if (current_deck < 0){
    return -1;
  }

  int result = -1;
  float best_distance = INTERACTION_RANGE + 1;

  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != screen) continue;

    if (current_deck < ladder_top_deck[i] || current_deck > ladder_bottom_deck[i]){
      continue;
    }

    if (current_deck == ladder_top_deck[i] && !move_down_held){
      continue;
    }
    if (current_deck == ladder_bottom_deck[i] && !move_up_held){
      continue;
    }

    float distance = abs(center_x - ladder_x[i]);

    if (distance <= INTERACTION_RANGE && distance < best_distance){
      result = i;
      best_distance = distance;
    }
  }

  return result;
}


float ladderX(int room_id, int slot){
  for (int i = 0; i < LADDER_COUNT; i++){
    if (ladder_room[i] != room_id) continue;
    if (slot-- == 0) return ladder_x[i];
  }

  return 0;
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
  float best_distance = Float.MAX_VALUE;

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


float pointInteractionRange(int point){
  if (point == POINT_ROUTE || point == POINT_TECH_BUNK || point == POINT_COMMON_TABLE || point == POINT_CONFLICT || point == POINT_RISK_BUNK || point == POINT_STOCK || point == POINT_RESERVE || point == POINT_ANTENNA){
    if (art_station != null && point < art_station.length && art_station[point] != null){
      return (art_station[point].width / (float) RENDER_SCALE) / 2.0 + 4;
    }
    return 40;
  }
  return (point_kind[point] == POINT_NPC) ? NPC_INTERACTION_RANGE : INTERACTION_RANGE;
}


boolean isPointInRange(int point){
  float player_center_x = player_x + PLAYER_W / 2.0;
  float player_bottom = player_y + PLAYER_H;
  return abs(player_center_x - point_x[point]) <= pointInteractionRange(point)
    && abs(player_bottom - point_y[point]) <= 3;
}

void drawQuestObject(PGraphics g, float x, float y){
  PImage art = questObjectArt(questObjectShown());

  if (art != null){
    drawArt(g, art, x, y, ART_SPRITE_DRAW, ART_SPRITE_DRAW);
    return;
  }

  g.stroke(COL_ORANGE);
  g.fill(COL_PANEL_2);
  g.rect(x - 4, y - 4, 8, 8);
  g.line(x - 2, y, x + 2, y);
}


/* Object on screen: the one in hand, or the quest at its collect step. */
int questObjectShown(){
  if (held_item > 0){
    return held_item - 1;
  }

  return active_quest >= 0 ? active_quest : selected_preventive_id;
}
