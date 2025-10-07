class Pickup {
  float x, y;

  PImage[] animationFrames;
  int currentFrame = 0;
  int frameDelay = 5, frameDelayCounter = 0;
  boolean collected = false;
  String type; // health or ammo

  //constructor
  Pickup(float x, PImage[] healthFrames, String type) {
    this.x = x;
    this.animationFrames = healthFrames;
    this.y = groundY - animationFrames[0].height;
    this.type = type;
  }
  
  //update frames
  void update() {
    frameDelayCounter++;
    if (frameDelayCounter >= frameDelay) {
      currentFrame = (currentFrame + 1) % animationFrames.length;
      frameDelayCounter = 0;
    }
  }

  void draw(float cameraX) {
    if (!collected) {
      float screenX = x - cameraX;
      float centerX = screenX + animationFrames[currentFrame].width / 2;
      float centerY = y + animationFrames[currentFrame].height / 2;
      
      noStroke();
      if (type.equals("ammo")) {
      fill(255, 255, 150, 100);  // soft yellow glow
      } else if (type.equals("health")) {
      fill(255, 100, 100, 100); // soft red glow
      }
    
      ellipse(centerX, centerY, 35, 35);
    
      image(animationFrames[currentFrame], x - cameraX, y);
    }
  }
  
    
  //randomise spawn
  void setRandomPosition(float arenaWidth) {
    x = random(10, arenaWidth);
  }
  
  //action
  void applyEffect(Player player) {
    if (type.equals("health")) {
      player.heal(50);
    } else if (type.equals("ammo")) {
      player.addAmmo(player.maxAmmo);
    }
    collected = true;
  }
  
  
  //collision detection
  boolean pickupCollision(){
    float playerAbsX = player.x + player.collisionX;
    float playerAbsY = player.y + player.collisionY;
    
    int hwidth = animationFrames[currentFrame].width;
    int hheight = animationFrames[currentFrame].height;
    
    return playerAbsX < this.x + hwidth && 
      playerAbsX + player.collisionWidth > this.x &&
      playerAbsY < this.y + hheight &&
      playerAbsY + player.collisionHeight > this.y;
  } 
}
