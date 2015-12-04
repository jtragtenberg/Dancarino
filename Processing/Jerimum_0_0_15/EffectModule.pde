public class EffectModule {
  //Effects atributes
  int channel = 0;
  int number = 1;
  int value = 0;
  int updateRate = 5;
  double timeRef = 0;
  

  int outputParamMin = 0;
  int outputParamMax = 127;
  
  float inputParamMin = -80;
  float inputParamMax = 160;



  public void updateEffects(float inputParam) {
    if (millis() - timeRef > updateRate) {
      if (inputParam < inputParamMin) inputParam = inputParamMin;
      if (inputParam > inputParamMax) inputParam = inputParamMax;      
      value = (int)map(inputParam, inputParamMin, inputParamMax, outputParamMin, outputParamMax);
      number = seeds.closestSeedNote();
      myBus.sendControllerChange(channel, number, value); // Send a controllerChange
      timeRef = millis();
    }
  }
  

  
  public int teste() {
    println(1234);
    return 123;
  }
}

