class Player {
  int spriteWidth = 128, spriteHeight = 128; //dimensions
  float sf = 1.5;
  float collisionWidth = 28 * sf; //for collision
  float collisionHeight = 72 * sf;
  float collisionX = 44 * sf;
  float collisionY = 58 * sf;

  float x, y, vy = 0, gravity = 0.6, jumpStrength;
  boolean facingRight = true;
  boolean isShooting = false;
  boolean isReloading = false;
  boolean isHurt = false;
  boolean isDead = false;

  PImage[] idleFrames, hurtFrames, deadFrames, runFrames, jumpFrames, shootFrames, reloadFrames; //all frames
  PImage[] currentAnimationFrames;
  PImage[] previousAnimationFrames;
  PImage bulletImg;
  PImage ammoImg;
  int currentFrame = 0, frameDelay = 5, frameDelayCounter = 0;

  //for bullets
  ArrayList<Bullet> ammo; //array of bullets
  int maxAmmo = 25;
  int currentAmmo = maxAmmo;

  //for health
  int maxHealth = 100;
  int currentHealth = maxHealth;

  int postDeathTimer = -1;
  int postDeathDelay = 90;

  //construction
  Player(PImage idleImg, PImage hurtImg, PImage deadImg, PImage runImg, PImage jumpImg, PImage shootImg, PImage reloadImg, PImage bulletImg, float startX, float startY) {
    this.x = startX;
    this.y = startY;
    loadFrames(idleImg, hurtImg, deadImg, runImg, jumpImg, shootImg, reloadImg);
    currentAnimationFrames = idleFrames;

    this.bulletImg = bulletImg;
    ammo = new ArrayList<Bullet>();
  }

  //load into frames array
  void loadFrames(PImage idle, PImage hurt, PImage dead, PImage run, PImage jump, PImage shoot, PImage reload) {
    idleFrames = sliceFrames(idle, 11);
    hurtFrames = sliceFrames(hurt, 5);
    deadFrames = sliceFrames(dead, 5);
    runFrames = sliceFrames(run, 10);
    jumpFrames = sliceFrames(jump, 10);
    shootFrames = sliceFrames(shoot, 4);
    reloadFrames = sliceFrames(reload, 17);
  }

  //slices sheets to specific frames, returning an array
  PImage[] sliceFrames(PImage sheet, int count) {
    PImage[] frames = new PImage[count];
    for (int i = 0; i < count; i++) {
      frames[i] = sheet.get(i * spriteWidth, 0, spriteWidth, spriteHeight);
    }
    return frames;
  }

  void update(boolean moveLeft, boolean moveRight, float ground, float speed, float arenaWidth) {
    // Gravity
    y += vy;
    vy += gravity;
    if (y >= ground) {
      y = ground;
      vy = 0;
      jumping = false;
    }

    //move
    movement(moveLeft, moveRight, speed, arenaWidth);


    // Switch off flags at animation end if needed
    if (isHurt && currentFrame == hurtFrames.length - 1) {
      isHurt = false;
    }
    if (isReloading && currentFrame == reloadFrames.length - 1) {
      isReloading = false;
    }
    if (isShooting && !isReloading && currentFrame == shootFrames.length - 1) {
      isShooting = false;
    }



    // Animation state selection (prioritize shooting)
    if (isDead) handleDeath();
    else if (isHurt) {
      currentAnimationFrames = hurtFrames;
    } else if (isReloading) {
      currentAnimationFrames = reloadFrames;
    } else if (isShooting) {
      currentAnimationFrames = shootFrames;
    } else if (jumping) {
      currentAnimationFrames = jumpFrames;
    } else if (moveLeft || moveRight) {
      currentAnimationFrames = runFrames;
    } else {
      currentAnimationFrames = idleFrames;
    }

    // Reset frames only when animation changes
    if (currentAnimationFrames != previousAnimationFrames) {
      currentFrame = 0;
      frameDelayCounter = 0;
      previousAnimationFrames = currentAnimationFrames;
    }

    if (!isDead) {
      frameDelayCounter++;
      if (frameDelayCounter >= frameDelay) {
        currentFrame = (currentFrame + 1) % currentAnimationFrames.length;
        frameDelayCounter = 0;
      }
    }
  }

  //arena movement code
  void movement(boolean moveLeft, boolean moveRight, float speed, float arenaWidth) {
    float leftEdge = x + collisionX;
    float rightEdge = leftEdge + collisionWidth;

    if (moveRight && rightEdge < arenaWidth) {
      facingRight = true;
      x += speed;
    }
    if (moveLeft && leftEdge > 0) {
      facingRight = false;
      x -= speed;
    }
  }

  //draws player
  void draw(float cameraX) {
    pushMatrix();
    float drawX = x - cameraX;
    float scaleFactor = 1.5;

    //Highlight if health < 30
    if (currentHealth < 30) {
      tint(255, 50, 50, 220); // Reddish tint with slight transparency
    }

    //translate image if facing left
    if (!facingRight) {
      translate(drawX + spriteWidth * scaleFactor, y);
      scale(-1, 1);
      image(currentAnimationFrames[currentFrame], 0, 0, spriteWidth * scaleFactor, spriteHeight * scaleFactor);
    } else {
      image(currentAnimationFrames[currentFrame], drawX, y, spriteWidth * scaleFactor, spriteHeight * scaleFactor);
    }
    noTint();
    popMatrix();

    for (Bullet b : ammo) {
      b.draw(cameraX);
    }
  }

  void handleDeath() {
    currentAnimationFrames = deadFrames;
    if (currentFrame < currentAnimationFrames.length - 1) {
      frameDelayCounter++;
      if (frameDelayCounter >= frameDelay) {
        currentFrame++;
        frameDelayCounter = 0;
      }
    }
    if (currentFrame == currentAnimationFrames.length - 1) {
      if (postDeathTimer == -1) postDeathTimer = postDeathDelay;
      else if (postDeathTimer > 0) {
        postDeathTimer--;
        if (postDeathTimer == 0) {
          currentState = State.LOSE_END;
          return;
        }
      }
    }
  }

  //calls jump
  void jump() {
    if (!jumping) {
      jumping = true;
      vy = jumpStrength;
      currentFrame = 0;
      frameDelayCounter = 0;
    }
  }

  //calls shoot
  void shoot() {
    if (currentAmmo > 0  && !isShooting) {
      float bulletX = facingRight ? x + collisionX + collisionWidth : x + collisionX; //set bullet x pos
      float bulletY = y + collisionY + collisionHeight * 0.1; // adjust to gun tip position

      ammo.add(new Bullet(bulletImg, bulletX, bulletY, facingRight));
      currentAmmo --;
      isShooting = true;

      //animation
      currentAnimationFrames = shootFrames;
      currentFrame = 0;
      frameDelayCounter = 0;
    }
  }

  void startReloadAnimation() {
    if (!isReloading) {
      isReloading = true;
      currentAnimationFrames = reloadFrames;
      currentFrame = 0;
      frameDelayCounter = 0;
    }
  }

  //removes bullets that are past arenaWidths
  void updateBullets(float arenaWidth) {
    for (int i = ammo.size() - 1; i >= 0; i--) {
      Bullet b = ammo.get(i);
      b.update(arenaWidth);
      if (b.shouldRemove) {
        ammo.remove(i);
      }
    }
  }


  //draws ammo UI
  void drawAmmoUI() {
    float boxWidth = 120;
    float labelHeight = 15;
    float padding = 3;
    float bulletIconSize = 15;

    //calculate rows needed
    int bulletsPerRow = (int)((boxWidth - padding) / (bulletIconSize + padding));
    int rowsNeeded = (int) ceil((float) currentAmmo / bulletsPerRow);

    //calculate box height
    float boxHeight = labelHeight + padding + rowsNeeded * (bulletIconSize + padding) + padding;
    float boxX = width - boxWidth - 10;
    float boxY = 10;

    //draw box
    noStroke();
    fill(0, 200);
    rect(boxX + 2, boxY + 2, boxWidth, boxHeight, 8);  // shadow
    fill(40, 40, 40, 220);
    rect(boxX, boxY, boxWidth, boxHeight, 8);

    // draw label text
    textFont(font);
    textSize(14);
    textAlign(LEFT, TOP);
    fill(0, 150);
    text("Ammo:", boxX + padding + 1.5, boxY + padding + 2.5);
    fill(255);
    text("Ammo:", boxX + padding, boxY + padding);

    //draw bullet icons
    for (int i = 0; i < currentAmmo; i++) {
      int row = i / bulletsPerRow;
      int col = i % bulletsPerRow;
      float xPos = boxX + padding + col * (bulletIconSize + padding);
      float yPos = boxY + labelHeight + padding + row * (bulletIconSize + padding);
      image(ammoPickup[0], xPos, yPos, bulletIconSize, bulletIconSize);
    }
  }


  //player takes damage
  void takeDamage(int amount) {
    if (levelEndPending) return;
    
    currentHealth = max(0, currentHealth - amount); //prevents -ve health

    // Trigger hurt animation when damaged
    if (currentHealth == 0 && !isDead) {
      isDead = true;
      currentFrame = 0;
      frameDelayCounter = 0;
      postDeathTimer = postDeathDelay;
    } else if (!isDead) {
      isHurt = true;
      currentFrame = 0;
      frameDelayCounter = 0;
    }
  }

  //heal
  void heal(int amount) {
    currentHealth = min(maxHealth, currentHealth + amount); //prevents overheal
  }

  //reload
  void addAmmo(int amount) {
    player.currentAmmo = min(maxAmmo, currentAmmo + amount); //prevents overload of ammo
  }
  
  //jump strength setter
  void setJumpStrength(float strength) {
    this.jumpStrength = strength;
  }

  void drawHealthBar() {
    float barX = 20; // top-left position
    float barY = 25;
    int barWidth = healthBarFill.width;
    int barHeight = healthBarFill.height;

    // crop width based on current health
    float healthPercent = (float)currentHealth / maxHealth;
    int fillWidth = int(barWidth * healthPercent);

    // Crop the fill based on current health fraction
    PImage croppedFill = healthBarFill.get(0, 0, fillWidth, barHeight);

    // Draw the red fill
    image(croppedFill, barX, barY, barWidth * healthPercent, barHeight);

    // Draw the outline/frame/bar
    image(healthBarBorder, barX, barY);
    
    
    // Draw health text centered on the bar
    String healthText = currentHealth + " / " + maxHealth;
    textFont(font);
    textSize(barHeight * 0.8); 
    fill(255);  
    textAlign(CENTER, CENTER);
    text(healthText, barX + barWidth / 2 + 10, barY + barHeight / 2 + 1);
  }

  //draws a black box behind player health
  void drawHealthBoxUI() {
    float boxWidth = 120;
    float labelHeight = 15;
    float padding = 3;

    float boxX = 18;
    float boxY = 10;

    // draw the black box
    noStroke();
    fill(0, 200);
    rect(boxX + 2, boxY + 2, boxWidth, labelHeight + padding * 2 + 18, 8); // shadow

    fill(40, 40, 40, 220);
    rect(boxX, boxY, boxWidth, labelHeight + padding * 2 + 18, 8);

    // draw label text
    textFont(font);
    textSize(14);
    textAlign(LEFT, TOP);
    fill(0, 150);
    text("Health:", boxX + padding + 1.5, boxY + padding + 2.5);
    fill(255);
    text("Health:", boxX + padding, boxY + padding);
  }

  void drawKillUI() {
    float boxWidth = 90;
    float labelHeight = 15;
    float padding = 3;

    float boxX = 18;
    float healthBoxHeight = labelHeight + padding * 2 + 18;
    float gap = 8; //between healthbox and killbox
    float boxY = 10 + healthBoxHeight + gap;

    // draw the black box
    noStroke();
    fill(0, 200);
    rect(boxX + 2, boxY + 2, boxWidth, labelHeight + padding * 2, 8); // shadow

    fill(40, 40, 40, 220);
    rect(boxX, boxY, boxWidth, labelHeight + padding * 2, 8);

    // draw label text
    textFont(font);
    textSize(14);
    textAlign(LEFT, TOP);
    fill(0, 150);
    text("Kills: " + killCount, boxX + padding + 1.5, boxY + padding + 2.5);
    fill(255);
    text("Kills: " + killCount, boxX + padding, boxY + padding);
  }


  //reset player attributes
  void reset() {
    this.x = 200;
    if(isDead) {
      isDead = false;
    }
    currentAmmo = maxAmmo;
    currentHealth = maxHealth;
  }
}
