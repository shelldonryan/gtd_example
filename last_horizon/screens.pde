final int VIGNETTE_PAGES = 3;

String[][] vignette_lines = {
  {"A TERRA ENTROU EM COLAPSO.", "NÃO HÁ RECURSOS PARA FICAR."},
  {"QUATRO SOBREVIVENTES A BORDO.", "A PARTIDA COMEÇA AGORA."},
  {"DEZ DIAS ATÉ MARTE.", "MOTOR OPERANTE. AO MENOS UM SOBREVIVENTE VIVO."}
};


boolean isMenuScreen(){
  return screen == SCREEN_INIT || screen == SCREEN_VIGNETTE || screen == SCREEN_VICTORY || screen == SCREEN_GAME_OVER;
}


boolean isRoomScreen(){
  return screen == SCREEN_COMMAND || screen == SCREEN_MACHINES || screen == SCREEN_DEPOT || screen == SCREEN_DORMITORY;
}


boolean modalOpen(){
  return uiLayer() != LAYER_SCENE;
}


int uiLayer(){
  if (paused){
    return LAYER_PAUSE;
  }

  if (transmission_open) return LAYER_TRANSMISSION;
  if (event_open) return LAYER_EVENT;
  if (orders_open) return LAYER_ORDERS;
  if (map_open) return LAYER_MAP;
  if (dialog_open) return LAYER_DIALOGUE;
  if (technical_open) return LAYER_TECHNICAL;
  if (end_day_open) return LAYER_SLEEP;
  if (help_open) return LAYER_HELP;
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
void drawModalLayer(PGraphics g){
  int active_layer = uiLayer();
  draw_layer = active_layer;

  if (active_layer == LAYER_PAUSE){
    drawPauseCard(g);
  } else if (active_layer == LAYER_TRANSMISSION){
    drawTransmissionCard(g);
  } else if (active_layer == LAYER_EVENT){
    drawEventCard(g);
  } else if (active_layer == LAYER_ORDERS){
    drawOrdersPanel(g);
  } else if (active_layer == LAYER_MAP){
    drawMapOverlay(g);
  } else if (active_layer == LAYER_DIALOGUE){
    drawDialogue(g);
  } else if (active_layer == LAYER_TECHNICAL){
    drawTechnicalPanel(g);
  } else if (active_layer == LAYER_SLEEP){
    drawEndDayPanel(g);
  } else if (active_layer == LAYER_HELP){
    drawHelpPanel(g);
  }
}


boolean closeTopModal(){
  int active_layer = uiLayer();

  if (active_layer == LAYER_PAUSE){
    paused = false;
    return true;
  }

  if (active_layer == LAYER_TRANSMISSION){
    transmission_open = false;
    return true;
  }

  if (active_layer == LAYER_EVENT){
    if (quest_review >= 0){
      quest_review = -1;
      return true;
    }
    /* A mandatory incident comparison remains available after ESC by moving
       to pause. This keeps the event intact and avoids falling through to a
       hidden room or modal control. */
    paused = true;
    return true;
  }

  if (active_layer == LAYER_ORDERS){
    orders_open = false;
    orders_details_open = false;
    pending_quest_action = ACTION_NONE;
    clearRetryState();
    return true;
  }
  if (active_layer == LAYER_MAP){
    map_open = false;
    return true;
  }
  if (active_layer == LAYER_DIALOGUE){
    dialog_open = false;
    dialog_result = "";
    dialog_crew = -1;
    pending_quest_action = ACTION_NONE;
    clearRetryState();
    return true;
  }
  if (active_layer == LAYER_TECHNICAL){
    technical_open = false;
    pending_quest_action = ACTION_NONE;
    clearRetryState();
    return true;
  }
  if (active_layer == LAYER_SLEEP){
    closeEndDayPanel();
    return true;
  }
  if (active_layer == LAYER_HELP){
    help_open = false;
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

  if (action == ACTION_OPEN_MAP){
    map_open = true;
    return;
  }

  if (action == ACTION_CLOSE_MODAL){
    closeTopModal();
    return;
  }

  if (action == ACTION_END_DAY){
    closeEndDayPanel();
    endDay();
    return;
  }
  if (action == ACTION_OPEN_ORDERS){
    orders_page = -1;
    orders_details_open = false;
    orders_open = true;
    return;
  }
  if (action == ACTION_OPEN_HELP){
    help_open = true;
    return;
  }
  if (action == ACTION_OPEN_RESCUE){
    map_open = false;
    orders_open = false;
    openRescuePanel();
    return;
  }
  if (action == ACTION_ORDER_A || action == ACTION_ORDER_B){
    int offer_slot = action == ACTION_ORDER_A ? 0 : 1;
    int selected_id = daily_offers[offer_slot];
    if (choosePreventive(selected_id)){
      orders_open = false;
      system_message = "CONFIRME COM " + crew_name[quest_owner[selected_id]] + " EM "
        + roomTitle(point_room[crew_point[quest_owner[selected_id]]]) + ".";
    }
    return;
  }
  if (action == ACTION_CONFIRM_QUEST){
    applyQuestAction();
    return;
  }
  if (action == ACTION_NEXT_RETRY){
    cycleRetry();
    return;
  }
  if (action == ACTION_TOGGLE_ORDER_DETAILS){
    orders_details_open = !orders_details_open;
    return;
  }
  if (action == ACTION_RETRY_QUEST){
    reviewRetry();
    return;
  }
  if (action == ACTION_ACCEPT_SOLUTION){
    if (quest_review >= 0) acceptSolution(quest_review);
    return;
  }
  if (action == ACTION_BACK_SOLUTION){
    quest_review = -1;
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
    player_name = "";
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


void drawScreenBackdrop(PGraphics g, int index){
  PImage art = art_screen == null ? null : art_screen[index];

  if (art != null){
    drawArtCorner(g, art, 0, 0, BASE_W, BASE_H);
    return;
  }

  drawStars(g);
}


void drawInitScreen(PGraphics g){
  drawScreenBackdrop(g, 0);

  textCentered(g, "LAST HORIZON", BASE_W / 2.0, 62, 32, COL_CYAN);
  textCentered(g, "A TERRA FICOU PARA TRÁS. MARTE É O DESTINO.", BASE_W / 2.0, 108, 10, COL_MUTED);

  drawPanel(g, 220, 138, 200, 46, COL_BORDER);
  text(g, "Nome do seu personagem:", 228, 144, 9, COL_MUTED);
  String name_cursor = (millis() / 500) % 2 == 0 ? "_" : "";
  text(g, player_name + name_cursor, 228, 158, 13, COL_TEXT);

  drawButton(g, 198, 196, 150, 24, "INICIAR (ENTER)", ACTION_START_GAME, player_name.trim().length() > 0);
  drawButton(g, 354, 196, 90, 24, "SAIR", ACTION_QUIT_GAME, true);
}


void drawVignetteScreen(PGraphics g){
  drawScreenBackdrop(g, 0);

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
  drawScreenBackdrop(g, 1);

  String trip = (day >= trip_days) ? str(trip_days) : str(day);

  textCentered(g, "A NAVE CHEGOU A MARTE", BASE_W / 2.0, 52, 20, COL_GREEN);
  textCentered(g, "VIAGEM CONCLUÍDA EM " + trip + " DIAS", BASE_W / 2.0, 86, 10, COL_TEXT);
  textCentered(g, survivorsSummary(), BASE_W / 2.0, 104, 10, COL_TEXT);
  textCentered(g, "ENERGIA " + str(int(energy)) + "   OXIGÊNIO " + str(int(oxygen)) + "   ÁGUA " + str(int(water)), BASE_W / 2.0, 126, 10, COL_MUTED);
  textCentered(g, "COMIDA " + str(int(food)) + "   PEÇAS " + str(parts) + "   MORAL " + str(int(morale)), BASE_W / 2.0, 144, 10, COL_MUTED);
  textCentered(g, marsMessage(), BASE_W / 2.0, 176, 10, COL_CYAN);

  drawButton(g, 220, 240, 200, 24, "NOVA PARTIDA", ACTION_NEW_GAME, true);
}


void drawGameOverScreen(PGraphics g){
  drawScreenBackdrop(g, 2);

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
