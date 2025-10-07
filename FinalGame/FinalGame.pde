//levels
enum State {
  START, CONTROLS, LEVEL1, LEVEL2, LEVEL3, LEVEL4, WIN_END, LOSE_END 
}

State currentState;
Background[] levelBackgrounds; //backgrounds
PImage[] healthPickup, ammoPickup;
PImage startupImg, tileSet1, tileSet2, tileSet3, tileSet4, healthBarBorder, healthBarFill, emptyhealthbar, nohealth, health;
PImage currentTileSet;
PImage[] level1_objects, level2_objects, level3_objects, level4_objects;
int currentLevel = 0;
int flickerCycleLength = 100;  // frames per flicker step
int flickerStepCount = 4;      // 4 steps in pattern


float charY; //character y pos
float mobY; //mob y pos
float boss1Y; //boss 1 y pos
float boss2Y; // boss 2 y pos

float cameraX; //camera and ground values
float groundY; //ground pos
float arenaWidth; //arena width

boolean moveRight = false;
boolean moveLeft = false;
boolean jumping = true;


//for health pickups
ArrayList<Pickup> healthPickups = new ArrayList<Pickup>();
ArrayList<Pickup> ammoPickups = new ArrayList<Pickup>();

//spawn timers
int spawnIntervalHealth = 60 * 25;
int spawnIntervalAmmo = 60 * 15;
int spawnTimerHealth, spawnTimerAmmo = 0;

String pickupNotification = "";
int pickupNotificationTimer = 0;
int pickupNotificationDuration = 180;

int mobSpawnTimer = 0;
int mobSpawnInterval = 180;
int killCount = 0;

// round start/end wait buffer
int roundStartMessageEndTime = 0;
boolean levelEndPending = false;
int levelEndDelayFrames = 90; 
int levelEndFrameCounter = 0;

//mob
ArrayList<Mob> mobs = new ArrayList<Mob>();
MobType[] level1MobTypes;
MobType[] level3MobTypes;

Player player;
Boss boss1;
Boss boss2;

PFont font;
void setup() {
  size(960, 540, P2D);
  font = createFont("Silkscreen.ttf", 14);
  textAlign(CENTER, CENTER);
  textSize(20);
  frameRate(60);

  //initialise
  startupImg = loadImage("startup.png");

  currentState = State.START;

  levelBackgrounds = new Background[4];
  levelBackgrounds[0] = new Background("level1", 7, new float[]{0.5, 1.0, 1.5, 2.0, 2.5, 0.3, 0.6}, 2000);
  levelBackgrounds[1] = new Background("level2", 8, new float[]{0.3, 0.5, 1.0, 1.3, 1.5, 0.3, 0.6, 1.2}, 4000);
  levelBackgrounds[2] = new Background("level3", 2, new float[]{0.3, 0.5, }, 2000);
  levelBackgrounds[3] = new Background("level4", 4, new float[]{0.5, 1.0, 1.2, 1.0}, 4000);
  

  //load

  //player
  PImage idle = loadImage("player/Idle.png");
  PImage hurt = loadImage("player/Hurt.png");
  PImage dead = loadImage("player/Dead.png");
  PImage run = loadImage("player/Run.png");
  PImage jump = loadImage("player/Jump.png");
  PImage shoot = loadImage("player/Shoot.png");
  PImage reload = loadImage("player/Reload.png");

  //boss1
  PImage boss1Idle = loadImage("boss1/Idle.png");
  PImage boss1Walk = loadImage("boss1/Walk.png");
  PImage boss1Jump = loadImage("boss1/Jump.png");
  PImage boss1Attack = loadImage("boss1/Attack1.png");
  PImage boss1Hurt = loadImage("boss1/Hurt.png");
  PImage boss1Dead = loadImage("boss1/Dead.png");
  PImage boss1Special = loadImage("boss1/Attack2.png");
  PImage boss1Ranged = loadImage("boss1/Attack3.png");
  PImage boss1RangedImg = loadImage("boss1/Fire-bomb.png");
  
  //boss2
  PImage boss2Idle = loadImage("boss2/Idle.png");
  PImage boss2Walk = loadImage("boss2/Walk.png");
  PImage boss2Jump = loadImage("boss2/Jump.png");
  PImage boss2Attack = loadImage("boss2/Attack1.png");
  PImage boss2Hurt = loadImage("boss2/Hurt.png");
  PImage boss2Dead = loadImage("boss2/Dead.png");
  PImage boss2Special = loadImage("boss2/Attack2.png");
  PImage boss2Ranged = loadImage("boss2/Attack3.png");
  PImage boss2RangedImg = loadImage("boss2/waveform.png");
  
  //zombie1
  PImage mobIdle1 = loadImage("mob/zombie1/Idle.png");
  PImage mobWalk1 = loadImage("mob/zombie1/Walk.png");
  PImage mobAttack1 = loadImage("mob/zombie1/Attack.png");
  PImage mobHurt1 = loadImage("mob/zombie1/Hurt.png");
  PImage mobDead1 = loadImage("mob/zombie1/Dead.png");
  //zombie2
  PImage mobIdle2 = loadImage("mob/zombie2/Idle.png");
  PImage mobWalk2 = loadImage("mob/zombie2/Walk.png");
  PImage mobAttack2 = loadImage("mob/zombie2/Attack.png");
  PImage mobHurt2 = loadImage("mob/zombie2/Hurt.png");
  PImage mobDead2 = loadImage("mob/zombie2/Dead.png");
  //zombie3
  PImage mobIdle3 = loadImage("mob/zombie3/Idle.png");
  PImage mobWalk3 = loadImage("mob/zombie3/Walk.png");
  PImage mobAttack3 = loadImage("mob/zombie3/Attack.png");
  PImage mobHurt3 = loadImage("mob/zombie3/Hurt.png");
  PImage mobDead3 = loadImage("mob/zombie3/Dead.png");
  //zombie4
  PImage mobIdle4 = loadImage("mob/zombie4/Idle.png");
  PImage mobWalk4 = loadImage("mob/zombie4/Walk.png");
  PImage mobAttack4 = loadImage("mob/zombie4/Attack.png");
  PImage mobHurt4 = loadImage("mob/zombie4/Hurt.png");
  PImage mobDead4 = loadImage("mob/zombie4/Dead.png");
  //homeless1
  PImage mobIdle5 = loadImage("mob/Homeless1/Idle.png");
  PImage mobWalk5 = loadImage("mob/Homeless1/Walk.png");
  PImage mobAttack5 = loadImage("mob/Homeless1/Attack.png");
  PImage mobHurt5 = loadImage("mob/Homeless1/Hurt.png");
  PImage mobDead5 = loadImage("mob/Homeless1/Dead.png");
  //homeless2
  PImage mobIdle6 = loadImage("mob/Homeless2/Idle.png");
  PImage mobWalk6 = loadImage("mob/Homeless2/Walk.png");
  PImage mobAttack6 = loadImage("mob/Homeless2/Attack.png");
  PImage mobHurt6 = loadImage("mob/Homeless2/Hurt.png");
  PImage mobDead6 = loadImage("mob/Homeless2/Dead.png");
   //homeless1
  PImage mobIdle7 = loadImage("mob/Homeless3/Idle.png");
  PImage mobWalk7 = loadImage("mob/Homeless3/Walk.png");
  PImage mobAttack7 = loadImage("mob/Homeless3/Attack.png");
  PImage mobHurt7 = loadImage("mob/Homeless3/Hurt.png");
  PImage mobDead7 = loadImage("mob/Homeless3/Dead.png");

  //bullet and ammo
  PImage bulletImg = loadImage("player/Bullet.png");
  PImage ammo = loadImage("pickups/Ammo.png");
  ammoPickup = new PImage[1];
  ammoPickup[0] = ammo;

  //health
  PImage healthSheet = loadImage("player/Health.png"); 
  PImage heart1 = loadImage("pickups/Heart1.png");
  PImage heart2 = loadImage("pickups/Heart2.png");
  
  //boss health
  emptyhealthbar = loadImage("boss1/empty health bar.png");
  nohealth = loadImage("boss1/no health.png");
  health = loadImage("boss1/health.png");
  
  healthPickup = new PImage[2]; //pickup
  healthPickup[0] = heart1;
  healthPickup[1] = heart2;
  healthBarBorder = healthSheet.get(0, 51, 113, 20);  // main border
  healthBarFill   = healthSheet.get(0, 0, 113, 11); //red fill

  // -- Tileset and Objects --
  //level1
  tileSet1 = loadImage("level1/Tileset.png");
  PImage tower1 = loadImage("level1/Tower1.png");
  PImage tower2 = loadImage("level1/Tower2.png");
  PImage barrel1 = loadImage("level1/Barrel1.png");
  PImage barrel2 = loadImage("level1/Barrel2.png");
  PImage barrel3 = loadImage("level1/Barrel3.png");
  PImage generator = loadImage("level1/Generator.png");
  PImage box1 = loadImage("level1/Box1.png");
  PImage box2 = loadImage("level1/Box2.png");
  PImage box3 = loadImage("level1/Box3.png");
  PImage fire_extinguisher = loadImage("level1/Fire-extinguisher.png");
  PImage pointer = loadImage("level1/Pointer.png");
  level1_objects = new PImage[] { tower1, tower2, barrel1, barrel2, barrel3, generator, box1, box2, box3, fire_extinguisher, pointer};
  
  //level2 
  tileSet2 = loadImage("level2/Tileset.png");
  PImage level2ObjSheet = loadImage("level2/objects.png");
  PImage crate = level2ObjSheet.get(42, 19, 45, 45);
  PImage scarecrow = level2ObjSheet.get(704, 230, 120, 90);
  PImage statue = level2ObjSheet.get(704, 115, 35, 77);
  PImage campfire = level2ObjSheet.get(354, 265, 61, 23);
  PImage cauldron = level2ObjSheet.get(797, 33, 39, 31);
  PImage chest1 = level2ObjSheet.get(31, 515, 34, 29);
  PImage chest2 = level2ObjSheet.get(95, 579, 34, 29); 
  PImage logs = level2ObjSheet.get(163, 335, 90, 49); 
  PImage haybale = level2ObjSheet.get(192, 254, 62, 34); 
  PImage well = level2ObjSheet.get(32, 165, 123, 91);
  PImage pot = level2ObjSheet.get(264, 35, 17, 29);
  PImage grave1 = level2ObjSheet.get(579, 147, 27, 45); 
  PImage grave2 = level2ObjSheet.get(511, 145, 35, 47); 
  PImage sign = level2ObjSheet.get(388, 23, 27, 41);
  PImage archery = level2ObjSheet.get(717, 20, 38, 44);
  level2_objects = new PImage[] { crate, scarecrow, statue, campfire, cauldron, chest1, chest2, logs, haybale, well, pot, grave1, grave2, sign, archery };
  
  //level3
  tileSet3 = loadImage("level3/Tileset.png");
  PImage decor = loadImage("level3/Decor.png");
  PImage bush1 = loadImage("level3/bush1.png");
  PImage bush2 = loadImage("level3/bush2.png");
  PImage salt = loadImage("level3/Salt.png");
  PImage tree1 = loadImage("level3/tree1.png");
  PImage tree2 = loadImage("level3/tree2.png");
  PImage fence = tileSet3.get(0, 243, 64, 77);
  PImage grave3 = decor.get(293, 101, 21, 27);
  PImage grave4 = decor.get(262, 107, 22, 21);
  level3_objects = new PImage[] { bush1, bush2,  salt, tree1, tree2, fence, grave3, grave4 };
  
  //level4
  tileSet4 = loadImage("level4/Tileset.png");
  PImage props1 = loadImage("level4/props1.png");
  PImage rock1 = props1.get(36, 503, 331, 264);
  PImage rock2 = props1.get(22, 864, 353, 144);
  PImage rock3 = props1.get(434, 743, 571, 264);
  PImage tree3 = props1.get(69, 6, 283, 170);
  PImage bush3 = props1.get(856, 101, 133, 75);
  PImage bush4 = props1.get(690, 110, 94, 66);
  PImage sawmill = loadImage("level4/Sawmill.png");
  PImage furnace = loadImage("level4/Furnace.png");
  PImage tent = loadImage("level4/Tent.png");
  PImage ores = loadImage("level4/Ores.png");
  PImage ore1 = ores.get(6, 26, 53, 38);
  PImage ore2 = ores.get(70, 90, 53, 38);
  level4_objects = new PImage[] { rock1, rock2, rock3, tree3, bush3, bush4, sawmill, furnace, tent, ore1, ore2 };

  player = new Player(idle, hurt, dead, run, jump, shoot, reload, bulletImg, 200, charY);
  boss1 = new Boss(BossType.BOSS1, boss1Idle, boss1Walk, boss1Jump, boss1Attack, boss1Hurt, boss1Dead, boss1Special, boss1Ranged, boss1RangedImg, 800, boss1Y, 1, 9, 7);
  boss2 = new Boss(BossType.BOSS2, boss2Idle, boss2Walk, boss2Jump, boss2Attack, boss2Hurt, boss2Dead, boss2Special, boss2Ranged, boss2RangedImg, 800, boss2Y, 1, 3, 7);
  
  level1MobTypes = new MobType[3];
  level1MobTypes[0] = new MobType(mobIdle5, mobWalk5, mobAttack5, mobHurt5, mobDead5, 0.5, 4);
  level1MobTypes[1] = new MobType(mobIdle6, mobWalk6, mobAttack6, mobHurt6, mobDead6, 0.7, 9);
  level1MobTypes[2] = new MobType(mobIdle7, mobWalk7, mobAttack7, mobHurt7, mobDead7, 0.5, 2);
  
  level3MobTypes = new MobType[4];
  level3MobTypes[0] = new MobType(mobIdle1, mobWalk1, mobAttack1, mobHurt1, mobDead1, 0.5, 3);
  level3MobTypes[1] = new MobType(mobIdle2, mobWalk2, mobAttack2, mobHurt2, mobDead2, 0.7, 4);
  level3MobTypes[2] = new MobType(mobIdle3, mobWalk3, mobAttack3, mobHurt3, mobDead3, 0.5, 4);
  level3MobTypes[3] = new MobType(mobIdle4, mobWalk4, mobAttack4, mobHurt4, mobDead4, 0.3, 9);
  

}

void draw() {
  background(0);
  switch(currentState) {
  case START:
    drawStartScreen();
    break;
  case CONTROLS:
    drawControlsScreen();
    break;
  case LEVEL1:
    level1();
    break;
  case LEVEL2:
    level2();
    break;
  case LEVEL3:
    level3();
    break;
  case LEVEL4:
    level4();
    break;
  case WIN_END:
    drawWinEndScreen();
    break;
  default:
    drawLoseEndScreen();
  }
}

//draws start screen
void drawStartScreen() {
  int step = (frameCount / flickerCycleLength) % flickerStepCount;
  float brightness = (step == 1 ? 100 : step == 3 ? 50 : 255);

  tint(brightness);
  imageMode(CORNER);
  image(startupImg, 0, 0, width, height);
  noTint();
  fill(255);
  textFont(font);
  
  textSize(16);  
  textAlign(CENTER, CENTER);
  text("Press space to start", width / 2, height - 60);
 
  textSize(11);  
  text("Press c for controls", width / 2, height - 30);
}

void drawWinEndScreen() {
  background(0);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(font);
  
  fill(255, 140, 0);
  textSize(48);
  text("SHIFT OVER!", width / 2, height / 2 - 40);
  
  fill(255, 140, 0);
  textSize(36);
  text("YOU WIN", width / 2, height / 2 + 10);
  
  fill(255);
  textSize(20);
  text("Thanks for playing", width / 2, height / 2 + 60);
  text("Press 1 to restart", width / 2, height / 2 + 90);
}

void drawLoseEndScreen() {
  background(0);
  textAlign(CENTER, CENTER);
  textFont(font);

  fill(180, 20, 20);
  textSize(48);
  text("THE LIGHT FADES...", width / 2, height / 2 - 40);

  fill(180, 20, 20);
  textSize(36);
  text("YOU DIED", width / 2, height / 2 + 10);

  fill(255);
  textSize(20);
  text("Better luck next time", width / 2, height / 2 + 60);
  text("Press 1 to restart", width / 2, height / 2 + 90);
}


void drawControlsScreen() {
  background(0);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(font);
  textSize(24);
  text("Game Controls", width / 2, 80);

  textSize(16);
  textLeading(30);  // Set line spacing
  text("Move Left: A \n" + 
       "Move Right: D \n" +
       "Jump: Space\n" +
       "Shoot: Left Mouse Button\n" +
       "Restart Game: 1\n" +
       "Next Level:  2\n", width / 2, height / 2);

  textSize(14);
  text("Press 'B' to go back", width / 2, height - 40);
}

//switches state to next
void nextLevel() {
  int nextOrdinal = currentState.ordinal() + 1;
  
  if (nextOrdinal > State.LEVEL4.ordinal()) {
    currentState = State.WIN_END;
  } else {
    currentState = State.values()[nextOrdinal];
  }
  startRound();
}

//handle input
void keyPressed() {
  if (levelEndPending) return;
  
  if (currentState == State.START) {
    if (key == 'c' || key == 'C') {  
      currentState = State.CONTROLS;
    } else if (key == ' ') {
      currentState = State.LEVEL1;
      startRound();
    }
  }
  else if(currentState == State.CONTROLS) {
    if (key == 'b' || key == 'B') {  
      currentState = State.START;  
    }
  } 
  
  if ((key == '2') && (currentState != State.START && currentState != State.LOSE_END) && (currentState.ordinal() < State.LEVEL4.ordinal())) {
    nextLevel();
    startRound();
  }
  
  if (key == '1') {
    currentState = State.START;
    startRound();
  }
  
  if(!player.isDead){ 
    if (key == 'd' || key == 'D') moveRight = true;
    if (key == 'a' || key == 'A') moveLeft = true;
    if (key == ' ') player.jump();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') moveLeft = false;
  if (key == 'd' || key == 'D') moveRight = false;
}

void mousePressed() {
  if(!player.isDead){
    player.shoot();
  }
}

//spawns a pickup object
void spawnPickup(ArrayList<Pickup> list, PImage[] frames, String type) {
  Pickup p = new Pickup(0, frames, type);
  p.setRandomPosition(arenaWidth);
  list.add(p);
  
  if(type.equals("health")) {
    pickupNotification = "Health Pickup Spawned!";
  } else {
    pickupNotification = "Ammo Pickup Spawned!"; 
  }
  pickupNotificationTimer = pickupNotificationDuration;
  
}

//updates and draws pickups
void updateAndDrawPickups(ArrayList<Pickup> list, float cameraX) {
  for (int i = list.size() - 1; i >= 0; i--) {
    Pickup p = list.get(i);
    p.update();
    p.draw(cameraX);
    if (!p.collected && p.pickupCollision()) {
      if (p.type.equals("ammo")) {
        player.startReloadAnimation();
      }
      p.applyEffect(player);
      list.remove(i);
    }
  }
}

// -------------------------------------------------------------------------------------- level1 --------------------------------------------------------------------------------------------------------
void level1() {
  if (millis() < roundStartMessageEndTime) {
    roundStart();
    return;
  }

  //map
  levelBackgrounds[0].drawAllParallaxLayers(cameraX);
  currentTileSet = tileSet1;
  groundY = height - 64;
  charY = groundY - (player.spriteHeight * player.sf);
  arenaWidth = levelBackgrounds[0].arenaWidth;
  
  //tile and objects
  Tile floorTile = new Tile(currentTileSet, groundY, 32, 0, 32, 64);  
  floorTile.drawFloor(cameraX);
  
  objDrawAt(level1_objects[0], 200, cameraX, 1.5);
  objDrawAt(level1_objects[1], 1500, cameraX, 1.5);
  objDrawAt(level1_objects[2], 1000, cameraX, 1);
  objDrawAt(level1_objects[3], 300, cameraX, 1);
  objDrawAt(level1_objects[4], 200, cameraX, 1);
  objDrawAt(level1_objects[5], 900, cameraX, 1);
  objDrawAt(level1_objects[6], 1560, cameraX, 1);
  objDrawAt(level1_objects[7], 130, cameraX, 1);
  objDrawAt(level1_objects[8], 800, cameraX, 1);
  objDrawAt(level1_objects[9], 1480, cameraX, 1);
  objDrawAt(level1_objects[10], 500, cameraX, 1);

  
  if (pickupNotificationTimer > 0) {
    fill(255);
    textFont(font);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(pickupNotification, width / 2, 50); 
    pickupNotificationTimer--;
  }

  //mob spawn
  if (mobSpawnTimer > 0) mobSpawnTimer--;

  if (mobSpawnTimer <= 0) {
    mobY = groundY - (128 * 1.5);
    spawnAtEdge(mobs, level1MobTypes, mobY, arenaWidth);
    mobSpawnTimer = mobSpawnInterval;
  }

  //mob handle
  for (int i = mobs.size() - 1; i >= 0; i--) {
    Mob m = mobs.get(i);
    
    if (!player.isDead && !levelEndPending) {
      m.moveTowardsPlayer(player.x, player.spriteWidth, player.sf);
  
      if (m.playerCollision(player) && !m.isAttacking && m.attackCooldown == 0) {
        m.attack();
        m.attackCooldown = m.attackCooldownDuration;
      }
    }
    for (int bi = player.ammo.size() - 1; bi >= 0; bi--) {
      Bullet b = player.ammo.get(bi);

      // collision of bullet and mob
      if (m.canCollide() && b.bulletCollision(m)) {
        m.takeDamage(30);
        b.shouldRemove = true;
      }
    }

    m.update();


    //ensures no attack while jumped above
    float playerFeet = player.y + player.collisionY + player.collisionHeight; // lower edge of player
    float mobHead = m.y + m.collisionY; // upper edge of mob
    boolean above = playerFeet < mobHead + 10;
    if (m.isAttacking && m.currentFrame == m.attackStrikeFrame && !m.attackDamageDealt && !above) {
      player.takeDamage(30);
      m.attackDamageDealt = true;
    }
    m.draw(cameraX);

    if (m.shouldRemove) {
      killCount ++;
      mobs.remove(i);
    }
    
    if (killCount == 30 && !levelEndPending) {
      levelEndPending = true;
      levelEndFrameCounter = 0;
    }
  }

  //pickups
  if (++spawnTimerHealth >= spawnIntervalHealth) {
    spawnTimerHealth = 0;
    spawnPickup(healthPickups, healthPickup, "health");
  }
  if (++spawnTimerAmmo >= spawnIntervalAmmo) {
    spawnTimerAmmo = 0;
    spawnPickup(ammoPickups, ammoPickup, "ammo");
  }
  updateAndDrawPickups(healthPickups, cameraX);
  updateAndDrawPickups(ammoPickups, cameraX);

  //player handle
  player.setJumpStrength(-14);
  player.update(moveLeft, moveRight, charY, 7, arenaWidth);
  floorTile.tileCollision(player);
  player.updateBullets(arenaWidth);

  cameraX = constrain(player.x + player.spriteWidth/2 - width/2, 0, arenaWidth - width);
  player.draw(cameraX);
  player.drawHealthBoxUI();
  player.drawHealthBar();
  player.drawAmmoUI();
  player.drawKillUI();
  
  if (levelEndPending) {
    levelEndFrameCounter++;
    if (levelEndFrameCounter > levelEndDelayFrames) {
      nextLevel();
      levelEndPending = false;
    }
  }
}

// -------------------------------------------------------------------------------------- level2 ---------------------------------------------------------------------------------------------------------
void level2() {
  if (millis() < roundStartMessageEndTime) {
    roundStart();
    return;
  }
  
  // -- Map --
  levelBackgrounds[1].drawAllParallaxLayers(cameraX);
  currentTileSet = tileSet2;
  groundY = height - 64;
  charY = groundY - (player.spriteHeight * player.sf);
  boss1Y = groundY - (boss1.spriteHeight * boss1.sf);
  arenaWidth = levelBackgrounds[1].arenaWidth;

  // -- Tiles and Objects --
  Tile floorTop = new Tile(currentTileSet, groundY, 763, 48, 154, 16);
  Tile floorBottom = new Tile(currentTileSet, groundY + 16, 752, 96, 48, 48);
  floorTop.drawFloor(cameraX);
  floorBottom.drawFloor(cameraX);
  
  objDrawAt(level2_objects[0], 200, cameraX, 1);
  objDrawAt(level2_objects[1], 900, cameraX, 2);
  objDrawAt(level2_objects[2], 1500, cameraX, 2);
  objDrawAt(level2_objects[3], 3800, cameraX, 1);
  objDrawAt(level2_objects[4], 300, cameraX, 1);
  objDrawAt(level2_objects[5], 700, cameraX, 1);
  objDrawAt(level2_objects[6], 3000, cameraX, 1);
  objDrawAt(level2_objects[7], 2500, cameraX, 2);
  objDrawAt(level2_objects[8], 3100, cameraX, 2);
  objDrawAt(level2_objects[9], 2100, cameraX, 2);
  objDrawAt(level2_objects[10], 1300, cameraX, 1);
  objDrawAt(level2_objects[11], 1900, cameraX, 1);
  objDrawAt(level2_objects[12], 1800, cameraX, 1);
  objDrawAt(level2_objects[13], 2800, cameraX, 1);
  objDrawAt(level2_objects[14], 3500, cameraX, 2);
  
  float notificationY = 20 + emptyhealthbar.height * 2.5 + 10;
  if (pickupNotificationTimer > 0) {
    fill(255);
    textFont(font);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(pickupNotification, width / 2, notificationY); 
    pickupNotificationTimer--;
  }

  //pickups
  if (++spawnTimerHealth >= spawnIntervalHealth) {
    spawnTimerHealth = 0;
    spawnPickup(healthPickups, healthPickup, "health");
  }
  if (++spawnTimerAmmo >= spawnIntervalAmmo) {
    spawnTimerAmmo = 0;
    spawnPickup(ammoPickups, ammoPickup, "ammo");
  }
  updateAndDrawPickups(healthPickups, cameraX);
  updateAndDrawPickups(ammoPickups, cameraX);

  //player handle
  player.setJumpStrength(-18);
  player.update(moveLeft, moveRight, charY, 7, arenaWidth);
  floorTop.tileCollision(player);
  player.updateBullets(arenaWidth);

  cameraX = constrain(player.x + player.spriteWidth/2 - width/2, 0, arenaWidth - width);
  player.draw(cameraX);
  player.drawHealthBoxUI();
  player.drawHealthBar();
  player.drawAmmoUI();
  
  //boss handle
  boss1.moveTowardsPlayer(player.x, player.spriteWidth, player.sf);
  
  for (int bi = player.ammo.size() - 1; bi >= 0; bi--) {
    Bullet b = player.ammo.get(bi);
  
    // collision of bullet and mob
    if (boss1.canCollide() && b.bulletCollision(boss1)) {
      boss1.takeDamage(30);
      b.shouldRemove = true;
    }
  }
  
  boss1.update(boss1Y);
  boss1.draw(cameraX);
  boss1.drawHealthBar();
  
}

// -------------------------------------------------------------------------------------- level3 ---------------------------------------------------------------------------------------------------------
void level3() {
  if (millis() < roundStartMessageEndTime) {
    roundStart();
    return;
  }
  
  // -- Map --
  levelBackgrounds[2].drawAllParallaxLayers(cameraX);
  groundY = height - 64;
  currentTileSet = tileSet3;
  charY = groundY - (player.spriteHeight * player.sf);
  arenaWidth = levelBackgrounds[2].arenaWidth;
  
  //tile and objects
  Tile floorBottom = new Tile(currentTileSet, groundY + 47, 190, 200, 100, 24); 
  Tile floorTop = new Tile(currentTileSet, groundY - 7, 128, 17, 96, 47);
  floorBottom.drawFloor(cameraX);
  floorTop.drawFloor(cameraX);
  
  objDrawAt(level3_objects[0], 1500, cameraX, 1);
  objDrawAt(level3_objects[1], 352, cameraX, 1);
  objDrawAt(level3_objects[2], 1000, cameraX, 1);
  objDrawAt(level3_objects[3], 1700, cameraX, 2);
  objDrawAt(level3_objects[4], 100, cameraX, 2);
  objDrawAt(level3_objects[5], 800, cameraX, 2);
  objDrawAt(level3_objects[6], 1200, cameraX, 2);
  objDrawAt(level3_objects[7], 900, cameraX, 2);
  
  if (pickupNotificationTimer > 0) {
    fill(255);
    textFont(font);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(pickupNotification, width / 2, 50); 
    pickupNotificationTimer--;
  }

  //mob spawn
  if (mobSpawnTimer > 0) mobSpawnTimer--;

  if (mobSpawnTimer <= 0) {
    mobY = groundY - (128 * 1.5);
    spawnAtEdge(mobs, level3MobTypes, mobY, arenaWidth);
    mobSpawnTimer = mobSpawnInterval;
  }

  //mob handle
  for (int i = mobs.size() - 1; i >= 0; i--) {
    Mob m = mobs.get(i);
    
    if (!player.isDead && !levelEndPending) {
      m.moveTowardsPlayer(player.x, player.spriteWidth, player.sf);
  
      if (m.playerCollision(player) && !m.isAttacking && m.attackCooldown == 0) {
        m.attack();
        m.attackCooldown = m.attackCooldownDuration;
      }
    }
    for (int bi = player.ammo.size() - 1; bi >= 0; bi--) {
      Bullet b = player.ammo.get(bi);

      // collision of bullet and mob
      if (m.canCollide() && b.bulletCollision(m)) {
        m.takeDamage(30);
        b.shouldRemove = true;
      }
    }

    m.update();


    //ensures no attack while jumped above
    float playerFeet = player.y + player.collisionY + player.collisionHeight; // lower edge of player
    float mobHead = m.y + m.collisionY; // upper edge of mob
    boolean above = playerFeet < mobHead + 10;
    if (m.isAttacking && m.currentFrame == m.attackStrikeFrame && !m.attackDamageDealt && !above) {
      player.takeDamage(30);
      m.attackDamageDealt = true;
    }
    m.draw(cameraX);

    if (m.shouldRemove) {
      killCount ++;
      mobs.remove(i);
    }
    
    if (killCount == 30 && !levelEndPending) {
      levelEndPending = true;
      levelEndFrameCounter = 0;
    }
  }

  //pickups
  if (++spawnTimerHealth >= spawnIntervalHealth) {
    spawnTimerHealth = 0;
    spawnPickup(healthPickups, healthPickup, "health");
  }
  if (++spawnTimerAmmo >= spawnIntervalAmmo) {
    spawnTimerAmmo = 0;
    spawnPickup(ammoPickups, ammoPickup, "ammo");
  }
  updateAndDrawPickups(healthPickups, cameraX);
  updateAndDrawPickups(ammoPickups, cameraX);

  //player handle
  player.setJumpStrength(-14);
  player.update(moveLeft, moveRight, charY, 7, arenaWidth);
  floorTop.tileCollision(player);
  player.updateBullets(arenaWidth);

  cameraX = constrain(player.x + player.spriteWidth/2 - width/2, 0, arenaWidth - width);
  player.draw(cameraX);
  player.drawHealthBoxUI();
  player.drawHealthBar();
  player.drawAmmoUI();
  player.drawKillUI();
  
  if (levelEndPending) {
    levelEndFrameCounter++;
    if (levelEndFrameCounter > levelEndDelayFrames) {
      nextLevel();
      levelEndPending = false;
    }
  }

}
// -------------------------------------------------------------------------------------- level4 ---------------------------------------------------------------------------------------------------------
void level4() {
  if (millis() < roundStartMessageEndTime) {
    roundStart();
    return;
  }
  
  //map
  levelBackgrounds[3].drawAllParallaxLayers(cameraX);
  currentTileSet = tileSet4;
  groundY = height - 65;
  charY = groundY - (player.spriteHeight * player.sf);
  boss2Y = groundY - (boss2.spriteHeight * boss2.sf);
  arenaWidth = levelBackgrounds[3].arenaWidth;
  
  Tile floorTileTop = new Tile(currentTileSet, groundY, 336, 367, 32, 33);
  Tile floorTileBottom = new Tile(currentTileSet, height - 32, 240, 496, 32, 32);
  floorTileTop.drawFloor(cameraX);
  floorTileBottom.drawFloor(cameraX);
  
  //rock1, rock2, rock3, tree3, bush3, bush4 2-3 4-5 5-6 sawmill, furnace, tent, ore1, ore2
  objDrawAt(level4_objects[0], 0, cameraX, 1);
  objDrawAt(level4_objects[1], 1400, cameraX, 1);
  objDrawAt(level4_objects[2], arenaWidth - 571, cameraX, 1);
  objDrawAt(level4_objects[3], 2000, cameraX, 2);
  objDrawAt(level4_objects[4], 2800, cameraX, 1);
  objDrawAt(level4_objects[5], 700, cameraX, 1);
  objDrawAt(level4_objects[6], 1000, cameraX, 2);
  objDrawAt(level4_objects[7], 900, cameraX, 2);
  objDrawAt(level4_objects[8], 3400, cameraX, 1);
  objDrawAt(level4_objects[9], 1700, cameraX, 1);
  objDrawAt(level4_objects[10], 3100, cameraX, 1);
  
  float notificationY = 20 + emptyhealthbar.height * 2.5 + 10;
  if (pickupNotificationTimer > 0) {
    fill(255);
    textFont(font);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(pickupNotification, width / 2, notificationY); 
    pickupNotificationTimer--;
  }

  //pickups
  if (++spawnTimerHealth >= spawnIntervalHealth) {
    spawnTimerHealth = 0;
    spawnPickup(healthPickups, healthPickup, "health");
  }
  if (++spawnTimerAmmo >= spawnIntervalAmmo) {
    spawnTimerAmmo = 0;
    spawnPickup(ammoPickups, ammoPickup, "ammo");
  }
  updateAndDrawPickups(healthPickups, cameraX);
  updateAndDrawPickups(ammoPickups, cameraX);

  //player handle
  player.setJumpStrength(-18);
  player.update(moveLeft, moveRight, charY, 7, arenaWidth);
  floorTileTop.tileCollision(player);
  player.updateBullets(arenaWidth);

  cameraX = constrain(player.x + player.spriteWidth/2 - width/2, 0, arenaWidth - width);
  player.draw(cameraX);
  player.drawHealthBoxUI();
  player.drawHealthBar();
  player.drawAmmoUI();
  
  //boss handle
  boss2.moveTowardsPlayer(player.x, player.spriteWidth, player.sf);
  
  for (int bi = player.ammo.size() - 1; bi >= 0; bi--) {
    Bullet b = player.ammo.get(bi);
  
    // collision of bullet and mob
    if (boss2.canCollide() && b.bulletCollision(boss2)) {
      boss2.takeDamage(30);
      b.shouldRemove = true;
    }
  }
  
  boss2.update(boss2Y);
  boss2.draw(cameraX);
  boss2.drawHealthBar();

}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//draws objects at specified x and y
void objDrawAt(PImage object, float drawX, float cameraX, float scaleFactor) {
  float screenX = drawX - cameraX;
  
  tint(180);
  image(object, screenX, groundY - object.height * scaleFactor, object.width * scaleFactor, object.height * scaleFactor);
  noTint();
    
}
  
//spawn of mobs
void spawnAtEdge(ArrayList<Mob> mobList, MobType[] mobTypes, float groundY, float arenaWidth) {
  float startX;
  boolean spawnLeft = int(random(2)) == 0;
  float collisionX = 44 * 1.5;

  if (spawnLeft) {
    startX = 0 - collisionX;
  } else {
    startX = arenaWidth - (128  * 1.5f) + collisionX;
  }

  // Select random type
  int mobTypeIdx = int(random(mobTypes.length));
  MobType type = mobTypes[mobTypeIdx];

  Mob newMob = new Mob(type.idle, type.walk, type.attack, type.hurt, type.dead, startX, groundY, type.speed, type.strikeFrame);
  mobList.add(newMob);
}

//ROUND START MESSAGE
void roundStart() {
  fill(0, 200);
  rect(width/2 - 170, height/2 - 60, 340, 80, 10); // backdrop
  textFont(font);
  textSize(26);
  fill(255);
  textAlign(CENTER, CENTER);
  if (currentState == State.LEVEL2 || currentState == State.LEVEL4) {
    text("BOSS ROUND!", width/2, height/2 - 20);
  } else {
    text("Mob round!", width/2, height/2 - 20);
  }
  textSize(14);
  text("Get Ready...", width/2, height/2 + 20);
}

//RESET GAME STATE
void resetGame() {
  // Reset player state
  player.reset();
  
  // Reset boss state
  boss1.reset();
  boss2.reset();

  // Clear mobs and pickups
  mobs.clear();
  healthPickups.clear();
  ammoPickups.clear();

  // Reset timers and counters
  mobSpawnTimer = mobSpawnInterval;
  spawnTimerHealth = 0;
  spawnTimerAmmo = 0;
  mobSpawnTimer = 0;
  killCount = 0;

  moveRight = false;
  moveLeft = false;
  jumping = false;
}

//reset + roundstart
void startRound() {
  resetGame();
  roundStartMessageEndTime = millis() + 1000;
}
