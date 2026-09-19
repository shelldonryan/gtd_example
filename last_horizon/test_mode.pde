/* ==========================================================================
   TEST-MODE: Módulo de teste manual (Remover antes da entrega)
   Ativação: Ctrl + K
   Atalhos:
     1 - Teleporte para Sala de Comando (deck do meio, centro)
     2 - Teleporte para Dormitório (deck do meio, centro)
     3 - Teleporte para Sala de Máquinas (deck do meio, centro)
     4 - Teleporte para Depósito (deck do meio, centro)
     5 - Alternar forçamento visual de interação das estações/objetos
   ========================================================================== */

boolean test_mode_active = false;
boolean test_mode_force_visual = false;


boolean testModeKeyPressed(){
  // Detecção de Ctrl + K (código ASCII 11 ou flag de tecla do keyEvent)
  boolean ctrl_down = (keyEvent != null && keyEvent.isControlDown());
  boolean is_ctrl_k = (ctrl_down && (key == 'k' || key == 'K')) || (key == 11);

  if (is_ctrl_k){
    test_mode_active = !test_mode_active;
    if (!test_mode_active){
      test_mode_force_visual = false;
    }
    return true;
  }

  if (!test_mode_active){
    return false;
  }

  if (key == '1'){
    testModeTeleport(SCREEN_COMMAND);
    return true;
  }

  if (key == '2'){
    testModeTeleport(SCREEN_DORMITORY);
    return true;
  }

  if (key == '3'){
    testModeTeleport(SCREEN_MACHINES);
    return true;
  }

  if (key == '4'){
    testModeTeleport(SCREEN_DEPOT);
    return true;
  }

  if (key == '5'){
    test_mode_force_visual = !test_mode_force_visual;
    return true;
  }

  return false;
}


void testModeTeleport(int target_screen){
  // Fecha modais e menus abertos para evitar inconsistências de interface
  event_open = false;
  orders_open = false;
  map_open = false;
  dialog_open = false;
  technical_open = false;
  end_day_open = false;
  help_open = false;
  transmission_open = false;
  paused = false;

  // Posiciona no deck do meio (deck_y[1]) e centro horizontal da sala
  float center_x = (ROOM_LEFT + ROOM_RIGHT) / 2.0;
  enterRoomAtPosition(target_screen, deck_y[1], center_x, 1);
}


void drawTestModeOverlay(PGraphics g){
  if (!test_mode_active){
    return;
  }

  g.pushStyle();
  int badge_border = test_mode_force_visual ? COL_GREEN : COL_CYAN;
  g.stroke(badge_border);
  g.fill(COL_PANEL, 235);
  g.rect(212, FOOTER_Y + 3, BASE_W - 218, 24, 3);

  String visual_label = test_mode_force_visual ? "VISUAL: ON" : "VISUAL: OFF";
  int visual_col = test_mode_force_visual ? COL_GREEN : COL_MUTED;

  text(g, "TEST-MODE", 218, FOOTER_Y + 7, 14, COL_CYAN);
  text(g, "| 1:Cmd 2:Dorm 3:Máq 4:Dep |", 282, FOOTER_Y + 7, 14, COL_TEXT);
  text(g, "5: " + visual_label, 472, FOOTER_Y + 7, 14, visual_col);
  g.popStyle();
}
