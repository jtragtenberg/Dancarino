//### Libraries
import processing.opengl.*;
import themidibus.*; 
import controlP5.*;

//### Global variables
BoardModule   board;
OnsetModule   onset;
SeedMgrModule seeds;

MidiBus myBus;
ControlP5 cp5;

float yawOffset; // To align

// Global setup
void setup() {
  // Setup graphics
  size(640, 480, OPENGL);
  smooth();
  noStroke();
  frameRate(50);

  // Setup board communication
  board = new BoardModule(0, 57600);
  
  //INICIALIZACAO MIDI
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 1, 3);
  
  // Setup Musical Seeds Manager
  seeds = new SeedMgrModule();
  
  // Setup OnsetModule
  onset = new OnsetModule(board, seeds, myBus);
  
  // GUI
  initGui();
}

void initGui() {
  cp5 = new ControlP5(this);
  
  // ThresholdGyroMin
  cp5.addSlider("OnsetModule.kick_threshold_min")
      .setPosition(100, 50)
      .setRange(-50000, 0)
      .setSize(200,20)
      .setValue(float(onset.kick_threshold_min))
      ;
  
  // ThresholdGyroMax
  cp5.addSlider("OnsetModule.kick_threshold_max")
      .setPosition(100, 80)
      .setRange(-50000, 0)
      .setSize(200,20)
      .setValue(float(onset.kick_threshold_max))
      ;

  // OnsetNote
  cp5.addSlider("OnsetModule.note")
      .setPosition(50, 110)
      .setRange(-50, 100)
      .setSize(500,10)
      .setValue(float(onset.note))
      ;
      
  cp5.addListener(onset);
}

void keyPressed() {
  switch (key) {
  case 'a':  // Align screen with Razor
    yawOffset = board.ypr[0];
    break;
  
  case 's':  // Create a new musical seed
    seeds.AddSeed(onset.note);
    break;
    
  case 'x':  // Remove the closest musical seed from drumstick
    seeds.DeleteSeed();
    break;
    
  default:
    break;
  } 
}

void drawSeed(SeedModule seed) {
    pushMatrix();
      translate(width/2, height/2, -350);
      stroke(255,128,0);
      line(0, 0, 0, 200*seed.x, 200*seed.y, 200*seed.z);
      stroke(255,128,0);
    popMatrix();
    
    pushMatrix();
      translate(width/2, height/2, -350);
      translate(seed.x*200, seed.y*200, seed.z*200);
      lights();
      noStroke();
      sphere(20);
    popMatrix();
}

void drawMusicalSeeds() {
  SeedModule curr_seed;
  for (int i = 0; i < seeds.seeds.size(); i++)
    drawSeed(seeds.seeds.get(i));
}

void draw() {
  // Refresh the board data
  if(!board.RefreshData()) return;

  // Reset scene
  color backgroundColor = color(0, 0, 0);
  background(backgroundColor);
  lights();
  
  // Verifies if there is a kick (choose one or other line)
  // onset.CheckForKick();
  onset.CheckForKickSensitive();
  
  // Output angles
  pushMatrix();
  translate(10, height - 40);
  textAlign(LEFT);
  
  // Show YAW PITCH e ROLL  
  text("Yaw: " +   int(degrees(board.ypr[0] - yawOffset)), 0, 0);
  text("Pitch: " + int(degrees(board.ypr[1])), 150, 0);
  text("Roll: " +  int(degrees(board.ypr[2])), 300, 0);
  
  // Trigonometric YPR
  text("_____________________________________", 0, 5);
  text("trigonometrics", 0, 15);
  text("Yaw: " +   sin(degrees(board.ypr[0] - yawOffset)), 0, 25);
  text("Pitch: " + sin(degrees(board.ypr[1])), 150, 25);
  text("Roll: " +  sin(degrees(board.ypr[2])), 300, 25);

  // Z gyroscope value
  text("z: " + ((int) board.gyro[2]), 450, 30);
  rect(550, 20, map(board.gyro[2], 0, 2000, 0, 50), 10);
  popMatrix();
  
  // Find board directional vector (drumstick)
  seeds.drumstick.x =  sin(board.ypr[0] - yawOffset)*cos(board.ypr[1]);
  seeds.drumstick.y = -sin(board.ypr[1]);
  seeds.drumstick.z = -cos(board.ypr[0] - yawOffset)*cos(board.ypr[1]);
  
  float angle = board.ypr[2];  // By treating the cursor/board/drumstick as a seed, the angle of roll remains in vain
  
  // Draw drumstick
  drawSeed(seeds.drumstick);
  
  // Draw all the musical seeds existing
  drawMusicalSeeds(); // TODO: receber cor
  
  // Output info text
  text("Aponta a parada pra tela e aperta 'a' pra alinhar o real com virtual -drogas", 10, 10);
  text("Vira a parada pra onde tu quiser e depois aperta 's' para adicionar uma semente musical para a nota selecionada -pesadas", 10, 25);
  text("Vira a parada pra onde tu quiser e depois aperta 'x' para aniquilar de vez uma semente -envelhecidas", 10, 40);
}
