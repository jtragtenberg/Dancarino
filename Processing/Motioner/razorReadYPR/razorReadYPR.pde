import processing.opengl.*;
import processing.serial.*;

final static int SERIAL_PORT_NUM = 7;
final static int SERIAL_PORT_BAUD_RATE = 57600;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;

float accel[] = new float[3];
float magnetom[] = new float[3];
float gyro[] = new float[3];

Serial serial;
boolean synched = false;

// Skip incoming serial stream data until token is found
boolean readToken(Serial serial, String token) {
  // Wait until enough bytes are available
  if (serial.available() < token.length())
    return false;

  // Check if incoming bytes match token
  for (int i = 0; i < token.length (); i++) {
    if (serial.read() != token.charAt(i))
      return false;
  }   

  return true;
}


// Global setup
void setup() {
  // Setup graphics
  size(640, 480, OPENGL);
  smooth();
  noStroke();
  frameRate(50);

  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  //String portName = Serial.list()[SERIAL_PORT_NUM];
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
}

void setupRazor() {
  println("Trying to setup and synch Razor...");
  delay(3000);  // 3 seconds should be enough

  ///YAW PITCH e ROLL
  // Set Razor output parameters
  serial.write("#ob");  // Turn on binary output
  serial.write("#o1");  // Turn on continuous streaming output
  serial.write("#oe0"); // Disable error message output


  //RAW SENSORS
  /*
  // Set Razor output parameters
   serial.write("#oscb");  // Turn on binary output of raw sensor data
   serial.write("#o1");    // Turn on continuous streaming output
   serial.write("#oe0");   // Disable error message output
   */

  // Synch with Razor
  serial.clear();  // Clear input buffer up to here
  serial.write("#s00");  // Request synch token
}


float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}

void draw() {
  // Reset scene
  background(0);
  lights();

  // Sync with Razor 
  if (!synched) {
    textAlign(CENTER);
    fill(255);
    text("Connecting to Razor...", width/2, height/2, -200);

    if (frameCount == 2)
      setupRazor();  // Set ouput params and request synch token
    else if (frameCount > 2)
      synched = readToken(serial, "#SYNCH00\r\n");  // Look for synch token
    return;
  }

  ///YAW PITCH e ROLL
  // Read angles from serial port 
  while (serial.available () >= 12) {
    yaw = readFloat(serial);
    pitch = readFloat(serial);
    roll = readFloat(serial);
  }

  ///RAW SENSOR VALUES
  /*
  while (serial.available () >= 36) {
   accel[0] = readFloat(serial);  // x
   accel[1] = readFloat(serial);  // y
   accel[2] = readFloat(serial);  // z
   magnetom[0] = readFloat(serial);  // x
   magnetom[1] = readFloat(serial);  // y
   magnetom[2] = readFloat(serial);  // z
   gyro[0] = readFloat(serial);  // x
   gyro[1] = readFloat(serial);  // y
   gyro[2] = readFloat(serial);  // z
   }
   */

  // Output angles
  pushMatrix();
  translate(10, height - 40);
  textAlign(LEFT);
  ///YAW PITCH e ROLL
  text("Yaw: " + ((int) yaw), 0, 0);
  text("Pitch: " + ((int) pitch), 150, 0);
  text("Roll: " + ((int) roll), 300, 0);


  ///Raw Sensor Values
  /*
  text("Acelerometro", 0, 0);
  text("x: " + ((int) accel[0]), 150, 0); 
  text("y: " + ((int) accel[1]), 300, 0);
  text("z: " + ((int) accel[2]), 450, 0);
  rect(250, -10, map(accel[0], 0, 255, 0, 50), 10);
  rect(400, -10, map(accel[1], 0, 255, 0, 50), 10);
  rect(550, -10, map(accel[2], 0, 255, 0, 50), 10);
  text("Magnetometro", 0, 15);
  text("x: " + ((int) magnetom[0]), 150, 15);
  text("y: " + ((int) magnetom[1]), 300, 15);
  text("z: " + ((int) magnetom[2]), 450, 15);
  rect(250, 5, map(magnetom[0], 0, 320, 0, 50), 10);
  rect(400, 5, map(magnetom[1], 0, 320, 0, 50), 10);
  rect(550, 5, map(magnetom[2], 0, 320, 0, 50), 10);
  text("Giroscopio", 0, 30);
  text("x: " + ((int) gyro[0]), 150, 30);
  text("y: " + ((int) gyro[1]), 300, 30);
  text("z: " + ((int) gyro[2]), 450, 30);
  rect(250, 20, map(gyro[0], 0, 2000, 0, 50), 10);
  rect(400, 20, map(gyro[1], 0, 2000, 0, 50), 10);
  rect(550, 20, map(gyro[2], 0, 2000, 0, 50), 10);
  */
  popMatrix();
}

