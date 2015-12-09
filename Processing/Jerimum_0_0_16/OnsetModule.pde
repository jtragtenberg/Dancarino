public class OnsetModule implements ControlListener {
  // General attributes
  BoardModule   board;
  SeedMgrModule seeds;
  MidiBus       midi_bus;

  // Kick attributes
  int     kick_threshold_min; 
  int     kick_threshold_max; 
  long    time_stamp_kick;
  boolean note_off_flag;
  int     duration;
  int     note;

  // Kick Sensitive attributes
  //float last_gyro_values[] = new float[3]; // x0, x1, x2 -> where x2 is the last value retrieved, x1 the penultimate and so on;


  public OnsetModule(BoardModule board, SeedMgrModule seeds, MidiBus midi_bus) {
    this.board = board;
    this.seeds = seeds;
    this.midi_bus = midi_bus;
    this.kick_threshold_min = 10000;
    this.kick_threshold_max = 20000;
    this.note_off_flag = false;
    this.duration = 30;
    this.note = 1;
  }

  public void CheckForKick() {  // Verifies the board data and the time of last kick to decide if there is a new kick
    if (!this.note_off_flag && board.gyro[2] > this.kick_threshold_min) {
      this.midi_bus.sendNoteOn(0, 60, 3127);
      this.note_off_flag = true;
      this.time_stamp_kick = millis();
    } 

    if (this.note_off_flag && (millis() - this.time_stamp_kick) > duration) {
      this.midi_bus.sendNoteOff(0, 60, 0);
      this.note_off_flag = false;
    }
  }

  float max = 0;
  boolean onsetFlag = false;
  double debounceTimeStamp = 0;
  double debounceTime = 50;

  //public void CheckForKickSensitive(float[] last_gyro_values, int kick_threshold_min, int kick_threshold_max, int midi_velocity_min, int midi_velocity_max, int midi_channel) { // Verifies the board data and the time of lasts kicks to decide if there is a new kick
  public void CheckForKickSensitive(float[] last_gyro_values, int kick_threshold_min, int kick_threshold_max, int midi_velocity_min, int midi_velocity_max) { // Verifies the board data and the time of lasts kicks to decide if there is a new kick
    // Verifies if there is a top (remember that we are getting the 'z' axis as the kick axis)
    boolean is_top = false;//(last_gyro_values[1] > last_gyro_values[0] && last_gyro_values[1] > last_gyro_values[2]);
    //boolean is_top = false;

    if (millis() - debounceTimeStamp > debounceTime) {

      //if (last_gyro_values[1] > kick_threshold_min) {
      //background(255, 0, 0);
      if (last_gyro_values[2] >= max) {
        //println(max);
        max = last_gyro_values[2];
      } else if (max > kick_threshold_min && !onsetFlag) {
        //is_top = true;
        onsetFlag = true;
        debounceTimeStamp = millis();
        //println("Tocou nota! :" + max);
        onsetTrigger(max, kick_threshold_min, kick_threshold_max, midi_velocity_min, midi_velocity_max);
      }
    } else { 
      max = 0;
      onsetFlag = false;
    }
  }

  public void onsetTrigger(float sensorIntensity, float intensityMin, float intensityMax, int midi_velocity_min, int midi_velocity_max) {
    int midi_velocity = (int)map(sensorIntensity, intensityMin, intensityMax, midi_velocity_min, midi_velocity_max );
    if (midi_velocity > 127) midi_velocity = 127;
    if (midi_velocity < 0) midi_velocity = 0;

    // Search for the closest seed to get it's note
    int closest_seed_note = this.note;
    int closest_seed_idx = this.seeds.ClosestSeedIdx();
    if (closest_seed_idx >= 0) closest_seed_note = this.seeds.seeds.get(closest_seed_idx).note;
    int closest_seed_channel = seeds.getClosestChannel();
    

    println("intensidade: " + sensorIntensity); // TODO: colocar um slider de feedback de intensidade para o usuario
    println("canal MIDI: " + closest_seed_channel);
    println("nota MIDI: " + closest_seed_note);
    println("velocity MIDI: " + midi_velocity);
    
   this.midi_bus.sendNoteOn(closest_seed_channel, closest_seed_note, midi_velocity);
   this.note_off_flag = true;
   this.time_stamp_kick = millis();
  }
  


  /*
if (is_top) {
   if (!this.note_off_flag && last_gyro_values[1] > this.kick_threshold_min) {
   //float normalized_intensity = (board.last_gyro_values[1] - this.kick_threshold_min)/ ((this.kick_threshold_max - this.kick_threshold_min)+1);
   //int midi_intensity         = int(normalized_intensity*127);
   
   int midi_intensity = (int)map(last_gyro_values[1], this.kick_threshold_min, this.kick_threshold_max, midi_velocity_min, midi_velocity_max );
   if (midi_intensity > 127) midi_intensity = 127;
   if (midi_intensity < 0) midi_intensity = 0;
   
   // Search for the closest seed to get it's note
   int closest_seed_note = this.note;
   int closest_seed_idx = this.seeds.ClosestSeedIdx();
   if (closest_seed_idx >= 0) closest_seed_note = this.seeds.seeds.get(closest_seed_idx).note;
   int closest_seed_channel = seeds.getClosestChannel();
   
   println("intensidade: " + last_gyro_values[1]); // TODO: colocar um slider de feedback de intensidade para o usuario
   println("canal MIDI: " + closest_seed_channel);
   println("velocity MIDI: " + midi_intensity);
   
   this.midi_bus.sendNoteOn(closest_seed_channel, closest_seed_note, midi_intensity);
   this.note_off_flag = true;
   this.time_stamp_kick = millis();
   }
   }
   if (this.note_off_flag && (millis() - this.time_stamp_kick) > duration) {
   // Search for the closest seed to get it's note
   int closest_seed_note = this.note;
   int closest_seed_idx = this.seeds.ClosestSeedIdx();
   if (closest_seed_idx >= 0) closest_seed_note = this.seeds.seeds.get(closest_seed_idx).note;
   int closest_seed_channel = seeds.getClosestChannel();
   this.midi_bus.sendNoteOff(closest_seed_channel, closest_seed_note, 0);
   this.note_off_flag = false;
   }
   }
   */
  // Listen the interface events to refresh the respective attribute
  public void controlEvent(ControlEvent theEvent) {
    if (theEvent.getName().equals("OnsetModule.kick_threshold_min")) {
      this.kick_threshold_min = int(theEvent.getValue());
    } else if (theEvent.getName().equals("OnsetModule.kick_threshold_max")) {
      this.kick_threshold_max = int(theEvent.getValue());
    } else if (theEvent.getName().equals("OnsetModule.note")) {
      this.note = int(theEvent.getValue());
      this.midi_bus.sendNoteOff(0, this.note, 0);
      this.note_off_flag = false;
    } else if (theEvent.getName().equals("Listen")) {
      this.midi_bus.sendNoteOn(0, this.note, 127);
      delay(200);
      this.midi_bus.sendNoteOff(0, this.note, 0);
    }
  }
}

