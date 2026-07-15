# 🥷 Kickoff: Lies_in_Shadow

Instead of taking "Kickoff" literally as a sports term, this game treats it as the ignition of momentum. Every level begins with one decisive, powerful, physics-defying dash: **The Shadow Burst**. Your survival depends entirely on one question: *When do I kickoff my run?*

---

## 📊 Status Snapshot

> Update this block as you go — it's the fastest way for any teammate to see where things stand without reading the whole doc. Check items off directly on GitHub (they render as clickable boxes) or in your editor.

**Current day:** Day _\_\__ · **Last updated by:** _\_\_\__ on _\_\_\__

- [ ] Day 0 Joint Setup complete
- [ ] Day 1 deliverables complete
- [ ] Day 2 Integration Checkpoint 1 passed
- [ ] Day 3 Integration Checkpoint 2 passed
- [ ] Day 4 build exported

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

### ✅ Day 0 Checklist

- [ ] Folder layout created
- [ ] `move_left` / `move_right` / `jump` / `kickoff_dash` bound in Input Map
- [ ] `game_manager.gd` added as Autoload named `GameManager`

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
- [ ] Basic walk, jump, and gravity loop in `player.gd`
- [ ] `kickoff_dash` logic wired up — disables `has_kickoff`, flips `is_dashing`
- [ ] Emits `kickoff_ready_changed(bool)` and `dashed` signals on kickoff (Person 3 depends on these)
- [ ] Player node added to the `"player"` group
- [ ] `camera_follow.gd` attached to Camera2D and added to `"camera"` group

### 🧱 Person 2: Levels, Obstacles, & Level Design

**Primary Scenes to Build:**
- `BreakableWall.tscn`, `Spike.tscn`, `Switch.tscn`, `Door.tscn`, `MovingPlatform.tscn`
- Levels 1 through 5

**Key Tasks:**
- [ ] All hazard scenes inherit `obstacle_base.gd` (`extends "res://scripts/obstacle_base.gd"`)
- [ ] `_on_dash_hit()` / `_on_normal_hit()` overridden per obstacle
- [ ] `BreakableWall.tscn` built (StaticBody2D solid child + Sprite2D)
- [ ] `Spike.tscn` built
- [ ] `Switch.tscn` + `Door.tscn` built and wired via `target_door_path`
- [ ] `MovingPlatform.tscn` built

**Level Build Checklist:**

| Level | Focus | Built | Playtested |
|---|---|---|---|
| 1 | Intro — single gap, forces the Kickoff | ☐ | ☐ |
| 2 | Wall breaking — `BreakableWall` guards the goal | ☐ | ☐ |
| 3 | Precision — dash mid-air over a spike field | ☐ | ☐ |
| 4 | Switch & Door — dash-triggered switch opens the path before a fall | ☐ | ☐ |
| 5 | Gauntlet — combines everything | ☐ | ☐ |

> Table cells can't be clicked on GitHub — use the task-list items above (or a commit/PR note) for anything you want live progress tracking on.

### 🎛️ Person 3: UI, Goal, Audio, & Game States

**Primary Scenes to Build:**
- `Goal.tscn` (`Area2D` with `goal.gd` attached)
- `UI.tscn` (`CanvasLayer` containing a `TextureRect` indicator and a `Label` for the level timer)
- `MainMenu.tscn`, `PauseMenu.tscn`, `VictoryScreen.tscn`

**Key Tasks:**
- [ ] `Goal.tscn` calls `GameManager.complete_level()` on player collision
- [ ] Timer + HUD implemented in `kickoff_ui.gd`
- [ ] Player's `kickoff_ready_changed` signal connected to the UI icon
- [ ] `MainMenu.tscn` built
- [ ] `PauseMenu.tscn` built
- [ ] `VictoryScreen.tscn` built
- [ ] SFX assembled (jump, dash, wall break, victory, death) and triggered via code

---

## 📅 4-Day Beginner Survival Roadmap

To complete this game in 4 days without burning out, stick strictly to this timeline. Check items off as your team clears them.

### Day 1 — Core Sandbox
- [ ] Step 0 Joint Setup complete
- [ ] Person 1 delivers a walking/jumping Player
- [ ] Person 2 sets up basic Spike and Breakable Wall scenes
- [ ] Person 3 finishes basic UI layout

### Day 2 — First Playable
- [ ] **Integration Checkpoint 1:** Player, Obstacles, and UI merged
- [ ] Smoke test passes: player can jump, dash through a wall, and trigger UI
- [ ] Person 2 builds Level 1 & 2

### Day 3 — Content Complete
- [ ] **Integration Checkpoint 2:** Levels 3 & 4 complete
- [ ] Person 3 connects Goal, Menus, Game Over, and Level Transition states
- [ ] SFX and simple background tracks implemented

### Day 4 — Polish & Publish
- [ ] Level 5 (The Gauntlet) designed
- [ ] Physics fine-tuned — `dash_gravity_scale` adjusted in the Inspector to feel natural
- [ ] Export templates configured
- [ ] Web/Windows builds tested

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
- **Keep this README's checklists current** — tick boxes off in the same commit/PR that completes the work, so the Status Snapshot at the top always reflects reality.
