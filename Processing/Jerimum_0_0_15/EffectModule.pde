public class EffectModule {
  //Effects atributes
  int channel = 0;
  int ctlNumber = 1;
  int value = 0;
  int updateRate = 5;
  double timeRef = 0;


  int outputParamMin = 0;
  int outputParamMax = 127;

  float inputParamMin = -80;
  float inputParamMax = 160;

  boolean buttonPressedFlag = false;


  public void updateEffects(float inputParam) {


    
    if (board.buttonPressed) {
      if (!buttonPressedFlag) {
        ctlNumber = seeds.closestSeedNote();
      }
      buttonPressedFlag = true;
      float parameter = degrees(board.ypr[2]);
      if (parameter > effects.inputParamMin && parameter < effects.inputParamMax) {

        if (millis() - timeRef > updateRate) {
          //if (inputParam < inputParamMin) inputParam = inputParamMin;
          //if (inputParam > inputParamMax) inputParam = inputParamMax;      
          value = (int)map(inputParam, inputParamMin, inputParamMax, outputParamMin, outputParamMax);
          //number = seeds.closestSeedNote();
          myBus.sendControllerChange(channel, ctlNumber, value); // Send a controllerChange
          timeRef = millis();
        }
      }
      
    } else if (buttonPressedFlag) {
      buttonPressedFlag = false;
    }
  }



  public int teste() {
    println(1234);
    return 123;
  }
}

