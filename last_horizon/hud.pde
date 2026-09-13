/* hud - cartoes do topo, painel de alertas e rodape (interface/HUD.md) */

void drawHud(PGraphics g){
  drawHeader(g);
  drawAlertPanel(g);
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
  hudText(g, label, x + 5, HUD_Y + 5, 10, COL_MUTED);
  hudText(g, value, x + 5, HUD_Y + 21, 16, accent);
}


void drawResourceCard(PGraphics g, float x, int icon, float value, int accent, float fill){
  boolean critical = icon != ICON_PARTS && value < RESOURCE_RED;
  boolean blink_on = (frameCount / 30) % 2 == 0;
  int border = critical && blink_on ? COL_RED : COL_BORDER;

  drawPanel(g, x, HUD_Y, HUD_CARD_W, HUD_H, border);
  drawResourceIcon(g, icon, x + 4, HUD_Y + 5, accent);
  hudText(g, str(int(value)), x + 24, HUD_Y + 8, 16, accent);

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


void hudText(PGraphics g, String value, float x, float y, float size, int colour){
  g.fill(colour);
  g.textSize(max(size, 10));
  g.text(value, x, y);
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


void drawAlertPanel(PGraphics g){
  drawPanel(g, SIDE_X, SIDE_Y, SIDE_W, SIDE_H, COL_BORDER);
  text(g, "SISTEMA", SIDE_X + 8, SIDE_Y + 7, 9, COL_CYAN);

  if (event_open){
    return;
  }

  float y = SIDE_Y + 26;

  y = drawAlert(g, y, energy < RESOURCE_RED, "ENERGIA CRÍTICA: VISITE A SALA DE ENERGIA.");
  y = drawAlert(g, y, oxygen < RESOURCE_RED, "OXIGÊNIO CRÍTICO: VERIFIQUE OS SISTEMAS.");
  y = drawAlert(g, y, water < RESOURCE_RED || food < RESOURCE_RED, "ESTOQUES BAIXOS: VISITE O DEPÓSITO.");
  y = drawAlert(g, y, morale < RESOURCE_RED, "MORAL BAIXA: VISITE O DORMITÓRIO.");
  y = drawAlert(g, y, engine_state == ENGINE_DAMAGED, "MOTOR DANIFICADO: USE 2 PEÇAS NO REPARO.");
  y = drawAlert(g, y, leak_on, "VAZAMENTO NO CASCO: REPARE COM 1 PEÇA.");
  y = drawAlert(g, y, saving_on, "MODO ECONOMIA ATIVO.");
  y = drawAlert(g, y, rationing_on, "RACIONAMENTO ATIVO.");
  y = drawAlert(g, y, action_used, "AÇÃO DO DIA JÁ FOI USADA.");
  g.fill(COL_CYAN);
  g.textSize(10);
  g.text("TAREFA", SIDE_X + 8, SIDE_Y + SIDE_H - 78);
  g.fill(COL_TEXT);
  g.textSize(fitTextSize(g, active_task == TASK_NONE ? "LIVRE" : task_label[active_task], 10, SIDE_W - 16));
  g.text(active_task == TASK_NONE ? "LIVRE" : task_label[active_task], SIDE_X + 8, SIDE_Y + SIDE_H - 64);

  if (y == SIDE_Y + 26){
    y = drawTextWrapped(g, "SISTEMAS ESTÁVEIS. ESCOLHA UM CÔMODO.", SIDE_X + 8, y, SIDE_W - 16, 9, 12, COL_MUTED);
  }

  if (system_message.length() > 0){
    drawTextWrapped(g, system_message, SIDE_X + 8, SIDE_Y + SIDE_H - 40, SIDE_W - 16, 9, 12, COL_CYAN);
  }
}


float drawAlert(PGraphics g, float y, boolean show, String value){
  if (!show){
    return y;
  }

  return drawTextWrapped(g, value, SIDE_X + 8, y, SIDE_W - 16, 9, 12, COL_TEXT) + 4;
}


void drawFooter(PGraphics g){
  g.noStroke();
  g.fill(COL_PANEL_2);
  g.rect(0, FOOTER_Y, BASE_W, FOOTER_H);

  boolean scene_controls_on = !event_open && !paused;

  drawButton(g, 6, FOOTER_Y + 4, 90, 19, "VOLTAR", ACTION_BACK_TO_SHIP, isRoomScreen() && scene_controls_on);
  drawButton(g, BASE_W - 6 - 166, FOOTER_Y + 4, 166, 19, "PASSAR DIA", ACTION_PASS_DAY, scene_controls_on);

  if (!paused){
    String hint = event_open ? "RESPONDA O EVENTO" : "ESC = PAUSA";
    int hint_colour = event_open ? COL_ORANGE : COL_DIM;
    textCentered(g, hint, (BASE_W + 106) / 2.0, FOOTER_Y + 8, 9, hint_colour);
  }
}
