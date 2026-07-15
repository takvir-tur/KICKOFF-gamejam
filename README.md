# 🥷 Kickoff: Lies_in_Shadow

*A fast-paced, high-momentum 2D ninja platformer built in Godot (GDScript) for a 4-day Game Jam.*

Instead of taking "Kickoff" literally as a sports term, this game treats it as the ignition of momentum. Every level begins with one decisive, powerful, physics-defying dash: **The Shadow Burst**. Your survival depends entirely on one question: *When do I kickoff my run?*

---

## 🎮 Game Concept & Mechanics

### The Core Loop

- **The Setup** — You spawn at the start of a collapsing ancient temple room. The screen reads `KICKOFF READY`.
- **The Decision** — You can run, jump, and wall-slide normally, but you have exactly **one** powerful dash (`Shift`).
- **The Kickoff** — Pressing `Shift` triggers the **Shadow Burst**: a high-velocity forward dash that breaks weak walls, crosses massive hazard gaps, and activates distant switches.
- **The Momentum** — Once used, the dash is gone for the rest of the level. You must rely on standard platforming to reach the exit portal before the room collapses (tracked by a level timer).

```
Main Menu ➔ Level Starts ➔ "KICKOFF READY" ➔ Use Dash ➔ Pure Platforming ➔ Reach Goal ➔ Next Level
```

### 🔹 "Arc-For-Free" Dash Physics

To keep development fast, lightweight, and balanced for a 4-day timeline:

- **No complex aiming or charge-up minigames.** A charge-up mechanic splits the player's focus and requires testing levels against dozens of variable distances.
- **Natural Trajectory** — Instead, the dash retains your current vertical velocity and applies a reduced gravity scale ($g_{\text{dash}} = 0.3 \times g$) during the dash duration.
- **Result** — Dashing mid-air naturally curves into a beautiful, intuitive ninja arc "for free," with no aiming UI needed.

---

## 🛠️ File Structure & Setup (Day 0)

Before anyone writes unique code, all three team members must set up the shared project to prevent merge conflicts.

### 1. Folder Directory Layout

Organize the `res://` folder exactly like this:

```
res://
├── scenes/
│   ├── player/       # Player.tscn, player.gd, camera_follow.gd
│   ├── levels/       # level_1.tscn to level_5.tscn
│   ├── obstacles/    # Spikes, BreakableWall, Switch, Door, MovingPlatform
│   └── ui/           # MainMenu.tscn, UI.tscn, VictoryScreen.tscn
├── scripts/          # The 11 GDScript scaffold files
└── assets/           # Art, SFX, and Music
```

### 2. Mandatory Input Map Bindings

Go to **Project → Project Settings → Input Map** and register these exact action names:

| Action | Bindings |
|---|---|
| `move_left` | A / Left Arrow |
| `move_right` | D / Right Arrow |
| `jump` | Space / W / Up Arrow |
| `kickoff_dash` | Shift |

### 3. Autoload Setup

Add `scripts/game_manager.gd` as an **Autoload** named `GameManager` in Project Settings. This script handles level transitions and global state.

---

## 👥 3-Person Orchestrated Task Distribution

```
                    ┌────────────────────────┐
                    │  STEP 0: JOINT SETUP   │
                    │   Inputs & Autoloads   │
                    └───────────┬────────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         ▼                      ▼                      ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│     PERSON 1     │  │     PERSON 2     │  │     PERSON 3     │
│  Player & Dash   │  │Levels & Obstacles│  │   UI & Systems   │
└────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
         │                     │                     │
         └─────────┬───────────┴───────────┬─────────┘
                   ▼                       ▼
             DAY 1 MERGE            DAY 2 MERGE
          (Player Playable)       (First Sandbox)
```

### 🥷 Person 1: Player, Dash, & Camera Movement

**Primary Scenes to Build:**
- `Player.tscn` (`CharacterBody2D` + `CollisionShape2D` + `AnimatedSprite2D` + `TrailTimer` [0.05s, one-shot])
- `Camera2D` (with `camera_follow.gd` attached)

**Key Tasks:**
- Implement basic walk, jump, and gravity loop in `player.gd`.
- Hook up the `kickoff_dash` logic. Ensure it disables `has_kickoff` and flips the `is_dashing` boolean state.
- Emit the signals `kickoff_ready_changed(bool)` and `dashed` when the kickoff is executed. (Person 3 needs these!)
- Add the player node to a node group called `"player"` so obstacles can identify it.

### 🧱 Person 2: Levels, Obstacles, & Level Design

**Primary Scenes to Build:**
- `BreakableWall.tscn`, `Spike.tscn`, `Switch.tscn`, `Door.tscn`, `MovingPlatform.tscn`
- Levels 1 through 5

**Key Tasks:**
- Study `obstacle_base.gd`. All other hazard scripts should inherit from it (`extends ObstacleBase`).
- Override `_on_dash_hit()` (e.g., break walls, flip switches) and `_on_normal_hit()` (e.g., kill player, slide off doors) in inherited scenes.
- Build levels sequentially:

| Level | Focus | Design |
|---|---|---|
| 1 | Intro | Simple movement, single gap requiring the Kickoff dash |
| 2 | Wall breaking | `BreakableWall` right in front of the goal |
| 3 | Precision | Jump over a pit, dash mid-air over a field of spikes |
| 4 | Switch & Door puzzle | Dash to trigger a distant switch that opens the path before you fall |
| 5 | The Final Gauntlet | Mix everything together |

### 🎛️ Person 3: UI, Goal, Audio, & Game States

**Primary Scenes to Build:**
- `Goal.tscn` (`Area2D` with `goal.gd` attached)
- `UI.tscn` (`CanvasLayer` containing a `TextureRect` indicator and a `Label` for the level timer)
- `MainMenu.tscn`, `PauseMenu.tscn`, `VictoryScreen.tscn`

**Key Tasks:**
- Make sure `Goal.tscn` correctly calls `GameManager.complete_level()` upon player collision.
- Implement the timer and HUD UI using `kickoff_ui.gd`. Connect the Player's `kickoff_ready_changed` signal to visual changes on the UI (like turning a UI icon gray when spent).
- Assemble SFX assets (jump, dash, wall break, victory, death) and write a simple audio manager or trigger them via code.

---

## 📅 4-Day Beginner Survival Roadmap

To complete this game in 4 days without burning out, stick strictly to this timeline:

| Day | Goal | Deliverable Checklist |
|---|---|---|
| **Day 1** | Core Sandbox | ☐ Step 0 Joint Setup complete<br>☐ Person 1 delivers a walking/jumping Player<br>☐ Person 2 sets up basic Spike and Breakable Wall scenes<br>☐ Person 3 finishes basic UI layout |
| **Day 2** | First Playable | ☐ Integration Checkpoint 1: merge Player, Obstacles, and UI<br>☐ Smoke test: can the player jump, dash through a wall, and trigger UI?<br>☐ Person 2 builds Level 1 & 2 |
| **Day 3** | Content Complete | ☐ Integration Checkpoint 2: complete Levels 3 & 4<br>☐ Person 3 connects Goal, Menus, Game Over, and Level Transition states<br>☐ Implement SFX and simple background tracks |
| **Day 4** | Polish & Publish | ☐ Design Level 5 (The Gauntlet)<br>☐ Fine-tune the physics: adjust `dash_gravity_scale` in the Inspector to feel natural<br>☐ Export templates and test the Web/Windows builds |

---

## 🎨 Art Direction Guidelines

Stick to a restrictive, high-contrast palette to keep the game visually striking but incredibly fast to produce:

| Color Element | Hex / Tone | Description |
|---|---|---|
| Backgrounds | `#0B0C10` (Dark Blue/Black) | Ancient, atmospheric, crumbling temple walls |
| Hazards | `#FF3B30` (Crimson Red) | Sharp spikes, lava pits, hot steam vents |
| Momentum Aura | `#00F5FF` (Cyan Glow) | Particle trails following the ninja during the Kickoff |
| Ambient Light | `#FF9500` (Orange) | Torches lighting up the pathways |

---

## 💡 Code Workflow Best Practices

- **Always pull before pushing** — coordinate with your team on Discord/GitHub before pushing to `main`.
- **Keep testing localized** — Person 2 can test obstacles using a dummy node with an `is_dashing = true` property before Person 1 even finishes the player script.
- **Don't touch placeholder code early** — the `TODO` blocks inside the scripts are deliberately left bare. Get the mechanical physics working perfectly first; add fancy particles, screen-shake, and sound effects only after Day 2's Integration Checkpoint is fully green!
