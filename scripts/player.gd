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
@export var dash_time: float = 0.2
@export var dash_gravity_scale: float = 0.3  # 0 = perfectly flat dash, 1 = falls like normal

@export var max_jumps: int = 2
var jumps_left: int = max_jumps

@export var max_stamina: float = 100.0
var current_stamina: float = max_stamina
@export var stamina_regen_rate: float = 40.0 # How fast it refills per second
@export var dash_cost: float = 50.0
@export var jump_cost: float = 25.0

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
		# move_toward smoothly increases the value without going over the max
		current_stamina = move_toward(current_stamina, max_stamina, stamina_regen_rate * delta)
		stamina_changed.emit(current_stamina, max_stamina)
		
	if is_dashing:
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

	if Input.is_action_just_pressed("kickoff_dash") and has_kickoff:
		if current_stamina >= dash_cost:
			current_stamina -= dash_cost
			stamina_changed.emit(current_stamina, max_stamina)
			_start_dash()
		else:
			print("Not enough stamina to dash!")


func _start_dash() -> void:
	#has_kickoff = false
	is_dashing = true
	is_invincible = true
	_dash_timer = dash_time
	velocity.x = dash_speed * facing_direction
	# velocity.y is left as-is on purpose: dashing off a ledge or mid-jump
	# now carries whatever vertical speed you already had into the burst,
	# which (combined with the light gravity below) reads as a natural
	# leap instead of a robotic flat line. On the ground velocity.y is
	# already ~0, so a grounded dash still looks basically flat.
	trail_timer.start()
	kickoff_ready_changed.emit(has_kickoff)
	dashed.emit()
	# Camera2D nodes in the "camera" group react to this - see camera_follow.gd
	get_tree().call_group("camera", "shake")


func _process_dash(delta: float) -> void:
	velocity.y += gravity * dash_gravity_scale * delta
	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_end_dash()


func _end_dash() -> void:
	is_dashing = false
	is_invincible = false
	trail_timer.stop()


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
