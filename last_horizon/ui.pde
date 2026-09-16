final int LAYER_SCENE = 0;
final int LAYER_MODAL = 1;
final int LAYER_PAUSE = 2;
final int MAX_BUTTONS = 24;
final int NAME_MAX_LENGTH = 12;
final float MIN_TEXT_SIZE = 16;
final float MIN_WRAP_TEXT_SIZE = 16;

int draw_layer = LAYER_SCENE;
int button_count = 0;
float[] button_x = new float[MAX_BUTTONS];
float[] button_y = new float[MAX_BUTTONS];
float[] button_w = new float[MAX_BUTTONS];
float[] button_h = new float[MAX_BUTTONS];
int[] button_action = new int[MAX_BUTTONS];
int[] button_layer = new int[MAX_BUTTONS];
boolean[] button_on = new boolean[MAX_BUTTONS];


void resetButtons(){
  button_count = 0;
}


void addButton(float x, float y, float w, float h, int action, boolean on){
  if (button_count >= MAX_BUTTONS){
    return;
  }

  button_x[button_count] = x + w / 2.0;
  button_y[button_count] = y + h / 2.0;
  button_w[button_count] = w;
  button_h[button_count] = h;
  button_action[button_count] = action;
  button_layer[button_count] = draw_layer;
  button_on[button_count] = on;
  button_count++;
}


int findButton(float x, float y){
  int layer = uiLayer();

  for (int i = 0; i < button_count; i++){
    if (!button_on[i] || button_layer[i] != layer){
      continue;
    }

    if (checkRectOverlap(x, y, 0, 0, button_x[i], button_y[i], button_w[i], button_h[i])){
      return button_action[i];
    }
  }

  return ACTION_NONE;
}
void updateCursor(){
  int top_layer = uiLayer();

  for (int i = button_count - 1; i >= 0; i--){
    if (button_layer[i] != top_layer || !isButtonHovered(i)){
      continue;
    }

    cursor(button_on[i] ? HAND : WAIT);
    return;
  }

  if (top_layer != LAYER_SCENE){
    for (int i = button_count - 1; i >= 0; i--){
      if (button_layer[i] != LAYER_SCENE || !isButtonHovered(i)){
        continue;
      }

      cursor(button_on[i] ? HAND : WAIT);
      return;
    }
  }

  cursor(ARROW);
}


boolean isButtonHovered(int index){
  return checkRectOverlap(base_mouse_x, base_mouse_y, 0, 0, button_x[index], button_y[index], button_w[index], button_h[index]);
}


boolean isHovering(float x, float y, float w, float h){
  return checkRectOverlap(base_mouse_x, base_mouse_y, 0, 0, x + w / 2.0, y + h / 2.0, w, h);
}


boolean checkRectOverlap(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh){
  return abs(ax - bx) * 2 < (aw + bw) && abs(ay - by) * 2 < (ah + bh);
}


void drawButton(PGraphics g, float x, float y, float w, float h, String label, int action, boolean on){
  boolean hover = on && uiLayer() == draw_layer && isHovering(x, y, w, h);
  int border = on ? (hover ? COL_CYAN : COL_BORDER) : COL_DIM;
  int colour = on ? (hover ? COL_CYAN : COL_TEXT) : COL_DIM;
  float text_size = fitTextSize(g, label, MIN_TEXT_SIZE, w - 16);
  float render_size = renderTextSize(text_size);

  drawPanel(g, x, y, w, h, border);
  g.fill(colour);
  g.textSize(render_size);
  g.text(label, x + 8, y + (h - render_size) / 2.0);

  addButton(x, y, w, h, action, on);
}


void drawPanel(PGraphics g, float x, float y, float w, float h, int border){
  g.fill(COL_PANEL);
  g.stroke(border);
  g.rect(x, y, w, h, 3);
}


void drawBackdrop(PGraphics g, float x, float y, float w, float h){
  g.fill(COL_ROOM);
  g.stroke(COL_BORDER);
  g.rect(x, y, w, h, 3);
}
void drawModalShade(PGraphics g){
  g.noStroke();
  g.fill(0xB8000000);
  g.rect(0, 0, BASE_W, BASE_H);
}


void openDialogue(String name, String value){
  pending_quest_action = ACTION_NONE;
  dialog_name = name;
  dialog_text = value;
  dialog_open = true;
}


void drawDialogue(PGraphics g){
  drawModalShade(g);
  drawPortrait(g, dialog_name, 470, 72);
  drawPanel(g, 24, 192, 592, 144, COL_CYAN);
  text(g, dialog_name, 40, 202, 16, COL_CYAN);
  drawTextWrapped(g, dialog_text, 40, 222, 552, 16, 18, COL_TEXT);
  if (pending_quest_action == ACTION_ACCEPT_ORDER){
    drawButton(g, 40, 304, 128, 22, "VOLTAR (ESC)", ACTION_CLOSE_MODAL, true);
    drawButton(g, 410, 304, 188, 22, "ACEITAR ORDEM (ENTER)", ACTION_CONFIRM_QUEST, true);
  } else {
    drawButton(g, 450, 304, 148, 22, "CONTINUAR (ENTER)", ACTION_CLOSE_MODAL, true);
  }
}


void drawPortrait(PGraphics g, String name, float x, float y){
  int colour = name.equals("VERA") ? COL_CYAN
    : name.equals("SÍLVIA") ? COL_ORANGE
    : name.equals("BENTO") ? COL_GREEN : COL_YELLOW;

  g.stroke(COL_BORDER);
  g.fill(COL_PANEL);
  g.rect(x, y, 112, 138, 4);
  g.noStroke();
  g.fill(colour);
  g.ellipse(x + 56, y + 40, 46, 46);
  g.rect(x + 30, y + 66, 52, 60, 6);
  g.fill(COL_TEXT);
  g.rect(x + 44, y + 35, 4, 4);
  g.rect(x + 64, y + 35, 4, 4);
}


void openTechnical(String title, String value){
  pending_quest_action = ACTION_NONE;
  pending_retry = -1;
  technical_title = title;
  technical_text = value;
  technical_open = true;
}


void drawTechnicalPanel(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 34, 108, 572, 210, COL_CYAN);
  text(g, technical_title, 50, 120, 16, COL_CYAN);
  drawTextWrapped(g, technical_text, 50, 148, 540, 16, 18, COL_TEXT);
  if (pending_quest_action != ACTION_NONE){
    drawButton(g, 50, 284, 128, 22, "VOLTAR (ESC)", ACTION_CLOSE_MODAL, true);
    String label = pending_quest_action == ACTION_DELIVER_QUEST ? "ENTREGAR (ENTER)" : "CONFIRMAR (ENTER)";
    drawButton(g, 422, 284, 168, 22, label, ACTION_CONFIRM_QUEST, pendingQuestEnabled());
    if (!pendingQuestEnabled()) text(g, "RECURSOS INSUFICIENTES OU QUEST DO DIA JÁ ESCOLHIDA.", 50, 257, 16, COL_ORANGE);
  } else {
    drawButton(g, 450, 284, 140, 22, "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
  }
}


void drawEndDayPanel(PGraphics g){
  drawModalShade(g);
  drawPanel(g, 28, 55, 584, 268, COL_ORANGE);
  text(g, "ENCERRAR O DIA — CONSUMO E PERDAS PREVISTOS", 42, 67, 16, COL_ORANGE);
  text(g, "ENERGIA -" + (ENERGY_PER_DAY + dailyProblemLoss(RESOURCE_ENERGY) + preventiveNightLoss(RESOURCE_ENERGY))
    + " | OXIGÊNIO -" + (OXYGEN_PER_DAY + dailyProblemLoss(RESOURCE_OXYGEN) + preventiveNightLoss(RESOURCE_OXYGEN))
    + " | ÁGUA -" + (WATER_PER_DAY + preventiveNightLoss(RESOURCE_WATER)), 42, 88, 16, COL_TEXT);
  text(g, "COMIDA -" + (FOOD_PER_DAY + dailyProblemLoss(RESOURCE_FOOD) + preventiveNightLoss(RESOURCE_FOOD))
    + " | MORAL -" + (MORALE_PER_DAY + dailyProblemLoss(RESOURCE_MORALE) + preventiveNightLoss(RESOURCE_MORALE))
    + " | PEÇAS -" + preventiveNightLoss(RESOURCE_PARTS), 42, 102, 16, COL_TEXT);
  float y = drawTextWrapped(g, questNightSummary(), 42, 122, 556, 16, 18, COL_CYAN);
  int risk = urgentRisk();
  if (risk >= 0) y = drawTextWrapped(g, crew_name[risk] + " EM RISCO — " + crew_risk_deadline[risk]
    + " NOITE(S)" + (crew_risk_deadline[risk] == 1 ? ": MORRE NESTA NOITE." : "."), 42, y + 5, 556, 16, 18, COL_ORANGE);
  y += 8;
  for (int p = 0; p < PROBLEM_COUNT; p++){
    if (!problem_active[p]) continue;
    y = drawTextWrapped(g, problemMapLine(p) + (problem_deadline[p] == 1 ? " — CRISE NESTA NOITE!" : ""),
      42, y + 3, 556, 16, 18, problem_deadline[p] == 1 ? COL_RED : COL_TEXT);
  }
  drawButton(g, 42, 291, 208, 24, "VOLTAR (ESC)", ACTION_CLOSE_MODAL, true);
  drawButton(g, 296, 291, 302, 24, "ENCERRAR DIA (ENTER)", ACTION_END_DAY, true);
}


void drawStars(PGraphics g){
  g.noStroke();
  g.fill(COL_DIM);

  for (int i = 0; i < 42; i++){
    float x = 8 + ((i * 83) % 624);
    float y = 8 + ((i * 47) % 344);
    float side = (i % 5 == 0) ? 2 : 1;
    g.rect(x, y, side, side);
  }
}
float fitTextSize(PGraphics g, String value, float desired_size, float max_width){
  float size = desired_size;
  g.textSize(renderTextSize(size));

  while (size > 10 && g.textWidth(value) > max_width){
    size -= 1;
    g.textSize(renderTextSize(size));
  }

  return size;
}
float renderTextSize(float size){
  return size / RENDER_SCALE;
}
float readableTextSize(float size){
  return max(size, MIN_TEXT_SIZE);
}


float readableWrapSize(float size){
  return max(size, MIN_WRAP_TEXT_SIZE);
}


void text(PGraphics g, String value, float x, float y, float size, int colour){
  float actual_size = readableTextSize(size);

  g.fill(colour);
  g.textSize(renderTextSize(actual_size));
  g.text(value, x, y);
}


void textCentered(PGraphics g, String value, float cx, float y, float size, int colour){
  float actual_size = readableTextSize(size);

  g.fill(colour);
  g.textSize(renderTextSize(actual_size));
  g.text(value, cx - g.textWidth(value) / 2.0, y);
}


float drawTextWrapped(PGraphics g, String value, float x, float y, float w, float size, float line_h, int colour){
  String[] words = split(value, ' ');
  String line = "";
  float actual_size = readableWrapSize(size);
  float actual_line_h = max(line_h, actual_size + 2);
  float render_size = renderTextSize(actual_size);
  float render_line_h = renderTextSize(actual_line_h);

  g.fill(colour);
  g.textSize(render_size);

  float line_y = y;

  for (int i = 0; i < words.length; i++){
    String candidate = (line.length() == 0) ? words[i] : line + " " + words[i];

    if (line.length() > 0 && g.textWidth(candidate) > w){
      g.text(line, x, line_y);
      line = words[i];
      line_y += render_line_h;
    } else {
      line = candidate;
    }
  }

  if (line.length() > 0){
    g.text(line, x, line_y);
  }

  return line_y + render_line_h;
}
