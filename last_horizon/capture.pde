/* capture - prova do esqueleto fora da IDE.
   --capture  : salva um PNG por estado em output/ e encerra sozinho.
   --hit-test : abre a janela fora de 16:9 e prova a conversao mouse -> base. */

boolean capture_mode = false;
boolean hit_test_mode = false;
int capture_step = 0;
int capture_next_frame = 0;
final int CAPTURE_FIRST_FRAME = 4;
final int CAPTURE_FRAME_GAP = 3;
final int HIT_TEST_FRAME = 5;

String[] capture_label = {
  "menu_init", "vignette_1", "vignette_2", "vignette_3",
  "ship_day1", "room_energy", "energy_saving_on", "ship_day1_saving",
  "room_depot", "depot_rationing", "ship_day1_rationing", "room_command",
  "ship_day1_action", "room_dormitory", "ship_day1_rested", "event_card",
  "ship_day2", "pause", "ship_day2_resumed", "game_over",
  "menu_init_again", "ship_last_day", "victory"
};


void readArgs(){
  if (args == null){
    return;
  }

  for (int i = 0; i < args.length; i++){
    if (args[i].equals("--capture")){
      capture_mode = true;
    }

    if (args[i].equals("--hit-test")){
      hit_test_mode = true;
    }
  }

  if (capture_mode){
    new File(sketchPath("output")).mkdirs();
  }
}


void updateCapture(){
  if (hit_test_mode && frameCount == HIT_TEST_FRAME){
    runHitTest();
    return;
  }

  if (!capture_mode || frameCount < CAPTURE_FIRST_FRAME){
    return;
  }

  if (frameCount < capture_next_frame){
    return;
  }

  if (capture_step >= capture_label.length){
    exit();
    return;
  }

  saveCanvas(capture_step);
  runCaptureStep(capture_step);

  capture_step++;
  capture_next_frame = frameCount + CAPTURE_FRAME_GAP;
}


void saveCanvas(int step){
  String name = "output/" + nf(step + 1, 2) + "_" + capture_label[step];

  base.save(sketchPath(name + ".png"));
  saveFrame(sketchPath(name + "_window.png"));
  println("capture: " + capture_label[step] + " -> " + screenName());
}


void runCaptureStep(int step){
  if (step == 0){
    typeText("TECNICO");
    clickAction(ACTION_START_GAME);
    return;
  }

  if (step >= 1 && step <= 3){
    clickAction(ACTION_VIGNETTE_NEXT);
    return;
  }

  if (step == 4){
    clickAction(ACTION_OPEN_ENERGY);
    return;
  }

  if (step == 5){
    clickAction(ACTION_TOGGLE_SAVING);
    return;
  }

  if (step == 6 || step == 9 || step == 11){
    clickAction(ACTION_BACK_TO_SHIP);
    return;
  }

  if (step == 7){
    clickAction(ACTION_OPEN_DEPOT);
    return;
  }

  if (step == 8){
    clickAction(ACTION_TOGGLE_RATIONING);
    return;
  }

  if (step == 10){
    clickAction(ACTION_OPEN_COMMAND);
    return;
  }

  if (step == 12){
    clickAction(ACTION_OPEN_DORMITORY);
    return;
  }

  if (step == 13){
    clickAction(ACTION_REST_CREW);
    return;
  }

  if (step == 14){
    clickAction(ACTION_PASS_DAY);
    return;
  }

  if (step == 15){
    clickAction(eventChoiceOn(0) ? ACTION_EVENT_A : ACTION_EVENT_B);
    return;
  }

  if (step == 16){
    handleEscape();
    return;
  }

  if (step == 17){
    clickAction(ACTION_RESUME);
    return;
  }

  if (step == 18){
    oxygen = 0;
    clickAction(ACTION_PASS_DAY);
    return;
  }

  if (step == 19){
    clickAction(ACTION_NEW_GAME);
    return;
  }

  if (step == 20){
    resetRun();
    day = trip_days;
    openDay();
    screen = SCREEN_SHIP;
    event_open = false;
    return;
  }

  if (step == 21){
    clickAction(ACTION_PASS_DAY);
  }
}


void clickAction(int action){
  drawBase();

  for (int i = 0; i < button_count; i++){
    if (button_action[i] != action || !button_on[i] || button_layer[i] != uiLayer()){
      continue;
    }

    handleClick(button_x[i], button_y[i]);
    return;
  }

  println("capture: botao " + action + " indisponivel na tela " + screenName());
}


void typeText(String value){
  for (int i = 0; i < value.length(); i++){
    handleChar(value.charAt(i));
  }
}


void runHitTest(){
  int[] expected = {SCREEN_COMMAND, SCREEN_ENERGY, SCREEN_DEPOT, SCREEN_DORMITORY};

  println("hit-test: janela " + width + "x" + height + " | escala " + view_scale
    + " | offset " + int(view_offset_x) + "," + int(view_offset_y)
    + " | base " + BASE_W + "x" + BASE_H);

  for (int i = 0; i < ROOM_COUNT; i++){
    screen = SCREEN_SHIP;
    paused = false;
    event_open = false;
    drawBase();

    float room_cx = room_x[i] + ROOM_W / 2.0;
    float room_cy = ROOM_Y + ROOM_H / 2.0;

    mouseX = int(room_cx * view_scale + view_offset_x);
    mouseY = int(room_cy * view_scale + view_offset_y);
    mouse_pressed = true;
    updateInput();

    println("hit-test: clique na janela (" + mouseX + "," + mouseY + ") -> base ("
      + int(base_mouse_x) + "," + int(base_mouse_y) + ") -> cômodo " + room_label[i]
      + " -> tela " + screenName() + (screen == expected[i] ? " OK" : " FALHOU"));
  }

  screen = SCREEN_SHIP;
  drawBase();
  mouseX = 4;
  mouseY = 4;
  mouse_pressed = true;
  updateInput();

  println("hit-test: clique no letterbox (" + mouseX + "," + mouseY + ") -> base ("
    + int(base_mouse_x) + "," + int(base_mouse_y) + ") -> tela " + screenName()
    + (screen == SCREEN_SHIP ? " OK" : " FALHOU"));

  exit();
}


String screenName(){
  if (screen == SCREEN_INIT){
    return "menu_init";
  }

  if (screen == SCREEN_VIGNETTE){
    return "vinheta";
  }

  if (screen == SCREEN_SHIP){
    return "nave";
  }

  if (screen == SCREEN_COMMAND){
    return "sala_comando";
  }

  if (screen == SCREEN_ENERGY){
    return "sala_energia";
  }

  if (screen == SCREEN_DEPOT){
    return "deposito";
  }

  if (screen == SCREEN_DORMITORY){
    return "dormitorio";
  }

  if (screen == SCREEN_VICTORY){
    return "vitoria";
  }

  return "derrota";
}
