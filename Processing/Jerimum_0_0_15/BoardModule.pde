import processing.serial.*;

public class BoardModule extends PApplet{
  // Connection properties
  int serial_port_number;
  int serial_port_baud_rate;
  Serial serial;
  boolean synched = false;
  
  // Data retrieved (it must be refreshed before use)
  float accel[] = new float[3]; // accelerometer
  float ypr[]   = new float[3]; // yaw, pitch, roll
  float gyro[]  = new float[3]; // gyroscope
  float last_zgyro_values[] = new float[3]; // x0, x1, x2 -> where x2 is the last value retrieved, x1 the penultimate and so on;
  boolean buttonPressed;
  
  public BoardModule(int serial_port_number, int serial_port_baud_rate) {
    this.serial_port_number    = serial_port_number;
    this.serial_port_baud_rate = serial_port_baud_rate;
    
    // Setup serial port I/O
    println("AVAILABLE SERIAL PORTS:");
    println(Serial.list());
    String portName = Serial.list()[this.serial_port_number];
    println();
    println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
    println("  -> Using port " + serial_port_number + ": " + portName);
    this.serial = new Serial(this, portName, serial_port_baud_rate);
    
    this.SetupRazor();
  }
  
  public void SetupRazor() {
    println("Trying to setup and synch Razor...");
    delay(3000);  // 3 seconds should be enough

    //RAW SENSORS MODIFIED (accelerometer, eulerAngles, gyroscope)
    // Set Razor output parameters
    this.serial.write("#oscb");  // Turn on binary output of raw sensor data modified
    this.serial.write("#o1");    // Turn on continuous streaming output
    this.serial.write("#oe0");   // Disable error message output

    // Synch with Razor
    this.serial.clear();  // Clear input buffer up to here
    this.serial.write("#s00");  // Request synch token
    
  }

  
  // Skip incoming serial stream data until token is found
  public boolean ReadToken(String token) {
    // Wait until enough bytes are available
    if (this.serial.available() < token.length())
      return false;

    // Check if incoming bytes match token
    for (int i = 0; i < token.length (); i++) {
      if (this.serial.read() != token.charAt(i))
        return false;
    }   

    return true;
  }
  
  public float ReadFloat(Serial s) {
    // Convert from little endian (Razor) to big endian (Java) and interpret as float
    return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
  }
  
  public boolean RefreshData() {
    // Sync with Razor 
    if (!this.synched) {
      println("Connecting to Razor...");

      this.synched = ReadToken("#SYNCH00\r\n");  // Look for synch token
      return false;
    } 
    
    ///RAW SENSOR VALUES
    while (serial.available () >= 37) {//joao
      this.accel[0] = this.ReadFloat(this.serial);  // x
      this.accel[1] = this.ReadFloat(this.serial);  // y
      this.accel[2] = this.ReadFloat(this.serial);  // z
      this.ypr[0]   = this.ReadFloat(this.serial);  // x
      this.ypr[1]   = this.ReadFloat(this.serial);  // y
      this.ypr[2]   = this.ReadFloat(this.serial);  // z
      this.gyro[0]  = this.ReadFloat(this.serial);  // x
      this.gyro[1]  = this.ReadFloat(this.serial);  // y
      
      //this.gyro[2]  = this.ReadFloat(this.serial);  // z
      this.last_zgyro_values[0]  = this.last_zgyro_values[1]; // refresh lasts z gyros
      this.last_zgyro_values[1]  = this.last_zgyro_values[2]; // refresh lasts z gyros
      this.gyro[2]  = this.ReadFloat(this.serial);  // z
      this.last_zgyro_values[2]  = this.gyro[2];              // refresh lasts z gyros
      
      if (this.serial.read() == 0){ //joao
        this.buttonPressed = true;
      }
      else this.buttonPressed = false;  

    }
    
    return this.synched;
  }
}
