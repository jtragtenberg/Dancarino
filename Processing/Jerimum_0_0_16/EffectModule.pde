public class EffectModule {
  EffectPadXYModule giroMouse;
  BoardModule   board;

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

  float yawOffset;

  public EffectModule(EffectPadXYModule giroMouse, BoardModule board, float yawOffset) {
    this.giroMouse = giroMouse;
    this.board = board;
    this.yawOffset = yawOffset;
  }


  public void giroMouseUpdate() {
    giroMouse.inputParamXMin = -30;
    giroMouse.inputParamXMax = 30;
    giroMouse.inputParamYMin = 0;
    giroMouse.inputParamYMax = 40;
    //giroMouse.inputParamButtonMin = 0;
    //giroMouse.inputParamButtonMax = 1;
    //int button = 0;
    //if (board.buttonPressed) button = 1;  
    //giroMouse.updateEffect(degrees(board.ypr[0] - yawOffset), degrees(board.ypr[1]),button);
    giroMouse.updateEffect(degrees(board.ypr[0] - this.yawOffset), degrees(board.ypr[1]));
  }

  public void knobEffectUpdate(float inputParam) {
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
  }

  public void updateEffects(float inputParam) {
    if (board.buttonPressed) {
      if (!buttonPressedFlag) {
        ctlNumber = seeds.closestSeedNote();
        channel = seeds.getClosestChannel();
        println("O canal dessa mulesta eh: " + channel);
      }
      buttonPressedFlag = true;
      if (channel == 16) {
        giroMouseUpdate();
      } else {
        knobEffectUpdate(inputParam);
      }
    }


    if (!board.buttonPressed && buttonPressedFlag) {
      buttonPressedFlag = false;
    }
  }



  public int teste() {
    println(1234);
    return 123;
  }
}

