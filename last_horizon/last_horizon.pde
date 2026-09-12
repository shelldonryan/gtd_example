/* Last Horizon - prototipo jogavel
   Processing 4.5.6, modo Java. Estilo do exemplo do professor: codigo em ingles,
   sketch plano, sem classes, pares update e draw separados e um PNG por quadro.
   Abas: ui (widgets), hud, screens (menus), ship (nave e salas), game (dia e eventos),
   capture (prova por PNG e teste do clique). Numeros: mechanics/ACTIONS.md. */

/* canvas */
final int BASE_W = 640;
final int BASE_H = 360;
final int WINDOW_W = BASE_W * 2;
final int WINDOW_H = BASE_H * 2;

/* telas */
final int SCREEN_INIT = 0;
final int SCREEN_VIGNETTE = 1;
final int SCREEN_SHIP = 2;
final int SCREEN_COMMAND = 3;
final int SCREEN_ENERGY = 4;
final int SCREEN_DEPOT = 5;
final int SCREEN_DORMITORY = 6;
final int SCREEN_VICTORY = 7;
final int SCREEN_GAME_OVER = 8;

/* acoes dos botoes */
final int ACTION_NONE = 0;
final int ACTION_START_GAME = 1;
final int ACTION_QUIT_GAME = 2;
final int ACTION_VIGNETTE_NEXT = 3;
final int ACTION_OPEN_COMMAND = 10;
final int ACTION_OPEN_ENERGY = 11;
final int ACTION_OPEN_DEPOT = 12;
final int ACTION_OPEN_DORMITORY = 13;
final int ACTION_BACK_TO_SHIP = 14;
final int ACTION_PASS_DAY = 15;
final int ACTION_REPAIR_ENGINE = 20;
final int ACTION_TOGGLE_SAVING = 21;
final int ACTION_BOOST_ENGINE = 22;
final int ACTION_TOGGLE_RATIONING = 23;
final int ACTION_REPAIR_HULL = 24;
final int ACTION_REST_CREW = 25;
final int ACTION_EVENT_A = 30;
final int ACTION_EVENT_B = 31;
final int ACTION_RESUME = 40;
final int ACTION_RESTART = 41;
final int ACTION_MAIN_MENU = 42;
final int ACTION_NEW_GAME = 43;

/* regras - mechanics/ACTIONS.md */
final int RESOURCE_MAX = 100;
final int RESOURCE_GREEN = 60;
final int RESOURCE_RED = 30;
final int RESOURCE_LOW_ENERGY = 30;
final int TRIP_DAYS = 10;
final int CREW_START = 4;
final int PARTS_START = 6;
final int STOCK_START = 100;

final int ENERGY_PER_DAY = 6;
final int ENERGY_PER_DAY_SAVING = 3;
final int OXYGEN_PER_DAY = 5;
final int OXYGEN_PER_DAY_LOW_ENERGY = 10;
final int WATER_PER_DAY = 8;
final int WATER_PER_DAY_RATIONING = 4;
final int FOOD_PER_DAY = 7;
final int FOOD_PER_DAY_RATIONING = 3;
final int MORALE_PER_DAY = 2;
final int MORALE_PER_RED_RESOURCE = 1;
final int MORALE_PER_DAY_SAVING = 1;
final int MORALE_PER_DAY_RATIONING = 1;
final int LEAK_PER_DAY = 3;
final int ENGINE_DAMAGED_LIMIT_DAYS = 3;
final int STARVING_MORALE_LOSS = 15;

final int REPAIR_ENGINE_PARTS = 2;
final int SAVING_MORALE_COST = 5;
final int BOOST_ENERGY_COST = 20;
final int BOOST_LIMIT = 2;
final int RATIONING_MORALE_COST = 8;
final int REPAIR_HULL_PARTS = 1;
final int REST_ENERGY_COST = 8;
final int REST_MORALE_GAIN = 15;

final int EVENT_REPAIR_PARTS = 2;
final int EVENT_METEOR_ENERGY = 15;
final int EVENT_METEOR_OXYGEN = 15;
final int EVENT_RATIONING_MORALE = 8;
final int EVENT_CONFLICT_MORALE_LOSS = 10;
final int EVENT_CONFLICT_MORALE_GAIN = 10;
final int EVENT_CONFLICT_ENERGY = 10;

/* motor */
final int ENGINE_WORKING = 0;
final int ENGINE_DAMAGED = 1;
final int ENGINE_DESTROYED = 2;

/* fim de jogo */
final int REASON_NONE = 0;
final int REASON_OXYGEN = 1;
final int REASON_ENERGY = 2;
final int REASON_MORALE = 3;
final int REASON_ENGINE = 4;
final int REASON_CREW = 5;

/* paleta - assets/HUD_CONCEPT_ART.png */
final int COL_BG = 0xFF060B16;
final int COL_ROOM = 0xFF0A1422;
final int COL_PANEL = 0xFF0D1B2B;
final int COL_PANEL_2 = 0xFF102238;
final int COL_BORDER = 0xFF24516B;
final int COL_CYAN = 0xFF3FC8E8;
final int COL_CYAN_DARK = 0xFF164968;
final int COL_ORANGE = 0xFFFFB449;
final int COL_TEXT = 0xFFD9E8F2;
final int COL_MUTED = 0xFF7E98AC;
final int COL_DIM = 0xFF3F5B6E;
final int COL_GREEN = 0xFF75D69A;
final int COL_YELLOW = 0xFFE8C95A;
final int COL_RED = 0xFFE8615A;

/* layout */
final float HUD_X = 6;
final float HUD_Y = 6;
final float HUD_H = 44;
final float HUD_GAP = 3;
final int HUD_CARDS = 8;
final float HUD_CARD_W = (BASE_W - HUD_X * 2 - HUD_GAP * (HUD_CARDS - 1)) / HUD_CARDS;

final float SIDE_X = 470;
final float SIDE_Y = 56;
final float SIDE_W = BASE_W - SIDE_X - 6;
final float SIDE_H = 270;

final float FOOTER_Y = 330;
final float FOOTER_H = BASE_H - FOOTER_Y;

/* estado da partida */
String player_name = "";
int screen = SCREEN_INIT;
boolean paused = false;
int vignette_page = 0;

int day = 1;
int trip_days = TRIP_DAYS;
int survivors = CREW_START;
float energy = STOCK_START;
float oxygen = STOCK_START;
float water = STOCK_START;
float food = STOCK_START;
float morale = STOCK_START;
int parts = PARTS_START;
int engine_state = ENGINE_WORKING;
int engine_damaged_days = 0;
boolean leak_on = false;
boolean saving_on = false;
boolean rationing_on = false;
boolean action_used = false;
int boost_count = 0;
int game_over_reason = REASON_NONE;
String system_message = "";

/* interface base */
PGraphics base;
PFont pixel_font;
int view_scale = 1;
float view_offset_x = 0;
float view_offset_y = 0;
float base_mouse_x = 0;
float base_mouse_y = 0;
boolean mouse_pressed = false;
boolean esc_pressed = false;
boolean enter_pressed = false;
boolean backspace_pressed = false;
boolean key_char_pressed = false;
char key_char = ' ';


void settings(){
  size(WINDOW_W, WINDOW_H);
  noSmooth();
  pixelDensity(1);
}


void setup(){
  surface.setResizable(true);
  surface.setTitle("Last Horizon");

  base = createGraphics(BASE_W, BASE_H);
  base.noSmooth();
  pixel_font = createFont("m5x7.ttf", 16, false);

  frameRate(60);
  readArgs();

  if (hit_test_mode){
    surface.setSize(1400, 900);
  }
}


void draw(){
  updateViewport();
  updateInput();

  drawBase();
  drawWindow();

  updateCapture();
}


void drawBase(){
  base.beginDraw();
  base.noSmooth();
  base.background(COL_BG);
  base.textFont(pixel_font);
  base.textAlign(LEFT, TOP);
  base.imageMode(CENTER);
  base.rectMode(CORNER);
  base.strokeWeight(1);

  resetButtons();

  draw_layer = LAYER_SCENE;
  drawScreen(base);

  if (!isMenuScreen()){
    drawHud(base);

    if (event_open){
      draw_layer = LAYER_EVENT;
      drawEventCard(base);
    }

    if (paused){
      draw_layer = LAYER_PAUSE;
      drawPauseCard(base);
    }
  }

  base.endDraw();
}


void drawWindow(){
  background(0);
  noSmooth();
  imageMode(CORNER);
  image(base, view_offset_x, view_offset_y, BASE_W * view_scale, BASE_H * view_scale);
}


void updateViewport(){
  view_scale = max(1, int(min(width / (float) BASE_W, height / (float) BASE_H)));
  view_offset_x = (width - BASE_W * view_scale) / 2.0;
  view_offset_y = (height - BASE_H * view_scale) / 2.0;
}


void updateMouseToBase(){
  base_mouse_x = (mouseX - view_offset_x) / view_scale;
  base_mouse_y = (mouseY - view_offset_y) / view_scale;
}


void updateInput(){
  updateMouseToBase();

  if (mouse_pressed){
    mouse_pressed = false;
    handleClick(base_mouse_x, base_mouse_y);
  }

  if (esc_pressed){
    esc_pressed = false;
    handleEscape();
  }

  if (enter_pressed){
    enter_pressed = false;
    handleEnter();
  }

  if (backspace_pressed){
    backspace_pressed = false;
    handleBackspace();
  }

  if (key_char_pressed){
    key_char_pressed = false;
    handleChar(key_char);
  }
}


void handleClick(float x, float y){
  if (isMenuScreen() && screen == SCREEN_VIGNETTE){
    doAction(ACTION_VIGNETTE_NEXT);
    return;
  }

  int action = findButton(x, y);

  if (action != ACTION_NONE){
    doAction(action);
  }
}


void handleEscape(){
  if (isMenuScreen() || screen == SCREEN_VICTORY || screen == SCREEN_GAME_OVER){
    return;
  }

  paused = !paused;
}


void handleEnter(){
  if (screen == SCREEN_INIT && player_name.trim().length() > 0){
    doAction(ACTION_START_GAME);
    return;
  }

  if (screen == SCREEN_VIGNETTE){
    doAction(ACTION_VIGNETTE_NEXT);
  }
}


void handleBackspace(){
  if (screen != SCREEN_INIT){
    return;
  }

  if (player_name.length() > 0){
    player_name = player_name.substring(0, player_name.length() - 1);
  }
}


void handleChar(char value){
  if (screen != SCREEN_INIT){
    return;
  }

  if (player_name.length() >= NAME_MAX_LENGTH){
    return;
  }

  player_name = player_name + value;
}


void mousePressed(){
  mouse_pressed = true;
}


void keyPressed(){
  if (keyCode == ESC){
    esc_pressed = true;
    return;
  }

  if (key == '\n' || key == '\r'){
    enter_pressed = true;
    return;
  }

  if (keyCode == BACKSPACE){
    backspace_pressed = true;
    return;
  }

  if (key != CODED && key >= 32){
    key_char = key;
    key_char_pressed = true;
  }
}
