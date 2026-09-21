/* Art layer — the game takes art by file, without changing code.

   Every PNG follows `assets/INVENTORY.md`: the canvas is the size the piece
   occupies on the 1280×720 render, so 1 art pixel = 1 render pixel. All art is
   drawn at exactly 1:1, with the position rounded to the logical unit.

   When a file is missing, the piece falls back to the prototype geometry and
   the game keeps running — that is what lets the sketch be delivered before
   the art is finished.

   Static files: icons/, stations/, objects/, rooms/, portraits/, screens/, map/.
   Animated files: one spritesheet PNG plus JSON, same format as data/player/. */

final String ART_ICON_DIR = "icons/";
final String ART_STATION_DIR = "stations/";
final String ART_OBJECT_DIR = "objects/";
final String ART_NPC_DIR = "npc/";
final String ART_ROOM_DIR = "rooms/";
final String ART_PORTRAIT_DIR = "portraits/";
final String ART_MAP_DIR = "map/";
final String ART_DOOR_SHEET = "doors/door_sheet.png";
final String ART_DOOR_DATA = "doors/door_sheet.json";
final String ART_HULL_SHEET = "stations/casco_sheet.png";
final String ART_HULL_DATA = "stations/casco_sheet.json";
final String ART_SCREEN_MENU = "screens/menu_space.png";
final String ART_SCREEN_VICTORY = "screens/victory_mars.png";
final String ART_SCREEN_DEFEAT = "screens/defeat_space.png";
final String ART_FLOOR_DIR = "environment/";
final String ART_DECORATION_DIR = "decorations/";
final int FLOOR_COUNT = 1;

/* canvas -> drawn size, in logical units */
final float ART_ICON_DRAW = 16;
final float ART_SPRITE_DRAW = 32;
final float ART_DOOR_W = 52.5;
final float ART_DOOR_H = 48.5;
final float ART_PORTRAIT_W = 112;
final float ART_PORTRAIT_H = 138;
final float ART_BACKDROP_TOP = 56;
final float ART_BACKDROP_H = 228;
final int ART_NPC_FRAME_MS = 500;
final int ART_HULL_FRAME_MS = 500;
final int ART_DOOR_PHASE_MS = 180;

/* 6 resource icons in data/icons/; the critical alert remains code-drawn */
String[] art_icon_file = {
  "energia", "oxigenio", "agua", "comida", "pecas", "moral"
};

/* 11 stations, in data/stations/; null on NPC and hull points */
String[] art_station_file = {
  null, "console_rota", "antena", "bancada_motor",
  null, "painel_distribuicao", "painel_suporte",
  null, "prateleira_reserva", "estoque_comida", "beliche_socorro",
  null, "mesa_grupo", "mesa_comum", "beliche_tecnico", null
};

/* 4 survivors in data/npc/ */
String[] art_crew_file = {"vera", "bento", "neusa", "silvia"};

/* 4 rooms in data/rooms/; the map uses the numbered captures supplied for it. */
String[] art_room_file = {"command", "machines", "depot", "dormitory"};
String[] art_map_file = {"4", "2", "1", "3"};

PImage[] art_icon;
PImage[] art_station;
PImage[] art_station_glow;
PImage[] art_station_glow_orange;
PImage[] art_object;
PImage[] art_backdrop;
PImage[] art_portrait;
PImage[] art_map;
PImage art_map_ship;
PImage[] art_screen = new PImage[3];
PImage[][] art_crew_frames;
PImage[][] art_crew_frames_left;
PImage[][] art_crew_frames_right;
PImage[][] art_crew_glow;
PImage[][] art_crew_glow_left;
PImage[][] art_crew_glow_right;
PImage[][] art_crew_glow_orange;
PImage[][] art_crew_glow_orange_left;
PImage[][] art_crew_glow_orange_right;

PImage[] art_door_frames = new PImage[2];
PImage[] art_door_glow = new PImage[2];
PImage[] art_hull_frames = new PImage[2];

String[] art_floor_file = {
  "floor_1"
};
PImage[] art_floor = new PImage[FLOOR_COUNT];
PImage[] art_deck_strip;
PImage[] art_floor_generation_sources = new PImage[FLOOR_COUNT];
int[] art_floor_generations = new int[FLOOR_COUNT];
PImage[] deck_strip_sources;
int[] deck_strip_widths;
int[] deck_strip_generations;
int[] deck_strip_builds_by_deck = new int[DECK_COUNT];
int deck_strip_builds = 0;
PImage art_dorm_bunk;

HashMap<String, PImage> art_cache = new HashMap<String, PImage>();
int art_loaded = 0;
int art_expected = 0;
int cache_invalidations = 0;
int art_load_ms = 0;

class DeckStripCacheEntry {
  PImage source;
  int render_width;
  int source_generation;
  PImage bitmap;

  DeckStripCacheEntry(PImage source_value, int width_value, int generation_value,
    PImage bitmap_value){
    source = source_value;
    render_width = width_value;
    source_generation = generation_value;
    bitmap = bitmap_value;
  }
}

ArrayList<DeckStripCacheEntry> deck_strip_cache_entries =
  new ArrayList<DeckStripCacheEntry>();


boolean artExists(String path){
  return new File(sketchPath("data/" + path)).isFile();
}


PImage loadArt(String path){
  if (path == null){
    return null;
  }

  if (art_cache.containsKey(path)){
    return art_cache.get(path);
  }

  art_expected++;
  PImage art = artExists(path) ? loadImage(path) : null;
  art_cache.put(path, art);

  if (art != null){
    art_loaded++;
  }

  return art;
}


void loadArtFrames(PImage[] frames, String sheet_path, String data_path){
  PImage sheet = loadArt(sheet_path);

  if (sheet == null){
    return;
  }

  JSONObject data = artExists(data_path) ? loadJSONObject(data_path) : null;
  JSONArray list = data == null ? null : data.getJSONArray("frames");

  if (list != null){
    /* Formato Aseprite com JSON: recorte por coordenadas do array frames */
    for (int i = 0; i < frames.length && i < list.size(); i++){
      JSONObject rect = list.getJSONObject(i).getJSONObject("frame");
      frames[i] = sheet.get(rect.getInt("x"), rect.getInt("y"), rect.getInt("w"), rect.getInt("h"));
    }
    return;
  }

  /* Formato Universal LPC: linha 24 (Sul / frontal), 2 quadros de respiração (D-141) */
  if (sheet.width >= 128 && sheet.height >= 25 * 64){
    for (int i = 0; i < frames.length && i < 2; i++){
      frames[i] = sheet.get(i * 64, 24 * 64, 64, 64);
    }
  } else if (frames.length >= 2 && sheet.width >= 128 && sheet.height >= 64){
    /* Tira horizontal de 2 quadros 64x64 (mesmo sem JSON) */
    frames[0] = sheet.get(0, 0, 64, 64);
    frames[1] = sheet.get(64, 0, 64, 64);
  } else if (frames.length > 0 && sheet.width >= 64 && sheet.height >= 64){
    frames[0] = sheet.get(0, 0, min(64, sheet.width), min(64, sheet.height));
  }
}

PImage flipHorizontal(PImage src){
  if (src == null){
    return null;
  }
  PImage dest = createImage(src.width, src.height, ARGB);
  src.loadPixels();
  dest.loadPixels();
  for (int y = 0; y < src.height; y++){
    for (int x = 0; x < src.width; x++){
      dest.pixels[y * src.width + (src.width - 1 - x)] = src.pixels[y * src.width + x];
    }
  }
  dest.updatePixels();
  return dest;
}


void loadNpcArtFrames(int crew, String sheet_path, String data_path){
  PImage sheet = loadArt(sheet_path);
  if (sheet == null){
    return;
  }

  JSONObject data = artExists(data_path) ? loadJSONObject(data_path) : null;
  JSONArray list = data == null ? null : data.getJSONArray("frames");

  if (list != null){
    /* Aseprite com JSON: 2 quadros para a direita, e espelhado para a esquerda */
    for (int i = 0; i < 2 && i < list.size(); i++){
      JSONObject rect = list.getJSONObject(i).getJSONObject("frame");
      PImage f = sheet.get(rect.getInt("x"), rect.getInt("y"), rect.getInt("w"), rect.getInt("h"));
      art_crew_frames[crew][i] = f;
      art_crew_frames_right[crew][i] = f;
      art_crew_frames_left[crew][i] = flipHorizontal(f);
    }
    return;
  }

  /* Universal LPC: matriz 64x64 com linhas direcionadas */
  if (sheet.width >= 128 && sheet.height >= 26 * 64){
    for (int i = 0; i < 2; i++){
      /* Linha 23: perfil esquerdo (olhando para a esquerda) */
      art_crew_frames_left[crew][i] = sheet.get(i * 64, 23 * 64, 64, 64);
      /* Linha 24: frontal / sul */
      art_crew_frames[crew][i] = sheet.get(i * 64, 24 * 64, 64, 64);
      /* Linha 25: perfil direito (olhando para a direita) */
      art_crew_frames_right[crew][i] = sheet.get(i * 64, 25 * 64, 64, 64);
    }
  } else if (sheet.width >= 128 && sheet.height >= 64){
    /* Tira horizontal simples de 2 quadros */
    for (int i = 0; i < 2; i++){
      PImage f = sheet.get(i * 64, 0, 64, 64);
      art_crew_frames[crew][i] = f;
      art_crew_frames_right[crew][i] = f;
      art_crew_frames_left[crew][i] = flipHorizontal(f);
    }
  } else if (sheet.width >= 64 && sheet.height >= 64){
    PImage f = sheet.get(0, 0, min(64, sheet.width), min(64, sheet.height));
    art_crew_frames[crew][0] = f;
    art_crew_frames[crew][1] = f;
    art_crew_frames_right[crew][0] = f;
    art_crew_frames_right[crew][1] = f;
    art_crew_frames_left[crew][0] = flipHorizontal(f);
    art_crew_frames_left[crew][1] = flipHorizontal(f);
  }
}
void prepareNpcGlow(int crew){
  for (int frame = 0; frame < 2; frame++){
    art_crew_glow[crew][frame] = buildNpcGlow(art_crew_frames[crew][frame]);
    art_crew_glow_left[crew][frame] = buildNpcGlow(art_crew_frames_left[crew][frame]);
    art_crew_glow_right[crew][frame] = buildNpcGlow(art_crew_frames_right[crew][frame]);
    art_crew_glow_orange[crew][frame] = buildColoredGlow(art_crew_frames[crew][frame], COL_ORANGE);
    art_crew_glow_orange_left[crew][frame] = buildColoredGlow(art_crew_frames_left[crew][frame], COL_ORANGE);
    art_crew_glow_orange_right[crew][frame] = buildColoredGlow(art_crew_frames_right[crew][frame], COL_ORANGE);
  }
}

void prepareDoorGlow(){
  for (int frame = 0; frame < art_door_frames.length; frame++){
    art_door_glow[frame] = buildNpcGlow(art_door_frames[frame]);
  }
}

void prepareStationGlow(){
  if (art_station == null) return;
  if (art_station_glow == null || art_station_glow.length != art_station.length){
    art_station_glow = new PImage[art_station.length];
    art_station_glow_orange = new PImage[art_station.length];
  }
  for (int point = 0; point < art_station.length; point++){
    if (art_station[point] != null){
      art_station_glow[point] = buildNpcGlow(art_station[point]);
      art_station_glow_orange[point] = buildColoredGlow(art_station[point], COL_ORANGE);
    } else {
      art_station_glow[point] = null;
      art_station_glow_orange[point] = null;
    }
  }
}


PImage buildColoredGlow(PImage source, int glow_color){
  if (source == null){
    return null;
  }

  PImage glow = createImage(source.width, source.height, ARGB);
  source.loadPixels();
  glow.loadPixels();
  int rgb = glow_color & 0x00FFFFFF;

  for (int y = 0; y < source.height; y++){
    for (int x = 0; x < source.width; x++){
      int index = y * source.width + x;
      int source_alpha = (source.pixels[index] >>> 24) & 0xFF;
      if (source_alpha > 24){
        continue;
      }

      int strongest_alpha = 0;
      for (int offset_y = -2; offset_y <= 2; offset_y++){
        for (int offset_x = -2; offset_x <= 2; offset_x++){
          int distance = offset_x * offset_x + offset_y * offset_y;
          if (distance == 0 || distance > 4){
            continue;
          }

          int sample_x = x + offset_x;
          int sample_y = y + offset_y;
          if (sample_x < 0 || sample_x >= source.width
            || sample_y < 0 || sample_y >= source.height){
            continue;
          }

          int sample = source.pixels[sample_y * source.width + sample_x];
          int sample_alpha = (sample >>> 24) & 0xFF;
          if (sample_alpha <= 24){
            continue;
          }

          int opacity = distance == 1 ? 150 : 70;
          strongest_alpha = max(strongest_alpha, min(opacity, sample_alpha));
        }
      }

      if (strongest_alpha > 0){
        glow.pixels[index] = (strongest_alpha << 24) | rgb;
      }
    }
  }

  glow.updatePixels();
  return glow;
}


PImage buildNpcGlow(PImage source){
  return buildColoredGlow(source, COL_CYAN);
}



void loadArtAssets(){
  long art_load_started_nanos = System.nanoTime();
  art_icon = new PImage[art_icon_file.length];
  art_station = new PImage[art_station_file.length];
  art_station_glow = new PImage[art_station_file.length];
  art_station_glow_orange = new PImage[art_station_file.length];
  art_object = new PImage[quest_id.length];
  art_backdrop = new PImage[ROOM_COUNT];
  art_portrait = new PImage[CREW_COUNT];
  art_map = new PImage[ROOM_COUNT];
  art_crew_frames = new PImage[CREW_COUNT][2];
  art_crew_frames_left = new PImage[CREW_COUNT][2];
  art_crew_frames_right = new PImage[CREW_COUNT][2];
  art_crew_glow = new PImage[CREW_COUNT][2];
  art_crew_glow_left = new PImage[CREW_COUNT][2];
  art_crew_glow_right = new PImage[CREW_COUNT][2];
  art_crew_glow_orange = new PImage[CREW_COUNT][2];
  art_crew_glow_orange_left = new PImage[CREW_COUNT][2];
  art_crew_glow_orange_right = new PImage[CREW_COUNT][2];


  for (int i = 0; i < art_icon_file.length; i++){
    art_icon[i] = loadArt(ART_ICON_DIR + art_icon_file[i] + ".png");
  }

  for (int point = 0; point < art_station_file.length; point++){
    if (art_station_file[point] != null){
      art_station[point] = loadArt(ART_STATION_DIR + art_station_file[point] + ".png");
    }
  }
  prepareStationGlow();

  for (int q = 0; q < quest_id.length; q++){
    art_object[q] = loadArt(ART_OBJECT_DIR + quest_object_file[q] + ".png");
  }

  for (int crew = 0; crew < CREW_COUNT; crew++){
    loadNpcArtFrames(crew,
      ART_NPC_DIR + art_crew_file[crew] + ".png",
      ART_NPC_DIR + art_crew_file[crew] + ".json");
    prepareNpcGlow(crew);
    art_portrait[crew] = loadArt(ART_NPC_DIR + art_crew_file[crew] + "_portrait.png");
    if (art_portrait[crew] == null && artExists(ART_PORTRAIT_DIR + art_crew_file[crew] + ".png")){
      art_portrait[crew] = loadArt(ART_PORTRAIT_DIR + art_crew_file[crew] + ".png");
    }
  }

  for (int room = 0; room < ROOM_COUNT; room++){
    art_backdrop[room] = loadArt(ART_ROOM_DIR + art_room_file[room] + ".png");
    art_map[room] = loadArt(ART_MAP_DIR + art_map_file[room] + ".png");
  }
  art_map_ship = loadArt(ART_MAP_DIR + "ship.png");

  loadArtFrames(art_door_frames, ART_DOOR_SHEET, ART_DOOR_DATA);
  prepareDoorGlow();
  loadArtFrames(art_hull_frames, ART_HULL_SHEET, ART_HULL_DATA);
  art_screen[0] = loadArt(ART_SCREEN_MENU);
  art_screen[1] = loadArt(ART_SCREEN_VICTORY);
  art_screen[2] = loadArt(ART_SCREEN_DEFEAT);

  art_deck_strip = new PImage[DECK_COUNT];
  for (int f = 0; f < FLOOR_COUNT; f++){
    art_floor[f] = loadArt(ART_FLOOR_DIR + art_floor_file[f] + ".png");
  }
  prepareDeckStrips();

  art_dorm_bunk = loadArt(ART_FLOOR_DIR + "dorm_bunk.png");

  prepareResourceIconCache();

  art_load_ms = int((System.nanoTime() - art_load_started_nanos) / 1000000L);

  println("arte: " + art_loaded + " de " + art_expected
    + " imagens carregadas; ausentes usam a geometria do protótipo");
}


boolean hasFloorArt(){
  if (art_floor == null) return false;
  for (int i = 0; i < art_floor.length; i++){
    if (art_floor[i] != null) return true;
  }
  return false;
}


PImage floorArtForDeck(int deck_index){
  if (art_floor == null || art_floor.length == 0) return null;
  return art_floor[0];
}


void prepareDeckStrips(){
  if (art_deck_strip == null || art_deck_strip.length != DECK_COUNT){
    art_deck_strip = new PImage[DECK_COUNT];
  }

  if (deck_strip_sources == null || deck_strip_sources.length != DECK_COUNT){
    deck_strip_sources = new PImage[DECK_COUNT];
    deck_strip_widths = new int[DECK_COUNT];
    deck_strip_generations = new int[DECK_COUNT];
  }

  syncFloorSourceGenerations();
  int render_w = round((ROOM_RIGHT - ROOM_LEFT - 8) * RENDER_SCALE);
  for (int i = 0; i < DECK_COUNT; i++){
    PImage tile = floorArtForDeck(i);
    int generation = floorSourceGeneration(tile);

    if (deckStripKeyChanged(i, tile, render_w, generation)){
      invalidateDeckStripCache(i);
    }

    if (tile == null){
      art_deck_strip[i] = null;
      continue;
    }

    DeckStripCacheEntry entry = findDeckStripCacheEntry(tile, render_w, generation);
    if (entry != null){
      art_deck_strip[i] = entry.bitmap;
      deck_strip_sources[i] = tile;
      deck_strip_widths[i] = render_w;
      deck_strip_generations[i] = generation;
      continue;
    }

    PGraphics strip = createGraphics(render_w, tile.height);
    strip.beginDraw();
    strip.clear();
    strip.noSmooth();
    int x = 0;
    while (x < render_w){
      int w_to_draw = min(tile.width, render_w - x);
      strip.image(tile.get(0, 0, w_to_draw, tile.height), x, 0);
      x += tile.width;
    }
    strip.endDraw();
    PImage bitmap = strip.get();
    deck_strip_cache_entries.add(new DeckStripCacheEntry(tile, render_w, generation, bitmap));
    art_deck_strip[i] = bitmap;
    deck_strip_sources[i] = tile;
    deck_strip_widths[i] = render_w;
    deck_strip_generations[i] = generation;
    deck_strip_builds_by_deck[i]++;
    deck_strip_builds++;
  }
}


void syncFloorSourceGenerations(){
  if (art_floor == null){
    return;
  }

  for (int i = 0; i < art_floor.length && i < art_floor_generations.length; i++){
    if (art_floor_generation_sources[i] != art_floor[i]){
      art_floor_generation_sources[i] = art_floor[i];
      art_floor_generations[i]++;
    }
  }
}


int floorSourceGeneration(PImage source){
  if (source == null || art_floor == null){
    return 0;
  }

  int generation = 0;
  for (int i = 0; i < art_floor.length && i < art_floor_generations.length; i++){
    if (art_floor[i] == source){
      generation = max(generation, art_floor_generations[i]);
    }
  }
  return generation;
}


boolean deckStripKeyChanged(int deck, PImage source, int render_w, int generation){
  return deck_strip_sources[deck] != source
    || deck_strip_widths[deck] != render_w
    || deck_strip_generations[deck] != generation;
}


DeckStripCacheEntry findDeckStripCacheEntry(PImage source, int render_w, int generation){
  for (int i = 0; i < deck_strip_cache_entries.size(); i++){
    DeckStripCacheEntry entry = deck_strip_cache_entries.get(i);
    if (entry.source == source && entry.render_width == render_w
      && entry.source_generation == generation){
      return entry;
    }
  }

  return null;
}


void invalidateDeckStripCache(int deck){
  PImage old_source = deck_strip_sources[deck];
  int old_width = deck_strip_widths[deck];
  int old_generation = deck_strip_generations[deck];
  art_deck_strip[deck] = null;
  deck_strip_sources[deck] = null;
  deck_strip_widths[deck] = 0;
  deck_strip_generations[deck] = 0;

  if (old_source == null){
    return;
  }

  boolean used_elsewhere = false;
  for (int other = 0; other < DECK_COUNT; other++){
    if (other != deck && deck_strip_sources[other] == old_source
      && deck_strip_widths[other] == old_width
      && deck_strip_generations[other] == old_generation){
      used_elsewhere = true;
      break;
    }
  }

  if (!used_elsewhere){
    for (int i = deck_strip_cache_entries.size() - 1; i >= 0; i--){
      DeckStripCacheEntry entry = deck_strip_cache_entries.get(i);
      if (entry.source == old_source && entry.render_width == old_width
        && entry.source_generation == old_generation){
        deck_strip_cache_entries.remove(i);
      }
    }
    cache_invalidations++;
  }
}


void drawArt(PGraphics g, PImage art, float cx, float cy, float w, float h){
  if (art == null){
    return;
  }

  g.imageMode(CENTER);
  g.image(art, round(cx), round(cy), w, h);
}


void drawArtCorner(PGraphics g, PImage art, float x, float y, float w, float h){
  if (art == null){
    return;
  }

  g.imageMode(CORNER);
  g.image(art, round(x), round(y), w, h);
}


PImage questObjectArt(int q){
  if (art_object == null || q < 0 || q >= art_object.length){
    return null;
  }

  return art_object[q];
}


int crewIndexForName(String name){
  if (name == null){
    return -1;
  }

  for (int crew = 0; crew < CREW_COUNT && crew < crew_name.length; crew++){
    if (crew_name[crew].equals(name)
      || (art_crew_file != null && crew < art_crew_file.length
        && art_crew_file[crew].equalsIgnoreCase(name))){
      return crew;
    }
  }

  return -1;
}


PImage[] crewArtFramesFacing(int crew, int facing){
  return selectCrewArtFrames(crew, facing,
    art_crew_frames, art_crew_frames_left, art_crew_frames_right);
}


PImage[] crewArtGlowFramesFacing(int crew, int facing){
  return selectCrewArtFrames(crew, facing,
    art_crew_glow, art_crew_glow_left, art_crew_glow_right);
}


PImage[] crewArtOrangeGlowFramesFacing(int crew, int facing){
  return selectCrewArtFrames(crew, facing,
    art_crew_glow_orange, art_crew_glow_orange_left, art_crew_glow_orange_right);
}


PImage[] selectCrewArtFrames(int crew, int facing, PImage[][] front,
  PImage[][] left, PImage[][] right){
  if (crew < 0 || crew >= CREW_COUNT){
    return null;
  }

  boolean has_left = left != null && crew < left.length
    && left[crew] != null && left[crew].length > 0 && left[crew][0] != null;
  boolean has_right = right != null && crew < right.length
    && right[crew] != null && right[crew].length > 0 && right[crew][0] != null;
  boolean has_front = front != null && crew < front.length
    && front[crew] != null && front[crew].length > 0 && front[crew][0] != null;

  if (facing < 0 && has_left) return left[crew];
  if (facing > 0 && has_right) return right[crew];
  if (has_front) return front[crew];
  return null;
}


PImage[] crewArtFramesFacing(String name, int facing){
  return crewArtFramesFacing(crewIndexForName(name), facing);
}


PImage[] crewArtGlowFramesFacing(String name, int facing){
  return crewArtGlowFramesFacing(crewIndexForName(name), facing);
}


PImage[] crewArtOrangeGlowFramesFacing(String name, int facing){
  return crewArtOrangeGlowFramesFacing(crewIndexForName(name), facing);
}



PImage[] crewArtFrames(String name){
  return crewArtFramesFacing(name, 0);
}


PImage crewPortraitArt(String name){
  if (art_portrait == null){
    return null;
  }

  for (int crew = 0; crew < CREW_COUNT && crew < crew_name.length; crew++){
    if (crew_name[crew].equals(name)){
      return art_portrait[crew];
    }
  }

  return null;
}


int artFrameIndex(int frame_count, int frame_ms){
  if (frame_count < 2 || frame_ms <= 0){
    return 0;
  }

  return int((millis() / frame_ms) % frame_count);
}


PImage artFrame(PImage[] frames, int frame_ms){
  if (frames == null || frames.length == 0 || frames[0] == null){
    return null;
  }

  return frames[artFrameIndex(frames.length, frame_ms)];
}
