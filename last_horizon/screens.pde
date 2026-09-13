/* telas - maquina de estados, menus, pausa e despacho das acoes */

final int VIGNETTE_PAGES = 3;

String[][] vignette_lines = {
  {"A TERRA SE ESGOTOU.", "NÃO HÁ VOLTA."},
  {"QUATRO SOBREVIVENTES A BORDO.", "DEZ DIAS ATÉ MARTE."},
  {"O MOTOR É O CORAÇÃO DA VIAGEM.", "MANTENHA-O OPERANTE."}
};


boolean isMenuScreen(){
  return screen == SCREEN_INIT || screen == SCREEN_VIGNETTE || screen == SCREEN_VICTORY || screen == SCREEN_GAME_OVER;
}


boolean isRoomScreen(){
  return screen == SCREEN_COMMAND || screen == SCREEN_ENERGY || screen == SCREEN_DEPOT || screen == SCREEN_DORMITORY;
}


int uiLayer(){
  if (paused){
    return LAYER_PAUSE;
  }

  if (event_open && !isMenuScreen()){
    return LAYER_EVENT;
  }

  return LAYER_SCENE;
}


void drawScreen(PGraphics g){
  if (screen == SCREEN_INIT){
    drawInitScreen(g);
    return;
  }

  if (screen == SCREEN_VIGNETTE){
    drawVignetteScreen(g);
    return;
  }

  if (screen == SCREEN_VICTORY){
    drawVictoryScreen(g);
    return;
  }

  if (screen == SCREEN_GAME_OVER){
    drawGameOverScreen(g);
    return;
  }

  drawShipArea(g);
}


void doAction(int action){
  if (action == ACTION_START_GAME){
    startGame();
    return;
  }

  if (action == ACTION_QUIT_GAME){
    exit();
    return;
  }

  if (action == ACTION_VIGNETTE_NEXT){
    nextVignettePage();
    return;
  }

  if (action == ACTION_OPEN_COMMAND){
    enterRoom(SCREEN_COMMAND);
    return;
  }

  if (action == ACTION_OPEN_ENERGY){
    enterRoom(SCREEN_ENERGY);
    return;
  }

  if (action == ACTION_OPEN_DEPOT){
    enterRoom(SCREEN_DEPOT);
    return;
  }

  if (action == ACTION_OPEN_DORMITORY){
    enterRoom(SCREEN_DORMITORY);
    return;
  }

  if (action == ACTION_BACK_TO_SHIP){
    leaveRoom();
    return;
  }

  if (action == ACTION_PASS_DAY){
    passDay();
    return;
  }


  if (action == ACTION_EVENT_A){
    applyEventChoice(0);
    return;
  }

  if (action == ACTION_EVENT_B){
    applyEventChoice(1);
    return;
  }

  if (action == ACTION_RESUME){
    paused = false;
    return;
  }

  if (action == ACTION_RESTART){
    resetRun();
    openDay();
    screen = SCREEN_SHIP;
    return;
  }

  if (action == ACTION_MAIN_MENU || action == ACTION_NEW_GAME){
    resetRun();
    screen = SCREEN_INIT;
    return;
  }
}


void nextVignettePage(){
  if (vignette_page < VIGNETTE_PAGES - 1){
    vignette_page++;
    return;
  }

  screen = SCREEN_SHIP;
  openDay();
}


void drawInitScreen(PGraphics g){
  drawStars(g);

  textCentered(g, "LAST HORIZON", BASE_W / 2.0, 62, 32, COL_CYAN);
  textCentered(g, "A TERRA FICOU PARA TRÁS. MARTE É O DESTINO.", BASE_W / 2.0, 108, 10, COL_MUTED);

  drawPanel(g, 220, 138, 200, 46, COL_BORDER);
  text(g, "TÉCNICO", 228, 144, 9, COL_MUTED);
  text(g, player_name + "_", 228, 158, 13, COL_TEXT);

  drawButton(g, 220, 196, 95, 24, "INICIAR", ACTION_START_GAME, player_name.trim().length() > 0);
  drawButton(g, 325, 196, 95, 24, "SAIR", ACTION_QUIT_GAME, true);

  textCentered(g, "ENTER TAMBÉM INICIA", BASE_W / 2.0, 236, 9, COL_DIM);
  textCentered(g, "PROTÓTIPO - TEXTO PROVISÓRIO", BASE_W / 2.0, 320, 9, COL_DIM);
}


void drawVignetteScreen(PGraphics g){
  drawStars(g);

  float y = 132;

  for (int i = 0; i < vignette_lines[vignette_page].length; i++){
    textCentered(g, vignette_lines[vignette_page][i], BASE_W / 2.0, y, 13, COL_TEXT);
    y += 24;
  }

  textCentered(g, "CLIQUE PARA CONTINUAR", BASE_W / 2.0, 268, 10, COL_CYAN);
  textCentered(g, (vignette_page + 1) + "/" + VIGNETTE_PAGES, BASE_W / 2.0, 300, 9, COL_DIM);

  addButton(0, 0, BASE_W, BASE_H, ACTION_VIGNETTE_NEXT, true);
}


void drawVictoryScreen(PGraphics g){
  drawStars(g);

  String trip = (day >= trip_days) ? str(trip_days) : str(day);

  textCentered(g, "A NAVE CHEGOU A MARTE", BASE_W / 2.0, 52, 20, COL_GREEN);
  textCentered(g, "VIAGEM CONCLUÍDA EM " + trip + " DIAS", BASE_W / 2.0, 86, 10, COL_TEXT);
  textCentered(g, "SOBREVIVENTES: " + survivors + " DE " + CREW_START, BASE_W / 2.0, 104, 10, COL_TEXT);
  textCentered(g, "ENERGIA " + str(int(energy)) + "   OXIGÊNIO " + str(int(oxygen)) + "   ÁGUA " + str(int(water)), BASE_W / 2.0, 126, 10, COL_MUTED);
  textCentered(g, "COMIDA " + str(int(food)) + "   PEÇAS " + str(parts) + "   MORAL " + str(int(morale)), BASE_W / 2.0, 144, 10, COL_MUTED);
  textCentered(g, "A BASE MARCIANA CONFIRMA A CHEGADA. A MISSÃO SEGUE.", BASE_W / 2.0, 176, 10, COL_CYAN);
  textCentered(g, "TEXTO DA MENSAGEM DE MARTE AINDA PROVISÓRIO.", BASE_W / 2.0, 194, 9, COL_DIM);

  drawButton(g, 220, 240, 200, 24, "NOVA PARTIDA", ACTION_NEW_GAME, true);
}


void drawGameOverScreen(PGraphics g){
  drawStars(g);

  textCentered(g, "FIM DA VIAGEM", BASE_W / 2.0, 52, 20, COL_RED);
  textCentered(g, gameOverTitle(), BASE_W / 2.0, 88, 14, COL_ORANGE);
  textCentered(g, gameOverMessage(), BASE_W / 2.0, 112, 10, COL_TEXT);
  textCentered(g, "DIA " + day + " DE " + trip_days + "   SOBREVIVENTES: " + survivors, BASE_W / 2.0, 140, 10, COL_MUTED);
  textCentered(g, "MOTOR: " + engineStateLabel(), BASE_W / 2.0, 158, 10, COL_MUTED);

  drawButton(g, 220, 240, 200, 24, "NOVA PARTIDA", ACTION_NEW_GAME, true);
}


void drawPauseCard(PGraphics g){
  g.noStroke();
  g.fill(0xB0000000);
  g.rect(0, 0, BASE_W, BASE_H);

  drawPanel(g, 200, 104, 240, 152, COL_CYAN);
  textCentered(g, "PAUSA", BASE_W / 2.0, 122, 16, COL_CYAN);

  drawButton(g, 216, 160, 208, 22, "CONTINUAR", ACTION_RESUME, true);
  drawButton(g, 216, 188, 208, 22, "REINICIAR PARTIDA", ACTION_RESTART, true);
  drawButton(g, 216, 216, 208, 22, "SAIR PARA O MENU", ACTION_MAIN_MENU, true);
}
