final int ROOM_COUNT = 4;
final float MAP_SHIP_X = 38;
final float MAP_SHIP_Y = 88;
final float MAP_SHIP_W = 564;
final float MAP_SHIP_H = 210;
final float MAP_SOURCE_W = 2057;
final float MAP_SOURCE_H = 764;
final float MAP_ROOM_SOURCE_W = 510;
final float MAP_ROOM_SOURCE_H = 185;

String[] room_label = {"COMANDO", "MÁQUINAS", "DEPÓSITO", "DORMITÓRIO"};
float[] map_room_source_x = {480, 480, 1067, 1067};
float[] map_room_source_y = {164, 421, 421, 164};
float[] room_x = new float[ROOM_COUNT];
float[] room_y = new float[ROOM_COUNT];
float[] room_w = new float[ROOM_COUNT];
float[] room_h = new float[ROOM_COUNT];
int[] room_screen = {SCREEN_COMMAND, SCREEN_MACHINES, SCREEN_DEPOT, SCREEN_DORMITORY};

float[] deck_y = {128, 202, 278};
final int LADDER_PER_ROOM = 2;
final int LADDER_COUNT = LADDER_PER_ROOM * ROOM_COUNT;
int[] ladder_room = {
  SCREEN_COMMAND, SCREEN_COMMAND, SCREEN_MACHINES, SCREEN_MACHINES,
  SCREEN_DEPOT, SCREEN_DEPOT, SCREEN_DORMITORY, SCREEN_DORMITORY
};
float[] ladder_x = {127, 532, 468, 136, 520, 130, 542, 243};
int[] ladder_top_deck = {
  1, 0, 1, 0, 1, 0, 1, 0
};
int[] ladder_bottom_deck = {
  2, 1, 2, 1, 2, 1, 2, 1
};
int current_ladder = -1;

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
int[] door_deck = {0, 1, 2, 0, 1, 2};
float[] door_x = {
  40, 598, 88,
  40, 45, 88
};
float[] door_y = {
  deck_y[0], deck_y[1], deck_y[2],
  deck_y[0], deck_y[1], deck_y[2]
};
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
  drawModalShade(g);
  drawPanel(g, 16, 60, 608, 270, COL_CYAN);

  updateMapRoomLayout();
  text(g, "MAPA DA NAVE", 32, 70, 16, COL_CYAN);

  if (art_map_ship != null){
    drawArtCorner(g, art_map_ship, MAP_SHIP_X, MAP_SHIP_Y, MAP_SHIP_W, MAP_SHIP_H);
  } else {
    g.noStroke();
    g.fill(COL_ROOM);
    g.rect(MAP_SHIP_X, MAP_SHIP_Y, MAP_SHIP_W, MAP_SHIP_H, 4);
  }

  for (int i = 0; i < ROOM_COUNT; i++){
    drawMapRoomCard(g, i);
  }

  drawModalFooter(g, 300, "", ACTION_NONE, false,
    "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
}


void updateMapRoomLayout(){
  for (int room = 0; room < ROOM_COUNT; room++){
    room_x[room] = MAP_SHIP_X + map_room_source_x[room] / MAP_SOURCE_W * MAP_SHIP_W;
    room_y[room] = MAP_SHIP_Y + map_room_source_y[room] / MAP_SOURCE_H * MAP_SHIP_H;
    room_w[room] = MAP_ROOM_SOURCE_W / MAP_SOURCE_W * MAP_SHIP_W;
    room_h[room] = MAP_ROOM_SOURCE_H / MAP_SOURCE_H * MAP_SHIP_H;
  }
}


void drawMapRoomCard(PGraphics g, int index){
  int objective_point = currentObjective();
  int objective_room = objective_point >= 0 && objective_point < point_room.length
    ? point_room[objective_point] : SCREEN_NONE;
  boolean current = room_screen[index] == screen;
  boolean objective = room_screen[index] == objective_room;
  int border = current || objective ? COL_CYAN : COL_BORDER;

  drawPanel(g, room_x[index], room_y[index], room_w[index], room_h[index], border);
  drawArtCorner(g, art_map == null ? null : art_map[index], room_x[index], room_y[index],
    room_w[index], room_h[index]);
  g.noFill();
  g.stroke(border);
  g.strokeWeight(current || objective ? 2 : 1);
  g.rect(room_x[index], room_y[index], room_w[index], room_h[index], 2);
  g.strokeWeight(1);

  g.noStroke();
  g.fill(COL_BG, 220);
  float label_w = min(room_w[index] - 4, max(42.0f, room_label[index].length() * 5.5f));
  g.rect(room_x[index] + (room_w[index] - label_w) / 2.0,
    room_y[index] + 2, label_w, 10, 2);
  textCentered(g, room_label[index], room_x[index] + room_w[index] / 2.0,
    room_y[index] + 3, 9, objective ? COL_CYAN : COL_TEXT);

  int alert_count = roomProblemCount(room_screen[index]);
  String status = "";
  int status_color = COL_MUTED;
  if (alert_count > 0){
    status = "!" + alert_count;
    status_color = COL_RED;
  }
  if (current){
    status = appendMapStatus(status, "VOCÊ ESTÁ AQUI");
    status_color = COL_ORANGE;
  }
  if (objective){
    status = appendMapStatus(status, "OBJETIVO");
    status_color = COL_GREEN;
  }
  if (status.length() > 0){
    g.noStroke();
    textCentered(g, status, room_x[index] + room_w[index] / 2.0,
      room_y[index] + room_h[index] - 10, 8, status_color);
  }
}


String appendMapStatus(String current, String value){
  return current.length() == 0 ? value : current + " · " + value;
}
int roomIndex(int room_id){
  for (int i = 0; i < ROOM_COUNT; i++){
    if (room_screen[i] == room_id){
      return i;
    }
  }

  return 0;
}


int roomIndexOrInvalid(int room_id){
  for (int i = 0; i < ROOM_COUNT; i++){
    if (room_screen[i] == room_id){
      return i;
    }
  }

  return -1;
}


void drawRoom(PGraphics g){
  PImage backdrop = art_backdrop == null ? null : art_backdrop[roomIndex(screen)];

  if (backdrop != null){
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


HashMap<String, PImage> room_detail_cache = new HashMap<String, PImage>();
HashMap<String, PImage> room_detail_last_valid_cache = new HashMap<String, PImage>();
PImage[] room_wall_surfaces = new PImage[ROOM_COUNT];

PImage roomDetail(String name){
  if (name == null || name.length() == 0){
    throw new IllegalArgumentException("o nome do detalhe da sala é obrigatório");
  }
  if (room_detail_cache.containsKey(name)){
    return room_detail_cache.get(name);
  }

  String data_path = ART_DECORATION_DIR + name + ".png";
  PImage art = loadArt(data_path);
  if (art == null){
    art = loadLegacyRoomArt(name);
  }
  PImage last_valid = room_detail_last_valid_cache.get(name);
  if (art == null && last_valid != null){
    art = last_valid;

  } else if (art != null && art != last_valid){
    room_detail_last_valid_cache.put(name, art);
    invalidateRoomDetailSurfaces();
  }
  room_detail_cache.put(name, art);
  return art;
}


void invalidateRoomDetailSurfaces(){
  for (int room = 0; room < room_wall_surfaces.length; room++){
    room_wall_surfaces[room] = null;
  }
  room_vent_strip = null;
  for (int view = 0; view < room_window_views.length; view++){
    room_window_views[view] = null;
  }
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
    wall.noStroke();
    for (int y = 0; y < height; y++){
      float edge = abs((y / (float) height) * 2 - 1);
      wall.fill(5, 12, 18, 22 + 55 * edge * edge);
      wall.rect(0, top + y, w, 1);
    }
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

  g.noStroke();
  g.fill(0x25000000);
  g.rect(card_x - 1, card_y + 1, card_w + 2, card_h + 1, 4);
  g.fill(0x45000000);
  g.rect(card_x, card_y + 1, card_w, card_h, 3);

  g.fill(COL_PANEL);
  g.stroke(COL_BORDER);
  g.strokeWeight(1);
  g.rect(card_x, card_y, card_w, card_h, 3);

  g.stroke(COL_CYAN_DARK);
  g.line(card_x + 3, card_y + 1, card_x + card_w - 3, card_y + 1);

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
  g.fill(53, 58, 58, 175);
  g.rect(x - half_w + 3, ceiling, ART_DOOR_W - 6, head - ceiling);
  g.fill(75, 80, 78, 130);
  g.rect(x - half_w + 3, head - 2, ART_DOOR_W - 6, 0.5);
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

  boolean is_quest = point == nextQuestPoint();
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
      float pulse = (1.0 - cos(TWO_PI * (presentationTimeMillis() % 2200) / 2200.0)) * 0.5;
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
  int frame_count = frames == null ? 0 : frames.length;
  int frame_index = artFrameIndex(frame_count, ART_NPC_FRAME_MS);
  PImage art = resolveNpcArt(crew, facing, frame_index);
  PImage glow = resolveNpcArt(crew, facing, frame_index, NPC_ART_CYAN_GLOW);
  PImage orange_glow = resolveNpcArt(crew, facing, frame_index, NPC_ART_ORANGE_GLOW);

  if (art != null){
    if (nearby && glow != null){
      drawArt(g, glow, x, y - PLAYER_H / 2.0, ART_SPRITE_DRAW, ART_SPRITE_DRAW);
    } else if (quest_target && orange_glow != null){
      float pulse = (1.0 - cos(TWO_PI * (presentationTimeMillis() % 2200) / 2200.0)) * 0.5;
      float alpha = lerp(80, 240, pulse);
      g.tint(255, alpha);
      drawArt(g, orange_glow, x, y - PLAYER_H / 2.0, ART_SPRITE_DRAW, ART_SPRITE_DRAW);
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
  player_assets_loaded = false;
  player_sheet = loadSpriteSheet(PLAYER_SHEET_FILE);
  player_sheet_data = readArtMetadata(PLAYER_SHEET_DATA_FILE);

  if (player_sheet == null){
    println("player: assets not loaded");
    return;
  }

  if (player_sheet.width < 64 || player_sheet.height < 64){

    println("player: spritesheet incomplete");
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

  if (player_sheet_data != null && player_sheet_data.hasKey("frames")){
    try {
      player_sheet_frames = player_sheet_data.getJSONArray("frames");
    } catch (RuntimeException error){

      return;
    }
    if (player_sheet_frames == null || player_sheet_frames.size() == 0){

      println("player: no frames in JSON");
      return;
    }

    int frame_count = player_sheet_frames.size();
    player_frame_images = new PImage[frame_count];
    player_frame_durations = new int[frame_count];

    boolean frames_valid = true;
    for (int i = 0; i < frame_count; i++){
      try {
        JSONObject frame_data = player_sheet_frames.getJSONObject(i);
        JSONObject frame_rect = frame_data.getJSONObject("frame");
        player_frame_images[i] = safeFrameFromRect(player_sheet, frame_rect);
        player_frame_durations[i] = max(1, frame_data.getInt("duration"));
      } catch (RuntimeException error){
        frames_valid = false;
      }
      frames_valid &= player_frame_images[i] != null;
    }

    if (!frames_valid){

      player_frame_images = null;
      player_frame_durations = null;
      return;
    }

    player_idle_start = 0;
    player_idle_end = 0;
    player_walk_start = 0;
    player_walk_end = frame_count - 1;

    try {
      JSONObject meta = player_sheet_data.hasKey("meta")
        ? player_sheet_data.getJSONObject("meta") : null;
      if (meta != null && meta.hasKey("frameTags")){
        JSONArray tags = meta.getJSONArray("frameTags");
        if (tags == null){
          throw new RuntimeException("frameTags ausente");
        }
        for (int i = 0; i < tags.size(); i++){
          JSONObject tag = tags.getJSONObject(i);
          String name = tag.getString("name");
          int from = tag.getInt("from");
          int to = tag.getInt("to");
          if (from < 0 || to < from || to >= frame_count){
            throw new RuntimeException("frame tag fora dos limites");
          }
          if (name.equals("idle")){
            player_idle_start = from;
            player_idle_end = to;
          } else if (name.equals("walk")){
            player_walk_start = from;
            player_walk_end = to;
          } else if (name.equals("climb")){
            player_climb_start = from;
            player_climb_end = to;
            player_has_climb = true;
          } else if (name.equals("jump")){
            player_jump_start = from;
            player_jump_end = to;
            player_has_jump = true;
          } else if (name.equals("run")){
            player_run_start = from;
            player_run_end = to;
            player_has_run = true;
          }
        }
      }
    } catch (RuntimeException error){

      player_idle_start = 0;
      player_idle_end = 0;
      player_walk_start = 0;
      player_walk_end = frame_count - 1;
      player_climb_start = -1;
      player_climb_end = -1;
      player_jump_start = -1;
      player_jump_end = -1;
      player_run_start = -1;
      player_run_end = -1;
      player_has_climb = false;
      player_has_jump = false;
      player_has_run = false;
    }
  } else {
    boolean can_idle = player_sheet.width >= 2 * 64
      && player_sheet.height >= 26 * 64;
    boolean can_walk = player_sheet.width >= 9 * 64
      && player_sheet.height >= 12 * 64;
    boolean can_climb = player_sheet.width >= 6 * 64
      && player_sheet.height >= 22 * 64;
    boolean can_jump = player_sheet.width >= 5 * 64
      && player_sheet.height >= 30 * 64;
    boolean can_run = player_sheet.width >= 8 * 64
      && player_sheet.height >= 42 * 64;

    if (!can_walk){

      player_frame_images = null;
      player_frame_durations = null;
      return;
    }

    int idle_count = can_idle ? 2 : 1;
    int walk_count = can_walk ? 8 : 1;
    int climb_count = can_climb ? 6 : 0;
    int jump_count = can_jump ? 6 : 0;
    int run_count = can_run ? 8 : 0;
    int total_frames = idle_count + walk_count + climb_count + jump_count + run_count;

    player_frame_images = new PImage[total_frames];
    player_frame_durations = new int[total_frames];

    int idx = 0;

    player_idle_start = idx;
    if (can_idle){
      for (int col = 0; col < 2; col++){
        player_frame_images[idx] = player_sheet.get(col * 64, 25 * 64, 64, 64);
        player_frame_durations[idx] = 500;
        idx++;
      }
    } else {
      player_frame_images[idx] = player_sheet.get(0, 0, 64, 64);
      player_frame_durations[idx] = 500;
      idx++;
    }
    player_idle_end = idx - 1;

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

  if (player_frame_images == null || player_frame_images.length == 0){
    return;
  }

  player_frame_layer = null;
  player_frame_layer_staging = null;
  player_frame_layer_valid = false;
  player_rendered_frame = -1;
  player_rendered_facing = 0;
  try {
    player_frame_layer = createGraphics(
      PLAYER_DRAW_W * RENDER_SCALE,
      PLAYER_DRAW_H * RENDER_SCALE
    );
    if (player_frame_layer != null){
      player_frame_layer.noSmooth();
    } else {
      rememberPlayerFrameLayerFailure(-1, player_facing);
    }
  } catch (RuntimeException error){
    player_frame_layer = null;
    rememberPlayerFrameLayerFailure(-1, player_facing);
  }
  player_assets_loaded = true;
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
  ladder_step_phase = 0;
  player_step_accum = 0;
  walk_step_accum = 0;
  walk_step_active = false;
  walk_step_phase = 0;
  run_step_phase = 0;
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
  clearPreparedPortalTransition();
  door_transition_door = -1;
  door_transition_phase = DOOR_PHASE_CLOSED;
  door_transition_started = 0;
  door_transition_target = SCREEN_NONE;
  door_transition_return_door = -1;
  door_transition_arrival_x = 0;
  door_transition_arrival_y = 0;
  door_transition_facing = 1;
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


int questObjectShown(){
  if (held_item > 0){
    return held_item - 1;
  }

  return active_quest >= 0 ? active_quest : selected_preventive_id;
}
