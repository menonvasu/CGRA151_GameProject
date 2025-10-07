enum BossType {
  BOSS1,
  BOSS2
}

enum AttackType {
  NONE, NORMAL, SPECIAL, RANGED
}

class Boss {
  BossType type;
  // --- Dimensions and Position ---
  int spriteWidth = 128, spriteHeight = 128; 
  float sf = 2.4;
  
  //for collision
  float collisionWidth = 30 * sf; 
  float collisionHeight = 67 * sf;
  float collisionX = 35 * sf;
  float collisionY = 61 * sf;
  
  float x, y, speed, vy = 0, gravity = 0.6, jumpStrength = -15;
  
  // --- Attack Parameters ---
  AttackType currentAttack = AttackType.NONE;
  RangedAttack rangedAttack = null;
  float specialAttackRange = 180; 
  
  // --- State ---  
  boolean facingRight = true;
  boolean isHurt = false;
  boolean isDead = false;
  boolean isWalking = false;
  boolean isAttacking = false;
  boolean rangedAttackPreparing = false;
  boolean attackDamageDealt = false;
  boolean jumping = false;
  int jumpInterval = 600;
  int jumpTimer = jumpInterval;

  int phase = 0;     
  int currentFrame = 0;
  int frameDelay = 5;
  int frameDelayCounter = 0;
  int normalAttackStrikeFrame;
  int specialAttackStrikeFrame;

  int attackCooldown = 40;
  int attackCooldownDuration = 90;

  int specialAttackCooldown = 280;
  int specialAttackCooldownDuration = 360;
  
  int rangedAttackCooldown = 390;
  int rangedAttackCooldownDuration = 480;
  
  int flashDuration = 10;  // frames to stay red
  int flashTimer = 0;

  int maxHealth = 2000;
  int currentHealth = maxHealth;
  int postDeathTimer = -1;
  int postDeathDelay = 90;
  
  // --- Animation ---
  PImage[] idleFrames, walkFrames, attackFrames, hurtFrames, deadFrames, specialAttackFrames, rangedPrepFrames, jumpFrames;
  PImage[] currentAnimationFrames;
  PImage[] previousAnimationFrames;
  PImage rangedAttackImg;

  // --- Constructor ---
  Boss( BossType type, PImage idleImg, PImage walkImg, PImage jumpImg, PImage attackImg, PImage hurtImg, PImage deadImg, PImage specialImg, PImage rangedPrepImg, PImage rangedAttackImg, float startX, float startY, float moveSpeed, int normalStrikeFrame, int specialStrikeFrame) {
    this.type = type;
    this.x = startX;
    this.y = startY; 
    this.rangedAttackImg = rangedAttackImg;
    this.speed = moveSpeed;

    idleFrames = sliceFrames(idleImg, idleImg.width / spriteWidth);
    walkFrames = sliceFrames(walkImg, walkImg.width / spriteWidth);
    jumpFrames = sliceFrames(jumpImg, jumpImg.width / spriteWidth);
    attackFrames = sliceFrames(attackImg, attackImg.width / spriteWidth);
    hurtFrames = sliceFrames(hurtImg, hurtImg.width / spriteWidth);
    deadFrames = sliceFrames(deadImg, deadImg.width / spriteWidth);
    specialAttackFrames = sliceFrames(specialImg, specialImg.width / spriteWidth);
    rangedPrepFrames = sliceFrames(rangedPrepImg, rangedPrepImg.width / spriteWidth);
    
    

    currentAnimationFrames = idleFrames;
    normalAttackStrikeFrame = normalStrikeFrame;
    specialAttackStrikeFrame = specialStrikeFrame;
  }

    //slices sheet into number of frams and passes into array
  PImage[] sliceFrames(PImage sheet, int count) {
    PImage[] frames = new PImage[count];
    for (int i = 0; i < count; i++) {
      frames[i] = sheet.get(i * spriteWidth, 0, spriteWidth, spriteHeight);
    }
    return frames;
  }

  // -- Update Logic --
  void update(float ground) {
    // Gravity and Movement
    y += vy;
    vy += gravity;
    if (y >= ground) {
      y = ground;
      vy = 0;
      jumping = false;
    }

    jumpTimer--;
    if (jumpTimer <= 0) {
      jump();
      jumpTimer = jumpInterval;
    }

    // Animation Priority: Dead > Hurt > Attacking > Jumping > Walking > Idle
    if (isDead) handleDeath();
    else if (isHurt) handleHurt();
    else if (isAttacking) handleAttack();
    else if (jumping) currentAnimationFrames = jumpFrames;
    else if (isWalking) currentAnimationFrames = walkFrames;
    else currentAnimationFrames = idleFrames;

    updateAnimation();

    if ((isWalking || jumping) && !isHurt) move();

    // Phase logic
    if (currentHealth < maxHealth / 2 && phase == 0) {
      phase = 1;
      speed += 1.5;
      attackCooldownDuration -= 20;
      specialAttackCooldownDuration -= 20;
      rangedAttackCooldownDuration -= 20;
    }

    handleCooldowns();
    
    if (rangedAttack != null) {
      rangedAttack.update(arenaWidth);
      
      if (rangedAttack.rangedCollision(player) && !rangedAttack.hitPlayer) {
        player.takeDamage(30);
        rangedAttack.hitPlayer = true;  
        rangedAttack.x = player.x + player.collisionX + player.collisionWidth / 2 - (rangedAttack.drawWidth / 2);
      }
      
      if (rangedAttack.shouldRemove) {
        rangedAttack = null;
      }
    }
    
    resetAnimationIfChanged();
  }

  // --- Animation Handlers ---
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
          nextLevel();
          return;
        }
      }
    }
  }

  void handleHurt() {
    currentAnimationFrames = hurtFrames;
    if (currentFrame == hurtFrames.length - 1) { 
      isHurt = false;
      if (isWalking) currentAnimationFrames = walkFrames;
      else currentAnimationFrames = idleFrames;
      currentFrame = 0;    
      frameDelayCounter = 0;
    }
  }

  void handleAttack() {
    switch (currentAttack) {
    case NORMAL:
      currentAnimationFrames = attackFrames;
      if (currentFrame == normalAttackStrikeFrame && !attackDamageDealt && !playerIsAbove()) {
        player.takeDamage(30);
        attackDamageDealt = true;
      }
      if (currentFrame == attackFrames.length - 1) {
        currentAttack = AttackType.NONE;
        isAttacking = false;
      }
      break;

    case SPECIAL:
      currentAnimationFrames = specialAttackFrames;
      if (currentFrame == specialAttackStrikeFrame && !attackDamageDealt
        && inSpecialRange() && !playerIsAbove()) {
        player.takeDamage(30);
        attackDamageDealt = true;
      }
      if (currentFrame == specialAttackFrames.length - 1) {
        currentAttack = AttackType.NONE;
        isAttacking = false;
      }
      break;
    
    case RANGED:
      currentAnimationFrames = rangedPrepFrames;
      if (currentFrame == rangedPrepFrames.length - 1) {
        
        if (rangedAttack == null) {
          shootRangedProjectile();
        }
        
        currentAttack = AttackType.NONE;
        isAttacking = false;
      }  
      break;
    
    default:
      break;
    }
  }
  
  void updateAnimation() {
    if (!isDead) {
      frameDelayCounter++;
      if (frameDelayCounter >= frameDelay) {
        currentFrame = (currentFrame + 1) % currentAnimationFrames.length;
        frameDelayCounter = 0;
      }
    }
  }

  void move() {
    if (facingRight) x += speed;
    else x -= speed;
  }

  void handleCooldowns() {
    if (attackCooldown > 0) attackCooldown--;
    else if (playerCollision(player) && !isAttacking) {
      isHurt = false;
      triggerAttack(AttackType.NORMAL);
      attackCooldown = attackCooldownDuration;
    }

    if (specialAttackCooldown > 0) specialAttackCooldown--;
    else if (!isAttacking && !isDead) {
      isHurt = false;
      triggerAttack(AttackType.SPECIAL);
      specialAttackCooldown = specialAttackCooldownDuration;
    }
    
    if (rangedAttackCooldown > 0) rangedAttackCooldown--;
    else if (!isAttacking && !isDead && rangedAttack == null) {
      isHurt = false;
      shootRanged();
      rangedAttackCooldown = rangedAttackCooldownDuration;
    }
    
    if (flashTimer > 0) {
      flashTimer--;
    }
  }

  void resetAnimationIfChanged() {
    if (currentAnimationFrames != previousAnimationFrames) {
      currentFrame = 0;
      frameDelayCounter = 0;
      previousAnimationFrames = currentAnimationFrames;
    }
  }

  // --- Player Damage Conditions ---
  boolean playerIsAbove() {
    float playerFeet = player.y + player.collisionY + player.collisionHeight;
    float bossHead = y + collisionY;
    return playerFeet < bossHead + 10;
  }

  boolean inSpecialRange() {
    float bossCenterX = x + collisionX + collisionWidth / 2;
    float playerCenterX = player.x + player.collisionX + player.collisionWidth / 2;
    return abs(bossCenterX - playerCenterX) <= specialAttackRange;
  }
  
  // --- Drawing ---
  void draw(float cameraX) {
    pushMatrix();
    float drawX = x - cameraX;
    float scaleFactor = sf;
    
    
    if (flashTimer > 0) {
      tint(150, 50, 50);
    } else {
      noTint();
    }    
  
    if (!facingRight) {
      translate(drawX + spriteWidth * scaleFactor, y);
      scale(-1, 1);
      image(currentAnimationFrames[currentFrame], 0, 0, spriteWidth * scaleFactor, spriteHeight * scaleFactor);
    } else {
      image(currentAnimationFrames[currentFrame], drawX, y, spriteWidth * scaleFactor, spriteHeight * scaleFactor);
    }
    
    noTint();
    popMatrix();
    
    if (rangedAttack != null) {
      rangedAttack.draw(cameraX);
    }
  }

  // --- State Control ---
  void takeDamage(int amount) {
    currentHealth = max(0, currentHealth - amount);
    if (currentHealth == 0 && !isDead) {
      currentHealth = 0;
      isDead = true;
    } else {
      flashTimer = flashDuration;
      if(!isAttacking) {
        isHurt = true;
      }
    }
  }

  void triggerAttack(AttackType type) {
    if (!isAttacking && !isDead) {
      isAttacking = true;
      currentAttack = type;
      currentFrame = 0;
      frameDelayCounter = 0;
      attackDamageDealt = false;
    }
  }
  
  //shoots ranged projectile
  void shootRangedProjectile() {
    float rangedX = facingRight ? x + collisionX + collisionWidth : x + collisionX;
    float rangedY = y + collisionY + collisionHeight * 0.2;
  
    if (type == BossType.BOSS1) {
      rangedAttack = new RangedAttack(rangedAttackImg, rangedX, rangedY, 64, 64, facingRight, player, 7, 7);
    } else if (type == BossType.BOSS2) {
      rangedAttack = new RangedAttack(rangedAttackImg, rangedX, rangedY, 95, 32, facingRight, player, 4, 4);
    }
  }
  
  //plays ranged attack animation
  void shootRanged() {
    if (!isDead && !isAttacking && rangedAttack == null) {
        triggerAttack(AttackType.RANGED);
    }
  }


  void walk(boolean right) {
    if (!isDead && !isAttacking && !isHurt) {
      isWalking = true;
      facingRight = right;
    }
  }

  void stopWalking() {
    isWalking = false;
  }

  void jump() {
    if (!jumping && !isDead) {
      vy = jumpStrength;
      jumping = true;
    }
  }



  void moveTowardsPlayer(float playerX, float playerWidth, float playerScale) {
    if (isDead) return;

    float bossCenterX = x + collisionX + collisionWidth / 2;
    float playerCenterX = playerX + (playerWidth * playerScale) / 2;

    float tolerance = 2;
    float attackPad = 10;

    if (bossCenterX < playerCenterX - tolerance - attackPad) {
      facingRight = true;
      x += speed;
      isWalking = true;
    } else if (bossCenterX > playerCenterX + tolerance + attackPad) {
      facingRight = false;
      x -= speed;
      isWalking = true;
    } else {
      isWalking = false;
    }
  }
  
  void drawHealthBar() {
    float barWidth = emptyhealthbar.width * 2.5;  
    float barHeight = emptyhealthbar.height * 2.5; 
    float barX = width / 2 - barWidth / 2; 
    float barY = 20;  
  
    
    float healthPercent = (float) currentHealth / maxHealth;
    int fillWidth = (int) (barWidth * healthPercent);
    
     // Health text 
    String healthDisplay = currentHealth + " / " + maxHealth;
  
    // Crop the fill image scaled
    PImage croppedFill = health.get(0, 0, (int)(health.width * healthPercent), health.height);
  
    
    image(emptyhealthbar, barX, barY, barWidth, barHeight);
    image(nohealth, barX, barY, barWidth, barHeight);
    image(croppedFill, barX, barY, fillWidth, barHeight);
    
    textFont(font);                    
    textSize(barHeight * 0.4);         
    fill(255);                          
    textAlign(CENTER, CENTER);         
    text(healthDisplay, barX + barWidth / 2, barY + barHeight / 2);
  }


  // --- Collision ---
  boolean canCollide() {
    if (isDead && currentAnimationFrames == deadFrames && currentFrame == deadFrames.length - 1) {
      return false;
    }
    return true;
  }
 
  boolean playerCollision(Player player) {
    float playerAbsX = player.x + player.collisionX;
    float playerAbsY = player.y + player.collisionY;

    float bossAbsX = this.x + collisionX;
    float bossAbsY = this.y + collisionY;

    return playerAbsX < bossAbsX + collisionWidth &&
      playerAbsX + player.collisionWidth > bossAbsX &&
      playerAbsY < bossAbsY + collisionHeight &&
      playerAbsY + player.collisionHeight > bossAbsY;
  }
  
  //reset boss attributes
  void reset() {
    this.x = 800;
    
    isDead = false;
    isHurt = false;
    isAttacking = false;
    isWalking = false;
    rangedAttackPreparing = false;
    attackDamageDealt = false;
    jumping = false;
    
    currentHealth = maxHealth;
    
    phase = 0;
    speed = 1;
    attackCooldownDuration = 90;
    specialAttackCooldownDuration = 360;
    rangedAttackCooldownDuration = 480;
    
    currentAttack = AttackType.NONE;
    
    currentFrame = 0;
    frameDelayCounter = 0;
    attackCooldown = attackCooldownDuration;
    specialAttackCooldown = specialAttackCooldownDuration;
    rangedAttackCooldown = rangedAttackCooldownDuration;
    postDeathTimer = -1;
    
    currentAnimationFrames = idleFrames;
    previousAnimationFrames = idleFrames;
  }
}
