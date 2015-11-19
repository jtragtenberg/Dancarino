
/// MotionerIMU using the follwing libraries
#include "CAN.h"
#include "vec3.h"
#include "EEPROM.h"
#include "Wire.h"
#include "SPI.h"
#include "I2Cdev.h"
#include "MPU60X0.h"
#include "RazorIMU.h"
#include "MotionerIMU.h"


/// Our serial baudrate
static const long BAUDRATE = 57600;

/// MotionerIMU object
MotionerIMU motioner;


/// setup
void setup()
{
  /// Use serial for get some information from MotionerIMU
  Serial.begin(BAUDRATE);

  Serial.println("[Motioner IMU]");

  /// Use I2C
  Wire.begin();

  /// Setup MotionerIMU
  motioner.setup();
}


/// main loop
void loop()
{
  /// Update MotionerIMU
  motioner.update();
  uint8_t dancarinoPacket[12] = { 
    '$', 0x02, 0,0 ,0,0, 0,0, 0,0, '\r', '\n'           };

  float qx = motioner.mRazorIMU.getQuatX();
  float qy = motioner.mRazorIMU.getQuatY();
  float qz = motioner.mRazorIMU.getQuatZ();
  float qw = motioner.mRazorIMU.getQuatW(); 


  int w = int((qw + 1)*100);
  int x = int((qx + 1)*100);
  int y = int((qy + 1)*100);
  int z = int((qz + 1)*100);


  float angle = 2*acos(qw);
  float vx = qx / (sqrt(1-(qw*qw)));
  float vy = qy / (sqrt(1-(qw*qw)));
  float vz = qz / (sqrt(1-(qw*qw)));

  int angle_ = int((angle + 1)*100);
  int vx_ = int((vx + 1)*100);
  int vy_ = int((vy + 1)*100);
  int vz_ = int((vz + 1)*100);

/*
   Serial.print('quat:');  
  Serial.print(qw);
   Serial.print('|');
   Serial.print(qx);
   Serial.print('|');
   Serial.print(qy);
   Serial.print('|');  
   Serial.print(qz);
  */ 
//   Serial.print(' angle:');    
  Serial.print(angle);
   Serial.print('|');
   Serial.print(vx);
   Serial.print('|');
   Serial.print(vy);
   Serial.print('|');  
   Serial.print(vz);
   
  Serial.print('||');  
   Serial.print(motioner.mRazorIMU.quat.w);
   Serial.print('|');
   Serial.print(motioner.mRazorIMU.quat.x);
   Serial.print('|');
   Serial.print(motioner.mRazorIMU.quat.y);
   Serial.print('|');  
   Serial.println(motioner.mRazorIMU.quat.z);
   
  /*
  Serial.print(motioner.mRazorIMU.yaw);
   Serial.print('|');
   Serial.print(motioner.mRazorIMU.pitch);
   Serial.print('|');
   Serial.println(motioner.mRazorIMU.roll);
   */

  dancarinoPacket[2] = vx_ >> 8 & B11111111;
  dancarinoPacket[3] = vx_ & B11111111;
  dancarinoPacket[4] = vy_ >> 8 & B11111111;
  dancarinoPacket[5] = vy_ & B11111111;
  dancarinoPacket[6] = vz_ >> 8 & B11111111;
  dancarinoPacket[7] = vz_ & B11111111;
  dancarinoPacket[8] = angle_ >> 8 & B11111111;
  dancarinoPacket[9] = angle_ & B11111111;

  /*
  int teste = 21759;
   uint8_t testePacket[2] = {
   0,0  };
   testePacket[0] = teste >> 8;
   testePacket[1] = teste & B11111111;
   
   Serial.print(testePacket[0]);
   Serial.print('|');
   Serial.println(testePacket[1]);
   */

  //Serial.write(dancarinoPacket, sizeof(dancarinoPacket));

  delay(10);
}









