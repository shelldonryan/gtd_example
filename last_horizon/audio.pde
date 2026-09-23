import javax.sound.sampled.*;
import java.util.ArrayList;

final String AUDIO_WALK_DIR = "audio/walk/";
final String AUDIO_RUN_DIR = "audio/run/";
final String AUDIO_LADDER_DIR = "audio/ladder/";
final String AUDIO_DOOR_DIR = "audio/door/";
final String AUDIO_LADDER_FILE = AUDIO_LADDER_DIR + "ladder.wav";
final String AUDIO_DOOR_FILE = AUDIO_DOOR_DIR + "door.wav";
final String[] AUDIO_WALK_STEP_FILES = {
  AUDIO_WALK_DIR + "step_01.wav", AUDIO_WALK_DIR + "step_02.wav",
  AUDIO_WALK_DIR + "step_03.wav", AUDIO_WALK_DIR + "step_04.wav"
};
final String[] AUDIO_RUN_STEP_FILES = {
  AUDIO_RUN_DIR + "step_01.wav", AUDIO_RUN_DIR + "step_02.wav",
  AUDIO_RUN_DIR + "step_03.wav", AUDIO_RUN_DIR + "step_04.wav"
};
final String[] AUDIO_LADDER_STEP_FILES = {
  AUDIO_LADDER_DIR + "step_01.wav", AUDIO_LADDER_DIR + "step_02.wav",
  AUDIO_LADDER_DIR + "step_03.wav", AUDIO_LADDER_DIR + "step_04.wav"
};

Clip sound_ladder;
Clip sound_door;
Clip[] sound_walk_step = new Clip[AUDIO_WALK_STEP_FILES.length];
Clip[] sound_run_step = new Clip[AUDIO_RUN_STEP_FILES.length];
Clip[] sound_ladder_step = new Clip[AUDIO_LADDER_STEP_FILES.length];
int sound_walk_step_index = 0;
int sound_run_step_index = 0;
int sound_ladder_step_index = 0;
final int FRAME_AUDIO_QUEUE_CAPACITY = 64;
final int FRAME_AUDIO_PLAY_CLIP = 1;
int[] frame_audio_commands = new int[FRAME_AUDIO_QUEUE_CAPACITY];
Clip[] frame_audio_clips = new Clip[FRAME_AUDIO_QUEUE_CAPACITY];
int frame_audio_command_count = 0;
int frame_audio_dropped_commands = 0;
boolean frame_audio_collecting = false;
boolean frame_audio_dispatching = false;
String frame_audio_diagnostic = "";

final String MOVEMENT_AUDIO_WALK = "walk";
final String MOVEMENT_AUDIO_RUN = "run";
final String MOVEMENT_AUDIO_LADDER = "ladder";
final String MOVEMENT_AUDIO_TAKEOFF = "takeoff";
final String MOVEMENT_AUDIO_LANDING = "landing";
CoalescingMovementAudioAdapter movement_audio_adapter =
  new CoalescingMovementAudioAdapter();


class MovementAudioEvent {
  public final String family;
  public final int variant;
  public final long callback_id;

  MovementAudioEvent(String eventFamily, int eventVariant, long callbackId){
    if (eventFamily == null || eventFamily.length() == 0
      || eventVariant < 0 || callbackId <= 0){
      throw new IllegalArgumentException("evento de áudio de movimento inválido");
    }
    family = eventFamily;
    variant = eventVariant;
    callback_id = callbackId;
  }
}


class CoalescingMovementAudioAdapter {
  private final ArrayList<MovementAudioEvent> callback_events =
    new ArrayList<MovementAudioEvent>();
  private long active_callback_id = -1;

  void beginCallback(long callbackId){
    if (callback_events.size() > 0){
      println("som: eventos físicos do callback " + active_callback_id
        + " foram descartados antes do despacho");
    }
    callback_events.clear();
    active_callback_id = callbackId;
  }

  void emit(MovementAudioEvent event){
    if (event == null) throw new IllegalArgumentException("evento de áudio obrigatório");
    if (event.callback_id == active_callback_id) callback_events.add(event);
  }

  void dispatchCallback(long callbackId){
    if (callback_events.size() == 0) return;
    if (callbackId != active_callback_id){
      callback_events.clear();
      println("som: despacho ignorado por divergência de callback");
      return;
    }

    ArrayList<String> dispatched_families = new ArrayList<String>();
    try {
      for (MovementAudioEvent event : callback_events){
        try {
          stopStepSounds();
        }
        catch (RuntimeException error){
          println("som: falha ao parar clips antes de " + event.family
            + " (partida continua): " + error.getMessage());
        }
      }
      for (MovementAudioEvent event : callback_events){
        if (dispatched_families.contains(event.family)) continue;
        dispatched_families.add(event.family);
        playMovementAudioEvent(event);
      }
    }
    finally {
      callback_events.clear();
    }
  }
}


void playMovementAudioEvent(MovementAudioEvent event){
  Clip clip = movementAudioClipFor(event);
  if (clip == null){
    println("som: clip ausente para " + event.family + " variante " + event.variant);
    return;
  }
  try {
    clip.stop();
    clip.setFramePosition(0);
    clip.start();
  }
  catch (RuntimeException error){
    println("som: falha ao reproduzir " + event.family + " (partida continua): "
      + error.getMessage());
  }
}


void emitMovementAudioEvent(FrameContext context, String family){
  requireMovementStep(context, "emitMovementAudioEvent");
  int variant = nextMovementAudioVariant(family);
  MovementAudioEvent event = new MovementAudioEvent(family, variant,
    context.callback_id);
  sound_step_play_count++;
  try {
    movement_audio_adapter.emit(event);
  }
  catch (RuntimeException error){
    println("som: adapter não registrou o evento " + family
      + " (movimento continua): " + error.getMessage());
  }
}

int nextMovementAudioVariant(String family){
  if (MOVEMENT_AUDIO_RUN.equals(family)){
    int variant = sound_run_step_index;
    sound_run_step_index = (sound_run_step_index + 1) % sound_run_step.length;
    return variant;
  }
  if (MOVEMENT_AUDIO_LADDER.equals(family)){
    int variant = sound_ladder_step_index;
    sound_ladder_step_index = (sound_ladder_step_index + 1) % sound_ladder_step.length;
    return variant;
  }
  if (MOVEMENT_AUDIO_WALK.equals(family) || MOVEMENT_AUDIO_TAKEOFF.equals(family)
    || MOVEMENT_AUDIO_LANDING.equals(family)){
    int variant = sound_walk_step_index;
    sound_walk_step_index = (sound_walk_step_index + 1) % sound_walk_step.length;
    return variant;
  }
  throw new IllegalArgumentException("família de áudio desconhecida: " + family);
}


Clip movementAudioClipFor(MovementAudioEvent event){
  if (event == null || event.variant < 0) return null;
  if (MOVEMENT_AUDIO_RUN.equals(event.family)){
    return event.variant < sound_run_step.length ? sound_run_step[event.variant] : null;
  }
  if (MOVEMENT_AUDIO_LADDER.equals(event.family)){
    return event.variant < sound_ladder_step.length ? sound_ladder_step[event.variant] : null;
  }
  if (MOVEMENT_AUDIO_WALK.equals(event.family) || MOVEMENT_AUDIO_TAKEOFF.equals(event.family)
    || MOVEMENT_AUDIO_LANDING.equals(event.family)){
    return event.variant < sound_walk_step.length ? sound_walk_step[event.variant] : null;
  }
  return null;
}


Clip loadSound(String path){
  try {
    AudioInputStream input = AudioSystem.getAudioInputStream(dataFile(path));
    Clip clip = AudioSystem.getClip();
    clip.open(input);
    input.close();
    return clip;
  }
  catch (Exception error) {
    println("som: " + path + " nao carregou (" + error.getMessage() + ")");
    return null;
  }
}


void playSound(Clip clip){
  if (clip == null){
    return;
  }

  if (frame_audio_collecting && !frame_audio_dispatching){
    enqueueFrameAudio(FRAME_AUDIO_PLAY_CLIP, clip);
    return;
  }

  playSoundImmediately(clip);
}


void playSoundImmediately(Clip clip){
  if (clip == null) return;

  try {
    clip.stop();
    clip.setFramePosition(0);
    clip.start();
  }
  catch (RuntimeException error) {
    println("som: falha ao reproduzir efeito (partida continua)");
  }
}


void beginFrameAudioCollection(){
  if (frame_audio_collecting && frame_audio_command_count > 0){
    frame_audio_diagnostic = "fila de áudio do callback anterior não foi despachada";
    frame_audio_dropped_commands += frame_audio_command_count;
  }
  frame_audio_command_count = 0;
  frame_audio_collecting = true;
  frame_audio_dispatching = false;
  frame_audio_diagnostic = "";
  if (current_frame_context != null){
    try {
      movement_audio_adapter.beginCallback(current_frame_context.callback_id);
    }
    catch (RuntimeException error){
      frame_audio_diagnostic = "adapter de áudio não iniciou o callback: "
        + error.getMessage();
      println("som: " + frame_audio_diagnostic);
    }
  }
}


void enqueueFrameAudio(int command, Clip clip){
  if (frame_audio_command_count >= FRAME_AUDIO_QUEUE_CAPACITY){
    frame_audio_dropped_commands++;
    if (frame_audio_diagnostic.length() == 0){
      frame_audio_diagnostic = "fila de áudio cheia; evento físico foi descartado";
      println("som: " + frame_audio_diagnostic);
    }
    return;
  }
  frame_audio_commands[frame_audio_command_count] = command;
  frame_audio_clips[frame_audio_command_count] = clip;
  frame_audio_command_count++;
}


void dispatchFrameAudio(){
  if (!frame_audio_collecting) return;
  frame_audio_collecting = false;
  frame_audio_dispatching = true;
  try {
    for (int i = 0; i < frame_audio_command_count; i++){
      if (frame_audio_commands[i] == FRAME_AUDIO_PLAY_CLIP){
        playSoundImmediately(frame_audio_clips[i]);
      } else {
        frame_audio_diagnostic = "comando de áudio desconhecido: " + frame_audio_commands[i];
        println("som: " + frame_audio_diagnostic);
      }
      frame_audio_clips[i] = null;
    }
    long callbackId = current_frame_context == null ? -1 : current_frame_context.callback_id;
    try {
      movement_audio_adapter.dispatchCallback(callbackId);
    }
    catch (RuntimeException error){
      frame_audio_diagnostic = "adapter de áudio falhou no despacho: "
        + error.getMessage();
      println("som: " + frame_audio_diagnostic);
    }
  }
  finally {
    frame_audio_command_count = 0;
    frame_audio_dispatching = false;
  }
}


boolean stopSound(Clip clip){
  if (clip == null){
    return true;
  }

  try {
    clip.stop();
    return true;
  }
  catch (RuntimeException error){
    println("som: falha ao parar clip (partida continua): " + error.getMessage());
    return false;
  }
}


void primeSound(Clip clip){
  if (clip == null) return;

  FloatControl gain = null;
  BooleanControl mute = null;
  float original_gain = 0;
  boolean original_mute = false;

  try {
    if (clip.isControlSupported(BooleanControl.Type.MUTE)){
      mute = (BooleanControl) clip.getControl(BooleanControl.Type.MUTE);
      original_mute = mute.getValue();
      mute.setValue(true);
    } else if (clip.isControlSupported(FloatControl.Type.MASTER_GAIN)){
      gain = (FloatControl) clip.getControl(FloatControl.Type.MASTER_GAIN);
      original_gain = gain.getValue();
      gain.setValue(gain.getMinimum());
    } else if (clip.isControlSupported(FloatControl.Type.VOLUME)){
      gain = (FloatControl) clip.getControl(FloatControl.Type.VOLUME);
      original_gain = gain.getValue();
      gain.setValue(gain.getMinimum());
    }

    clip.stop();
    clip.setFramePosition(0);
    clip.start();
    Thread.sleep(50);
  }
  catch (Exception error) {
  }
  finally {
    stopSound(clip);
    try {
      clip.setFramePosition(0);
    }
    catch (RuntimeException error){
    }

    if (mute != null){
      try {
        mute.setValue(original_mute);
      }
      catch (RuntimeException error){
      }
    }

    if (gain != null){
      try {
        gain.setValue(original_gain);
      }
      catch (RuntimeException error){
      }
    }
  }
}



void stopStepSounds(){
  for (int i = 0; i < sound_walk_step.length; i++){
    stopSound(sound_walk_step[i]);
    stopSound(sound_run_step[i]);
    stopSound(sound_ladder_step[i]);
  }
}


void loadGameAudio(){
  sound_ladder = loadSound(AUDIO_LADDER_FILE);
  sound_door = loadSound(AUDIO_DOOR_FILE);

  for (int i = 0; i < AUDIO_WALK_STEP_FILES.length; i++){
    sound_walk_step[i] = loadSound(AUDIO_WALK_STEP_FILES[i]);
    sound_run_step[i] = loadSound(AUDIO_RUN_STEP_FILES[i]);
    sound_ladder_step[i] = loadSound(AUDIO_LADDER_STEP_FILES[i]);
  }

  primeSound(sound_ladder);
  primeSound(sound_door);
  for (int i = 0; i < sound_walk_step.length; i++){
    primeSound(sound_walk_step[i]);
    primeSound(sound_run_step[i]);
    primeSound(sound_ladder_step[i]);
  }

}
