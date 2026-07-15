# Kickoff: Shadow Burst — starter pack

Real GDScript for Godot 4.x, split across three people with the exact order
to build it in so nobody blocks anybody else.

## What's inside

```
scripts/
  player/
    player.gd          Person 1 - movement, jump, the Kickoff dash, state machine
    camera_follow.gd   Person 1 - simple smoothed camera follow
  obstacles/
    dash_obstacle.gd   Person 2 - base script every obstacle extends
    breakable_wall.gd  Person 2 - wall that breaks on a dashing hit
    spike.gd           Person 2 - kills on a normal hit, harmless on a dash hit
    switch.gd          Person 2 - fires a signal on a dashing hit
    moving_platform.gd Person 2 - simple back-and-forth platform
  autoload/
    game_manager.gd    Person 3 - timer, level flow, restart / next level
  ui/
    goal.gd            Person 3 - win detection
    kickoff_ui.gd      Person 3 - dims the "Kickoff Ready" icon after use
    timer_ui.gd        Person 3 - displays the run timer
```

One deliberate change from the original 8-module list: Dash isn't a separate
module. It lives inside `player.gd` as one more state in the same state
machine (Idle / Run / Air / Dash). For a 4-day beginner build, one file with
four clear states is far less to wire up than two files constantly signalling
each other, and it's still cleanly organized — every dash-specific function
is grouped together at the bottom of the file.

## One-time setup (do this together, ~15 minutes, before splitting up)

1. Create a new Godot 4.x project, copy the whole `scripts/` folder into it.
2. Project Settings > Input Map — add four actions: `move_left`, `move_right`,
   `jump`, `kickoff`. Suggested bindings: A/Left arrow, D/Right arrow, Space,
   Left Shift.
3. Project Settings > Autoload — add `scripts/autoload/game_manager.gd`, name
   it exactly `GameManager`, make sure it's enabled. Every other script calls
   `GameManager.something()` assuming that exact name.
4. Collision layers — pick layer 1 = "world" (floors/walls), layer 2 =
   "player." Set the Player's collision layer to 2, and every obstacle's
   Area2D collision mask to include layer 2. If you skip this, `body_entered`
   never fires and nothing will react to the player at all.

## The contract (read before writing any obstacle or UI code)

Every obstacle only ever asks one question of whatever touches it: is
`is_dashing` true on that body right now? That property, plus a small signal
set, is the entire interface `player.gd` promises the rest of the team:

- `var is_dashing: bool` — true only during the burst window
- `func die()` — call this on anything that should kill the player
- signals: `kickoff_used`, `kickoff_ready`, `dash_started`, `dash_ended`, `player_died`

Person 2 and Person 3 can write and test their scripts against this contract
before Person 1's player.gd is fully polished — as long as these names don't
change, nobody's work breaks anybody else's.

## Person 1 — player, dash, camera, animation

Build in this order:

1. Create the Player scene: `CharacterBody2D` root, `CollisionShape2D`, your
   ninja sprite (`Sprite2D` or `AnimatedSprite2D`). Attach `player.gd`.
2. Test walk + jump alone on Person 2's empty test level before touching
   anything else.
3. Test the dash: press Shift once, confirm it fires exactly once and
   `has_kickoff` doesn't refill until the scene reloads.
4. Wire your `AnimatedSprite2D` to the `state` variable (Idle/Run/Air/Dash) —
   play the matching animation whenever it changes.
5. Build the Camera2D: attach `camera_follow.gd`, drag the Player into
   "Target Path."
6. Add trail particles and camera shake, triggered off the `dash_started`
   signal.

**Push player.gd the moment step 3 works** — Person 2 and Person 3 both need
`is_dashing` to exist before their obstacles and UI mean anything.

## Person 2 — level, obstacles, level design

Build in this order:

1. Import your tileset, block out one flat test level — this is what
   Person 1 tests movement on in parallel, so talk to them on day one instead
   of working in isolation.
2. Build the `BreakableWall` scene: a `StaticBody2D` (the solid, visible
   wall) plus a child `Area2D` running `breakable_wall.gd`. Point
   `wall_body_path` and `wall_sprite_path` at the right nodes in the
   Inspector.
3. Build `Spike` (`Area2D` + `spike.gd`) — confirm it kills on a normal
   touch and does nothing while you're mid-dash.
4. Build `MovingPlatform` (`AnimatableBody2D` + `moving_platform.gd`),
   enable "Sync to Physics" in the Inspector.
5. Build `KickoffSwitch` (`Area2D` + `switch.gd`) — in the editor, connect
   its `activated` signal to whatever should open.
6. Build levels 1 through 4 using these pieces, following the progression:
   gap crossing → breakable wall → spike timing → switch trigger.

## Person 3 — UI, goal, audio, effects, menus

Build in this order:

1. Register `game_manager.gd` as the `GameManager` autoload (see setup
   above) before anything else on this list — goal.gd, kickoff_ui.gd, and
   timer_ui.gd all call it.
2. Build `Goal` (`Area2D` + `goal.gd`), place it at each level's exit.
3. Build the "Kickoff Ready" icon: a `Control` with a child `TextureRect`
   named `KickoffIcon`, script `kickoff_ui.gd`. Drag the Player into
   "Player Path" once Person 1's Player scene exists.
4. Build the timer `Label` with `timer_ui.gd` attached.
5. Build the main menu and pause menu — plain button scripts calling
   `get_tree().change_scene_to_file(...)`, nothing fancier needed.
6. Hook up SFX (jump, dash, wall break, win, death) and the victory screen,
   using `GameManager`'s `level_completed` / `level_failed` signals as your
   trigger points.

## Order across the whole team

Day 1: Person 1 gets `player.gd` working (walk, jump, dash) on Person 2's
flat test level, while Person 3 sets up the autoload and menu shells. That's
the one real dependency in this entire plan — don't start obstacle or UI code
that reads `is_dashing` until Person 1 confirms it works. Everything else
(level geometry, menus, audio hookup) runs in parallel from hour one.

## Common gotchas

- Area2D nodes never physically block anything — they only detect overlap.
  That's why `BreakableWall` needs a separate `StaticBody2D` for the actual
  solid collision.
- If `body_entered` never fires, it's almost always a collision layer/mask
  mismatch — check setup step 4.
- `player.gd` adds the Player to the `"player"` group automatically in
  `_ready()`. If `goal.gd` isn't triggering, check the Groups tab to confirm
  it's actually there.
- `GameManager` must be named exactly `GameManager` in Autoload — every
  script assumes that name.
