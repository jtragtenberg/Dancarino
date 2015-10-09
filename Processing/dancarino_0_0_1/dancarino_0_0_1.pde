import processing.serial.*;

Serial port;

char[] dancarinoPacket = new char[12]; 
int serialCount = 0;                 // current packet byte position
int aligned = 0;
int interval = 0;
float[] q = new float[4];

int[] valores = new int[4];

boolean startFlag = false;

void setup () {
  // set the window size:
  size(200, 200);

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
  background(100);

  if (startFlag) {
    //text(valores[1], 10, 30);
    //text(valores[1], 10, 50);
    //text(valores[2], 10, 70);
    //text(valores[3], 10, 90);
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
      println(ch + " " + aligned + " " + serialCount);
      serialCount++;
      if (serialCount == 8) serialCount = 0;
    } else {
      if (serialCount > 0 || ch == '$') {
        dancarinoPacket[serialCount++] = (char)ch;
        if (serialCount == dancarinoPacket.length) {
          serialCount = 0; // restart packet byte position
          
          valores[0] = dancarinoPacket[2];
          valores[1] = dancarinoPacket[3];
          valores[2] = dancarinoPacket[4];
          valores[3] = dancarinoPacket[5];
          println(valores[0] + " " + valores[1] + " " + valores[2] + " " + valores[3]);
          
          
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
