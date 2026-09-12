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

  textCentered(g, "ARES-7", SIDE_X / 2.0, 232, 13, COL_CYAN);
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
  drawBackdrop(g, 8, 62, SIDE_X - 16, 192);

  if (screen == SCREEN_COMMAND){
    drawCommandRoom(g);
    return;
  }

  if (screen == SCREEN_ENERGY){
    drawEnergyRoom(g);
    return;
  }

  if (screen == SCREEN_DEPOT){
    drawDepotRoom(g);
    return;
  }

  drawDormitoryRoom(g);
}


void drawCommandRoom(PGraphics g){
  text(g, "SALA DE COMANDO", 18, 70, 12, COL_CYAN);

  drawPanel(g, 24, 92, 424, 106, COL_BORDER);
  text(g, "ROTA TERRA - MARTE", 34, 100, 9, COL_MUTED);

  g.stroke(COL_CYAN_DARK);
  g.line(56, 150, 416, 150);
  g.noStroke();

  float progress = constrain((day - 1) / (float) trip_days, 0, 1);

  g.fill(COL_CYAN);
  g.ellipse(56 + 360 * progress, 150, 10, 10);
  g.fill(COL_ORANGE);
  g.ellipse(416, 150, 14, 14);

  text(g, "TERRA", 42, 166, 9, COL_MUTED);
  text(g, "MARTE", 404, 166, 9, COL_ORANGE);

  text(g, "DIA " + day + " DE " + trip_days, 34, 216, 11, COL_TEXT);
  text(g, "RESTAM " + max(trip_days - day, 0) + " DIAS DE VIAGEM", 224, 216, 11, COL_MUTED);
  text(g, "TÉCNICO: " + player_name, 34, 236, 10, COL_MUTED);
}


void drawEnergyRoom(PGraphics g){
  text(g, "SALA DE ENERGIA", 18, 70, 12, COL_CYAN);

  drawPanel(g, 24, 92, 190, 110, COL_BORDER);
  text(g, "MOTOR", 34, 100, 9, COL_MUTED);
  text(g, engineStateLabel(), 34, 114, 13, engine_state == ENGINE_WORKING ? COL_GREEN : COL_RED);
  text(g, "DIAS DANIFICADO: " + engine_damaged_days + "/" + ENGINE_DAMAGED_LIMIT_DAYS, 34, 140, 9, COL_MUTED);
  text(g, "ENERGIA NA BATERIA: " + str(int(energy)), 34, 160, 9, resourceColour(energy));

  drawPanel(g, 228, 92, 220, 110, COL_BORDER);
  text(g, saving_on ? "ECONOMIA: LIGADA" : "ECONOMIA: DESLIGADA", 238, 102, 10, saving_on ? COL_CYAN : COL_DIM);
  text(g, "POTÊNCIA EXTRA: " + boost_count + "/" + BOOST_LIMIT, 238, 124, 10, COL_TEXT);
  text(g, "AÇÃO DO DIA: " + (action_used ? "USADA" : "LIVRE"), 238, 146, 10, action_used ? COL_ORANGE : COL_GREEN);
  text(g, "GASTO DIÁRIO: " + (saving_on ? ENERGY_PER_DAY_SAVING : ENERGY_PER_DAY), 238, 168, 9, COL_MUTED);

  drawButton(g, 8, 262, 144, 24, "REPARAR MOTOR (2 PEÇAS)", ACTION_REPAIR_ENGINE, canRepairEngine());
  drawButton(g, 164, 262, 144, 24, saving_on ? "ECONOMIA: LIGADA" : "ECONOMIA: DESLIGADA", ACTION_TOGGLE_SAVING, true);
  drawButton(g, 320, 262, 144, 24, "AUMENTAR POTÊNCIA", ACTION_BOOST_ENGINE, canBoostEngine());
}


void drawDepotRoom(PGraphics g){
  text(g, "DEPÓSITO", 18, 70, 12, COL_CYAN);

  drawPanel(g, 24, 92, 190, 110, COL_BORDER);
  text(g, "COMIDA: " + str(int(food)), 34, 108, 11, resourceColour(food));
  text(g, "ÁGUA: " + str(int(water)), 34, 130, 11, resourceColour(water));
  text(g, "PEÇAS: " + str(parts), 34, 152, 11, COL_TEXT);
  text(g, "GASTO DIÁRIO: " + (rationing_on ? "RACIONADO" : "NORMAL"), 34, 174, 9, COL_MUTED);

  drawPanel(g, 228, 92, 220, 110, COL_BORDER);
  text(g, rationing_on ? "RACIONAMENTO: LIGADO" : "RACIONAMENTO: DESLIGADO", 238, 102, 10, rationing_on ? COL_CYAN : COL_DIM);
  text(g, leak_on ? "CASCO: VAZANDO" : "CASCO: INTEIRO", 238, 124, 10, leak_on ? COL_RED : COL_GREEN);
  text(g, "VAZAMENTO: -" + LEAK_PER_DAY + " DE OXIGÊNIO POR DIA", 238, 146, 9, COL_MUTED);
  text(g, rationing_on ? "MORAL: -" + MORALE_PER_DAY_RATIONING + " POR DIA" : "SEM CUSTO DE MORAL", 238, 164, 9, COL_MUTED);

  drawButton(g, 8, 262, 216, 24, rationing_on ? "RACIONAMENTO: LIGADO" : "RACIONAMENTO: DESLIGADO", ACTION_TOGGLE_RATIONING, true);
  drawButton(g, 236, 262, 216, 24, "REPARAR CASCO (1 PEÇA)", ACTION_REPAIR_HULL, canRepairHull());
}


void drawDormitoryRoom(PGraphics g){
  text(g, "DORMITÓRIO", 18, 70, 12, COL_CYAN);

  drawPanel(g, 24, 92, 190, 110, COL_BORDER);
  text(g, "SOBREVIVENTES: " + survivors + " DE " + CREW_START, 34, 108, 11, COL_TEXT);
  text(g, "MORAL: " + str(int(morale)), 34, 130, 11, resourceColour(morale));
  text(g, "AÇÃO DO DIA: " + (action_used ? "USADA" : "LIVRE"), 34, 152, 10, action_used ? COL_ORANGE : COL_GREEN);
  text(g, "DESCANSO GASTA " + REST_ENERGY_COST + " DE ENERGIA", 34, 172, 9, COL_MUTED);

  for (int i = 0; i < CREW_START; i++){
    float bunk_x = 240 + (i % 2) * 104;
    float bunk_y = 100 + (i / 2) * 50;
    boolean alive = i < survivors;

    drawPanel(g, bunk_x, bunk_y, 88, 40, alive ? COL_CYAN_DARK : COL_DIM);
    text(g, alive ? "A BORDO" : "PERDIDO", bunk_x + 10, bunk_y + 15, 9, alive ? COL_TEXT : COL_DIM);
  }

  drawButton(g, 8, 262, 240, 24, "DESCANSO E ORGANIZAÇÃO (8 ENERGIA)", ACTION_REST_CREW, canRestCrew());
}
