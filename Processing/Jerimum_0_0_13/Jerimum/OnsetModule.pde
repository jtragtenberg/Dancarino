public class OnsetModule implements ControlListener{
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
  //float last_zgyro_values[] = new float[3]; // x0, x1, x2 -> where x2 is the last value retrieved, x1 the penultimate and so on;
  

  public OnsetModule(BoardModule board, SeedMgrModule seeds, MidiBus midi_bus) {
    this.board = board;
    this.seeds = seeds;
    this.midi_bus = midi_bus;
    this.kick_threshold_min = -10000;
    this.kick_threshold_max = -20000;
    this.note_off_flag = false;
    this.duration = 30;
    this.note = 60;
  }
  
  public void CheckForKick() {  // Verifies the board data and the time of last kick to decide if there is a new kick
    if (!this.note_off_flag && board.gyro[2] < this.kick_threshold_min) {
      this.midi_bus.sendNoteOn(0, 60, 127);
      this.note_off_flag = true;
      this.time_stamp_kick = millis();
    } 

    if (this.note_off_flag && (millis() - this.time_stamp_kick) > duration) {
      this.midi_bus.sendNoteOff(0, 60, 0);
      this.note_off_flag = false;
    }
  }
  
  public void CheckForKickSensitive() { // Verifies the board data and the time of lasts kicks to decide if there is a new kick
    // Verifies if there is a top (remember that we are getting the '-z' axis as the kick axis)
    boolean is_top = (board.last_zgyro_values[1] < board.last_zgyro_values[0] && board.last_zgyro_values[1] < board.last_zgyro_values[2]);
    
    if(is_top) {
      if (!this.note_off_flag && board.last_zgyro_values[1] < this.kick_threshold_min) {
        float normalized_intensity = (board.last_zgyro_values[1] - this.kick_threshold_min)/ ((this.kick_threshold_max - this.kick_threshold_min)+1);
        int midi_intensity         = int(normalized_intensity*127);
        
        // Search for the closest seed to get it's note
        int closest_seed_note = this.note;
        int closest_seed_idx = this.seeds.ClosestSeedIdx();
        if (closest_seed_idx >= 0) closest_seed_note = this.seeds.seeds.get(closest_seed_idx).note;
        println("intensidade: " + board.last_zgyro_values[1]); // TODO: colocar um slider de feedback de intensidade para o usuario
        println("intensidade (normalizada): " + normalized_intensity);
        println("intensidade (midi): " + midi_intensity);
        this.midi_bus.sendNoteOn(0, closest_seed_note, midi_intensity);
        this.note_off_flag = true;
        this.time_stamp_kick = millis();
      } 
    }
    if (this.note_off_flag && (millis() - this.time_stamp_kick) > duration) {
      // Search for the closest seed to get it's note
      int closest_seed_note = this.note;
      int closest_seed_idx = this.seeds.ClosestSeedIdx();
      if (closest_seed_idx >= 0) closest_seed_note = this.seeds.seeds.get(closest_seed_idx).note;
      this.midi_bus.sendNoteOff(0, closest_seed_note, 0);
      this.note_off_flag = false;      
    }
  }
  
  // Listen the interface events to refresh the respective attribute
  public void controlEvent(ControlEvent theEvent) {
    if (theEvent.getName().equals("OnsetModule.kick_threshold_min")) {
      this.kick_threshold_min = int(theEvent.getValue());
    } 
    else if (theEvent.getName().equals("OnsetModule.kick_threshold_max")) {
      this.kick_threshold_max = int(theEvent.getValue());
    }
    else if (theEvent.getName().equals("OnsetModule.note")) {
      this.note = int(theEvent.getValue());
      this.midi_bus.sendNoteOff(0, this.note, 0);
      this.note_off_flag = false;
    }
  } 
}
