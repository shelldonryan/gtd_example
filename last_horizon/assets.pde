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

/* canvas -> drawn size, in logical units */
final int ART_ICON_WARNING = 6;
final float ART_ICON_DRAW = 16;
final float ART_SPRITE_DRAW = 32;
final float ART_DOOR_W = 32;
final float ART_DOOR_H = 64;
final float ART_PORTRAIT_W = 112;
final float ART_PORTRAIT_H = 138;
final float ART_BACKDROP_TOP = 56;
final float ART_BACKDROP_H = 228;
final float ART_MAP_W = 120;
final float ART_MAP_H = 72;
final int ART_NPC_FRAME_MS = 500;
final int ART_HULL_FRAME_MS = 500;
final int ART_DOOR_PHASE_MS = 180;

/* 6 resources plus the warning icon, in data/icons/ */
String[] art_icon_file = {
  "energia", "oxigenio", "agua", "comida", "pecas", "moral", "aviso"
};

/* 13 stations, in data/stations/; null on NPC and hull points */
String[] art_station_file = {
  null, "console_rota", "painel_situacao", "antena", "bancada_motor",
  null, "painel_distribuicao", "reator", "painel_suporte",
  null, "prateleira_reserva", "estoque_comida", "beliche_socorro",
  null, "mesa_grupo", "mesa_comum", "beliche_tecnico", null
};

/* 4 survivors in data/npc/ and data/portraits/ */
String[] art_crew_file = {"vera", "bento", "neusa", "silvia"};

/* 4 rooms in data/rooms/ and data/map/ */
String[] art_room_file = {"command", "machines", "depot", "dormitory"};

PImage[] art_icon;
PImage[] art_station;
PImage[] art_object;
PImage[] art_backdrop;
PImage[] art_portrait;
PImage[] art_map;
PImage[] art_screen = new PImage[3];
PImage[][] art_crew_frames;
PImage[][] art_crew_frames_left;
PImage[][] art_crew_frames_right;
PImage[] art_door_frames = new PImage[2];
PImage[] art_hull_frames = new PImage[2];

HashMap<String, PImage> art_cache = new HashMap<String, PImage>();
int art_loaded = 0;
int art_expected = 0;


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


void loadArtAssets(){
  art_icon = new PImage[art_icon_file.length];
  art_station = new PImage[art_station_file.length];
  art_object = new PImage[quest_id.length];
  art_backdrop = new PImage[ROOM_COUNT];
  art_portrait = new PImage[CREW_COUNT];
  art_map = new PImage[ROOM_COUNT];
  art_crew_frames = new PImage[CREW_COUNT][2];
  art_crew_frames_left = new PImage[CREW_COUNT][2];
  art_crew_frames_right = new PImage[CREW_COUNT][2];

  for (int i = 0; i < art_icon_file.length; i++){
    art_icon[i] = loadArt(ART_ICON_DIR + art_icon_file[i] + ".png");
  }

  for (int point = 0; point < art_station_file.length; point++){
    if (art_station_file[point] != null){
      art_station[point] = loadArt(ART_STATION_DIR + art_station_file[point] + ".png");
    }
  }

  for (int q = 0; q < quest_id.length; q++){
    art_object[q] = loadArt(ART_OBJECT_DIR + quest_object_file[q] + ".png");
  }

  for (int crew = 0; crew < CREW_COUNT; crew++){
    loadNpcArtFrames(crew,
      ART_NPC_DIR + art_crew_file[crew] + ".png",
      ART_NPC_DIR + art_crew_file[crew] + ".json");
    art_portrait[crew] = loadArt(ART_PORTRAIT_DIR + art_crew_file[crew] + ".png");
    if (art_portrait[crew] == null){
      art_portrait[crew] = loadArt(ART_NPC_DIR + art_crew_file[crew] + "_portrait.png");
    }
  }

  for (int room = 0; room < ROOM_COUNT; room++){
    art_backdrop[room] = loadArt(ART_ROOM_DIR + art_room_file[room] + ".png");
    art_map[room] = loadArt(ART_MAP_DIR + art_room_file[room] + ".png");
  }

  loadArtFrames(art_door_frames, ART_DOOR_SHEET, ART_DOOR_DATA);
  loadArtFrames(art_hull_frames, ART_HULL_SHEET, ART_HULL_DATA);
  art_screen[0] = loadArt(ART_SCREEN_MENU);
  art_screen[1] = loadArt(ART_SCREEN_VICTORY);
  art_screen[2] = loadArt(ART_SCREEN_DEFEAT);

  println("arte: " + art_loaded + " de " + art_expected
    + " imagens carregadas; ausentes usam a geometria do protótipo");
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


PImage[] crewArtFramesFacing(String name, int facing){
  for (int crew = 0; crew < CREW_COUNT && crew < crew_name.length; crew++){
    if (crew_name[crew].equals(name) || art_crew_file[crew].equalsIgnoreCase(name)){
      if (facing < 0 && art_crew_frames_left != null && art_crew_frames_left[crew][0] != null){
        return art_crew_frames_left[crew];
      }
      if (facing > 0 && art_crew_frames_right != null && art_crew_frames_right[crew][0] != null){
        return art_crew_frames_right[crew];
      }
      if (art_crew_frames != null && art_crew_frames[crew][0] != null){
        return art_crew_frames[crew];
      }
      return null;
    }
  }
  return null;
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
