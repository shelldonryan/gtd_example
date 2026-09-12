/* ui - paineis, texto, botoes e hit-test
   Coordenadas do desenho: canto superior esquerdo. O hit-test usa o centro do
   retangulo, no checkRectOverlap() do professor (AABB por centro). */

final int LAYER_SCENE = 0;
final int LAYER_EVENT = 1;
final int LAYER_PAUSE = 2;
final int MAX_BUTTONS = 16;
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

  drawPanel(g, x, y, w, h, border);
  g.fill(colour);
  g.textSize(text_size);
  g.text(label, x + 8, y + (h - text_size) / 2.0);

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
  g.textSize(size);

  while (size > 10 && g.textWidth(value) > max_width){
    size -= 1;
    g.textSize(size);
  }

  return size;
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
  g.textSize(actual_size);
  g.text(value, x, y);
}


void textCentered(PGraphics g, String value, float cx, float y, float size, int colour){
  float actual_size = readableTextSize(size);

  g.fill(colour);
  g.textSize(actual_size);
  g.text(value, cx - g.textWidth(value) / 2.0, y);
}


float drawTextWrapped(PGraphics g, String value, float x, float y, float w, float size, float line_h, int colour){
  String[] words = split(value, ' ');
  String line = "";
  float actual_size = readableWrapSize(size);
  float actual_line_h = max(line_h, actual_size + 2);

  g.fill(colour);
  g.textSize(actual_size);

  float line_y = y;

  for (int i = 0; i < words.length; i++){
    String candidate = (line.length() == 0) ? words[i] : line + " " + words[i];

    if (line.length() > 0 && g.textWidth(candidate) > w){
      g.text(line, x, line_y);
      line = words[i];
      line_y += actual_line_h;
    } else {
      line = candidate;
    }
  }

  if (line.length() > 0){
    g.text(line, x, line_y);
  }

  return line_y + actual_line_h;
}
