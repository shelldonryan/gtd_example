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
  return screen == SCREEN_COMMAND || screen == SCREEN_MACHINES || screen == SCREEN_DEPOT || screen == SCREEN_DORMITORY;
}


boolean modalOpen(){
  return event_open || map_open || dialog_open || technical_open || end_day_open;
}


int uiLayer(){
  if (paused){
    return LAYER_PAUSE;
  }

  return modalOpen() ? LAYER_MODAL : LAYER_SCENE;
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
void drawModalLayer(PGraphics g){
  if (paused){
    draw_layer = LAYER_PAUSE;
    drawPauseCard(g);
    return;
  }

  if (!modalOpen()){
    return;
  }

  draw_layer = LAYER_MODAL;

  if (event_open){
    drawEventCard(g);
  } else if (map_open){
    drawMapOverlay(g);
  } else if (dialog_open){
    drawDialogue(g);
  } else if (technical_open){
    drawTechnicalPanel(g);
  } else if (end_day_open){
    drawEndDayPanel(g);
  }
}


boolean closeTopModal(){
  if (paused){
    paused = false;
    return true;
  }

  if (event_open){
    return false;
  }


  if (map_open || dialog_open || technical_open || end_day_open){
    map_open = false;
    dialog_open = false;
    technical_open = false;
    end_day_open = false;
    pending_switch_point = -1;
    pending_intervention_point = -1;
    pending_collect_point = -1;
    pending_panel_choice = -1;
    return true;
  }

  return false;
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

  if (action >= ACTION_INSPECT_COMMAND && action <= ACTION_INSPECT_DORMITORY){
    map_selected_room = action - ACTION_INSPECT_COMMAND;
    return;
  }

  if (action == ACTION_OPEN_MAP){
    map_open = true;
    map_selected_room = roomIndex(screen);
    return;
  }

  if (action == ACTION_CLOSE_MODAL){
    closeTopModal();
    return;
  }

  if (action == ACTION_END_DAY){
    end_day_open = false;
    endDay();
    return;
  }
  if (action == ACTION_CONFIRM_SWITCH){
    applySwitchPoint();
    return;
  }
  if (action == ACTION_CONFIRM_INTERVENTION){
    applyPendingIntervention();
    return;
  }

  if (action == ACTION_CONFIRM_COLLECT){
    applyPendingCollect();
    return;
  }

  if (action == ACTION_PANEL_REPAIR){
    applyPanelRepair();
    return;
  }

  if (action == ACTION_PANEL_ECONOMY){
    applyPanelEconomy();
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
    enterRoom(SCREEN_COMMAND);
    openDay();
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

  enterRoom(SCREEN_COMMAND);
  openDay();
}


void drawInitScreen(PGraphics g){
  drawStars(g);

  textCentered(g, "LAST HORIZON", BASE_W / 2.0, 62, 32, COL_CYAN);
  textCentered(g, "A TERRA FICOU PARA TRÁS. MARTE É O DESTINO.", BASE_W / 2.0, 108, 10, COL_MUTED);

  drawPanel(g, 220, 138, 200, 46, COL_BORDER);
  text(g, "TÉCNICO", 228, 144, 9, COL_MUTED);
  text(g, player_name + "_", 228, 158, 13, COL_TEXT);

  drawButton(g, 198, 196, 150, 24, "INICIAR (ENTER)", ACTION_START_GAME, player_name.trim().length() > 0);
  drawButton(g, 354, 196, 90, 24, "SAIR", ACTION_QUIT_GAME, true);

  textCentered(g, "PROTÓTIPO - TEXTO PROVISÓRIO", BASE_W / 2.0, 320, 9, COL_DIM);
}


void drawVignetteScreen(PGraphics g){
  drawStars(g);

  float y = 132;

  for (int i = 0; i < vignette_lines[vignette_page].length; i++){
    textCentered(g, vignette_lines[vignette_page][i], BASE_W / 2.0, y, 13, COL_TEXT);
    y += 24;
  }

  textCentered(g, "CLIQUE OU ENTER PARA CONTINUAR", BASE_W / 2.0, 268, 10, COL_CYAN);
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

  drawButton(g, 216, 160, 208, 22, "CONTINUAR (ESC)", ACTION_RESUME, true);
  drawButton(g, 216, 188, 208, 22, "REINICIAR PARTIDA", ACTION_RESTART, true);
  drawButton(g, 216, 216, 208, 22, "SAIR PARA O MENU", ACTION_MAIN_MENU, true);
}
