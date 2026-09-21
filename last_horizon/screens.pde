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


void drawCosmicAtmosphere(PGraphics g, boolean show_mars){
  drawStars(g);

  if (show_mars){
    g.noStroke();
    // Brilho difuso da atmosfera marciana
    g.fill(0x0C9E2A14);
    g.ellipse(BASE_W + 20, BASE_H + 40, 360, 260);
    g.fill(0x14C0361C);
    g.ellipse(BASE_W + 20, BASE_H + 40, 260, 190);
    g.fill(0x22D44824);
    g.ellipse(BASE_W + 20, BASE_H + 40, 180, 130);
    g.fill(0x35E05830);
    g.ellipse(BASE_W + 20, BASE_H + 40, 110, 80);
    // Arco do limbo planetário
    g.stroke(0x60FF7A50);
    g.noFill();
    g.arc(BASE_W + 20, BASE_H + 40, 260, 190, PI * 0.95f, PI * 1.55f);
  }

  // Linhas de telemetria orbital / coordenadas
  g.noFill();
  g.stroke(0x103FC8E8);
  g.ellipse(BASE_W / 2.0, BASE_H / 2.0, 480, 480);
  g.ellipse(BASE_W / 2.0, BASE_H / 2.0, 320, 320);
  g.stroke(0x183FC8E8);
  g.line(BASE_W / 2.0 - 15, BASE_H / 2.0, BASE_W / 2.0 + 15, BASE_H / 2.0);
  g.line(BASE_W / 2.0, BASE_H / 2.0 - 15, BASE_W / 2.0, BASE_H / 2.0 + 15);
}


void drawScreenBackdrop(PGraphics g, int index){
  PImage art = art_screen == null ? null : art_screen[index];

  if (art != null){
    drawArtCorner(g, art, 0, 0, BASE_W, BASE_H);
    return;
  }

  drawCosmicAtmosphere(g, index == 0 || index == 1);
}


void drawInitScreen(PGraphics g){
  drawScreenBackdrop(g, 0);

  float now = millis();

  // 1. Tag de missão e telemetria militar
  textCentered(g, "MISSÃO STS-10 · DESTINO: MARTE", BASE_W / 2.0, 28, 9, 0x903FC8E8);

  // 2. Título LAST HORIZON com bloom holográfico em múltiplas passadas
  float title_y = 50;
  float title_pulse = (1 + sin(now * 0.002f)) * 0.5f;
  int title_glow_col = lerpColor(0x1A3FC8E8, 0x353FC8E8, title_pulse);

  textCentered(g, "LAST HORIZON", BASE_W / 2.0 - 2, title_y, 32, title_glow_col);
  textCentered(g, "LAST HORIZON", BASE_W / 2.0 + 2, title_y, 32, title_glow_col);
  textCentered(g, "LAST HORIZON", BASE_W / 2.0, title_y - 2, 32, title_glow_col);
  textCentered(g, "LAST HORIZON", BASE_W / 2.0, title_y + 2, 32, title_glow_col);
  textCentered(g, "LAST HORIZON", BASE_W / 2.0 - 1, title_y - 1, 32, 0x503FC8E8);
  textCentered(g, "LAST HORIZON", BASE_W / 2.0 + 1, title_y + 1, 32, 0x503FC8E8);
  textCentered(g, "LAST HORIZON", BASE_W / 2.0, title_y, 32, 0xFFEBF8FC);

  // Delimitadores sci-fi com losangos centrais
  g.stroke(0x403FC8E8);
  g.line(BASE_W / 2.0 - 175, title_y + 16, BASE_W / 2.0 - 120, title_y + 16);
  g.line(BASE_W / 2.0 + 120, title_y + 16, BASE_W / 2.0 + 175, title_y + 16);
  g.noStroke();
  g.fill(COL_CYAN);
  g.rect(BASE_W / 2.0 - 122, title_y + 14.5f, 3, 3);
  g.rect(BASE_W / 2.0 + 119, title_y + 14.5f, 3, 3);

  // 3. Subtítulo com divisores
  textCentered(g, "A TERRA FICOU PARA TRÁS. MARTE É O DESTINO.", BASE_W / 2.0, 90, 10, COL_MUTED);

  // 4. Terminal de Registro do Personagem
  float card_w = 280;
  float card_h = 104;
  float card_x = (BASE_W - card_w) / 2.0;
  float card_y = 112;

  // Sombra suave profunda
  drawDropShadow(g, card_x, card_y, card_w, card_h, 4);

  // Chassis do console
  g.fill(0xF0081220);
  g.stroke(COL_BORDER);
  g.rect(card_x, card_y, card_w, card_h, 4);

  // Cantoneiras técnicas
  g.stroke(COL_CYAN);
  g.line(card_x, card_y + 8, card_x, card_y);
  g.line(card_x, card_y, card_x + 8, card_y);
  g.line(card_x + card_w - 8, card_y, card_x + card_w, card_y);
  g.line(card_x + card_w, card_y, card_x + card_w, card_y + 8);
  g.line(card_x, card_y + card_h - 8, card_x, card_y + card_h);
  g.line(card_x, card_y + card_h, card_x + 8, card_y + card_h);
  g.line(card_x + card_w - 8, card_y + card_h, card_x + card_w, card_y + card_h);
  g.line(card_x + card_w, card_y + card_h - 8, card_x + card_w, card_y + card_h);

  // Faixa de cabeçalho do terminal
  g.noStroke();
  g.fill(0xFF0F2338);
  g.rect(card_x + 1, card_y + 1, card_w - 2, 20, 3, 3, 0, 0);
  g.stroke(0x303FC8E8);
  g.line(card_x + 1, card_y + 21, card_x + card_w - 1, card_y + 21);

  text(g, "TERMINAL DE EMBARQUE - REGISTRO", card_x + 10, card_y + 4, 9, COL_CYAN);

  // LED de status com respiração suave
  float led_pulse = (1 + sin(now * 0.006f)) * 0.5f;
  float led_y = card_y + 8.5f;
  g.noStroke();
  g.fill(COL_GREEN, int(60 + 140 * led_pulse));
  g.ellipse(card_x + card_w - 60, led_y, 7, 7);
  g.fill(COL_GREEN);
  g.ellipse(card_x + card_w - 60, led_y, 3.5f, 3.5f);
  text(g, "ONLINE", card_x + card_w - 50, card_y + 4, 9, COL_GREEN);

  // Campo de entrada rebaixado
  float input_x = card_x + 14;
  float input_y = card_y + 30;
  float input_w = card_w - 28;
  float input_h = 44;

  g.fill(0xFF040810);
  g.stroke(player_name.length() > 0 ? COL_CYAN_DARK : 0xFF183850);
  g.rect(input_x, input_y, input_w, input_h, 3);
  g.noStroke();
  g.fill(0x35000000);
  g.rect(input_x + 1, input_y + 1, input_w - 2, 3);

  text(g, "IDENTIFICAÇÃO DO TÉCNICO:", input_x + 8, input_y + 6, 9, COL_MUTED);

  // Prompt e texto
  text(g, ">", input_x + 8, input_y + 21, 14, COL_CYAN);
  text(g, player_name, input_x + 20, input_y + 21, 14, COL_TEXT);

  // Cursor em bloco com respiração suave contínua
  float cursor_alpha = 120 + 135 * sin(now * 0.009f);
  if (cursor_alpha > 40){
    g.textSize(renderTextSize(14));
    float cursor_x = input_x + 20 + g.textWidth(player_name) + 2;
    g.noStroke();
    g.fill(COL_CYAN, cursor_alpha);
    g.rect(cursor_x, input_y + 21, 7, 13, 1);
  }

  // Dica e contador
  text(g, "[ DIGITE O NOME · ENTER CONFIRMA ]", card_x + 14, card_y + 82, 8.5f, COL_DIM);
  text(g, player_name.length() + "/" + NAME_MAX_LENGTH, card_x + card_w - 42, card_y + 82, 9, COL_DIM);

  // 5. Botões de ação alinhados com feedback tátil
  float btn_y = 228;
  boolean can_start = player_name.trim().length() > 0;
  drawButton(g, 180, btn_y, 170, 26, "INICIAR (ENTER)", ACTION_START_GAME, can_start);
  drawButton(g, 360, btn_y, 100, 26, "SAIR", ACTION_QUIT_GAME, true);

  // 6. Rodapé de telemetria
  textCentered(g, "SISTEMA OPERACIONAL MERCURY v4.5 · NAVE HORIZON · TELEMETRIA ATIVA", BASE_W / 2.0, 336, 8.5f, 0x60A6BBC7);
}


void drawVignetteScreen(PGraphics g){
  drawScreenBackdrop(g, 0);

  // Card central elevado para transmissão
  float card_w = 480;
  float card_h = 130;
  float card_x = (BASE_W - card_w) / 2.0;
  float card_y = 110;

  drawDropShadow(g, card_x, card_y, card_w, card_h, 4);
  drawPanel(g, card_x, card_y, card_w, card_h, COL_CYAN_DARK);

  // Faixa de cabeçalho
  g.noStroke();
  g.fill(0xFF0F2338);
  g.rect(card_x + 1, card_y + 1, card_w - 2, 20, 3, 3, 0, 0);
  g.stroke(0x303FC8E8);
  g.line(card_x + 1, card_y + 21, card_x + card_w - 1, card_y + 21);
  text(g, "REGISTRO DE PARTIDA // TRANSMISSÃO TERRESTRE", card_x + 12, card_y + 4, 9, COL_CYAN);

  float y = card_y + 36;
  for (int i = 0; i < vignette_lines[vignette_page].length; i++){
    textCentered(g, vignette_lines[vignette_page][i], BASE_W / 2.0, y, 13, COL_TEXT);
    y += 24;
  }

  // Paginação por pontos de telemetria
  float dot_cx = BASE_W / 2.0;
  float dot_y = card_y + card_h - 14;
  g.noStroke();
  for (int i = 0; i < VIGNETTE_PAGES; i++){
    float dx = dot_cx + (i - (VIGNETTE_PAGES - 1) / 2.0f) * 12;
    g.fill(i == vignette_page ? COL_CYAN : 0x50648091);
    g.ellipse(dx, dot_y, i == vignette_page ? 5 : 3.5f, i == vignette_page ? 5 : 3.5f);
  }

  // Prompt pulsante inferior
  float prompt_pulse = (1 + sin(millis() * 0.005f)) * 0.5f;
  int prompt_col = lerpColor(0x903FC8E8, COL_CYAN, prompt_pulse);
  textCentered(g, "CLIQUE OU ENTER PARA CONTINUAR", BASE_W / 2.0, 276, 10, prompt_col);

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
