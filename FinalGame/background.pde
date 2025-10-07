class Background {
  PImage[] layers; //all layers for one level
  float[] layerXPositions; //positions
  float[] scrollSpeeds; //speeds
  float arenaWidth; // arena width
  
  //construction and loading of background
  Background(String levelPrefix, int numLayers, float[] speeds, float arenaWidth) {
    this.arenaWidth = arenaWidth;
    layers = new PImage[numLayers];
    layerXPositions = new float[numLayers];
    scrollSpeeds = speeds;
    for (int i=0; i<numLayers; i++) {
      layers[i] = loadImage("backgrounds/" + levelPrefix + "_layer" + i + ".png");
      layers[i].resize(width, height);
      layerXPositions[i] = 0;
    }
  }

  //draws the scrolling effect 
  void drawParallaxLayer(PImage bg, float cameraX, float depth, float arenaWidth) {  
    float offsetX = (cameraX / depth) % bg.width; // ensures wrap-around and shifting of 1 background layer
    if (offsetX < 0) offsetX += bg.width; //ensures offset is adjusted if -ve
    int tiles = ceil(arenaWidth / bg.width); //num of copies to cover arena
    for (int i = 0; i < tiles; i++) { 
      image(bg, i * bg.width - offsetX, 0); //draws each tile in a row, shifted with offset
    }
  }
  
  
  //calls drawParallaxLayer for all the background layers
  void drawAllParallaxLayers(float cameraX) {
    for (int i = 0; i < layers.length; i++) {
      float depth = i + 1;
      drawParallaxLayer(layers[i], cameraX, depth, arenaWidth);
    }
    
    fill(0, 0, 0, 100);
    noStroke();
    rect(0, 0, width, height); 
  } 
}
