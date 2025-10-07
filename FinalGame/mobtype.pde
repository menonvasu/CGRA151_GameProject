//reason for this class was to use the flexibility of the mob class to have multiples types of looks for mobs
class MobType {
  PImage idle, walk, attack, hurt, dead;
  float speed;
  int strikeFrame;
  MobType(PImage idle, PImage walk, PImage attack, PImage hurt, PImage dead, float speed, int strikeFrame) {
    this.idle = idle;
    this.walk = walk;
    this.attack = attack;
    this.hurt = hurt;
    this.dead = dead;
    this.speed = speed;
    this.strikeFrame = strikeFrame;
  }
}
