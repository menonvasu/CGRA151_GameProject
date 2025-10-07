class RangedAttack {
  Player player;
  PImage rangedImg; //image
  float x, y; //start values
  float vx, vy;
  float gravity = 0.6f;
  int drawWidth, drawHeight;
  int originalFrameWidth, originalFrameHeight;
  int speed;
  boolean facingRight;
  boolean hitPlayer = false;
  boolean shouldRemove;

  int currentFrame = 0;
  int frameDelay = 5; 
  int frameDelayCounter = 0;
  
  float stopThreshold = 2; // distance threshold to stop near player
  PImage[] rangedFrames;

  // Animation split
  int flyingFrameCount;  // Number of frames for flying animation
  int impactFrameCount;  // Number of frames for impact animation
  int impactFrameStart;  // Index where impact frames begin
  
  int impactTimer = 10;
  
  
  //construction
  RangedAttack (PImage rangedImg, float x, float y, int drawWidth, int drawHeight, boolean facingRight, Player player, int flyingFrameCount, int impactFrameCount) {
    this.x = x;
    this.y = y;
    this.drawWidth = drawWidth;
    this.drawHeight = drawHeight;
    this.rangedImg = rangedImg;
    this.facingRight = facingRight;
    this.player = player;
    this.speed = 10;
    this.shouldRemove = false;
    
    // slice frames
    int totalFrames = flyingFrameCount + impactFrameCount;
    this.originalFrameWidth = rangedImg.width / totalFrames;
    this.originalFrameHeight = rangedImg.height;
    this.rangedFrames = sliceFrames(rangedImg, totalFrames, originalFrameWidth, originalFrameHeight);
    
    this.flyingFrameCount = flyingFrameCount;
    this.impactFrameCount = impactFrameCount;
    this.impactFrameStart = flyingFrameCount; 
  }
  
  PImage[] sliceFrames(PImage sheet, int count, int frameWidth, int frameHeight) {
    PImage[] frames = new PImage[count];
    for (int i = 0; i < count; i++) {
      frames[i] = sheet.get(i * frameWidth, 0, frameWidth, frameHeight);
    }
    return frames;
  }
  
  // movement
  void move(){
    if (hitPlayer) return;
    
    float playerCenterX = player.x + player.collisionX + player.collisionWidth / 2;
    float distToPlayer = Math.abs(playerCenterX - x);
    
    
    if (distToPlayer > 0) {
      if(facingRight){
        x += speed;
      } else {
        x -= speed;
      }
    } else {
      hitPlayer = true;
      currentFrame = impactFrameStart;
      speed = 0;
      
    }
  }
  
  //draws at x,y
  void draw(float cameraX) {
    float scaleFactor = 1.5f;
    pushMatrix();
    float drawX = x - cameraX;
    if (!facingRight) {
      translate(drawX + drawWidth, y);
      scale(-1, 1);
      image(rangedFrames[currentFrame], 0, 0, drawWidth * scaleFactor, drawHeight * scaleFactor);
    } else {
      image(rangedFrames[currentFrame], drawX, y, drawWidth * scaleFactor, drawHeight * scaleFactor);
    }
    popMatrix();
  }
  
  
  //checks for removing from game
  void checkRemove(float arenaWidth) {
    if (x < 0 || x > arenaWidth) {
      shouldRemove = true;
    }
  }
  
  //update
  void update(float arenaWidth) {
    move();
    checkRemove(arenaWidth);
  
    frameDelayCounter++;
    if (frameDelayCounter >= frameDelay) {
      frameDelayCounter = 0;
      if (hitPlayer) {
        // Only play impact frames
        if (currentFrame < impactFrameStart + impactFrameCount - 1) {
          currentFrame++;
        } else {
          // End of impact sequence
          if (impactTimer > 0) {
            impactTimer--;
          } else {
            shouldRemove = true;
          }
        }
      } else {
        // Loop through flying frames
        if (currentFrame < flyingFrameCount - 1) {
          currentFrame++;
        } else {
          currentFrame = 0;
        }
      }
    }
  }
  
  //collision with player
  boolean rangedCollision(Player player){
    float playerAbsX = player.x + player.collisionX;
    float playerAbsY = player.y + player.collisionY;
    
    return playerAbsX < this.x + drawWidth && 
      playerAbsX + player.collisionWidth > this.x &&
      playerAbsY < this.y + drawHeight &&
      playerAbsY + player.collisionHeight > this.y;
  }
}
