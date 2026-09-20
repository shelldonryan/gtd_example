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
PImage[] resource_icon_cache = new PImage[6];
PImage[] resource_icon_sources = new PImage[6];
int[] resource_icon_scales = new int[6];
int[] resource_icon_builds_by_icon = new int[6];
int resource_icon_builds = 0;
int[] HUD_RESOURCE_ORDER;

class ResourceIconCacheEntry {
  PImage source;
  int render_scale;
  PImage bitmap;

  ResourceIconCacheEntry(PImage source_value, int scale_value, PImage bitmap_value){
    source = source_value;
    render_scale = scale_value;
    bitmap = bitmap_value;
  }
}

ArrayList<ResourceIconCacheEntry> resource_icon_entries =
  new ArrayList<ResourceIconCacheEntry>();


void drawHeader(PGraphics g){
  if (HUD_RESOURCE_ORDER == null){
    HUD_RESOURCE_ORDER = new int[] {
      RESOURCE_ENERGY, RESOURCE_OXYGEN, RESOURCE_WATER,
      RESOURCE_FOOD, RESOURCE_PARTS, RESOURCE_MORALE
    };
  }

  float x = HUD_X;

  drawHeaderCard(g, x, "DIA", day + "/" + trip_days, COL_CYAN);
  x += HUD_CARD_W + HUD_GAP;
  drawHeaderCard(g, x, "A BORDO", str(survivors), COL_TEXT);
  x += HUD_CARD_W + HUD_GAP;
  for (int i = 0; i < HUD_RESOURCE_ORDER.length; i++){
    int resource = HUD_RESOURCE_ORDER[i];
    drawResourceCard(g, x, resource, hudResourceIcon(resource), hudResourceValue(resource),
      hudResourceLabel(resource), hudResourceAccent(resource), hudResourceFill(resource));
    x += HUD_CARD_W + HUD_GAP;
  }
}

int hudResourceIcon(int resource){
  if (resource == RESOURCE_ENERGY) return ICON_ENERGY;
  if (resource == RESOURCE_OXYGEN) return ICON_OXYGEN;
  if (resource == RESOURCE_WATER) return ICON_WATER;
  if (resource == RESOURCE_FOOD) return ICON_FOOD;
  if (resource == RESOURCE_PARTS) return ICON_PARTS;
  return ICON_MORALE;
}


float hudResourceValue(int resource){
  if (resource == RESOURCE_ENERGY) return energy;
  if (resource == RESOURCE_OXYGEN) return oxygen;
  if (resource == RESOURCE_WATER) return water;
  if (resource == RESOURCE_FOOD) return food;
  if (resource == RESOURCE_PARTS) return parts;
  return morale;
}


String hudResourceLabel(int resource){
  if (resource == RESOURCE_ENERGY) return "ENERGIA";
  if (resource == RESOURCE_OXYGEN) return "OXIGÊNIO";
  if (resource == RESOURCE_WATER) return "ÁGUA";
  if (resource == RESOURCE_FOOD) return "COMIDA";
  if (resource == RESOURCE_PARTS) return "PEÇAS";
  return "MORAL";
}


int hudResourceAccent(int resource){
  return resource == RESOURCE_PARTS ? COL_TEXT : resourceColour(hudResourceValue(resource));
}


float hudResourceFill(int resource){
  return resource == RESOURCE_PARTS ? -1 : hudResourceValue(resource) / RESOURCE_MAX;
}


void drawHeaderCard(PGraphics g, float x, String label, String value, int accent){
  drawPanel(g, x, HUD_Y, HUD_CARD_W, HUD_H, COL_BORDER);
  text(g, label, x + 5, HUD_Y + 5, 16, COL_MUTED);
  text(g, value, x + 5, HUD_Y + 21, 16, accent);
}


void drawResourceCard(PGraphics g, float x, int resource, int icon, float value, String label,
  int accent, float fill){
  boolean critical = resource != RESOURCE_PARTS && value < RESOURCE_RED;
  boolean blink_on = (frameCount / 30) % 2 == 0;
  int border = critical && blink_on ? COL_RED : COL_BORDER;

  drawPanel(g, x, HUD_Y, HUD_CARD_W, HUD_H, border);
  drawResourceIcon(g, icon, x + 4, HUD_Y + 5, accent);
  text(g, str(int(value)), x + 24, HUD_Y + 6, 16, accent);
  text(g, label, x + 5, HUD_Y + 24, 16, COL_MUTED);

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
    ensureResourceIconCache(icon);

    g.imageMode(CENTER);
    g.image(resource_icon_cache[icon],
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

void ensureResourceIconCache(int icon){
  if (icon < 0 || icon >= resource_icon_cache.length || art_icon == null
    || icon >= art_icon.length){
    return;
  }

  PImage source = art_icon[icon];
  int render_scale = RENDER_SCALE;

  if (source == null){
    if (resource_icon_sources[icon] != null){
      invalidateResourceIconCache(icon);
    }
    return;
  }

  if (resource_icon_cache[icon] != null
    && resource_icon_sources[icon] == source
    && resource_icon_scales[icon] == render_scale){
    return;
  }

  if (resource_icon_sources[icon] != null
    && (resource_icon_sources[icon] != source
      || resource_icon_scales[icon] != render_scale)){
    invalidateResourceIconCache(icon);
  }

  ResourceIconCacheEntry entry = findResourceIconCacheEntry(source, render_scale);
  if (entry != null){
    resource_icon_cache[icon] = entry.bitmap;
    resource_icon_sources[icon] = source;
    resource_icon_scales[icon] = render_scale;
    return;
  }

  int size = round(ART_ICON_DRAW * render_scale);
  PGraphics layer = createGraphics(size, size);
  layer.noSmooth();
  layer.beginDraw();
  layer.clear();
  layer.imageMode(CENTER);
  layer.image(source, size / 2.0, size / 2.0, size, size);
  layer.endDraw();
  PImage bitmap = layer.get();
  resource_icon_entries.add(new ResourceIconCacheEntry(source, render_scale, bitmap));
  resource_icon_cache[icon] = bitmap;
  resource_icon_sources[icon] = source;
  resource_icon_scales[icon] = render_scale;
  resource_icon_builds_by_icon[icon]++;
  resource_icon_builds++;
}

void prepareResourceIconCache(){
  for (int icon = 0; icon < resource_icon_cache.length; icon++){
    ensureResourceIconCache(icon);
  }
}


ResourceIconCacheEntry findResourceIconCacheEntry(PImage source, int render_scale){
  for (int i = 0; i < resource_icon_entries.size(); i++){
    ResourceIconCacheEntry entry = resource_icon_entries.get(i);
    if (entry.source == source && entry.render_scale == render_scale){
      return entry;
    }
  }

  return null;
}


void invalidateResourceIconCache(int icon){
  if (icon < 0 || icon >= resource_icon_cache.length){
    return;
  }

  PImage old_source = resource_icon_sources[icon];
  int old_scale = resource_icon_scales[icon];
  resource_icon_cache[icon] = null;
  resource_icon_sources[icon] = null;
  resource_icon_scales[icon] = 0;

  if (old_source == null){
    return;
  }

  boolean used_elsewhere = false;
  for (int other = 0; other < resource_icon_sources.length; other++){
    if (other != icon && resource_icon_sources[other] == old_source
      && resource_icon_scales[other] == old_scale){
      used_elsewhere = true;
      break;
    }
  }

  if (!used_elsewhere){
    for (int i = resource_icon_entries.size() - 1; i >= 0; i--){
      ResourceIconCacheEntry entry = resource_icon_entries.get(i);
      if (entry.source == old_source && entry.render_scale == old_scale){
        resource_icon_entries.remove(i);
      }
    }
  }

  cache_invalidations++;
}


String resourceIconLabel(int icon){
  if (icon == ICON_ENERGY) return hudResourceLabel(RESOURCE_ENERGY);
  if (icon == ICON_OXYGEN) return hudResourceLabel(RESOURCE_OXYGEN);
  if (icon == ICON_WATER) return hudResourceLabel(RESOURCE_WATER);
  if (icon == ICON_FOOD) return hudResourceLabel(RESOURCE_FOOD);
  if (icon == ICON_PARTS) return hudResourceLabel(RESOURCE_PARTS);
  return hudResourceLabel(RESOURCE_MORALE);
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

  text(g, currentObjectiveLine(), 16, OBJECTIVE_Y + 4, 16, COL_CYAN);
  text(g, currentAlertLine(), 16, OBJECTIVE_Y + 24, 16, alertLineColour());
}

/* A única fonte do alvo consultivo do HUD e do mapa. */
int currentObjective(){
  if (quest_completed) return POINT_TECH_BUNK;
  if (active_quest >= 0) return nextQuestPoint();
  if (selected_preventive_id >= 0) return nextQuestPoint();
  if (urgentRisk() >= 0) return POINT_RISK_BUNK;
  return MAP_TARGET_NONE;
}

String currentObjectiveLine(){
  int objective = currentObjective();
  if (event_open && objective == MAP_TARGET_NONE) return "Escolha uma solução no incidente";
  if (active_quest >= 0){
    if (quest_stage == QUEST_COLLECT)
      return "Pegue " + quest_object[active_quest] + " — " + pointLocation(objective);
    return "Leve " + quest_object[active_quest] + " — " + pointLocation(objective);
  }
  if (selected_preventive_id >= 0){
    int owner = quest_owner[selected_preventive_id];
    return "Fale com " + crewDisplayName(owner) + " — " + pointLocation(objective);
  }
  if (quest_completed){
    return atQuestPoint(POINT_TECH_BUNK)
      ? "Encerre o dia no seu beliche"
      : "Volte ao seu beliche — " + pointLocation(POINT_TECH_BUNK);
  }
  if (urgentRisk() >= 0) return "Socorra a pessoa em risco — " + pointLocation(POINT_RISK_BUNK);
  if (ordersAvailable()) return "Escolha uma ordem em Ordens";
  return "Local indisponível. Consulte o mapa";
}

String currentAlertLine(){
  String fatal = nightFatalWarning();
  if (fatal.length() > 0){
    int visible_problem = fatal.indexOf("Crise fatal:") == 0 ? 1 : 0;
    int extra = max(0, activeProblemCount() - visible_problem);
    if (extra > 0) fatal += " · +" + extra + " problemas";
    return fatal;
  }
  int risk = urgentRisk();
  if (risk >= 0){
    String risk_line = "Risco: " + crewDisplayName(risk) + " — " + crew_risk_deadline[risk] + " noite(s)";
    int active = activeProblemCount();
    if (active > 0) risk_line += " · +" + active + " problemas";
    return risk_line;
  }
  int urgent = urgentProblem();
  if (urgent >= 0){
    String warning = problem_short[urgent] + " · prazo " + problem_deadline[urgent]
      + " dia(s) · " + roomTitle(problem_room[urgent]);
    int other = max(0, activeProblemCount() - 1);
    if (other > 0) warning += " · +" + other + " problemas";
    return warning;
  }
  if (system_message.length() > 0 && frameCount < system_message_until) return system_message;
  return "Sem problemas ativos";
}

int alertLineColour(){
  return nightFatalWarning().length() > 0 ? COL_RED : COL_ORANGE;
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
  if (q < 0) return quest_completed ? questNightSummary() : "Voce pode aceitar uma por dia e após aceitar, não pode ser cancelada.";
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
  if (urgentRisk() >= 0){
    drawButton(g, 210, FOOTER_Y + 4, 96, 22, "SOCORRO", ACTION_OPEN_RESCUE, controls_on);
  }
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
