public class SeedModule {
  // x, y, z of the musical seed
  float x;
  float y;
  float z;
  int note;
  int channel;
  float colors[] = new float[3];
  
  
  public SeedModule(float x, float y, float z, int note, int channel, int r, int g, int b) {
    this.x    = x;
    this.y    = y;
    this.z    = z;
    this.note = note;
    this.channel = channel;
    this.colors[0] = r;
    this.colors[1] = g;
    this.colors[2] = b;
  }
}
