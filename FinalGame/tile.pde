class Tile {
  float y;
  PImage tileSet;
  PImage specific;
  int sh;

  //constructor for tile object (floor)
  Tile(PImage tileSet, float y, int sx, int sy, int sw, int sh) {
    this.y = y;
    this.tileSet = tileSet;
    this.specific = tileSet.get(sx, sy, sw, sh);
    this.sh = sh;
  }

  //draws the floor across the arena
  void drawFloor(float cameraX) {
    for (int i = 0; i < width / specific.width + 2; i++) {
      float dx = i * specific.width - (cameraX % specific.width);
      image(specific, dx, y);
    }
  }
  

  //checks tile collision with player
  boolean collision(Player player) {
    float scaleFactor = 1.5f;

    float playerAbsY = player.y + player.collisionY * scaleFactor;
    float playerBottomY = playerAbsY + player.collisionHeight;


    float tileTop = groundY;
    float tileBottom = groundY + specific.height;

    return playerBottomY > tileTop && playerAbsY < tileBottom;
  }
  

  void tileCollision(Player player) {
    if (collision(player) && player.vy >= 0) {
      float scaleFactor = 1.5f;
      player.y = groundY - player.spriteHeight * scaleFactor;
      player.vy = 0;
      jumping = false;
    }
  }
  
}
