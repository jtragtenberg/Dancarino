public class EffectPadXYModule {
  //Effects atributes

  int channel = 15;
  //int value = 0;
  int updateRate = 5;
  double timeRef = 0;

  //mouseX

  int xValue = 0;
  int outputParamXMin = 0;
  int outputParamXMax = 127;

  float inputParamXMin = -80;
  float inputParamXMax = 160;

  int xCtlNumber = 0;

  //mouseY
  int yValue = 0;
  int outputParamYMin = 0;
  int outputParamYMax = 127;

  float inputParamYMin = -80;
  float inputParamYMax = 160;

  int yCtlNumber = 1;

  //Button
  int buttonValue = 0;
  int outputParamButtonMin = 0;
  int outputParamButtonMax = 127;

  float inputParamButtonMin = -80;
  float inputParamButtonMax = 160;

  int buttonCtlNumber = 2;


  public void updateEffect(float inputParamX, float inputParamY, float inputParamButton) {
    if (millis() - timeRef > updateRate) {
      xValue = (int)map(inputParamX, inputParamXMin, inputParamXMax, outputParamXMin, outputParamXMax);
      yValue = (int)map(inputParamY, inputParamYMin, inputParamYMax, outputParamYMin, outputParamYMax);
      buttonValue = (int)map(inputParamButton, inputParamButtonMin, inputParamButtonMax, outputParamButtonMin, outputParamButtonMax);
      myBus.sendControllerChange(channel, xCtlNumber, xValue); // Send a controllerChange
      myBus.sendControllerChange(channel, yCtlNumber, yValue); // Send a controllerChange
      myBus.sendControllerChange(channel, buttonCtlNumber, buttonValue); // Send a controllerChange

        timeRef = millis();
    }
  }
}

