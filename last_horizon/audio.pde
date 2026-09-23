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
int audio_loaded = 0;
int audio_expected = 0;
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
long movement_audio_global_order = 0;
long movement_audio_playback_failure_count = 0;
MovementAudioAdapter movement_audio_adapter = new CoalescingMovementAudioAdapter();
ArrayList<StopStepSoundsMetric> stop_step_sound_metrics = new ArrayList<StopStepSoundsMetric>();


boolean movementAudioDiagnosticsEnabled(){
  if (current_frame_context == null) return false;
  String mode = current_frame_context.harness_mode;
  return "capture".equals(mode) || "profiling".equals(mode);
}


class MovementAudioEvent {
  public final String family;
  public final int variant;
  public final double logical_timestamp_seconds;
  public final long global_order;
  public final long callback_id;
  public final int step_index;

  MovementAudioEvent(String eventFamily, int eventVariant, double timestamp,
    long order, long callbackId, int stepIndex){
    if (eventFamily == null || eventFamily.length() == 0
      || !java.lang.Double.isFinite(timestamp) || order <= 0
      || callbackId <= 0 || stepIndex < 0){
      throw new IllegalArgumentException("evento de áudio de movimento inválido");
    }
    family = eventFamily;
    variant = eventVariant;
    logical_timestamp_seconds = timestamp;
    global_order = order;
    callback_id = callbackId;
    step_index = stepIndex;
  }
}


class MovementAudioPlaybackResult {
  public final long callback_id;
  public final long event_order;
  public final String family;
  public final int variant;
  public final String status;

  MovementAudioPlaybackResult(MovementAudioEvent event, String resultStatus){
    callback_id = event.callback_id;
    event_order = event.global_order;
    family = event.family;
    variant = event.variant;
    status = resultStatus;
  }
}


class MovementAudioSequenceComparison {
  public final String status;
  public final String diagnostic;

  MovementAudioSequenceComparison(String resultStatus, String reason){
    status = resultStatus;
    diagnostic = reason;
  }
}


interface MovementAudioAdapter {
  void beginCallback(long callbackId);
  void emit(MovementAudioEvent event, boolean physicalPlaybackAllowed);
  void dispatchCallback(long callbackId);
}


interface MovementAudioPlaybackPort {
  String play(MovementAudioEvent event);
}


class JavaClipMovementAudioPlaybackPort implements MovementAudioPlaybackPort {
  public String play(MovementAudioEvent event){
    Clip clip = movementAudioClipFor(event);
    if (clip == null){
      movement_audio_playback_failure_count++;
      println("som: clip ausente para " + event.family + " variante " + event.variant);
      return "clip_missing";
    }
    try {
      clip.stop();
      clip.setFramePosition(0);
      clip.start();
      return "played";
    }
    catch (RuntimeException error){
      movement_audio_playback_failure_count++;
      println("som: falha ao reproduzir " + event.family + " (partida continua): "
        + error.getMessage());
      return "playback_exception";
    }
  }
}


class CoalescingMovementAudioAdapter implements MovementAudioAdapter {
  private final MovementAudioPlaybackPort playback_port;
  private final ArrayList<MovementAudioEvent> callback_events = new ArrayList<MovementAudioEvent>();
  private final ArrayList<MovementAudioPlaybackResult> callback_results = new ArrayList<MovementAudioPlaybackResult>();
  private final ArrayList<MovementAudioPlaybackResult> playback_history = new ArrayList<MovementAudioPlaybackResult>();
  private long active_callback_id = -1;

  CoalescingMovementAudioAdapter(){
    this(new JavaClipMovementAudioPlaybackPort());
  }

  CoalescingMovementAudioAdapter(MovementAudioPlaybackPort playbackPort){
    if (playbackPort == null){
      throw new IllegalArgumentException("porta de reprodução de áudio obrigatória");
    }
    playback_port = playbackPort;
  }

  public void beginCallback(long callbackId){
    if (callback_events.size() > 0){
      println("som: eventos físicos do callback " + active_callback_id
        + " foram descartados antes do despacho");
      for (MovementAudioEvent event : callback_events){
        recordPlaybackResult(event, "undispatched");
      }
    }
    callback_events.clear();
    callback_results.clear();
    active_callback_id = callbackId;
  }

  public void emit(MovementAudioEvent event, boolean physicalPlaybackAllowed){
    if (event == null) throw new IllegalArgumentException("evento de áudio obrigatório");
    if (physicalPlaybackAllowed && event.callback_id == active_callback_id){
      callback_events.add(event);
    }
  }

  public void dispatchCallback(long callbackId){
    if (callback_events.size() == 0) return;
    if (callbackId != active_callback_id){
      for (MovementAudioEvent event : callback_events){
        recordPlaybackResult(event, "callback_mismatch");
      }
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
        if (dispatched_families.contains(event.family)){
          recordPlaybackResult(event, "coalesced");
          continue;
        }
        dispatched_families.add(event.family);
        String status = "adapter_exception";
        try {
          status = playback_port.play(event);
          if (status == null || status.length() == 0){
            status = "adapter_invalid_status";
          }
        }
        catch (RuntimeException error){
          println("som: adapter falhou para " + event.family
            + " (partida continua): " + error.getMessage());
        }
        recordPlaybackResult(event, status);
      }
    }
    finally {
      callback_events.clear();
    }
  }

  int resultCount(){
    return callback_results.size();
  }

  MovementAudioPlaybackResult resultAt(int index){
    return callback_results.get(index);
  }

  int playbackHistoryCount(){
    return playback_history.size();
  }

  MovementAudioPlaybackResult playbackHistoryAt(int index){
    return playback_history.get(index);
  }

  private void recordPlaybackResult(MovementAudioEvent event, String status){
    MovementAudioPlaybackResult result = new MovementAudioPlaybackResult(event, status);
    callback_results.add(result);
    if (movementAudioDiagnosticsEnabled()) playback_history.add(result);
  }
}


class StopStepSoundsMetric {
  public final long callback_id;
  public final int step_index;
  public final long duration_nanos;
  public final int clips_visited;
  public final String[] visit_order;
  public final int stop_failures;

  StopStepSoundsMetric(long callbackId, int stepIndex, long duration,
    String[] visits, int failures){
    callback_id = callbackId;
    step_index = stepIndex;
    duration_nanos = duration;
    clips_visited = visits.length;
    visit_order = visits;
    stop_failures = failures;
  }
}


MovementAudioSequenceComparison compareMovementAudioSequences(
  MovementAudioEvent[] baselineEvents,
  MovementAudioPlaybackResult[] baselinePlayback,
  MovementAudioEvent[] revisedEvents,
  MovementAudioPlaybackResult[] revisedPlayback){
  if (baselineEvents == null || baselinePlayback == null
    || revisedEvents == null || revisedPlayback == null){
    return new MovementAudioSequenceComparison("INCONCLUSIVO",
      "baseline ou sequência revisada ausente");
  }
  if (!sameMovementAudioEvents(baselineEvents, revisedEvents)){
    return new MovementAudioSequenceComparison("FAIL",
      "sequência de eventos lógicos divergiu");
  }
  if (!sameMovementAudioPlayback(baselinePlayback, revisedPlayback)){
    return new MovementAudioSequenceComparison("FAIL",
      "sequência de reproduções físicas divergiu");
  }
  return new MovementAudioSequenceComparison("PASS", "sequências equivalentes");
}


boolean sameMovementAudioEvents(MovementAudioEvent[] first, MovementAudioEvent[] second){
  if (first.length != second.length) return false;
  for (int i = 0; i < first.length; i++){
    MovementAudioEvent a = first[i];
    MovementAudioEvent b = second[i];
    if (a == null || b == null || !a.family.equals(b.family)
      || a.variant != b.variant || a.global_order != b.global_order
      || a.callback_id != b.callback_id || a.step_index != b.step_index
      || java.lang.Math.abs(a.logical_timestamp_seconds - b.logical_timestamp_seconds)
        > FRAME_STEP_EPSILON_SECONDS){
      return false;
    }
  }
  return true;
}


boolean sameMovementAudioPlayback(MovementAudioPlaybackResult[] first,
  MovementAudioPlaybackResult[] second){
  if (first.length != second.length) return false;
  for (int i = 0; i < first.length; i++){
    MovementAudioPlaybackResult a = first[i];
    MovementAudioPlaybackResult b = second[i];
    if (a == null || b == null || !a.family.equals(b.family)
      || !a.status.equals(b.status) || a.variant != b.variant
      || a.callback_id != b.callback_id || a.event_order != b.event_order){
      return false;
    }
  }
  return true;
}


boolean audioOptimizationHasEquivalentTrace(MovementAudioSequenceComparison comparison){
  return comparison != null && "PASS".equals(comparison.status);
}


void replaceMovementAudioAdapter(MovementAudioAdapter adapter){
  if (adapter == null){
    throw new IllegalArgumentException("adapter de áudio de movimento obrigatório");
  }
  movement_audio_adapter = adapter;
}


void emitMovementAudioEvent(FrameContext context, String family){
  requireMovementStep(context, "emitMovementAudioEvent");
  int variant = nextMovementAudioVariant(family);
  long order = ++movement_audio_global_order;
  double timestamp = context.simulation_time_seconds + context.fixed_step_seconds;
  MovementAudioEvent event = new MovementAudioEvent(family, variant, timestamp,
    order, context.callback_id, context.step_index);
  if ("profiling".equals(context.harness_mode)){
    context.recordLogicalAudioEvent(event);
  }
  sound_step_play_count++;
  boolean physicalPlaybackAllowed = "production".equals(context.clock_origin)
    || "profiling".equals(context.harness_mode);
  try {
    movement_audio_adapter.emit(event, physicalPlaybackAllowed);
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
  audio_expected++;

  try {
    AudioInputStream input = AudioSystem.getAudioInputStream(dataFile(path));
    Clip clip = AudioSystem.getClip();
    clip.open(input);
    input.close();
    audio_loaded++;
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
    long physicalDispatchStarted = System.nanoTime();
    long callbackId = current_frame_context == null ? -1 : current_frame_context.callback_id;
    try {
      movement_audio_adapter.dispatchCallback(callbackId);
    }
    catch (RuntimeException error){
      frame_audio_diagnostic = "adapter de áudio falhou no despacho: "
        + error.getMessage();
      println("som: " + frame_audio_diagnostic);
    }
    if (current_frame_context != null){
      current_frame_context.physical_audio_dispatch_duration_nanos =
        java.lang.Math.max(0L, System.nanoTime() - physicalDispatchStarted);
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
    movement_audio_playback_failure_count++;
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
  boolean recordMetrics = movementAudioDiagnosticsEnabled();
  String[] visitOrder = null;
  if (recordMetrics){
    visitOrder = new String[sound_walk_step.length * 3];
    for (int i = 0; i < sound_walk_step.length; i++){
      int visitIndex = i * 3;
      visitOrder[visitIndex] = "walk[" + i + "]";
      visitOrder[visitIndex + 1] = "run[" + i + "]";
      visitOrder[visitIndex + 2] = "ladder[" + i + "]";
    }
  }
  long started = recordMetrics ? System.nanoTime() : 0L;
  int failures = 0;
  for (int i = 0; i < sound_walk_step.length; i++){
    if (!stopSound(sound_walk_step[i])) failures++;
    if (!stopSound(sound_run_step[i])) failures++;
    if (!stopSound(sound_ladder_step[i])) failures++;
  }
  if (!recordMetrics) return;
  long stopCompleted = System.nanoTime();
  long callbackId = current_frame_context == null ? -1 : current_frame_context.callback_id;
  int stepIndex = current_frame_context == null ? -1 : current_frame_context.step_index;
  stop_step_sound_metrics.add(new StopStepSoundsMetric(callbackId, stepIndex,
    java.lang.Math.max(0L, stopCompleted - started), visitOrder, failures));
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

  println("som: " + audio_loaded + " de " + audio_expected + " carregados");
}
