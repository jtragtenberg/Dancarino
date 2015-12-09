public class Graph {
  int maxWidth = 1000;
  float[] valores = new float[maxWidth];
  int xPos = 0;         // horizontal position of the graph
/*
  public Graph(float inputParamMin, float inputParamMax, int windowWidth, int windowHeight) {
    this.inputParamMin = inputParamMin;
    this.inputParamMax = inputParamMax;
    this.windowWidth = windowWidth;
    this.windowHeight = windowHeight;
  }
*/
  public void drawGraph(float inputParam, float inputParamMin, float inputParamMax, int windowWidth, int windowHeight) {
    if (windowWidth > maxWidth) {
      println("a janela precisa ser menor do que" + maxWidth);
    } else {
      if (inputParam > inputParamMax) { inputParam = inputParamMax; }
      if (inputParam < inputParamMin) { inputParam = inputParamMin; }
      valores [xPos] = map(inputParam, inputParamMin, inputParamMax, 0, windowHeight);
      if (xPos >= windowWidth) {
        xPos = 0;
        for (int i = 0; i < windowWidth; i++) {
          valores[i] = 0;
        }
      } else {
        // increment the horizontal position:
        xPos++;
      }
      // draw the line:
      stroke(255);
      for (int i = 0; i < windowWidth; i++) {
        line(i, windowHeight, i, windowHeight - valores[i]);
      }
    }
  }
}

