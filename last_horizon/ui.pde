final int LAYER_SCENE = 0;
final int LAYER_PAUSE = 1;
final int LAYER_TRANSMISSION = 2;
final int LAYER_EVENT = 3;
final int LAYER_ORDERS = 4;
final int LAYER_MAP = 5;
final int LAYER_DIALOGUE = 6;
final int LAYER_TECHNICAL = 7;
final int LAYER_SLEEP = 8;
final int LAYER_HELP = 9;
final int MAX_BUTTONS = 24;
final int NAME_MAX_LENGTH = 12;
final float MIN_TEXT_SIZE = 16;
final float MIN_WRAP_TEXT_SIZE = 16;
final float MODAL_FOOTER_LEFT = 40;
final float MODAL_FOOTER_RIGHT = 600;
final float MODAL_FOOTER_GAP = 8;
final float MODAL_BUTTON_HEIGHT = 20;

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

  for (int i = button_count - 1; i >= 0; i--){
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
  float tx = max(x + 4, x + (w - g.textWidth(label)) / 2.0);
  g.text(label, tx, y + (h - render_size) / 2.0);

  addButton(x, y, w, h, action, on);
}


void drawPanel(PGraphics g, float x, float y, float w, float h, int border){
  g.fill(COL_PANEL);
  g.stroke(border);
  g.rect(x, y, w, h, 3);
}

/* Núcleo único para o contorno. Os wrappers abaixo continuam decidindo
   alinhamento e piso tipográfico, enquanto este módulo concentra os cinco
   deslocamentos usados pelo projeto. */
void drawShadowText(PGraphics g, String value, float x, float y, float size, int colour){
  float render_size = renderTextSize(size);
  g.textSize(render_size);
  g.fill(0xFF000000);
  g.text(value, x + 1, y);
  g.text(value, x - 1, y);
  g.text(value, x, y + 1);
  g.text(value, x, y - 1);
  g.text(value, x + 1, y + 1);
  g.fill(colour);
  g.text(value, x, y);
}

float modalButtonWidth(PGraphics g, String label){
  return modalButtonWidth(g, label, MODAL_FOOTER_RIGHT - MODAL_FOOTER_LEFT);
}


float modalButtonWidth(PGraphics g, String label, float max_width){
  if (label.length() == 0){
    return 0;
  }

  float text_width = max(0, max_width - 18);
  float text_size = fitTextSize(g, label, MIN_TEXT_SIZE, text_width);
  g.textSize(renderTextSize(text_size));
  return min(max_width, max(84, g.textWidth(label) + 18));
}

void drawModalFooter(PGraphics g, float y, String secondary, int secondary_action, boolean secondary_on,
  String primary, int primary_action, boolean primary_on){
  drawModalFooter(g, y, secondary, secondary_action, secondary_on,
    primary, primary_action, primary_on, MODAL_FOOTER_LEFT, MODAL_FOOTER_RIGHT);
}


void drawModalFooter(PGraphics g, float y, String secondary, int secondary_action, boolean secondary_on,
  String primary, int primary_action, boolean primary_on, float left, float right){
  float content_w = right - left;
  float primary_w = modalButtonWidth(g, primary, content_w);
  float secondary_w = modalButtonWidth(g, secondary, content_w);
  float total_w = primary_w + secondary_w + (secondary_w > 0 ? MODAL_FOOTER_GAP : 0);

  if (total_w > content_w){
    float available_w = content_w - (secondary_w > 0 ? MODAL_FOOTER_GAP : 0);
    float primary_ratio = primary_w / max(1, primary_w + secondary_w);
    if (secondary_w > 0){
      primary_w = constrain(available_w * primary_ratio, 84, available_w - 84);
      secondary_w = available_w - primary_w;
    } else {
      primary_w = available_w;
    }
  }

  if (primary.length() > 0) drawButton(g, right - primary_w, y, primary_w, MODAL_BUTTON_HEIGHT,
    primary, primary_action, primary_on);
  if (secondary.length() > 0) drawButton(g, right - primary_w - MODAL_FOOTER_GAP - secondary_w, y,
    secondary_w, MODAL_BUTTON_HEIGHT,
    secondary, secondary_action, secondary_on);
}


void drawBackdrop(PGraphics g, float x, float y, float w, float h){
  g.fill(COL_ROOM);
  g.stroke(COL_BORDER);
  g.rect(x, y, w, h, 3);
}
void drawModalShade(PGraphics g){
  g.noStroke();
  g.fill(0xB8000000);
  g.rect(0, 52, BASE_W, BASE_H - 52);
}


void openDialogue(String name, String value){
  pending_quest_action = ACTION_NONE;
  dialog_name = name;
  dialog_text = value;
  dialog_result = "";
  dialog_crew = -1;
  dialog_open = true;
}


void drawDialogue(PGraphics g){
  drawModalShade(g);
  drawPortrait(g, dialog_name, 470, 72);
  drawPanel(g, 24, 176, 592, 126, COL_CYAN);
  text(g, dialog_name + " — FALA", 40, 188, 16, COL_CYAN);
  drawTextWrapped(g, dialog_text, 40, 207, 552, 16, 18, COL_TEXT);
  if (dialog_result.length() > 0){
    drawPanel(g, 34, 254, 572, 42, COL_BORDER);
    text(g, "RESULTADO", 46, 264, 16, COL_GREEN);
    drawTextWrapped(g, dialog_result, 136, 264, 454, 16, 16, COL_TEXT);
  }
  if (pending_quest_action == ACTION_ACCEPT_ORDER){
    boolean enabled = pendingQuestEnabled();
    drawModalFooter(g, 305, "AGORA NÃO (ESC)", ACTION_CLOSE_MODAL, true,
      "ACEITAR (ENTER)", ACTION_CONFIRM_QUEST, enabled);
    if (!enabled) text(g, questReasonText(pendingQuestReason()), 40, 288, 16, COL_ORANGE);
  } else {
    drawModalFooter(g, 305, "", ACTION_NONE, false,
      "CONTINUAR (ENTER)", ACTION_CLOSE_MODAL, true);
  }
}


void drawPortrait(PGraphics g, String name, float x, float y){
  g.stroke(COL_BORDER);
  g.fill(COL_PANEL);
  g.rect(x, y, ART_PORTRAIT_W, ART_PORTRAIT_H, 4);

  PImage art = crewPortraitArt(name);

  if (art != null){
    drawArtCorner(g, art, x, y, ART_PORTRAIT_W, ART_PORTRAIT_H);
    return;
  }

  int colour = name.equals("VERA") ? COL_CYAN
    : name.equals("SÍLVIA") ? COL_ORANGE
    : name.equals("BENTO") ? COL_GREEN : COL_YELLOW;

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
  clearRetryState();
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
    boolean deliver = pending_quest_action == ACTION_DELIVER_QUEST;
    String dismiss_label = pending_quest_action == ACTION_RETRY_QUEST
      ? "VOLTAR (ESC)" : "AGORA NÃO (ESC)";
    String label = deliver ? "APLICAR REPARO (ENTER)"
      : pending_quest_action == ACTION_RESCUE ? "SOCORRER (ENTER)"
      : pending_quest_action == ACTION_RETRY_QUEST ? "RETOMAR (ENTER)" : "CONFIRMAR (ENTER)";
    boolean enabled = pendingQuestEnabled();
    drawModalFooter(g, 284, dismiss_label, ACTION_CLOSE_MODAL, true,
      label, ACTION_CONFIRM_QUEST, enabled);
    if (!enabled) text(g, questReasonText(pendingQuestReason()), 50, 257, 16, COL_ORANGE);
  } else {
    drawModalFooter(g, 284, "", ACTION_NONE, false,
      "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
  }
}


void drawEndDayPanel(PGraphics g){
  NightProjection projection = recalculateEndDayPanel();
  drawModalShade(g);
  drawPanel(g, 12, 12, 616, 336, COL_ORANGE);
  text(g, "Encerrar o dia?", 28, 24, 16, COL_ORANGE);
  text(g, "RECURSO        VARIAÇÃO       VALOR PREVISTO", 28, 48, 16, COL_MUTED);
  text(g, projection.resource_line_a, 28, 64, 16, COL_TEXT);
  text(g, projection.resource_line_b, 28, 80, 16, COL_TEXT);
  float y = drawTextWrapped(g, projection.quest_summary, 28, 104, 584, 16, 18, COL_CYAN);
  y = drawTextWrapped(g, projection.risk_line, 28, y + 3, 584, 16, 18, COL_ORANGE);
  y = drawTextWrapped(g, projection.outcome_line, 28, y + 3, 584, 16, 18,
    projection.game_outcome == NIGHT_OUTCOME_DEFEAT ? COL_RED : COL_GREEN);
  if (projection.fatal_conditions.length > 0){
    text(g, "CONDIÇÕES FATAIS", 28, y + 3, 16, COL_RED);
    y += 21;
    for (int i = 0; i < projection.fatal_conditions.length; i++){
      y = drawTextWrapped(g, "• " + projection.fatal_conditions[i], 28, y, 584, 16, 18, COL_RED);
    }
  } else {
    y = drawTextWrapped(g, "Nenhuma condição fatal prevista.", 28, y + 3, 584, 16, 18, COL_GREEN);
  }
  /* Effects are already reflected in the table and the fatality list. Keeping
     the reserved lower band empty guarantees that every condition stays above
     the confirmation controls, including the multi-fatality defeat preview. */
  drawModalFooter(g, 320, "VOLTAR (ESC)", ACTION_CLOSE_MODAL, true,
    "DORMIR (ENTER)", ACTION_END_DAY, true);
}


final String[] help_lines = {
  "ANDAR: ← → OU A/D",
  "CORRER: SHIFT COM ← → OU A/D",
  "ESCADA: ↑ ↓ OU W/S",
  "PULAR: ESPAÇO",
  "INTERAGIR E ABRIR PORTAS: E",
  "CONFIRMAR DIÁLOGO, ORDEM E DORMIR: ENTER",
  "PAUSA, FECHAR MODAL E VOLTAR: ESC",
  "MAPA, ORDENS E AJUDA: BOTÕES DO RODAPÉ, COM O MOUSE"
};


void drawHelpPanel(PGraphics g){
  /* O painel dimensiona pelo número de linhas: acrescentar uma tecla não
     exige recortar a altura nem mover o botão. */
  float panel_h = 84 + 9 * (help_lines.length - 1);
  drawModalShade(g);
  drawPanel(g, 34, 88, 572, panel_h, COL_CYAN);
  text(g, "AJUDA — CONTROLES", 50, 98, 16, COL_CYAN);

  float y = 120;

  for (int i = 0; i < help_lines.length; i++){
    text(g, help_lines[i], 50, y, 16, COL_TEXT);
    y += 9;
  }

  drawModalFooter(g, y + 2, "", ACTION_NONE, false,
    "FECHAR (ESC)", ACTION_CLOSE_MODAL, true);
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


void textShadow(PGraphics g, String value, float x, float y, float size, int colour){
  float actual_size = readableTextSize(size);
  drawShadowText(g, value, x, y, actual_size, colour);
}


void textCenteredShadow(PGraphics g, String value, float cx, float y, float size, int colour){
  float actual_size = size;
  float render_size = renderTextSize(actual_size);
  g.textSize(render_size);
  float tx = cx - g.textWidth(value) / 2.0;
  drawShadowText(g, value, tx, y, actual_size, colour);
}


void textPromptShadow(PGraphics g, String value, float cx, float y, float size, int colour){
  float render_size = renderTextSize(size);
  g.textSize(render_size);
  float tx = cx - g.textWidth(value) / 2.0;
  drawShadowText(g, value, tx, y, size, colour);
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
