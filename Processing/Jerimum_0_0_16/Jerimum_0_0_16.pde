//### Libraries
import processing.opengl.*;
import themidibus.*; 
import controlP5.*;

// I/O
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.io.*;

//### Global variables
BoardModule   board;
OnsetModule   onset;
SeedMgrModule seeds;
EffectModule effects;
EffectPadXYModule giroMouse;
Graph graph;

MidiBus myBus;
ControlP5 cp5;

int MIDI_Velocity_Min = 10, MIDI_Velocity_Max = 120, MIDI_Channel = 2;
int GYRO_MIN = -30000;
int GYRO_MAX = 30000;


float yawOffset; // To align

//### Global setup
void setup() {
  // Setup graphics
  // size(640, 480, OPENGL);
  size(760, 600, OPENGL);
  smooth();
  noStroke();
  frameRate(50);

  // Setup board communication
  board = new BoardModule(7, 38400);

  //INICIALIZACAO MIDI
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 3);

  // Setup Musical Seeds Manager
  seeds = new SeedMgrModule();

  // Setup OnsetModule
  onset = new OnsetModule(board, seeds, myBus);

  // Setup EffectsModule
  giroMouse = new EffectPadXYModule();
  effects = new EffectModule(giroMouse, board, yawOffset);
  

  //Setup Graph
  graph = new Graph();

  // GUI
  initGui();
  //cp5.enableShortcuts();
  loadConfig();
}



//### GUI setup
void initGui() {
  cp5 = new ControlP5(this);

  //cp5.addColorWheel("c", 250, 10, 200 ).setRGB(color(128, 0, 255));

  // ## Onset widgets 
  // ThresholdGyroMin
  cp5.addSlider("OnsetModule.kick_threshold_min")
    .setPosition(25, 220)
      .setRange(0, GYRO_MAX)
        .setSize(200, 20)
          .setValue(float(onset.kick_threshold_min))
            ;


  // ThresholdGyroMax
  cp5.addSlider("OnsetModule.kick_threshold_max")
    .setPosition(25, 260)
      .setRange(0, GYRO_MAX)
        .setSize(200, 20)
          .setValue(float(onset.kick_threshold_max))
            ;


  // OnsetNote
  cp5.addSlider("OnsetModule.note")
    .setPosition(275, 130)
      .setSize(200, 10)
        .setRange(0, 127)    
          .setValue(float(onset.note))
            .setNumberOfTickMarks(128)
              ;



  //Listen Button
  cp5.addButton("Listen")
    .setValue(0)
      .setPosition(575, 250)
        .setSize(30, 30)
          ;

  cp5.addListener(onset);

  // ## SeedMgr widgets
  cp5.addSlider("SeedMgrModule.curr_color_RED")
    .setPosition(275, 175)
      .setRange(0, 255)
        .setSize(100, 10)
          .setValue(float(seeds.curr_color[0]))
            ; 

  cp5.addSlider("SeedMgrModule.curr_color_GREEN")
    .setPosition(275, 200)
      .setRange(0, 255)
        .setSize(100, 10)
          .setValue(float(seeds.curr_color[1]))
            ;  

  cp5.addSlider("SeedMgrModule.curr_color_BLUE")
    .setPosition(275, 225)
      .setRange(0, 255)
        .setSize(100, 10)
          .setValue(float(seeds.curr_color[2]))
            ;

  cp5.addButton("New_Seed")
    .setValue(0)
      .setPosition(275, 250)
        .setSize(50, 30)
          ;
  cp5.addButton("Delete_Seed")
    .setValue(0)
      .setPosition(335, 250)
        .setSize(60, 30)
          ;



  cp5.addSlider("MIDI_Channel")
    .setPosition(575, 130)
      .setRange(1, 16)
        .setSize(100, 10)
          .setValue(float(MIDI_Channel))
            .setNumberOfTickMarks(16)
              ;

  cp5.addSlider("MIDI_Velocity_Min")
    .setPosition(575, 170)
      .setRange(0, 127)
        .setSize(100, 10)
          .setValue(float(MIDI_Velocity_Min))
            //.setNumberOfTickMarks(128)
            ;

  cp5.addSlider("MIDI_Velocity_Max")
    .setPosition(575, 200)
      .setRange(0, 127)
        .setSize(100, 10)
          .setValue(float(MIDI_Velocity_Max))
            //.setNumberOfTickMarks(128)
            ;


  /*
  cp5.addButton("Save")
   .setValue(0)
   .setPosition(630, 500)
   .setSize(40, 30)
   ;
   cp5.addButton("Load")
   .setValue(0)
   .setPosition(680, 500)
   .setSize(40, 30)
   ;
   
   cp5.addButton("Export")
   .setValue(0)
   .setPosition(630, 550)
   .setSize(40, 30)
   ;
   cp5.addButton("Import")
   .setValue(0)
   .setPosition(680, 550)
   .setSize(40, 30)
   ;
   */


  cp5.addListener(seeds);

  alignLabels();
}

void alignLabels() {
  cp5.getController("OnsetModule.kick_threshold_min").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("OnsetModule.kick_threshold_max").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("OnsetModule.note").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("SeedMgrModule.curr_color_RED").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("SeedMgrModule.curr_color_GREEN").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("SeedMgrModule.curr_color_BLUE").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("MIDI_Velocity_Max").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("MIDI_Velocity_Min").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);            
  cp5.getController("MIDI_Channel").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
}

public void New_Seed(int theValue) {
  seeds.AddSeed(onset.note, MIDI_Channel);
}
public void Delete_Seed(int theValue) {
  seeds.DeleteSeed();
}
/*
void Save(int theValue) {
 saveConfig();
 println("Configurações e sementes salvas");
 }
 void Load(int theValue) {
 loadConfig();
 println("Últimas Configurações e sementes carregadas");
 }
 void Export(int theValue) {
 println("Escolha um local para salvar as sementes e os dados da interface");
 exportSeeds();
 exportInterface();
 }
 void Import(int theValue) {
 println("Escolha os arquivos de sementes e dos dados da interface para abrir");
 exportSeeds();
 exportInterface();
 }
 */


void loadConfig() {
  // Restore the last saved interface values
  cp5.loadProperties();
  //cp5.loadLayout("jerimum.sem");
  alignLabels();

  // Restore the last saved seeds
  loadSeeds("jerimum.seeds");
}

void saveConfig() {
  cp5.saveProperties();
  //cp5.saveLayout("jerimum.sem");
  saveSeeds("jerimum.seeds");
}

void loadSeeds(String dir) {
  try {
    ObjectInputStream objectInputStream = new ObjectInputStream(
    new FileInputStream(dir));
    // start getting the objects out in the order in which they were written
    seeds.seeds = (ArrayList<SeedModule>) objectInputStream.readObject();
  } 
  catch(Exception ex) {
    ex.printStackTrace();
  }
}

void saveSeeds(String dir) {
  try {
    // Write object with ObjectOutputStream
    ObjectOutputStream obj_out = new
      ObjectOutputStream (new 
      FileOutputStream(dir));

    // Write object out to disk
    obj_out.writeObject (seeds.seeds);

    // Export to temp
    // Write object with ObjectOutputStream
    ObjectOutputStream obj_out_temp = new
      ObjectOutputStream (new 
      FileOutputStream("jerimum.seeds"));

    // Write object out to disk
    obj_out_temp.writeObject (seeds.seeds);
  }
  catch(Exception ex) {
    ex.printStackTrace();
  }
}

void exportSeeds() {
  JFileChooser seed_file_chooser = new JFileChooser();
  int result = seed_file_chooser.showSaveDialog(this);
  if (result == 1) return; // Canceled    
  String seeds_file_dir = (seed_file_chooser.getSelectedFile().getAbsolutePath() + ".seeds");
  saveSeeds(seeds_file_dir);
  return;
}

void importSeeds() {
  JFileChooser seed_file_chooser = new JFileChooser();
  int result = seed_file_chooser.showOpenDialog(this);
  if (result == 1) return; // Canceled    
  String seeds_file_dir = seed_file_chooser.getSelectedFile().getAbsolutePath();
  loadSeeds(seeds_file_dir);
}

void exportInterface() {
  JFileChooser interface_file_chooser = new JFileChooser();
  //interface_file_chooser.setFileFilter(new FileNameExtensionFilter("Valores de interface", "json", "interfaces"));
  String seeds_file_dir;
  int result;
  result = interface_file_chooser.showSaveDialog(this);
  if (result == 1) return; // Canceled  
  seeds_file_dir = interface_file_chooser.getSelectedFile().getAbsolutePath();
  cp5.saveProperties(seeds_file_dir);
  cp5.saveProperties();
  alignLabels();
  return;
}

void importInterface() {
  JFileChooser interface_file_chooser = new JFileChooser();
  //interface_file_chooser.setFileFilter(new FileNameExtensionFilter("Valores de interface", "json", "interfaces"));
  String seeds_file_dir;
  int result;
  result = interface_file_chooser.showOpenDialog(this);
  if (result == 1) return; // Canceled  
  seeds_file_dir = interface_file_chooser.getSelectedFile().getAbsolutePath();
  cp5.loadProperties(seeds_file_dir);
  alignLabels();
  return;
}

//### Keyboard callback
void keyPressed() {

  switch (key) {
  case 'a':  // Align screen with Razor
    yawOffset = board.ypr[0];
    break;

  case ENTER:  // Align screen with Razor
    yawOffset = board.ypr[0];
    break;

  case ' ':  // Create a new musical seed
    seeds.AddSeed(onset.note, MIDI_Channel);
    onset.note = onset.note + 1;
    break;

  case 'x':  // Remove the closest musical seed from drumstick
    seeds.DeleteSeed();
    if (onset.note > 1) { 
      onset.note = onset.note - 1;
    }
    break;

  case 'e':  // Export file of current seeds setup
    exportSeeds();
    exportInterface();
    break;

  case 'i':  // Import file to current seeds setup 
    importSeeds();
    importInterface();
    break;

  case 's': 
    saveConfig();
    println("Configuracao Salva");
    break;

  case 'l':
    loadConfig();
    println("Configuracao Carregada");
    break; 

  default:
    break;
  }
}



//### Draw callback (every frame)
void draw() {
  background(0);
  // Refresh the board data
  if (!board.RefreshData()) return;

  // Reset scene
  color backgroundColor = color(0, 0, 0);
  background(backgroundColor);


  // Verifies if there is a kick (choose one or other line)
  // onset.CheckForKick();
  onset.CheckForKickSensitive(board.last_zgyro_values, onset.kick_threshold_min, onset.kick_threshold_max, MIDI_Velocity_Min, MIDI_Velocity_Max);
  //onset.CheckForNoteOff();

  //roll (-80,160) pitch (-50,50)
  
  effects.inputParamMin = -80;
  effects.inputParamMax = 160;

  effects.updateEffects(degrees(board.ypr[2]));
  //GUI


  //GRAPH
  pushMatrix();
  translate(0, 400);
  int graphWindowWidth = 220;
  int graphWindowHeight = 200;

  graph.drawGraph(board.last_zgyro_values[2], GYRO_MIN, GYRO_MAX, graphWindowWidth, graphWindowHeight);
  stroke(255, 160, 0);
  float thresholdLine = map(onset.kick_threshold_min, GYRO_MIN, GYRO_MAX, 0, graphWindowHeight);
  line(0, graphWindowHeight - thresholdLine, graphWindowWidth, graphWindowHeight -thresholdLine);
  float maxIntensityLine = map(onset.kick_threshold_max, GYRO_MIN, GYRO_MAX, 0, graphWindowHeight);
  line(0, graphWindowHeight - maxIntensityLine, graphWindowWidth, graphWindowHeight -maxIntensityLine);
  popMatrix();


  //INPUT
  pushMatrix();
  translate(25, 75);
  fill(255);
  stroke(255);
  text("INPUT", 0, 0);
  text("Gyro", 0, 25);

  text("x:   " + ((int) board.gyro[0]), 0, 50);
  rect(100, 50, map(board.gyro[0], 0, 10000, 0, 10), 10);

  text("y:   " + ((int) board.gyro[1]), 0, 70);
  rect(100, 70, map(board.gyro[1], 0, 10000, 0, 50), 10);

  // Z gyroscope value
  text("z:   " + ((int) board.gyro[2]), 0, 90);
  rect(100, 90, map(board.gyro[2], 0, 10000, 0, 50), 10);

  text("button: ", 0, 110);
  if (board.buttonPressed) { 
    rect(100, 105, 10, 10);
  }

  // Show YAW PITCH e ROLL  
  text("Yaw:   " +   int(degrees(board.ypr[0] - yawOffset)), 0, 230);
  text("Pitch:   " + int(degrees(board.ypr[1])), 0, 250);
  text("Roll:   " +  int(degrees(board.ypr[2])), 0, 270);


  popMatrix();

  //Seed
  pushMatrix();
  translate(275, 75);
  fill(255);
  text("SEED", 0, 0);
  text("Aperte barra de espaço pra inserir semente e 'x' para excluir", 0, 25);


  popMatrix();

  //Output

  pushMatrix();
  translate(575, 75);
  fill(255);
  text("OUTPUT", 0, 0);
  text("Midi Config", 0, 25);

  int MIDI_Velocity_Value = onset.getVelocity();
  
  int barWidth = 50;
  int barHeight = 200;
  int barPosX = 50;
  int barPosY = 525;
  
  fill(255);
  int onsetTriggerColor = (int)map(MIDI_Velocity_Value,0,127,255,0);

  stroke(255,onsetTriggerColor,0);
  int barValueMin = 0;
  int barValueMax = 127;
  if (MIDI_Velocity_Value < barValueMin) MIDI_Velocity_Value = barValueMin;
  if (MIDI_Velocity_Value > barValueMax) MIDI_Velocity_Value = barValueMax;
  int barValue = int(map(MIDI_Velocity_Value, barValueMin, barValueMax, 0, barHeight));
  rect(barPosX,barPosY,barWidth, -barValue);
  noFill();
  rect(barPosX,barPosY,barWidth,-barHeight);
   
  int barLineMin = (int)map(MIDI_Velocity_Min, barValueMin, barValueMax, 0, barHeight);
  line(barPosX,barPosY - barLineMin, barPosX + barWidth, barPosY - barLineMin);
  int barLineMax = (int)map(MIDI_Velocity_Max, barValueMin, barValueMax, 0, barHeight);
  line(barPosX,barPosY - barLineMax, barPosX + barWidth, barPosY - barLineMax);
  
  text("MIDI trigger: " + MIDI_Velocity_Value, 50, 300);
  popMatrix();


  // Find board directional vector (drumstick)
  seeds.drumstick.x =  sin(board.ypr[0] - yawOffset)*cos(board.ypr[1]);
  seeds.drumstick.y = -sin(board.ypr[1]);
  seeds.drumstick.z = -cos(board.ypr[0] - yawOffset)*cos(board.ypr[1]);

  float angle = board.ypr[2];  // By treating the cursor/board/drumstick as a seed, the angle of roll remains in vain

  lights();
  // Draw drumstick
  drawSeed(seeds.drumstick);

  // Draw all the musical seeds existing
  drawMusicalSeeds();
  noLights();

  // Output info text
  //fill(255, 255, 255);
  //text("Aponta a parada pra tela e aperta 'a' pra alinhar o real com virtual -drogas", 10, 10);
  //text("Vira a parada pra onde tu quiser e depois aperta 's' para adicionar uma semente musical para a nota selecionada -pesadas", 10, 25);
  //text("Vira a parada pra onde tu quiser e depois aperta 'x' para aniquilar de vez uma semente -envelhecidas", 10, 40);

  // Draw Preview of new Seed
  //text("Previa da nova nota:", 300, 300);
  stroke(0, 0, 0);
  fill(seeds.curr_color[0], seeds.curr_color[1], seeds.curr_color[2]);
  ellipse(width/2, 320, 30, 30);
  fill(255-seeds.curr_color[0], 255-seeds.curr_color[1], 255-seeds.curr_color[2]);
  text(String.valueOf(onset.note), width/2 - 5, 320);
}

//### Auxiliary functions
void drawSeed(SeedModule seed) {
  pushMatrix();
  translate(width/2, height/2 + 300, -350);
  //stroke(255, 255, 255);
  stroke(seed.colors[0], seed.colors[1], seed.colors[2]);
  line(0, 0, 0, 200*seed.x, 200*seed.y, 200*seed.z);
  popMatrix();

  pushMatrix();
  translate(width/2, height/2 + 300, -350);
  translate(seed.x*200, seed.y*200, seed.z*200);
  lights();
  //noStroke();
  stroke(seed.colors[0], seed.colors[1], seed.colors[2]);

  sphere(20);

  //fill(255-seed.colors[0], 255-seed.colors[1], 255-seed.colors[2]);
  //textSize(18);
  //stroke(seed.colors[0], seed.colors[1], seed.colors[2]);
  //fill(0, 0, 0);
  //text(String.valueOf(seed.note), -15, 0, 25);
  //fill(255, 255, 255);
  //background(0, 0, 0);
  //textSize(10);
  popMatrix();
}

void drawMusicalSeeds() {
  SeedModule curr_seed;
  for (int i = 0; i < seeds.seeds.size (); i++)
    drawSeed(seeds.seeds.get(i));
}

