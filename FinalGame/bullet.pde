class Bullet {
  PImage bulletImg; //image
  float x, y; //start values
  int speed;
  boolean facingRight;
  boolean shouldRemove;
  
  int bwidth = 16;  // bullet width
  int bheight = 5; // bullet height
  
  //construction
  Bullet (PImage bulletImg, float x, float y, boolean facingRight){
    this.x = x;
    this.y = y;
    this.bulletImg = bulletImg;
    this.facingRight = facingRight;
   
    speed = 15;
    shouldRemove = false;
  }
  
  //bullet movement
  void move(){
    if(facingRight){
      x += speed;
    } else {
      x -= speed;
    }
  }
  
  //draws bullet at x,y
  void draw(float cameraX) {
    image(bulletImg, x - cameraX, y, 75, 75); 
  }
  
  
  //checks for removing from game
  void checkRemove(float arenaWidth) {
    if (x < 0 || x > arenaWidth) {
      shouldRemove = true;
    }
  }
  
  //calls checkRemove and move together in one call
  void update(float arenaWidth) {
    move();
    checkRemove(arenaWidth);
  }
  
  //collision with mob
  boolean bulletCollision(Mob m){
    float mobAbsX = m.x + m.collisionX;
    float mobAbsY = m.y + m.collisionY;
    
    return mobAbsX < this.x + bwidth && 
      mobAbsX + m.collisionWidth > this.x &&
      mobAbsY < this.y + bheight &&
      mobAbsY + m.collisionHeight > this.y;
  }
  
  //collision with boss
  boolean bulletCollision(Boss b){
    float bossAbsX = b.x + b.collisionX;
    float bossAbsY = b.y + b.collisionY;
    
    return bossAbsX < this.x + bwidth && 
      bossAbsX + b.collisionWidth > this.x &&
      bossAbsY < this.y + bheight &&
      bossAbsY + b.collisionHeight > this.y;
  }
}
