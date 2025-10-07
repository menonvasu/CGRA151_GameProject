class Mob {
  int spriteWidth = 128, spriteHeight = 128; //dimensions
  
  float sf = 1.5;
  float collisionWidth = 28 * sf; //for collision
  float collisionHeight = 72 * sf;
  float collisionX = 44 * sf;
  float collisionY = 58 * sf;
  float x, y, speed;
  
  boolean facingRight = true;
  boolean isAttacking = false;
  boolean isHurt = false;
  boolean isDead = false;
  boolean isWalking = false;
  boolean shouldRemove = false;
  boolean attackDamageDealt = false;
  
  PImage[] idleFrames, walkFrames, attackFrames, hurtFrames, deadFrames;
  PImage[] currentAnimationFrames;
  PImage[] previousAnimationFrames;
  
  int currentFrame = 0;
  int frameDelay = 5;
  int frameDelayCounter = 0;
  
  int attackStrikeFrame;
  int attackCooldown = 0; 
  int attackCooldownDuration = 60;
  
  int maxHealth = 100;
  int currentHealth = maxHealth;
  int postDeathTimer = -1;
  int postDeathDelay = 60;
  
  // Constructor
  Mob(PImage idleImg, PImage walkImg, PImage attackImg, PImage hurtImg, PImage deadImg, float startX, float startY, float moveSpeed, int strikeFrame) {
    this.x = startX;
    this.y = startY;
    this.speed = moveSpeed;
    
    idleFrames = sliceFrames(idleImg, idleImg.width / spriteWidth);
    walkFrames = sliceFrames(walkImg, walkImg.width / spriteWidth);
    attackFrames = sliceFrames(attackImg, attackImg.width / spriteWidth);
    hurtFrames = sliceFrames(hurtImg, hurtImg.width / spriteWidth);
    deadFrames = sliceFrames(deadImg, deadImg.width / spriteWidth);
    
    currentAnimationFrames = idleFrames;
    attackStrikeFrame = strikeFrame;
  }
  
  //slice sheets to specific frames, returning an array
  PImage[] sliceFrames(PImage sheet, int count) {
    PImage[] frames = new PImage[count];
    for (int i = 0; i < count; i++) {
      frames[i] = sheet.get(i * spriteWidth, 0, spriteWidth, spriteHeight);
    }
    return frames;
  }
  
  void update() {
    //Animation state selection
    if (isDead) {
      currentAnimationFrames = deadFrames;
      
      // freeze on last frame
      if (currentFrame < currentAnimationFrames.length - 1) {
        frameDelayCounter++;
        if (frameDelayCounter >= frameDelay) {
          currentFrame++;
          frameDelayCounter = 0;
        }
      }
        
      // Start post-death timer
      if (currentFrame == currentAnimationFrames.length - 1) {
        if (postDeathTimer == -1) {
          postDeathTimer = postDeathDelay;
        } else if (postDeathTimer > 0) {
          postDeathTimer--;
          if (postDeathTimer == 0) {
            shouldRemove = true;
          }
        }
      }
      
    } else if (isHurt) {
      currentAnimationFrames = hurtFrames;
      if (currentFrame == hurtFrames.length - 1) isHurt = false;
    } else if (isAttacking) {
      currentAnimationFrames = attackFrames;
      if (currentFrame == attackFrames.length - 1) isAttacking = false;
    } else if (isWalking) {
      currentAnimationFrames = walkFrames;
    } else {
      currentAnimationFrames = idleFrames;
    }
    
    if (currentAnimationFrames != previousAnimationFrames) {
      currentFrame = 0;
      frameDelayCounter = 0;
      previousAnimationFrames = currentAnimationFrames;
    }
    
    // Update animation
    if(!isDead) {
      frameDelayCounter++;
      if (frameDelayCounter >= frameDelay) {
        currentFrame = (currentFrame + 1) % currentAnimationFrames.length;
        frameDelayCounter = 0;
      }
    }
    
    // movement
    if (isWalking) {
      if (facingRight) {
        x += speed;
      } else {
        x -= speed;
      }
    }
    
    //attack cooldown
    if (attackCooldown > 0) {
      attackCooldown--;
    }
  }
  
  void draw(float cameraX) {
    pushMatrix();
    float drawX = x - cameraX;
    float scaleFactor = sf;
    
    if (!facingRight) {
      translate(drawX + spriteWidth * scaleFactor, y);
      scale(-1, 1);
      image(currentAnimationFrames[currentFrame], 0, 0, spriteWidth * scaleFactor, spriteHeight * scaleFactor);
    } else {
      image(currentAnimationFrames[currentFrame], drawX, y, spriteWidth * scaleFactor, spriteHeight * scaleFactor);
    }
    popMatrix();
  }
  
  ///takes damage when hit
  void takeDamage(int amount) {
    currentHealth -= amount;
    if (currentHealth <= 0) {
      currentHealth = 0;
      isDead = true;
    } else {
      isHurt = true;
    }
  }
  
  //attack anim
  void attack() {
    if (!isAttacking && !isDead) {
      isAttacking = true;
      currentFrame = 0;
      frameDelayCounter = 0;
      attackDamageDealt = false;
    }
  }
  
  //walk anim
  void walk(boolean right) {
    if (!isDead && !isAttacking && !isHurt) {
      isWalking = true;
      facingRight = right;
    }
  }
  
  void stopWalking() {
    isWalking = false;
  }
  
  //moves towards the players position
  void moveTowardsPlayer(float playerX, float playerWidth, float playerScale) {
    if (isDead) return;
  
    float mobCenterX = x + collisionX + collisionWidth / 2;
    float playerCenterX = playerX + (playerWidth * playerScale) / 2;
    
    float tolerance = 5; //stops near player
    
    float attackPad = 25;
  
    if (mobCenterX < playerCenterX - tolerance - attackPad) {
      facingRight = true;
      x += speed;
      isWalking = true;
    } else if (mobCenterX > playerCenterX + tolerance + attackPad) {
      facingRight = false;
      x -= speed;
      isWalking = true;
    } else {
      isWalking = false;
    }
  }
  
  //removes collision if dead
  boolean canCollide() {
    if (isDead && currentAnimationFrames == deadFrames && currentFrame == deadFrames.length - 1) {
        return false;
    }
    return true;
  }
  
  //collision with player 
  boolean playerCollision(Player player){
    float playerAbsX = player.x + player.collisionX;
    float playerAbsY = player.y + player.collisionY;
    
    float mobAbsX = this.x + collisionX;
    float mobAbsY = this.y + collisionY;
    
    return playerAbsX < mobAbsX + collisionWidth && 
      playerAbsX + player.collisionWidth > mobAbsX &&
      playerAbsY < mobAbsY + collisionHeight &&
      playerAbsY + player.collisionHeight > mobAbsY;
  }
}
