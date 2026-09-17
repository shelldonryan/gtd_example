/* logical design grid and physical render target */
final int BASE_W = 640;
final int BASE_H = 360;
final int RENDER_SCALE = 2;
final int RENDER_W = BASE_W * RENDER_SCALE;
final int RENDER_H = BASE_H * RENDER_SCALE;

/* screens */
final int SCREEN_INIT = 0;
final int SCREEN_VIGNETTE = 1;
final int SCREEN_NONE = -1;
final int SCREEN_COMMAND = 3;
final int SCREEN_MACHINES = 4;
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
final int ACTION_INSPECT_MACHINES = 11;
final int ACTION_INSPECT_DEPOT = 12;
final int ACTION_INSPECT_DORMITORY = 13;
final int ACTION_OPEN_MAP = 14;
final int ACTION_CLOSE_MODAL = 15;
final int ACTION_END_DAY = 16;
final int ACTION_OPEN_ORDERS = 17;
final int ACTION_ORDER_A = 18;
final int ACTION_ORDER_B = 19;
final int ACTION_ACCEPT_ORDER = 20;
final int ACTION_COLLECT_QUEST = 21;
final int ACTION_DELIVER_QUEST = 22;
final int ACTION_RESCUE = 23;
final int ACTION_NEXT_RETRY = 24;
final int ACTION_RETRY_QUEST = 25;
final int ACTION_ACCEPT_SOLUTION = 26;
final int ACTION_BACK_SOLUTION = 27;
final int ACTION_CONFIRM_QUEST = 28;
final int ACTION_EVENT_A = 30;
final int ACTION_EVENT_B = 31;
final int ACTION_RESUME = 40;
final int ACTION_RESTART = 41;
final int ACTION_MAIN_MENU = 42;
final int ACTION_NEW_GAME = 43;
final int ACTION_OPEN_HELP = 44;

/* playable room - interface/ROOMS.md */
final int PLAYER_W = 16;
final int PLAYER_H = 24;
final String PLAYER_SHEET_FILE = "player/player_sheet.png";
final String PLAYER_SHEET_DATA_FILE = "player/player_sheet.json";
final int PLAYER_DRAW_W = 32;
final int PLAYER_DRAW_H = 32;
final float PLAYER_SPEED = 1.5;
final float JUMP_HEIGHT = 48;
final float GRAVITY = 0.5;
final float LADDER_SPEED = 1.0;
final float INTERACTION_RANGE = 12;
final float ROOM_LEFT = 8;
final float ROOM_RIGHT = 632;
final float ROOM_TOP = 56;
final float ROOM_BOTTOM = 284;
final int ITEM_NONE = 0;

/* rules - mechanics/ACTIONS.md */
final int RESOURCE_MAX = 100;
final int RESOURCE_GREEN = 60;
final int RESOURCE_RED = 30;
final int TRIP_DAYS = 10;
final int CREW_START = 4;
final int ENERGY_PER_DAY = 7;
final int OXYGEN_PER_DAY = 4;
final int WATER_PER_DAY = 6;
final int FOOD_PER_DAY = 6;
final int MORALE_PER_DAY = 2;

/* engine */
final int ENGINE_WORKING = 0;
final int ENGINE_DESTROYED = 1;

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

final float OBJECTIVE_Y = 284;
final float OBJECTIVE_H = 46;
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
float energy = 80;
float oxygen = 85;
float water = 80;
float food = 70;
float morale = 80;
int parts = 4;
int engine_state = ENGINE_WORKING;
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
boolean end_day_open = false;
boolean help_open = false;

/* input */
boolean move_left_held = false;
boolean move_right_held = false;
boolean move_up_held = false;
boolean move_down_held = false;
PGraphics base;
PFont ui_font;
PImage player_sheet;
JSONObject player_sheet_data;
JSONArray player_sheet_frames;
PImage[] player_frame_images;
int[] player_frame_durations;
PGraphics player_frame_layer;
boolean player_assets_loaded = false;
int player_facing = 1;
boolean player_animation_moving = false;
int player_animation_started_at = 0;
int player_rendered_frame = -1;
int player_rendered_facing = 0;
int player_idle_start = 0;
int player_idle_end = 0;
int player_walk_start = 0;
int player_walk_end = 0;
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


/* Verification seam — the harness tab exists only in the repository sketch and
   installs its hooks at construction. The delivered copy keeps the inert
   defaults below, so the game compiles and runs without the harness. */
interface SceneHook {
  boolean draw(PGraphics target);
}

Runnable harness_setup = () -> {};
Runnable harness_update = () -> {};
SceneHook harness_scene = (target) -> false;


void settings(){
  size(RENDER_W, RENDER_H);
  noSmooth();
  pixelDensity(1);
}


void setup(){
  surface.setResizable(true);
  surface.setTitle("Last Horizon");

  base = createGraphics(RENDER_W, RENDER_H);
  base.smooth(4);
  ui_font = createFont("Segoe UI", 64, true);

  frameRate(60);
  cursor(ARROW);
  loadPlayerAssets();
  loadArtAssets();
  harness_setup.run();
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

  harness_update.run();
}


void drawBase(){
  base.beginDraw();
  base.smooth(4);
  base.resetMatrix();
  base.background(COL_BG);
  base.scale(RENDER_SCALE);
  base.textFont(ui_font);
  base.textAlign(LEFT, TOP);
  base.imageMode(CENTER);
  base.rectMode(CORNER);
  base.strokeWeight(1);

  resetButtons();

  draw_layer = LAYER_SCENE;
  if (!harness_scene.draw(base)){
    drawScreen(base);

    if (!isMenuScreen()){
      drawHud(base);
      drawModalLayer(base);
    }
  }

  base.endDraw();
}


void drawWindow(){
  background(0);
  noSmooth();
  imageMode(CORNER);
  image(base, view_offset_x, view_offset_y, RENDER_W * view_scale, RENDER_H * view_scale);
}


void updateViewport(){
  view_scale = max(1, int(min(width / (float) RENDER_W, height / (float) RENDER_H)));
  view_offset_x = (width - RENDER_W * view_scale) / 2.0;
  view_offset_y = (height - RENDER_H * view_scale) / 2.0;
}


void updateMouseToBase(){
  base_mouse_x = (mouseX - view_offset_x) / view_scale / RENDER_SCALE;
  base_mouse_y = (mouseY - view_offset_y) / view_scale / RENDER_SCALE;
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
  if (paused) return;
  if (transmission_open){
    doAction(ACTION_CLOSE_MODAL);
    return;
  }
  if (event_open){
    if (quest_review >= 0) doAction(ACTION_ACCEPT_SOLUTION);
    return;
  }
  if ((dialog_open || technical_open) && pending_quest_action != ACTION_NONE){
    doAction(ACTION_CONFIRM_QUEST);
    return;
  }
  if (dialog_open || technical_open){
    doAction(ACTION_CLOSE_MODAL);
    return;
  }
  if (end_day_open){
    doAction(ACTION_END_DAY);
    return;
  }
  if (screen == SCREEN_INIT && player_name.trim().length() > 0) doAction(ACTION_START_GAME);
  else if (screen == SCREEN_VIGNETTE) doAction(ACTION_VIGNETTE_NEXT);
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
