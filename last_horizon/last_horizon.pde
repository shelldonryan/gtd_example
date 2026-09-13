/* canvas */
final int BASE_W = 640;
final int BASE_H = 360;
final int WINDOW_W = BASE_W * 2;
final int WINDOW_H = BASE_H * 2;

/* screens */
final int SCREEN_INIT = 0;
final int SCREEN_VIGNETTE = 1;
final int SCREEN_NONE = -1;
final int SCREEN_COMMAND = 3;
final int SCREEN_ENERGY = 4;
final int SCREEN_DEPOT = 5;
final int SCREEN_DORMITORY = 6;
final int SCREEN_VICTORY = 7;
final int SCREEN_GAME_OVER = 8;

/* actions */
final int ACTION_NONE = 0;
final int ACTION_START_GAME = 1;
final int ACTION_QUIT_GAME = 2;
final int ACTION_VIGNETTE_NEXT = 3;
final int ACTION_INSPECT_COMMAND = 10;
final int ACTION_INSPECT_ENERGY = 11;
final int ACTION_INSPECT_DEPOT = 12;
final int ACTION_INSPECT_DORMITORY = 13;
final int ACTION_OPEN_MAP = 14;
final int ACTION_CLOSE_MODAL = 15;
final int ACTION_END_DAY = 16;
final int ACTION_CONFIRM_SWITCH = 17;
final int ACTION_EVENT_A = 30;
final int ACTION_EVENT_B = 31;
final int ACTION_RESUME = 40;
final int ACTION_RESTART = 41;
final int ACTION_MAIN_MENU = 42;
final int ACTION_NEW_GAME = 43;

/* playable room - interface/ROOMS.md */
final int PLAYER_W = 16;
final int PLAYER_H = 24;
final float PLAYER_SPEED = 1.5;
final float JUMP_HEIGHT = 48;
final float GRAVITY = 0.5;
final float LADDER_SPEED = 1.0;
final float INTERACTION_RANGE = 12;
final float ROOM_LEFT = 8;
final float ROOM_RIGHT = 632;
final float ROOM_TOP = 56;
final float ROOM_BOTTOM = 294;

final int ITEM_NONE = 0;
final int ITEM_ENGINE_PARTS = 1;
final int ITEM_WATER = 2;
final int ITEM_SEAL_KIT = 3;
final int ITEM_SPARE_PART = 4;
final int ITEM_FUSE = 5;
final int ITEM_CABLE = 6;
final int ITEM_COOLANT = 7;

/* rules - mechanics/ACTIONS.md */
final int RESOURCE_MAX = 100;
final int RESOURCE_GREEN = 60;
final int RESOURCE_RED = 30;
final int RESOURCE_LOW_ENERGY = 30;
final int TRIP_DAYS = 10;
final int CREW_START = 4;
final int PARTS_START = 6;
final int STOCK_START = 100;
final int FOOD_START = 70;

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
final int OXYGEN_PER_DAY_EMERGENCY = 3;
final int ENERGY_PER_DAY_POWER_FAULT = 3;
final int MORALE_PER_DAY_NO_COMMS = 1;

final int EVENT_REPAIR_PARTS = 2;
final int EVENT_METEOR_ENERGY = 15;
final int EVENT_METEOR_OXYGEN = 15;
final int EVENT_RATIONING_MORALE = 8;
final int EVENT_CONFLICT_MORALE_LOSS = 10;
final int EVENT_CONFLICT_MORALE_GAIN = 10;
final int EVENT_CONFLICT_ENERGY = 10;
final int EVENT_LIFE_PARTS = 2;
final int EVENT_LIFE_ENERGY = 10;
final int EVENT_POWER_ENERGY = 10;
final int EVENT_POWER_MORALE = 10;
final int EVENT_COMMS_PARTS = 1;

/* power repair variants */
final int POWER_VARIANT_NONE = -1;
final int POWER_VARIANT_FUSE = 0;
final int POWER_VARIANT_CABLE = 1;
final int POWER_VARIANT_COOLANT = 2;
final int POWER_VARIANT_COUNT = 3;

/* engine */
final int ENGINE_WORKING = 0;
final int ENGINE_DAMAGED = 1;
final int ENGINE_DESTROYED = 2;

/* end states */
final int REASON_NONE = 0;
final int REASON_OXYGEN = 1;
final int REASON_ENERGY = 2;
final int REASON_MORALE = 3;
final int REASON_ENGINE = 4;
final int REASON_CREW = 5;

/* palette */
final int COL_BG = 0xFF060B16;
final int COL_ROOM = 0xFF0A1422;
final int COL_PANEL = 0xFF0D1B2B;
final int COL_PANEL_2 = 0xFF102238;
final int COL_BORDER = 0xFF24516B;
final int COL_CYAN = 0xFF3FC8E8;
final int COL_CYAN_DARK = 0xFF164968;
final int COL_ORANGE = 0xFFFFB449;
final int COL_TEXT = 0xFFD9E8F2;
final int COL_MUTED = 0xFFA6BBC7;
final int COL_DIM = 0xFF648091;
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

final float OBJECTIVE_Y = 294;
final float OBJECTIVE_H = 36;
final float FOOTER_Y = 330;
final float FOOTER_H = BASE_H - FOOTER_Y;

/* run state */
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
boolean life_support_emergency = false;
boolean power_fault_on = false;
boolean comms_silent = false;
int power_variant = POWER_VARIANT_NONE;
boolean[] power_variant_used = new boolean[POWER_VARIANT_COUNT];
boolean action_used = false;
int boost_count = 0;
int game_over_reason = REASON_NONE;
String system_message = "";
String last_system_message = "";
int system_message_until = 0;

/* room state */
int current_room = SCREEN_COMMAND;
float player_x = ROOM_LEFT + 24;
float player_y = 276;
float player_velocity_y = 0;
boolean player_grounded = true;
boolean player_on_ladder = false;
boolean ladder_vertical_release_required = false;
boolean jump_queued = false;
boolean interact_queued = false;
int held_item = ITEM_NONE;

/* overlays */
boolean map_open = false;
int map_selected_room = 0;
boolean dialog_open = false;
String dialog_name = "";
String dialog_text = "";
boolean technical_open = false;
String technical_title = "";
String technical_text = "";
int pending_switch_point = -1;
boolean end_day_open = false;

/* input */
boolean move_left_held = false;
boolean move_right_held = false;
boolean move_up_held = false;
boolean move_down_held = false;
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
  cursor(ARROW);
  readArgs();

  if (hit_test_mode){
    surface.setSize(1400, 900);
  }
}


void draw(){
  updateViewport();
  updateInput();

  if (isRoomScreen()){
    updateRoom();
  }

  drawBase();
  updateCursor();
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
    drawModalLayer(base);
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
  if (isMenuScreen()){
    return;
  }

  if (closeTopModal()){
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
    key = 0;
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

  if (isRoomScreen()){
    setMovementKey(keyCode, true);

    if (key == 'a' || key == 'A' || key == 'd' || key == 'D'
      || key == 'w' || key == 'W' || key == 's' || key == 'S'){
      setMovementLetter(key, true);
      return;
    }

    if (key == ' '){
      jump_queued = true;
      return;
    }

    if (key == 'e' || key == 'E'){
      interact_queued = true;
      return;
    }

    return;
  }

  if (key != CODED && key >= 32){
    key_char = key;
    key_char_pressed = true;
  }
}


void keyReleased(){
  setMovementKey(keyCode, false);
  setMovementLetter(key, false);
}


void setMovementKey(int code, boolean value){
  if (code == LEFT){
    move_left_held = value;
  } else if (code == RIGHT){
    move_right_held = value;
  } else if (code == UP){
    move_up_held = value;
  } else if (code == DOWN){
    move_down_held = value;
  }
}


void setMovementLetter(char value, boolean state){
  if (value == 'a' || value == 'A'){
    move_left_held = state;
  } else if (value == 'd' || value == 'D'){
    move_right_held = state;
  } else if (value == 'w' || value == 'W'){
    move_up_held = state;
  } else if (value == 's' || value == 'S'){
    move_down_held = state;
  }
}
