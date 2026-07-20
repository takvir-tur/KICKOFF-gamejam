#extends CharacterBody2D
#
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -600.0
#var max_jumps := 2
#var jumps_left := max_jumps
#var isAttacking = false
#var health = 3       # Total hits they can take
#var is_dead = false
#var damage_stat = 1 
#var has_fire_power = true
#
##@export var fireball_scene : PackedScene # Drag fireball.tscn here in Inspector
##@export var fire_input := "fire" # Set this in Input Map (e.g., Key 'F')
#@onready var animated_sprite = $AnimatedSprite2D
#
##func activate_fire_power():
	##has_fire_power = true
	##damage_stat = 2 # Double damage!
	##$FireEffect.visible = true # <--- Show the fireball!
	##
	### Visual Feedback: Turn the player red
	##modulate = Color(1, 0.5, 0.5) 
	##
	### Optional: If you want to show the fireball sprite above their head
	### $FireballSprite.visible = true 
	##print("FIRE MODE ACTIVATED!")
#
#func take_damage(amount):
	#if is_dead: return # Don't hit them if they are already dead
	#
	#health -= amount
	#print("Health left: ", health) # Debugging helper
	#
	#if health <= 0:
		#die()
	#else:
		## Optional: Play a "hurt" animation here if you have one
		## animated_sprite.play("hurt")
		#pass
		#
#func die():
	#is_dead = true
	#animated_sprite.play("death")
	#
##func shoot_fireball():
	### 1. Create the fireball
	##var fireball = fireball_scene.instantiate()
	#
	## 2. Set the position (Start at player's center)
	##fireball.position = position
	##
	### 3. Set the direction based on player facing
	##if animated_sprite.flip_h == true:
		##fireball.direction = -1 # Face Left
		##fireball.get_node("AnimatedSprite2D").flip_h = true # Flip sprite too
	##else:
		##fireball.direction = 1  # Face Right
		##fireball.get_node("AnimatedSprite2D").flip_h = false
##
	### 4. Tell the fireball who shot it (so it doesn't kill us immediately)
	##fireball.shooter_ref = self
	##
	### 5. Add it to the Game World (Not as a child of the player!)
	##get_parent().add_child(fireball)
#
#func _physics_process(delta: float) -> void:
	#if is_dead:
		#return
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta * 2
	#
	## Reset jumps when touching ground
	#if is_on_floor():
		#jumps_left = max_jumps
#
	## Handle jump.
	#if Input.is_action_just_pressed("move_up") and jumps_left > 0:
		#velocity.y = JUMP_VELOCITY
		#jumps_left -= 1
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("move_left", "move_right")
	#
	#if direction > 0:
		#animated_sprite.flip_h = false
		##$AttackArea.scale.x = 1
	#elif direction < 0:
		#animated_sprite.flip_h = true
		##$AttackArea.scale.x = -1
#
	## 3. Handle Animation States
	#if isAttacking:
		#pass 
	#elif not is_on_floor():
		## PRIORITY 2: Air
		#animated_sprite.play("jump")
	#elif direction != 0:
		## PRIORITY 3: Run
		#animated_sprite.play("run")
	#else:
		## PRIORITY 4: Idle
		#animated_sprite.play("idle")
		#
	#if direction:
		#velocity.x = direction * SPEED 
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#
	##if Input.is_action_just_pressed("Attack11"):
		##animated_sprite.play("attack")
		##$AttackArea/CollisionShape2D.disabled = false
		##isAttacking = true
		##
	##if Input.is_action_just_pressed("fire1") and has_fire_power:
		##shoot_fireball()
#
	#move_and_slide()
#
##func _on_animated_sprite_2d_animation_finished():
	##if animated_sprite.animation == "attack":
		##$AttackArea/CollisionShape2D.disabled = true
		##isAttacking = false
	##if animated_sprite.animation == "death":
		##queue_free()
		##
##
##func _on_hitbox_area_entered(area: Area2D) -> void:
	##if area.is_in_group("Sword"):
		##var attacker = area.get_parent()
		##
		### Only take damage if the attacker is NOT me
		##if attacker != self:
			##take_damage(attacker.damage_stat)


#abraz
extends CharacterBody2D

# ============================================================
# PLAYER MODULE + DASH MODULE   (owned by Person 1)
# ============================================================
# Scene setup expected (build a "Player.tscn"):
#   Player (CharacterBody2D)   <- this script goes here
#     - CollisionShape2D
#     - AnimatedSprite2D        (animations: idle, run, jump, dash)
#     - TrailTimer (Timer)      (wait_time ~0.05, One Shot = OFF)
#
# The Player is added to the "player" group automatically in _ready().
# Obstacle scripts check for this group, so don't rename or skip it.
#
# Input Map actions needed (Project Settings > Input Map):
#   move_left, move_right, jump, kickoff_dash (bind kickoff_dash to Shift)
# ============================================================

@export var speed: float = 200.0
@export var jump_velocity: float = -300.0
@export var gravity: float = 1200.0

@export var dash_speed: float = 900.0
@export var dash_time: float = 0.6
@export var dash_gravity_scale: float = .8  # 0 = perfectly flat dash, 1 = falls like normal
@export var dash_angle: float = 30.0 # 30 to 45 degrees is usually a great sweet spot
var _active_dash_gravity: float = 1.0

@export var max_jumps: int = 2
var jumps_left: int = max_jumps

@export var max_stamina: float = 100.0
var current_stamina: float = max_stamina
@export var stamina_regen_rate: float = 40.0 # How fast it refills per second
@export var dash_cost: float = 50.0
@export var jump_cost: float = 25.0

@export var charge_duration: float = 3.0
var is_charging_kickoff: bool = false
var charge_timer: float = 0.0

signal stamina_changed(current_value: float, max_value: float)

var has_kickoff: bool = true
var is_dashing: bool = false
var is_invincible: bool = false
var facing_direction: int = 1

var _dash_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var trail_timer: Timer = $TrailTimer

# Person 3: connect this in the level script to update the
# "Kickoff Ready" UI icon, e.g.
#   $Player.kickoff_ready_changed.connect($UI.set_kickoff_ready)
signal kickoff_ready_changed(is_ready: bool)
signal dashed
# Signals for the UI person to connect to the progress bar
signal kickoff_charge_started()
signal kickoff_charge_updated(needle_position: float)
signal kickoff_charge_ended()


func _ready() -> void:
	add_to_group("player")
	has_kickoff = true
	
	# FIX: Auto-create the timer if it wasn't added in the editor
	if trail_timer == null:
		trail_timer = Timer.new()
		trail_timer.name = "TrailTimer"
		trail_timer.wait_time = 0.05
		trail_timer.one_shot = false
		add_child(trail_timer)
		
	kickoff_ready_changed.emit(has_kickoff)
	trail_timer.timeout.connect(_on_trail_timer_timeout)
	

func _physics_process(delta: float) -> void:
	if not is_dashing and current_stamina < max_stamina:
		current_stamina = move_toward(current_stamina, max_stamina, stamina_regen_rate * delta)
		stamina_changed.emit(current_stamina, max_stamina)
		
	# NEW STATE MACHINE
	if is_charging_kickoff:
		_process_charge(delta)
	elif is_dashing:
		_process_dash(delta)
	else:
		_process_normal_movement(delta)

	move_and_slide()
	_update_animation()


func _process_normal_movement(delta: float) -> void:
	# 1. Reset jumps when touching ground
	if is_on_floor():
		jumps_left = max_jumps
	else:
		# Only apply gravity if NOT on the floor
		velocity.y += gravity * delta

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		facing_direction = int(sign(input_dir))
		sprite.flip_h = facing_direction < 0
	velocity.x = input_dir * speed

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		if current_stamina >= jump_cost:
			current_stamina -= jump_cost
			velocity.y = jump_velocity
			jumps_left -= 1
			stamina_changed.emit(current_stamina, max_stamina)
		else:
			print("Not enough stamina to jump!") # Optional debug print

	# Replace your old kickoff_dash check with this:
	if Input.is_action_just_pressed("kickoff_dash") and has_kickoff:
		if current_stamina >= dash_cost:
			current_stamina -= dash_cost
			stamina_changed.emit(current_stamina, max_stamina)
			_start_charge()
		else:
			print("Not enough stamina to dash!")
			
# Add the parameter to the function definition
func _start_dash(accuracy: float) -> void:
	#has_kickoff = false # UNCOMMENTED: Enforces one dash per level
	is_dashing = true
	is_invincible = true
	_dash_timer = dash_time
	
	# 1. SCALE POWER: 0.2 (20% power) for bad timing, 1.0 (100% power) for perfect timing
	var power_multiplier = lerp(0.2, 1.0, accuracy)
	var launch_power = dash_speed * power_multiplier
	
	# 2. SCALE DASH TIME: 0.3 seconds for a bad jump, 1.2 seconds for a perfect jump
	_dash_timer = lerp(0.3, 1.2, accuracy)
	
	# 3. SCALE GRAVITY: 1.5 (heavy rock) for a bad jump, 0.7 (floaty heroic arc) for a perfect jump
	_active_dash_gravity = lerp(1.5, 0.7, accuracy)
	
	# Apply the projectile math
	var angle_rad = deg_to_rad(dash_angle) # Make sure you added dash_angle to your export variables!
	velocity.x = launch_power * cos(angle_rad) * facing_direction
	velocity.y = -launch_power * sin(angle_rad)
	
	trail_timer.start()
	kickoff_ready_changed.emit(has_kickoff)
	dashed.emit()
	get_tree().call_group("camera", "shake")

func _process_dash(delta: float) -> void:
	velocity.y += gravity * _active_dash_gravity * delta
	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_end_dash()


func _end_dash() -> void:
	is_dashing = false
	is_invincible = false
	trail_timer.stop()


func _start_charge() -> void:
	is_charging_kickoff = true
	charge_timer = 0.0
	velocity.x = 0 # Lock horizontal movement while aiming
	kickoff_charge_started.emit()

func _process_charge(delta: float) -> void:
	velocity.y += gravity * delta # Player still falls while charging
	charge_timer += delta

	# pingpong bounces a value between 0.0 and 1.0. 
	# Multiplying by 3.0 means the needle moves back and forth quickly.
	var needle_speed_multiplier = 3.0 
	var needle_pos = pingpong(charge_timer * needle_speed_multiplier, 1.0)
	
	kickoff_charge_updated.emit(needle_pos)

	# Execute if button is released OR 3 seconds have passed
	if Input.is_action_just_released("kickoff_dash") or charge_timer >= charge_duration:
		_execute_charged_dash(needle_pos)

func _execute_charged_dash(needle_pos: float) -> void:
	is_charging_kickoff = false
	kickoff_charge_ended.emit()
	
	# Math to calculate accuracy. Center is 0.5.
	# 1.0 = perfect dead center, 0.0 = terrible (far edges)
	var accuracy = 1.0 - (abs(needle_pos - 0.5) * 2.0)
	
	# Pass the raw accuracy to the start_dash function
	_start_dash(accuracy)

func _update_animation() -> void:
	if is_dashing:
		sprite.play("dash")
	elif not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")


# Called by obstacles (spikes, falling rocks, etc). Dash-invincibility
# is checked here, so obstacle scripts never need to know about it.
func take_hit() -> void:
	if is_invincible:
		return
	# TODO (Person 3): replace with a proper death animation + respawn.
	get_tree().reload_current_scene()


func _on_trail_timer_timeout() -> void:
	_spawn_trail_ghost()


func _spawn_trail_ghost() -> void:
	var ghost := sprite.duplicate() as AnimatedSprite2D
	get_parent().add_child(ghost)
	ghost.global_position = global_position
	ghost.flip_h = sprite.flip_h
	ghost.pause()
	ghost.modulate = Color(0.4, 0.9, 1.0, 0.6)
	ghost.z_index = -1
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tw.tween_callback(ghost.queue_free)
