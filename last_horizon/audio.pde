/* Audio layer — world effects taken by file, like the art (#28).

   Format contract: WAV PCM 16 bits, 44,1 kHz, mono. The JVM embedded in
   Processing 4.5.6 reads WAV/AU/AIFF only, so `javax.sound.sampled` needs no
   library, no installation and no network (issue #3). OGG and 32-bit float WAV
   are rejected by the Clip.

   A missing file leaves the game mute instead of breaking it: the loader
   returns null and every trigger ignores null. */

import javax.sound.sampled.*;

/* One folder per event under data/audio/, each with its own LICENSE.txt. */
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

  clip.stop();
  clip.setFramePosition(0);
  clip.start();
}
void primeSound(Clip clip){
  if (clip == null) return;

  FloatControl gain = null;
  BooleanControl mute = null;
  float original_gain = 0;
  boolean original_mute = false;

  try {
    /*
      Clip.open() decodes the file but does not necessarily start the
      platform mixer. Starting at the end, as before, could leave that
      initialization for the first real step.
    */
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
    // Silenciosamente ignora se o mixer nao suportar pre-roll
  }
  finally {
    clip.stop();
    clip.setFramePosition(0);

    if (mute != null){
      mute.setValue(original_mute);
    }

    if (gain != null){
      gain.setValue(original_gain);
    }
  }
}



void stopStepSounds(){
  for (int i = 0; i < sound_walk_step.length; i++){
    if (sound_walk_step[i] != null) sound_walk_step[i].stop();
    if (sound_run_step[i] != null) sound_run_step[i].stop();
    if (sound_ladder_step[i] != null) sound_ladder_step[i].stop();
  }
}


void playDeckStepSound(boolean running){
  sound_step_play_count++;
  Clip[] steps = running ? sound_run_step : sound_walk_step;
  int index = running ? sound_run_step_index : sound_walk_step_index;
  Clip clip = steps[index];

  if (running){
    sound_run_step_index = (sound_run_step_index + 1) % sound_run_step.length;
  } else {
    sound_walk_step_index = (sound_walk_step_index + 1) % sound_walk_step.length;
  }
  stopStepSounds();
  playSound(clip);
}


void playLadderStepSound(){
  sound_step_play_count++;
  Clip clip = sound_ladder_step[sound_ladder_step_index];
  sound_ladder_step_index = (sound_ladder_step_index + 1) % sound_ladder_step.length;
  stopStepSounds();
  playSound(clip);
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
