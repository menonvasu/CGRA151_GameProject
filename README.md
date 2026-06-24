# 2D Side-Scrolling Zombie Survival Game

A 2D wave-based survival platformer developed in Java using the Processing library. The project features parallax background layers, modular level structures, varied enemy types, and complex multi-phase Boss AI driven by a state machine.

This project was built to demonstrate key Object-Oriented Programming (OOP) architectures, collision detection math, and real-time state management in game development.
This was a part of my final grade for my first year CGRA course.

---

## Core Architecture & Class Structure

The game is organized into modular classes to enforce separation of concerns and maintainable game-loop updates:

- **`Player`:** Manages player state (health, ammo, jumping mechanics, rendering) and controls shooting/reloads. Includes custom health UI rendering.
- **`Boss`:** A state-driven AI entity that shifts into Phase 2 when health drops below 50% (increasing speed and reducing attack cooldowns). Manages Normal, Special, and Ranged attack routines.
- **`Mob` & `MobType`:** Handles basic zombie behaviors, player tracking, and attack intervals. Leverages a design via `MobType` to load distinct sprite frames and speeds for multiple zombie archetypes.
- **`RangedAttack`:** Coordinates specialized projectile mechanics, managing directional trajectories, velocity tracking, and collision bounds.
- **`Bullet`:** Manages the player's basic projectile lifetime, movement, and boundaries.
- **`Pickup`:** Handles the procedural spawning, rendering, and collision detection of standard power-ups (Health and Ammo) across the level width.
- **`Tile`:** A modular floor component that manages segment rendering and collision boundaries.

---

## Technical Highlights

- **Multi-State Game Engine:** Driven by an `enum State` machine managing screens smoothly: `START`, `CONTROLS`, `LEVEL1`, `LEVEL2`, `LEVEL3`, `LEVEL4`, `WIN_END`, and `LOSE_END`.
- **Multi-Layer Parallax Backgrounds:** Implements real-time camera tracking (`cameraX`) relative to the player's movement, shifting multiple background layers at distinct speeds to simulate a 3D depth effect.
- **Collision Mathematics:** Implements Axis-Aligned Bounding Box (AABB) intersection math to process collisions between player bullets, enemies, and interactive pickups.
- **Procedural Spawning & Waves:** Features an interval-based spawning engine that places basic enemies on the edges of the active arena and procedurally drops supplies based on the player's current progression.

---

## How to Play

### Controls
- **Move Left:** `A`
- **Move Right:** `D`
- **Jump:** `Spacebar`
- **Shoot:** `Left Mouse Click`
- **Show Controls Screen:** `C` (from Start Screen)
- **Go Back:** `B` (from Controls Screen)
- **Restart Game:** `1`
- **Dev-Skip to Next Level:** `2`

---

## How to Run the Game

### Prerequisites
- **Processing 3 or 4 IDE** (Download from [processing.org](https://processing.org/))
- **Java JDK** (Standard bundle included with Processing)

### Launch Steps
1. Clone this repository to your computer:
   ```bash
   git clone https://github.com/menonvasu/Zombie_Survival_Game.git
   ```
2. Open the Processing IDE.
3. Select File -> Open... and select the main .pde controller file.
4. Click the Run button (the Play icon in the top left) to launch the game.
