import processing.serial.*;

Serial port;

char[] dancarinoPacket = new char[12]; 
int serialCount = 0;                 // current packet byte position
int aligned = 0;
int interval = 0;
float[] q = new float[4];
float[] gravity = new float[3];
float[] ypr = new float[3];

float[] vector = new float[3];
float angle;

int[] valores = new int[4];

boolean startFlag = false;

void setup () {
  // set the window size:
  size(300, 300, P3D);

  // List all the available serial ports
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  port = new Serial(this, Serial.list()[7], 57600);

  // don't generate a serialEvent() unless you get a newline character:
  port.bufferUntil('\n');
}

void draw () {
  background(0);

  if (startFlag) {
    line(gravity[0]*50 + 150, gravity[1]*50 + 150, gravity[2]*50 + 150, 150, 150, 150);
    stroke(100);
    //line(gravity[0]*50 + 150, gravity[1]*50 + 150, gravity[2]*50 + 150, 150, 150, 150);
    text(gravity[0], 10, 50);
    text(gravity[1], 10, 80);
    text(gravity[2], 10, 110);
    
  }

  //println(startFlag);
}

void serialEvent (Serial port) {
  while (port.available () > 0) {
    int ch = port.read();
    //print((char)ch);
    if (ch == '$') {
      serialCount = 0;
    } // this will help with alignment
    if (aligned < 4) {
      if (serialCount == 0) {
        if (ch == '$') aligned++;
        else aligned = 0;
      } else if (serialCount == 1) {
        if (ch == 2) aligned++;
        else aligned = 0;
      } else if (serialCount == dancarinoPacket.length - 2) {
        if (ch == '\r') aligned++; 
        else aligned = 0;
      } else if (serialCount == dancarinoPacket.length - 1) {
        if (ch == '\n') aligned++; 
        else aligned = 0;
      }
      println("canal " + ch + " aligned " + aligned + " serialCount " + serialCount);
      serialCount++;
      if (serialCount == dancarinoPacket.length) serialCount = 0;
    } else {
      if (serialCount > 0 || ch == '$') {
        dancarinoPacket[serialCount++] = (char)ch;
        if (serialCount == dancarinoPacket.length) {
          serialCount = 0; // restart packet byte position

          /*
          q[0] = (((dancarinoPacket[2] << 8) | dancarinoPacket[3]) / 16384.0f) - 1;
           q[1] = (((dancarinoPacket[4] << 8) | dancarinoPacket[5]) / 16384.0f) - 1;
           q[2] = (((dancarinoPacket[6] << 8) | dancarinoPacket[7]) / 16384.0f) - 1;
           q[3] = (((dancarinoPacket[8] << 8) | dancarinoPacket[9]) / 16384.0f) - 1;
           */
          q[0] = (dancarinoPacket[3] / 100.0f) - 1;
          q[1] = (dancarinoPacket[5] / 100.0f) - 1;
          q[2] = (dancarinoPacket[7] / 100.0f) - 1;
          q[3] = (dancarinoPacket[9] / 100.0f) - 1;

          println(q[0] + " " + q[1] + " " + q[2] + " " + q[3]);
          startFlag = true;

          gravity[0] = 2 * (q[1]*q[3] - q[0]*q[2]);
          gravity[1] = 2 * (q[0]*q[1] + q[2]*q[3]);
          gravity[2] = q[0]*q[0] - q[1]*q[1] - q[2]*q[2] + q[3]*q[3];
         
          ypr[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
          ypr[1] = atan(gravity[0] / sqrt(gravity[1]*gravity[1] + gravity[2]*gravity[2]));
          ypr[2] = atan(gravity[1] / sqrt(gravity[0]*gravity[0] + gravity[2]*gravity[2]));
          
          angle = 2*acos(q[0]);
          vector [0] = q[1] / (sqrt(1-q[0]*q[0]));
          vector [1] = q[2] / (sqrt(1-q[0]*q[0]));
          vector [2] = q[3] / (sqrt(1-q[0]*q[0]));
          // get quaternion from data packet
          //q[0] = ((girominPacket[2] << 8) | girominPacket[3]) / 16384.0f;
          //q[1] = ((girominPacket[4] << 8) | girominPacket[5]) / 16384.0f;
          //q[2] = ((girominPacket[6] << 8) | girominPacket[7]) / 16384.0f;
          //q[3] = ((girominPacket[8] << 8) | girominPacket[9]) / 16384.0f;
          //for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];
        }
      }
    }
  }
}

