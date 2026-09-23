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

String[] art_icon_file = {
  "energia", "oxigenio", "agua", "comida", "pecas", "moral"
};

String[] art_station_file = {
  null, "console_rota", "antena", "bancada_motor",
  null, "painel_distribuicao", "painel_suporte",
  null, "prateleira_reserva", "estoque_comida", "beliche_socorro",
  null, "mesa_grupo", "mesa_comum", "beliche_tecnico", null
};

String[] art_crew_file = {"vera", "bento", "neusa", "silvia"};

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
int[] deck_strip_scales;
int[] deck_strip_generations;
int[] deck_strip_builds_by_deck = new int[DECK_COUNT];
int deck_strip_builds = 0;
long deck_strip_cache_hits = 0;
long deck_strip_cache_misses = 0;
PImage art_dorm_bunk;

HashMap<String, PImage> art_cache = new HashMap<String, PImage>();
int art_loaded = 0;
int art_expected = 0;
int cache_invalidations = 0;
int art_load_ms = 0;
boolean art_load_measured = false;
boolean cache_metrics_available = false;
long cache_memory_bytes = 0;
long cache_memory_peak_bytes = 0;
long art_cache_hits = 0;
long art_cache_misses = 0;
long art_filesystem_checks = 0;
long art_decode_failures = 0;
long fallback_diagnostic_count = 0;
long room_detail_cache_hits = 0;
long room_detail_cache_misses = 0;
long room_detail_cache_invalidations = 0;

final String FALLBACK_DIAGNOSTICS_FILE = "output/fallback-diagnostics.jsonl";
java.io.PrintWriter fallback_diagnostics_writer;
java.util.HashSet<String> fallback_diagnostics_keys =
  new java.util.HashSet<String>();

class DeckStripCacheEntry {
  PImage source;
  int render_width;
  int render_scale;
  int source_generation;
  PImage bitmap;

  DeckStripCacheEntry(PImage source_value, int width_value, int scale_value,
    int generation_value, PImage bitmap_value){
    source = source_value;
    render_width = width_value;
    render_scale = scale_value;
    source_generation = generation_value;
    bitmap = bitmap_value;
  }
}


class DeckStripFailureEntry {
  PImage source;
  int render_width;
  int render_scale;
  int source_generation;

  DeckStripFailureEntry(PImage sourceValue, int widthValue, int scaleValue,
    int generationValue){
    source = sourceValue;
    render_width = widthValue;
    render_scale = scaleValue;
    source_generation = generationValue;
  }
}

ArrayList<DeckStripCacheEntry> deck_strip_cache_entries =
  new ArrayList<DeckStripCacheEntry>();
ArrayList<DeckStripFailureEntry> deck_strip_failed_entries =
  new ArrayList<DeckStripFailureEntry>();


void recordFallbackDiagnostic(String file, String asset_type, String failure,
  String fallback){
  String normalized_file = file == null ? "" : file;
  String key = normalized_file + "|" + asset_type + "|" + failure + "|" + fallback;
  if (fallback_diagnostics_keys.contains(key)){
    return;
  }

  fallback_diagnostics_keys.add(key);
  fallback_diagnostic_count++;
  if (fallback_diagnostics_writer == null){
    new File(sketchPath("output")).mkdirs();
    fallback_diagnostics_writer = createWriter(sketchPath(FALLBACK_DIAGNOSTICS_FILE));
  }

  JSONObject diagnostic = new JSONObject();
  diagnostic.setString("file", normalized_file);
  diagnostic.setString("asset_type", asset_type);
  diagnostic.setString("failure", failure);
  diagnostic.setString("fallback", fallback);
  String json_line = diagnostic.toString().replace("\r", "").replace("\n", "");
  fallback_diagnostics_writer.println(json_line);
  fallback_diagnostics_writer.flush();
}


long imageMemoryBytes(PImage image){
  if (image == null || image.width <= 0 || image.height <= 0){
    return 0;
  }
  return (long) image.width * (long) image.height * 4L;
}


void registerCacheBitmap(PImage bitmap){
  cache_memory_bytes += imageMemoryBytes(bitmap);
  cache_memory_peak_bytes = java.lang.Math.max(cache_memory_peak_bytes, cache_memory_bytes);
}


void releaseCacheBitmap(PImage bitmap){
  cache_memory_bytes = java.lang.Math.max(0L,
    cache_memory_bytes - imageMemoryBytes(bitmap));
}


JSONObject readArtMetadata(String path){
  if (!artExists(path)){
    recordFallbackDiagnostic(path, "spritesheet_metadata", "missing_file",
      "layout_detection_or_geometric_fallback");
    return null;
  }

  try {
    JSONObject metadata = loadJSONObject(path);
    if (metadata == null){
      recordFallbackDiagnostic(path, "spritesheet_metadata", "invalid_json",
        "layout_detection_or_geometric_fallback");
    }
    return metadata;
  } catch (RuntimeException error){
    recordFallbackDiagnostic(path, "spritesheet_metadata", "invalid_json",
      "layout_detection_or_geometric_fallback");
    return null;
  }
}


PImage safeFrameFromRect(PImage sheet, JSONObject rect){
  if (sheet == null || rect == null){
    return null;
  }

  try {
    int x = rect.getInt("x");
    int y = rect.getInt("y");
    int w = rect.getInt("w");
    int h = rect.getInt("h");
    if (x < 0 || y < 0 || w <= 0 || h <= 0
      || w > sheet.width || h > sheet.height
      || x > sheet.width - w || y > sheet.height - h){
      return null;
    }
    return sheet.get(x, y, w, h);
  } catch (RuntimeException error){
    return null;
  }
}


boolean allFramesPresent(PImage[] frames){
  if (frames == null || frames.length == 0){
    return false;
  }

  for (int i = 0; i < frames.length; i++){
    if (!validArtImage(frames[i])){
      return false;
    }
  }
  return true;
}


boolean artExists(String path){
  art_filesystem_checks++;
  return new File(sketchPath("data/" + path)).isFile();
}


boolean validArtImage(PImage image){
  return image != null && image.width > 0 && image.height > 0;
}


PImage loadArt(String path){
  return loadArt(path, "geometric_fallback");
}


PImage loadArt(String path, String failure_fallback){
  if (path == null){
    return null;
  }

  if (art_cache.containsKey(path)){
    art_cache_hits++;
    return art_cache.get(path);
  }

  art_cache_misses++;
  art_expected++;
  PImage art = null;
  if (!artExists(path)){
    recordFallbackDiagnostic(path, "image", "missing_file", failure_fallback);
  } else {
    boolean decode_failed = false;
    try {
      art = loadImage(path);
    } catch (RuntimeException error){
      art_decode_failures++;
      decode_failed = true;
      recordFallbackDiagnostic(path, "image", "invalid_png", failure_fallback);
    }

    if (!validArtImage(art)){
      art = null;
      if (!decode_failed) art_decode_failures++;
      recordFallbackDiagnostic(path, "image", "invalid_png", failure_fallback);
    }
  }
  art_cache.put(path, art);

  if (art != null){
    art_loaded++;
  }

  return art;
}


PImage loadLegacyRoomArt(String name){
  String key = "legacy-room:" + name;
  if (art_cache.containsKey(key)){
    art_cache_hits++;
    return art_cache.get(key);
  }

  art_cache_misses++;
  String relative_path = "../assets/PNG/" + name + ".png";
  String diagnostic_path = "../assets/PNG/" + name + ".png";
  String file_path = sketchPath(relative_path);
  art_filesystem_checks++;
  PImage art = null;
  if (!new File(file_path).isFile()){
    recordFallbackDiagnostic(ART_DECORATION_DIR + name + ".png",
      "decoration", "missing_file", "geometric_fallback");
  } else {
    boolean decode_failed = false;
    try {
      art = loadImage(file_path);
    } catch (RuntimeException error){
      art_decode_failures++;
      decode_failed = true;
      recordFallbackDiagnostic(diagnostic_path, "image", "invalid_png",
        "geometric_fallback");
    }
    if (!validArtImage(art)){
      art = null;
      if (!decode_failed) art_decode_failures++;
      recordFallbackDiagnostic(diagnostic_path, "image", "invalid_png",
        "geometric_fallback");
    }
  }

  art_cache.put(key, art);
  if (art != null) art_loaded++;
  return art;
}


void invalidateArtPath(String path){
  if (path == null || path.length() == 0){
    throw new IllegalArgumentException("o caminho do asset a invalidar é obrigatório");
  }
  boolean invalidated = art_cache.containsKey(path);
  if (invalidated) art_cache.remove(path);
  if (path.indexOf(ART_DECORATION_DIR) == 0){
    String name = path.substring(ART_DECORATION_DIR.length());
    if (name.endsWith(".png")) name = name.substring(0, name.length() - 4);
    if (room_detail_cache.containsKey(name)){
      room_detail_cache.remove(name);
      room_detail_cache_invalidations++;
      invalidated = true;
    }
    if (art_cache.containsKey("legacy-room:" + name)){
      art_cache.remove("legacy-room:" + name);
      invalidated = true;
    }
  }
  if (invalidated) cache_invalidations++;
}


PImage loadSpriteSheet(String path){
  if (path == null || !artExists(path)){
    recordFallbackDiagnostic(path, "spritesheet", "missing_file",
      "geometric_fallback");
    return null;
  }

  try {
    PImage sheet = loadImage(path);
    if (validArtImage(sheet)){
      return sheet;
    }
  } catch (RuntimeException error){
  }

  recordFallbackDiagnostic(path, "spritesheet", "invalid_png", "geometric_fallback");
  return null;
}


PImage frameFromMetadata(PImage sheet, JSONArray frames, int index){
  if (sheet == null || frames == null || index < 0 || index >= frames.size()){
    return null;
  }

  try {
    JSONObject rect = frames.getJSONObject(index).getJSONObject("frame");
    return safeFrameFromRect(sheet, rect);
  } catch (RuntimeException error){
    return null;
  }
}


void loadArtFrames(PImage[] frames, String sheet_path, String data_path){
  PImage sheet = loadArt(sheet_path);

  if (sheet == null){
    return;
  }

  JSONObject data = readArtMetadata(data_path);
  JSONArray list = null;
  if (data != null && data.hasKey("frames")){
    try {
      list = data.getJSONArray("frames");
    } catch (RuntimeException error){
      recordFallbackDiagnostic(data_path, "spritesheet_metadata", "invalid_frames",
        "layout_detection_or_geometric_fallback");
    }
  } else if (data != null){
    recordFallbackDiagnostic(data_path, "spritesheet_metadata", "missing_frames",
      "layout_detection_or_geometric_fallback");
  }

  if (list != null){
    for (int i = 0; i < frames.length && i < list.size(); i++){
      frames[i] = frameFromMetadata(sheet, list, i);
    }
    if (!allFramesPresent(frames)){
      for (int i = 0; i < frames.length; i++){
        frames[i] = null;
      }
      recordFallbackDiagnostic(sheet_path, "spritesheet", "incomplete_frames",
        "per_item_geometric_fallback");
    }
    return;
  }

  if (sheet.width >= 128 && sheet.height >= 25 * 64){
    for (int i = 0; i < frames.length && i < 2; i++){
      frames[i] = sheet.get(i * 64, 24 * 64, 64, 64);
    }
  } else if (frames.length >= 2 && sheet.width >= 128 && sheet.height >= 64){
    frames[0] = sheet.get(0, 0, 64, 64);
    frames[1] = sheet.get(64, 0, 64, 64);
  } else if (frames.length > 0 && sheet.width >= 64 && sheet.height >= 64){
    frames[0] = sheet.get(0, 0, min(64, sheet.width), min(64, sheet.height));
  }

  if (!allFramesPresent(frames)){
    for (int i = 0; i < frames.length; i++){
      frames[i] = null;
    }
    recordFallbackDiagnostic(sheet_path, "spritesheet", "incomplete_frames",
      "per_item_geometric_fallback");
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

  JSONObject data = readArtMetadata(data_path);
  JSONArray list = null;
  if (data != null && data.hasKey("frames")){
    try {
      list = data.getJSONArray("frames");
    } catch (RuntimeException error){
      recordFallbackDiagnostic(data_path, "spritesheet_metadata", "invalid_frames",
        "layout_detection_or_geometric_fallback");
    }
  } else if (data != null){
    recordFallbackDiagnostic(data_path, "spritesheet_metadata", "missing_frames",
      "layout_detection_or_geometric_fallback");
  }

  if (list != null){
    for (int i = 0; i < 2 && i < list.size(); i++){
      PImage f = frameFromMetadata(sheet, list, i);
      art_crew_frames[crew][i] = f;
      art_crew_frames_right[crew][i] = f;
      art_crew_frames_left[crew][i] = flipHorizontal(f);
    }
    if (!allFramesPresent(art_crew_frames[crew])
      || !allFramesPresent(art_crew_frames_left[crew])
      || !allFramesPresent(art_crew_frames_right[crew])){
      for (int frame = 0; frame < 2; frame++){
        art_crew_frames[crew][frame] = null;
        art_crew_frames_left[crew][frame] = null;
        art_crew_frames_right[crew][frame] = null;
      }
      recordFallbackDiagnostic(sheet_path, "spritesheet", "incomplete_frames",
        "per_item_geometric_fallback");
    }
    return;
  }

  if (sheet.width >= 128 && sheet.height >= 26 * 64){
    for (int i = 0; i < 2; i++){
      art_crew_frames_left[crew][i] = sheet.get(i * 64, 23 * 64, 64, 64);
      art_crew_frames[crew][i] = sheet.get(i * 64, 24 * 64, 64, 64);
      art_crew_frames_right[crew][i] = sheet.get(i * 64, 25 * 64, 64, 64);
    }
  } else if (sheet.width >= 128 && sheet.height >= 64){
    for (int i = 0; i < 2; i++){
      PImage f = sheet.get(i * 64, 0, 64, 64);
      art_crew_frames[crew][i] = f;
      art_crew_frames_right[crew][i] = f;
      art_crew_frames_left[crew][i] = flipHorizontal(f);
    }
  }

  if (!allFramesPresent(art_crew_frames[crew])
    || !allFramesPresent(art_crew_frames_left[crew])
    || !allFramesPresent(art_crew_frames_right[crew])){
    for (int frame = 0; frame < 2; frame++){
      art_crew_frames[crew][frame] = null;
      art_crew_frames_left[crew][frame] = null;
      art_crew_frames_right[crew][frame] = null;
    }
    recordFallbackDiagnostic(sheet_path, "spritesheet", "incomplete_frames",
      "per_item_geometric_fallback");
  }
}


void prepareGlowFrames(PImage[] sources, PImage[] cyan_glow, PImage[] orange_glow){
  if (sources == null){
    return;
  }

  for (int frame = 0; frame < sources.length; frame++){
    if (cyan_glow != null && frame < cyan_glow.length){
      cyan_glow[frame] = buildNpcGlow(sources[frame]);
    }
    if (orange_glow != null && frame < orange_glow.length){
      orange_glow[frame] = buildColoredGlow(sources[frame], COL_ORANGE);
    }
  }
}


void prepareNpcGlow(int crew){
  prepareGlowFrames(art_crew_frames[crew], art_crew_glow[crew],
    art_crew_glow_orange[crew]);
  prepareGlowFrames(art_crew_frames_left[crew], art_crew_glow_left[crew],
    art_crew_glow_orange_left[crew]);
  prepareGlowFrames(art_crew_frames_right[crew], art_crew_glow_right[crew],
    art_crew_glow_orange_right[crew]);
}

void prepareDoorGlow(){
  prepareGlowFrames(art_door_frames, art_door_glow, null);
}

void prepareStationGlow(){
  if (art_station == null) return;
  if (art_station_glow == null || art_station_glow.length != art_station.length){
    art_station_glow = new PImage[art_station.length];
    art_station_glow_orange = new PImage[art_station.length];
  }
  prepareGlowFrames(art_station, art_station_glow, art_station_glow_orange);
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
  art_load_measured = true;
  cache_metrics_available = true;

  println("arte: " + art_loaded + " de " + art_expected
    + " imagens carregadas; ausentes usam a geometria do protótipo");
}


boolean cacheMetricsAvailable(){
  return cache_metrics_available
    && resource_icon_builds_by_icon != null
    && resource_icon_builds_by_icon.length == 6
    && deck_strip_builds_by_deck != null
    && deck_strip_builds_by_deck.length == DECK_COUNT;
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
  int source_index = constrain(deck_index, 0, art_floor.length - 1);
  return art_floor[source_index];
}


void prepareDeckStrips(){
  int render_w = round((ROOM_RIGHT - ROOM_LEFT - 8) * RENDER_SCALE);
  prepareDeckStrips(render_w, RENDER_SCALE);
}


void prepareDeckStrips(int render_w, int render_scale){
  if (art_deck_strip == null || art_deck_strip.length != DECK_COUNT){
    art_deck_strip = new PImage[DECK_COUNT];
  }

  if (deck_strip_sources == null || deck_strip_sources.length != DECK_COUNT){
    deck_strip_sources = new PImage[DECK_COUNT];
    deck_strip_widths = new int[DECK_COUNT];
    deck_strip_scales = new int[DECK_COUNT];
    deck_strip_generations = new int[DECK_COUNT];
  }

  render_w = max(1, render_w);
  render_scale = max(1, render_scale);
  syncFloorSourceGenerations();
  for (int i = 0; i < DECK_COUNT; i++){
    PImage tile = floorArtForDeck(i);
    int generation = floorSourceGeneration(tile);
    boolean key_changed = deckStripKeyChanged(i, tile, render_w,
      render_scale, generation);

    if (tile == null){
      if (art_deck_strip[i] == null && key_changed){
        invalidateDeckStripCache(i);
      } else if (art_deck_strip[i] != null){
        recordFallbackDiagnostic("environment/floor_1.png#deck-" + i,
          "floor_band_cache", "source_unavailable",
          "last_valid_or_geometric_fallback");
      }
      continue;
    }

    if (findDeckStripFailureEntry(tile, render_w, render_scale, generation) != null){
      deck_strip_cache_hits++;
      continue;
    }

    if (!validArtImage(tile)){
      deck_strip_cache_misses++;
      rememberDeckStripFailure(tile, render_w, render_scale, generation);
      recordFallbackDiagnostic("environment/floor_1.png#deck-" + i,
        "floor_band_cache", "invalid_source",
        "last_valid_or_geometric_fallback");
      continue;
    }

    DeckStripCacheEntry entry = findDeckStripCacheEntry(tile, render_w, render_scale,
      generation);
    if (entry != null){
      deck_strip_cache_hits++;
      if (key_changed) invalidateDeckStripCache(i);
      art_deck_strip[i] = entry.bitmap;
      deck_strip_sources[i] = tile;
      deck_strip_widths[i] = render_w;
      deck_strip_scales[i] = render_scale;
      deck_strip_generations[i] = generation;
      continue;
    }
    deck_strip_cache_misses++;

    PGraphics strip = null;
    PImage bitmap = null;
    boolean drawing = false;
    String failure = "";
    try {
      strip = createGraphics(render_w, tile.height);
      if (strip == null){
        throw new IllegalStateException("buffer gráfico indisponível");
      }
      strip.beginDraw();
      drawing = true;
      strip.clear();
      strip.noSmooth();
      int x = 0;
      while (x < render_w){
        int w_to_draw = min(tile.width, render_w - x);
        strip.image(tile.get(0, 0, w_to_draw, tile.height), x, 0);
        x += tile.width;
      }
      strip.endDraw();
      drawing = false;
      bitmap = strip.get();
      if (!validArtImage(bitmap)){
        throw new IllegalStateException("a faixa preparada está vazia");
      }
    } catch (RuntimeException error){
      bitmap = null;
      failure = error.getMessage() == null ? error.getClass().getSimpleName()
        : error.getMessage();
      if (drawing){
        try {
          strip.endDraw();
        } catch (RuntimeException endError){
          String endFailure = endError.getMessage() == null
            ? endError.getClass().getSimpleName() : endError.getMessage();
          failure += "; encerramento do desenho: " + endFailure;
        }
      }
    }
    if (bitmap == null){
      rememberDeckStripFailure(tile, render_w, render_scale, generation);
      recordFallbackDiagnostic("environment/floor_1.png#deck-" + i,
        "floor_band_cache", "preparation_failed:" + failure,
        "last_valid_or_geometric_fallback");
      continue;
    }

    if (key_changed) invalidateDeckStripCache(i);
    deck_strip_cache_entries.add(new DeckStripCacheEntry(tile, render_w, render_scale,
      generation, bitmap));
    registerCacheBitmap(bitmap);
    art_deck_strip[i] = bitmap;
    deck_strip_sources[i] = tile;
    deck_strip_widths[i] = render_w;
    deck_strip_scales[i] = render_scale;
    deck_strip_generations[i] = generation;
    deck_strip_builds_by_deck[i]++;
    deck_strip_builds++;
  }
}


DeckStripFailureEntry findDeckStripFailureEntry(PImage source, int render_w,
  int render_scale, int generation){
  for (int index = 0; index < deck_strip_failed_entries.size(); index++){
    DeckStripFailureEntry entry = deck_strip_failed_entries.get(index);
    if (entry.source == source && entry.render_width == render_w
      && entry.render_scale == render_scale
      && entry.source_generation == generation){
      return entry;
    }
  }
  return null;
}


void rememberDeckStripFailure(PImage source, int render_w, int render_scale,
  int generation){
  if (findDeckStripFailureEntry(source, render_w, render_scale, generation) == null){
    deck_strip_failed_entries.add(new DeckStripFailureEntry(source, render_w,
      render_scale, generation));
  }
}


void syncFloorSourceGenerations(){
  if (art_floor == null){
    return;
  }

  if (art_floor_generation_sources == null
    || art_floor_generation_sources.length != art_floor.length){
    PImage[] previous_sources = art_floor_generation_sources;
    int[] previous_generations = art_floor_generations;
    art_floor_generation_sources = new PImage[art_floor.length];
    art_floor_generations = new int[art_floor.length];
    for (int i = 0; i < art_floor.length && previous_sources != null
      && i < previous_sources.length; i++){
      art_floor_generation_sources[i] = previous_sources[i];
      art_floor_generations[i] = previous_generations[i];
    }
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
  return deckStripKeyChanged(deck, source, render_w, RENDER_SCALE, generation);
}


boolean deckStripKeyChanged(int deck, PImage source, int render_w, int render_scale,
  int generation){
  return deck_strip_sources[deck] != source
    || deck_strip_widths[deck] != render_w
    || deck_strip_scales[deck] != render_scale
    || deck_strip_generations[deck] != generation;
}


DeckStripCacheEntry findDeckStripCacheEntry(PImage source, int render_w, int generation){
  return findDeckStripCacheEntry(source, render_w, RENDER_SCALE, generation);
}


DeckStripCacheEntry findDeckStripCacheEntry(PImage source, int render_w, int render_scale,
  int generation){
  for (int i = 0; i < deck_strip_cache_entries.size(); i++){
    DeckStripCacheEntry entry = deck_strip_cache_entries.get(i);
    if (entry.source == source && entry.render_width == render_w
      && entry.render_scale == render_scale
      && entry.source_generation == generation){
      return entry;
    }
  }

  return null;
}


void invalidateDeckStripCache(int deck){
  PImage old_source = deck_strip_sources[deck];
  int old_width = deck_strip_widths[deck];
  int old_scale = deck_strip_scales[deck];
  int old_generation = deck_strip_generations[deck];
  art_deck_strip[deck] = null;
  deck_strip_sources[deck] = null;
  deck_strip_widths[deck] = 0;
  deck_strip_scales[deck] = 0;
  deck_strip_generations[deck] = 0;

  if (old_source == null){
    return;
  }

  boolean used_elsewhere = false;
  for (int other = 0; other < DECK_COUNT; other++){
    if (other != deck && deck_strip_sources[other] == old_source
      && deck_strip_widths[other] == old_width
      && deck_strip_scales[other] == old_scale
      && deck_strip_generations[other] == old_generation){
      used_elsewhere = true;
      break;
    }
  }

  if (!used_elsewhere){
    boolean removed = false;
    for (int i = deck_strip_cache_entries.size() - 1; i >= 0; i--){
      DeckStripCacheEntry entry = deck_strip_cache_entries.get(i);
      if (entry.source == old_source && entry.render_width == old_width
        && entry.render_scale == old_scale
        && entry.source_generation == old_generation){
        releaseCacheBitmap(entry.bitmap);
        deck_strip_cache_entries.remove(i);
        removed = true;
      }
    }
    if (removed){
      cache_invalidations++;
    }
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


final int NPC_ART_NORMAL = 0;
final int NPC_ART_CYAN_GLOW = 1;
final int NPC_ART_ORANGE_GLOW = 2;


PImage resolveNpcArt(int crew, int facing, int frame_index, int variant){
  PImage[] frames;
  if (variant == NPC_ART_CYAN_GLOW){
    frames = crewArtGlowFramesFacing(crew, facing);
  } else if (variant == NPC_ART_ORANGE_GLOW){
    frames = crewArtOrangeGlowFramesFacing(crew, facing);
  } else {
    frames = crewArtFramesFacing(crew, facing);
  }

  if (frames == null || frames.length == 0){
    return null;
  }

  int safe_index = constrain(frame_index, 0, frames.length - 1);
  return frames[safe_index];
}


PImage resolveNpcArt(int crew, int facing, int frame_index){
  return resolveNpcArt(crew, facing, frame_index, NPC_ART_NORMAL);
}


PImage resolveNpcArt(String name, int facing, int frame_index, int variant){
  return resolveNpcArt(crewIndexForName(name), facing, frame_index, variant);
}


PImage resolveNpcArt(String name, int facing, int frame_index){
  return resolveNpcArt(crewIndexForName(name), facing, frame_index, NPC_ART_NORMAL);
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

  return int((presentationTimeMillis() / frame_ms) % frame_count);
}


PImage artFrame(PImage[] frames, int frame_ms){
  if (frames == null || frames.length == 0 || frames[0] == null){
    return null;
  }

  return frames[artFrameIndex(frames.length, frame_ms)];
}
