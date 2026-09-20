/* Consultas de navegação do mapa. O módulo expõe poucos resultados para o
   desenho e não altera a partida, não usa RNG e não executa ações. */

final int MAP_TARGET_NONE = -1;
final int MAP_REASON_NONE = 0;
final int MAP_REASON_NO_TARGET = 1;
final int MAP_REASON_NO_ROUTE = 2;
final int MAP_REASON_INVALID_TARGET = 3;
final int MAP_REASON_VERTICAL_UNAVAILABLE = 4;
final int MAP_REASON_OUTSIDE_DECK = 5;

int map_target_point = MAP_TARGET_NONE;
int map_target_room = SCREEN_NONE;
int map_target_reason = MAP_REASON_NONE;
int map_consult_point = MAP_TARGET_NONE;
String map_target_text = "";
int[] map_route_rooms;
int[] map_route_doors;
int map_route_length = 0;
int map_next_door = -1;
int map_next_ladder = -1;

String deckLabel(int deck){
  if (deck == 0) return "superior";
  if (deck == 1) return "médio";
  if (deck == 2) return "inferior";
  return "altura livre";
}

int pointDeck(int point){
  if (point < 0 || point >= point_y.length) return -1;
  int best = -1;
  float distance = Float.MAX_VALUE;
  for (int deck = 0; deck < DECK_COUNT; deck++){
    float candidate = abs(point_y[point] - deck_y[deck]);
    if (candidate < distance){
      distance = candidate;
      best = deck;
    }
  }
  return distance <= 5 ? best : -1;
}

int playerDeckForMap(){
  if (player_on_ladder && current_ladder >= 0){
    float feet = player_y + PLAYER_H;
    int top = ladder_top_deck[current_ladder];
    int bottom = ladder_bottom_deck[current_ladder];
    int nearest = top;
    float distance = abs(feet - deck_y[top]);
    for (int deck = top; deck <= bottom; deck++){
      float candidate = abs(feet - deck_y[deck]);
      if (candidate < distance){
        nearest = deck;
        distance = candidate;
      }
    }
    return nearest;
  }
  float feet = player_y + PLAYER_H;
  int best = -1;
  float distance = Float.MAX_VALUE;
  for (int deck = 0; deck < DECK_COUNT; deck++){
    float candidate = abs(feet - deck_y[deck]);
    if (candidate < distance){
      best = deck;
      distance = candidate;
    }
  }
  return distance <= 8 ? best : -1;
}

int mapTargetPoint(){
  return currentObjective();
}

String mapTargetText(){
  int point = mapTargetPoint();
  if (point < 0) return "";
  if (active_quest >= 0){
    if (quest_stage == QUEST_COLLECT) return "Pegue " + quest_object[active_quest] + " — " + pointLocation(point);
    return "Leve " + quest_object[active_quest] + " — " + pointLocation(point);
  }
  if (selected_preventive_id >= 0) return "Fale com " + crewDisplayName(quest_owner[selected_preventive_id])
    + " — " + pointLocation(point);
  if (quest_completed) return "Volte ao seu beliche — " + pointLocation(POINT_TECH_BUNK);
  if (urgentRisk() >= 0) return "Ver local do socorro — " + pointLocation(POINT_RISK_BUNK);
  return "Nenhum destino ativo.";
}

String mapTargetKind(){
  if (active_quest >= 0) return quest_stage == QUEST_COLLECT ? "PRÓXIMA AÇÃO · PEGAR" : "PRÓXIMA AÇÃO · LEVAR";
  if (selected_preventive_id >= 0) return "PRÓXIMA AÇÃO · CONFIRMAR";
  if (quest_completed) return "PRÓXIMA AÇÃO · DESCANSAR";
  if (urgentRisk() >= 0) return "CONSULTA · SOCORRO";
  return ordersAvailable() ? "SEM ORDEM SELECIONADA" : "SEM DESTINO ATIVO";
}


String mapNoTargetInstruction(){
  if (map_consult_point >= 0){
    return "Consulta de " + pointDisplayLabel(map_consult_point)
      + ". Ela não altera sua ordem. Escolha uma oferta em Ordens para traçar uma rota.";
  }
  if (ordersAvailable()){
    return "Escolha uma oferta em Ordens. O mapa mostrará quem procurar e as próximas passagens.";
  }
  return "Nenhuma tarefa tem destino agora. Selecione uma sala para consultar conveses e conexões.";
}

void calculateMapRoute(){
  if (map_route_rooms == null){
    map_route_rooms = new int[ROOM_COUNT];
    map_route_doors = new int[ROOM_COUNT - 1];
  }

  map_target_point = mapTargetPoint();
  map_target_room = SCREEN_NONE;
  map_target_reason = MAP_REASON_NONE;
  map_target_text = mapTargetText();
  map_route_length = 0;
  map_next_door = -1;
  map_next_ladder = -1;

  if (map_target_point < 0){
    map_target_reason = MAP_REASON_NO_TARGET;
    return;
  }
  if (map_target_point >= point_room.length || point_room[map_target_point] == SCREEN_NONE){
    map_target_reason = MAP_REASON_INVALID_TARGET;
    return;
  }
  map_target_room = point_room[map_target_point];

  int start = roomIndexOrInvalid(screen);
  int goal = roomIndexOrInvalid(map_target_room);
  if (start < 0 || goal < 0){
    map_target_reason = MAP_REASON_NO_ROUTE;
    return;
  }
  int[] previous = new int[ROOM_COUNT];
  int[] previous_door = new int[ROOM_COUNT];
  boolean[] visited = new boolean[ROOM_COUNT];
  int[] queue = new int[ROOM_COUNT];
  for (int i = 0; i < ROOM_COUNT; i++){
    previous[i] = -1;
    previous_door[i] = -1;
  }

  int head = 0;
  int tail = 0;
  queue[tail++] = start;
  visited[start] = true;
  while (head < tail){
    int current = queue[head++];
    if (current == goal) break;
    int current_screen = room_screen[current];
    for (int door = 0; door < DOOR_COUNT; door++){
      if (door_room[door] != current_screen) continue;
      int next = roomIndexOrInvalid(door_target[door]);
      if (next < 0) continue;
      if (visited[next]) continue;
      visited[next] = true;
      previous[next] = current;
      previous_door[next] = door;
      queue[tail++] = next;
    }
  }

  if (!visited[goal]){
    map_target_reason = MAP_REASON_NO_ROUTE;
    return;
  }

  int[] reverse_rooms = new int[ROOM_COUNT];
  int[] reverse_doors = new int[ROOM_COUNT - 1];
  int length = 0;
  int cursor = goal;
  while (cursor >= 0 && length < ROOM_COUNT){
    reverse_rooms[length++] = cursor;
    if (previous[cursor] >= 0) reverse_doors[length - 1] = previous_door[cursor];
    cursor = previous[cursor];
  }
  map_route_length = length;
  for (int i = 0; i < length; i++){
    map_route_rooms[i] = reverse_rooms[length - i - 1];
    if (i < length - 1) map_route_doors[i] = reverse_doors[length - i - 2];
  }
  if (length > 1){
    map_next_door = map_route_doors[0];
    if (map_next_door >= 0 && map_next_door < DOOR_COUNT
      && door_deck[map_next_door] < 0)
      map_target_reason = MAP_REASON_OUTSIDE_DECK;
  }
  if (map_target_room == screen){
    map_next_ladder = findNextMapLadder(map_target_point);
    int target_deck = pointDeck(map_target_point);
    int current_deck = playerDeckForMap();
    if (target_deck >= 0 && current_deck >= 0 && target_deck != current_deck
      && map_next_ladder < 0)
      map_target_reason = MAP_REASON_VERTICAL_UNAVAILABLE;
  }
}

int findNextMapLadder(int point){
  int target_deck = pointDeck(point);
  int current_deck = playerDeckForMap();
  if (target_deck < 0 || current_deck < 0 || target_deck == current_deck) return -1;
  int direction = target_deck < current_deck ? -1 : 1;
  int next_deck = current_deck + direction;
  int best = -1;
  float best_distance = Float.MAX_VALUE;
  for (int ladder = 0; ladder < LADDER_COUNT; ladder++){
    if (ladder_room[ladder] != screen) continue;
    boolean reaches_current = current_deck >= ladder_top_deck[ladder]
      && current_deck <= ladder_bottom_deck[ladder];
    boolean reaches_next = next_deck >= ladder_top_deck[ladder]
      && next_deck <= ladder_bottom_deck[ladder];
    if (!reaches_current || !reaches_next) continue;
    float distance = abs(player_x + PLAYER_W / 2.0 - ladder_x[ladder]);
    if (distance < best_distance){
      best = ladder;
      best_distance = distance;
    }
  }
  return best;
}

String mapRouteText(){
  if (map_target_reason == MAP_REASON_NO_TARGET) return "Rota automática ainda não definida.";
  if (map_target_reason == MAP_REASON_INVALID_TARGET) return "Destino da etapa inválido.";
  if (map_target_reason == MAP_REASON_NO_ROUTE) return "Não há portas conectadas até o destino.";
  if (map_target_reason == MAP_REASON_VERTICAL_UNAVAILABLE)
    return "Não há escada configurada até o convés do objetivo.";
  String value = "";
  for (int i = 0; i < map_route_length; i++){
    if (i > 0) value += " → ";
    value += room_label[map_route_rooms[i]];
  }
  if (map_target_reason == MAP_REASON_OUTSIDE_DECK)
    value += " · Abertura fora do convés";
  return value.length() > 0 ? value : roomTitle(screen);
}

int roomIndexOrInvalid(int room_id){
  for (int i = 0; i < ROOM_COUNT; i++){
    if (room_screen[i] == room_id) return i;
  }
  return -1;
}

String mapNextInstruction(){
  if (map_target_reason == MAP_REASON_NO_TARGET) return mapNoTargetInstruction();
  if (map_target_reason == MAP_REASON_INVALID_TARGET)
    return "Confira a etapa atual em Ordens; o local indicado não existe na nave.";
  if (map_target_reason == MAP_REASON_NO_ROUTE)
    return "Confira as conexões das portas ou consulte outra sala.";
  if (map_target_reason == MAP_REASON_VERTICAL_UNAVAILABLE)
    return "O destino está nesta sala, mas falta uma escada até o convés certo.";
  if (map_target_reason == MAP_REASON_OUTSIDE_DECK && map_next_door >= 0)
    return "Próxima passagem: porta para " + roomTitle(door_target[map_next_door])
      + " em abertura fora do convés.";
  if (map_target_reason != MAP_REASON_NONE) return "Consulte Ordens para conferir o destino atual.";
  if (map_target_room != screen && map_next_door >= 0){
    String deck = door_deck[map_next_door] >= 0 ? " no convés " + deckLabel(door_deck[map_next_door]) : " em abertura fora do convés";
    return "Próxima passagem: porta para " + roomTitle(door_target[map_next_door]) + deck + ".";
  }
  if (map_next_ladder >= 0){
    float player_center = player_x + PLAYER_W / 2.0;
    String side = ladder_x[map_next_ladder] < player_center ? "à esquerda" : "à direita";
    return "Troca para o convés " + deckLabel(pointDeck(map_target_point))
      + " pela escada " + side + ".";
  }
  if (map_target_room == screen && map_target_point >= 0){
    if (pointDeck(map_target_point) >= 0 && playerDeckForMap() >= 0
      && pointDeck(map_target_point) != playerDeckForMap())
      return "Não há escada configurada para este convés.";
    return "Objetivo nesta sala: " + pointDisplayLabel(map_target_point) + " no convés " + deckLabel(pointDeck(map_target_point)) + ".";
  }
  return "Consulte a rota antes de fechar o mapa.";
}
