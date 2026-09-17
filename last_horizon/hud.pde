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
PGraphics resource_icon_layer;


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
  text(g, str(int(value)), x + 24, HUD_Y + 6, 16, accent);
  text(g, resourceIconLabel(icon), x + 5, HUD_Y + 24, 16, COL_MUTED);

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
  if (art_icon != null && art_icon[icon] != null){
    if (resource_icon_layer == null){
      int size = round(ART_ICON_DRAW * RENDER_SCALE);
      resource_icon_layer = createGraphics(size, size);
      resource_icon_layer.noSmooth();
    }

    resource_icon_layer.beginDraw();
    resource_icon_layer.clear();
    resource_icon_layer.imageMode(CENTER);
    resource_icon_layer.image(art_icon[icon],
      resource_icon_layer.width / 2.0,
      resource_icon_layer.height / 2.0,
      resource_icon_layer.width,
      resource_icon_layer.height
    );
    resource_icon_layer.endDraw();

    g.imageMode(CENTER);
    g.image(resource_icon_layer,
      round(x + ART_ICON_DRAW / 2),
      round(y + ART_ICON_DRAW / 2),
      ART_ICON_DRAW,
      ART_ICON_DRAW
    );
    return;
  }

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


String resourceIconLabel(int icon){
  if (icon == ICON_ENERGY) return "ENERGIA";
  if (icon == ICON_OXYGEN) return "OXIGÊNIO";
  if (icon == ICON_WATER) return "ÁGUA";
  if (icon == ICON_FOOD) return "COMIDA";
  if (icon == ICON_PARTS) return "PEÇAS";
  return "MORAL";
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

  int q = active_quest >= 0 ? active_quest : selected_order;
  text(g, orderStageLine(q), 16, OBJECTIVE_Y + 3, 16, COL_CYAN);
  text(g, orderRouteLine(q), 16, OBJECTIVE_Y + 14, 16, COL_MUTED);
  text(g, orderFailureLine(q), 16, OBJECTIVE_Y + 25, 16, COL_ORANGE);
  text(g, problemWarningLine(), 16, OBJECTIVE_Y + 36, 16, COL_ORANGE);
}


String orderStageLine(int q){
  if (q < 0) return quest_completed
    ? "ORDEM CONCLUÍDA — RETORNE AO SEU BELICHE"
    : "NENHUMA ORDEM ATIVA — COMPARE AS DUAS OFERTAS EM ORDENS";
  if (active_quest < 0) return "CONFIRMAR COM " + crew_name[quest_owner[q]] + " EM "
    + pointLocation(crew_point[quest_owner[q]]) + " | OBJETO: " + quest_object[q];
  return questStageLabel(q) + ": " + quest_object[q] + " | RESPONSÁVEL: " + crew_name[quest_owner[q]];
}


String orderRouteLine(int q){
  if (q < 0) return quest_completed ? questNightSummary() : "UMA QUEST POR DIA. ACEITA: NÃO PODE SER CANCELADA.";
  if (held_item != ITEM_NONE)
    return "NA MÃO: " + quest_object[q] + " | ENTREGA: " + pointLocation(quest_destination[q]);
  return "COLETA: " + pointLocation(quest_origin[q]) + " | ENTREGA: " + pointLocation(quest_destination[q]);
}


String orderFailureLine(int q){
  if (q < 0) return "";
  return questEffect(q) + " | " + questFailure(q);
}


String problemWarningLine(){
  if (system_message.length() > 0 && frameCount < system_message_until) return system_message;

  int urgent = urgentProblem();
  String warning = urgent < 0 ? "SEM PROBLEMAS ATIVOS" : problem_short[urgent] + ": " + problem_deadline[urgent] + "D"
    + " | " + roomTitle(problem_room[urgent]) + " | +" + (activeProblemCount() - 1) + " PROBLEMA(S)";
  int risk = urgentRisk();

  if (risk >= 0) warning += " | " + crew_name[risk] + " EM RISCO: " + crew_risk_deadline[risk] + "D";

  return warning;
}




void drawFooter(PGraphics g){
  g.noStroke();
  g.fill(COL_PANEL_2);
  g.rect(0, FOOTER_Y, BASE_W, FOOTER_H);

  boolean controls_on = !modalOpen() && !paused;
  drawButton(g, 6, FOOTER_Y + 4, 80, 22, "MAPA", ACTION_OPEN_MAP, controls_on);
  drawButton(g, 92, FOOTER_Y + 4, 80, 22, "ORDENS", ACTION_OPEN_ORDERS, controls_on);
  if (controls_on && ordersAvailable()){
    drawOrdersBadge(g, 159, FOOTER_Y + 15, ordersPulse());
  }
  drawButton(g, 178, FOOTER_Y + 4, 26, 22, "?", ACTION_OPEN_HELP, controls_on);
}


float ordersPulse(){
  return (1 - cos(TWO_PI * (millis() % 1400) / 1400.0)) * 0.5;
}


void drawOrdersBadge(PGraphics g, float cx, float cy, float pulse){
  g.pushMatrix();
  g.translate(cx, cy);
  g.scale(1 + pulse * 0.375);
  g.noStroke();
  g.fill(lerpColor(COL_ORANGE, COL_YELLOW, pulse));
  g.ellipse(0, 0, 8, 8);
  g.fill(COL_BG);
  g.rect(-0.7, -2.7, 1.4, 3.3, 0.4);
  g.rect(-0.7, 1.4, 1.4, 1.4, 0.4);
  g.popMatrix();
}
