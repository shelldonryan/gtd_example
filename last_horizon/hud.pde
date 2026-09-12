/* hud - cartoes do topo, painel de alertas e rodape (interface/HUD.md) */

void drawHud(PGraphics g){
  drawHeader(g);
  drawAlertPanel(g);
  drawFooter(g);
}


void drawHeader(PGraphics g){
  float x = HUD_X;

  drawHeaderCard(g, x, "DIA", day + "/" + trip_days, COL_CYAN, -1);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "TRIPULAÇÃO", str(survivors), COL_TEXT, -1);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "ENERGIA", str(int(energy)), resourceColour(energy), energy / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "OXIGÊNIO", str(int(oxygen)), resourceColour(oxygen), oxygen / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "ÁGUA", str(int(water)), resourceColour(water), water / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "COMIDA", str(int(food)), resourceColour(food), food / RESOURCE_MAX);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "PEÇAS", str(parts), COL_TEXT, -1);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "MORAL", str(int(morale)), resourceColour(morale), morale / RESOURCE_MAX);
}


void drawHeaderCard(PGraphics g, float x, String label, String value, int accent, float fill){
  drawPanel(g, x, HUD_Y, HUD_CARD_W, HUD_H, COL_BORDER);
  text(g, label, x + 5, HUD_Y + 5, 8, COL_MUTED);
  text(g, value, x + 5, HUD_Y + 16, 13, COL_TEXT);

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
