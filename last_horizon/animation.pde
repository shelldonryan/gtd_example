/* Renderização do técnico. A seleção de quadro permanece baseada no estado de
   animação calculado pelo sketch; esta aba concentra o desenho e o fallback. */

void drawPlayer(PGraphics g){
  if (!player_assets_loaded){
    drawPlayerFallback(g);
    return;
  }

  int frame = playerCurrentFrame();
  updatePlayerFrameLayer(frame);
  g.imageMode(CENTER);
  g.image(player_frame_layer,
    player_x + PLAYER_W / 2.0,
    player_y + PLAYER_H / 2.0,
    PLAYER_DRAW_W,
    PLAYER_DRAW_H
  );
}


void drawPlayerFallback(PGraphics g){
  g.noStroke();
  g.fill(player_on_ladder ? COL_CYAN : COL_ORANGE);
  g.rect(player_x, player_y, PLAYER_W, PLAYER_H);
  g.fill(COL_BG);
  g.rect(player_x + 4, player_y + 5, 2, 2);
  g.rect(player_x + 10, player_y + 5, 2, 2);
  g.rect(player_x + 4, player_y + 17, 8, 2);
}
