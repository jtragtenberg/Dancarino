public class SeedMgrModule {
  SeedModule drumstick;  // The cursor coordinates. Treated as a seed for practical purposes
  ArrayList<SeedModule> seeds = new ArrayList<SeedModule>();
  
  public SeedMgrModule() {
    this.drumstick = new SeedModule(0.0, 0.0, 0.0, -1);
  }
  
  public void AddSeed(int note) {  // Add a new Musical at the coords of the drumstick
    this.seeds.add(new SeedModule(drumstick.x, drumstick.y, drumstick.z, note));
    println("Musical Seed of note " + note + " added successful at [" +drumstick.x+", "+drumstick.y+", "+drumstick.z+"]");
  }
  
  public void DeleteSeed() {  // Delete the seed more close to the drumstick
    int closest_seed_idx = this.ClosestSeedIdx();
    if (closest_seed_idx < 0) {
      println("Bora boy! Nao tem semente pra deletar.");
      return;
    } else {
      this.seeds.remove(closest_seed_idx);      
      println("Musical Seed closest from [" +drumstick.x+", "+drumstick.y+", "+drumstick.z+"] removed successful");
    }
  }
  
  public int ClosestSeedIdx() {  // Return the idx of the closest Seed stored, from drumstick
    if (this.seeds.size() < 1) // There is no seed
      return -1;
    else {
      int closest_seed_idx = 0;
      float min_dist       = 999999; // A high value :P - the coords are normalized so it's impossible beat the value 2 in distance between two seeds..
      float curr_dist      = 0;
      
      for (int i = 0; i < this.seeds.size(); i++) {
        SeedModule curr_seed = this.seeds.get(i);
        curr_dist = this.DistBetweenSeeds(this.drumstick, curr_seed);
        if (curr_dist < min_dist) {
          min_dist = curr_dist;
          closest_seed_idx = i;
        }
      } 
      return closest_seed_idx;
    }
  }
  
  public float DistBetweenSeeds(SeedModule seed1, SeedModule seed2) {
    return sqrt(pow(seed1.x - seed2.x, 2) + pow(seed1.y - seed2.y, 2) + pow(seed1.z - seed2.z, 2));
  }
}