void drawHud(PGraphics g){
  drawHeader(g);
  drawObjectiveStrip(g);
  drawFooter(g);
}


final int ICON_ENERGY = 0;
final int ICON_OXYGEN = 1;
final int ICON_WATER = 2;
final int ICON_FOOD = 3;
final int ICON_PARTS = 4;
final int ICON_MORALE = 5;


void drawHeader(PGraphics g){
  float x = HUD_X;

  drawHeaderCard(g, x, "DIA", day + "/" + trip_days, COL_CYAN);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "A BORDO", str(survivors), COL_TEXT);
  x += HUD_CARD_W + HUD_GAP;
  drawResourceCard(g, x, ICON_ENERGY, energy, resourceColour(energy), energy / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawResourceCard(g, x, ICON_OXYGEN, oxygen, resourceColour(oxygen), oxygen / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawResourceCard(g, x, ICON_WATER, water, resourceColour(water), water / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawResourceCard(g, x, ICON_FOOD, food, resourceColour(food), food / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawResourceCard(g, x, ICON_PARTS, parts, COL_TEXT, -1);
  x += HUD_CARD_W + HUD_GAP;
  drawResourceCard(g, x, ICON_MORALE, morale, resourceColour(morale), morale / RESOURCE_MAX);
}


void drawHeaderCard(PGraphics g, float x, String label, String value, int accent){
  drawPanel(g, x, HUD_Y, HUD_CARD_W, HUD_H, COL_BORDER);
  text(g, label, x + 5, HUD_Y + 5, 16, COL_MUTED);
  text(g, value, x + 5, HUD_Y + 21, 16, accent);
}


void drawResourceCard(PGraphics g, float x, int icon, float value, int accent, float fill){
  boolean critical = icon != ICON_PARTS && value < RESOURCE_RED;
  boolean blink_on = (frameCount / 30) % 2 == 0;
  int border = critical && blink_on ? COL_RED : COL_BORDER;

  drawPanel(g, x, HUD_Y, HUD_CARD_W, HUD_H, border);
  drawResourceIcon(g, icon, x + 4, HUD_Y + 5, accent);
  text(g, str(int(value)), x + 24, HUD_Y + 8, 16, accent);

  if (critical){
    drawWarningIcon(g, x + HUD_CARD_W - 18, HUD_Y + 5);
  }

  if (fill < 0){
    return;
  }

  float bar_x = x + 5;
  float bar_w = HUD_CARD_W - 10;
  float bar_y = HUD_Y + HUD_H - 9;

  g.noStroke();
  g.fill(COL_DIM);
  g.rect(bar_x, bar_y, bar_w, 4);
  g.fill(accent);
  g.rect(bar_x, bar_y, bar_w * constrain(fill, 0, 1), 4);
}


void drawResourceIcon(PGraphics g, int icon, float x, float y, int colour){
  g.noStroke();
  g.fill(colour);

  if (icon == ICON_ENERGY){
    g.quad(x + 8, y, x + 14, y, x + 9, y + 7, x + 15, y + 7);
    g.quad(x + 7, y + 6, x + 13, y + 6, x + 7, y + 16, x + 2, y + 16);
    return;
  }

  if (icon == ICON_OXYGEN){
    g.ellipse(x + 8, y + 8, 14, 14);
    g.fill(COL_PANEL);
    g.ellipse(x + 8, y + 8, 5, 5);
    return;
  }

  if (icon == ICON_WATER){
    g.triangle(x + 8, y, x + 15, y + 10, x + 8, y + 16);
    g.triangle(x + 8, y, x + 1, y + 10, x + 8, y + 16);
    return;
  }

  if (icon == ICON_FOOD){
    g.ellipse(x + 8, y + 8, 15, 12);
    g.fill(COL_PANEL);
    g.rect(x + 2, y + 7, 12, 3);
    return;
  }

  if (icon == ICON_PARTS){
    g.ellipse(x + 8, y + 8, 15, 15);
    g.fill(COL_PANEL);
    g.ellipse(x + 8, y + 8, 5, 5);
    return;
  }

  g.ellipse(x + 8, y + 8, 15, 15);
  g.fill(COL_PANEL);
  g.ellipse(x + 5, y + 6, 2, 2);
  g.ellipse(x + 11, y + 6, 2, 2);
  g.rect(x + 4, y + 10, 8, 2);
}


void drawWarningIcon(PGraphics g, float x, float y){
  g.fill(COL_RED);
  g.triangle(x + 8, y, x + 16, y + 16, x, y + 16);
  g.fill(COL_BG);
  g.rect(x + 7, y + 5, 2, 6);
  g.rect(x + 7, y + 13, 2, 2);
}


void drawObjectiveStrip(PGraphics g){
  drawPanel(g, 6, OBJECTIVE_Y, BASE_W - 12, OBJECTIVE_H - 2, COL_BORDER);

  if (!system_message.equals(last_system_message)){
    last_system_message = system_message;
    system_message_until = frameCount + 180;
  }

  boolean show_notice = system_message.length() > 0 && frameCount < system_message_until;
  String title = active_task == TASK_NONE
    ? (action_used ? "DIA CONCLUÍDO" : "SEM TAREFA")
    : task_label[active_task];
  String value = show_notice ? system_message : taskNextInstruction();
  int colour = show_notice ? COL_ORANGE : COL_TEXT;

  text(g, title, 16, OBJECTIVE_Y + 4, 16, COL_CYAN);
  text(g, value, 210, OBJECTIVE_Y + 4, 16, colour);
}




void drawFooter(PGraphics g){
  g.noStroke();
  g.fill(COL_PANEL_2);
  g.rect(0, FOOTER_Y, BASE_W, FOOTER_H);

  boolean controls_on = !modalOpen() && !paused;
  drawButton(g, 6, FOOTER_Y + 4, 112, 22, "MAPA", ACTION_OPEN_MAP, controls_on);
  textCentered(g, "A/D ANDAR  W/S ESCADA  ESPAÇO PULAR  E INTERAGIR",
    370, FOOTER_Y + 7, 16, controls_on ? COL_MUTED : COL_DIM);
  text(g, "ESC PAUSA", 536, FOOTER_Y + 7, 16, COL_DIM);
}
