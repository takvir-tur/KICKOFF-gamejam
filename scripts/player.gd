extends CharacterBody2D

# ============================================================
# PLAYER MODULE + KICKOFF DASH MODULE
# ============================================================

@export var speed: float = 200.0
@export var jump_velocity: float = -340.0
@export var gravity: float = 1200.0
@export var max_hp: int = 100
var current_hp: int = max_hp
@export var dash_speed: float = 900.0
@export var dash_time: float = 0.6
@export var dash_gravity_scale: float = 0.8  
@export var dash_angle: float = 30.0 # Launch angle in degrees
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

var is_attacking: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var trail_timer: Timer = $TrailTimer

# --- AUDIO ---
var attack_sfx: AudioStreamPlayer
var dash_sfx: AudioStreamPlayer
var jump_sfx: AudioStreamPlayer
@onready var sword_collision: CollisionShape2D = $SwordHitbox/CollisionShape2D

# UI Signals
signal kickoff_ready_changed(is_ready: bool)
signal dashed
signal kickoff_charge_started()
signal kickoff_charge_updated(needle_position: float)
signal kickoff_charge_ended()
signal died
var is_dead: bool = false


func _ready() -> void:
	add_to_group("player")
	has_kickoff = true
	$ProgressBar.max_value = max_hp
	$ProgressBar.value = current_hp
	# Auto-create the timer if it wasn't added in the editor
	if trail_timer == null:
		trail_timer = Timer.new()
		trail_timer.name = "TrailTimer"
		trail_timer.wait_time = 0.05
		trail_timer.one_shot = false
		add_child(trail_timer)
		
	kickoff_ready_changed.emit(has_kickoff)
	trail_timer.timeout.connect(_on_trail_timer_timeout)
	sprite.animation_finished.connect(_on_animation_finished)
	
	# --- Create audio players ---
	attack_sfx = AudioStreamPlayer.new()
	attack_sfx.stream = load("res://assets/Sounds/Attack/Sword Attack 1.wav")
	attack_sfx.volume_db = -5.0
	add_child(attack_sfx)
	
	dash_sfx = AudioStreamPlayer.new()
	dash_sfx.stream = load("res://assets/Sounds/Walk_run_jump/15_human_dash_1.wav")
	dash_sfx.volume_db = -5.0
	add_child(dash_sfx)
	
	jump_sfx = AudioStreamPlayer.new()
	jump_sfx.stream = load("res://assets/Sounds/Walk_run_jump/Stone Jump.wav")
	jump_sfx.volume_db = -8.0
	add_child(jump_sfx)
	
	
func _physics_process(delta: float) -> void:
	# Stamina Regeneration
	if not is_dashing and current_stamina < max_stamina:
		current_stamina = move_toward(current_stamina, max_stamina, stamina_regen_rate * delta)
		stamina_changed.emit(current_stamina, max_stamina)
		
	# State Machine
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
		velocity.y += gravity * delta

	# 2. Horizontal Movement
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		facing_direction = int(sign(input_dir))
		sprite.flip_h = facing_direction < 0
		$SwordHitbox.scale.x = facing_direction
	velocity.x = input_dir * speed

	# 3. Jump Logic with Stamina
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		if current_stamina >= jump_cost:
			current_stamina -= jump_cost
			velocity.y = jump_velocity
			jumps_left -= 1
			stamina_changed.emit(current_stamina, max_stamina)
			if jump_sfx:
				jump_sfx.play()
		else:
			print("Not enough stamina to jump!") 

	# 4. Kickoff Charge Logic with Stamina
	if Input.is_action_just_pressed("kickoff_dash") and has_kickoff:
		if current_stamina >= dash_cost:
			current_stamina -= dash_cost
			stamina_changed.emit(current_stamina, max_stamina)
			_start_charge()
		else:
			print("Not enough stamina to dash!")
			
	# --- THE ATTACK TRIGGERS ---
	if not is_attacking:
		if Input.is_action_just_pressed("attack1"):
			_start_attack("slash")
			return # Skip the rest of movement this frame
		elif Input.is_action_just_pressed("attack2"):
			_start_attack("stab")
			return # Skip the rest of movement this frame

# --- CHARGING MECHANIC ---

func _start_charge() -> void:
	is_charging_kickoff = true
	charge_timer = 0.0
	velocity.x = 0 # Lock horizontal movement while aiming
	kickoff_charge_started.emit()

func _process_charge(delta: float) -> void:
	velocity.y += gravity * delta # Player still falls while charging
	charge_timer += delta

	# Bounce the needle back and forth
	var needle_speed_multiplier = 3.0 
	var needle_pos = pingpong(charge_timer * needle_speed_multiplier, 1.0)
	
	kickoff_charge_updated.emit(needle_pos)

	# Execute if button is released OR max charge time is reached
	if Input.is_action_just_released("kickoff_dash") or charge_timer >= charge_duration:
		_execute_charged_dash(needle_pos)

func _execute_charged_dash(needle_pos: float) -> void:
	is_charging_kickoff = false
	kickoff_charge_ended.emit()
	
	# Center is 0.5. 1.0 = perfect dead center, 0.0 = terrible
	var accuracy = 1.0 - (abs(needle_pos - 0.5) * 2.0)
	
	_start_dash(accuracy)

# --- DASH EXECUTION ---

func _start_dash(accuracy: float) -> void:
	#has_kickoff = false # Enforces one dash per level
	is_dashing = true
	is_invincible = true
	
	# Dynamically scale stats based on accuracy
	var power_multiplier = lerp(0.2, 1.0, accuracy)
	var launch_power = dash_speed * power_multiplier
	
	_dash_timer = lerp(0.3, 1.2, accuracy)
	_active_dash_gravity = lerp(1.5, 0.7, accuracy)
	
	# Apply projectile math
	var angle_rad = deg_to_rad(dash_angle) 
	velocity.x = launch_power * cos(angle_rad) * facing_direction
	velocity.y = -launch_power * sin(angle_rad)
	
	trail_timer.start()
	kickoff_ready_changed.emit(has_kickoff)
	dashed.emit()
	get_tree().call_group("camera", "shake")
	if dash_sfx:
		dash_sfx.play()

func _process_dash(delta: float) -> void:
	velocity.y += gravity * _active_dash_gravity * delta
	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_end_dash()

func _end_dash() -> void:
	is_dashing = false
	is_invincible = false
	trail_timer.stop()

# --- ANIMATION & EFFECTS ---

func _update_animation() -> void:
	if is_attacking:
		return
	if is_dashing:
		sprite.play("dash")
	elif not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

# --- REPLACE YOUR EXISTING take_hit() WITH THIS ---
func take_hit(amount: int) -> void:
	if is_invincible or is_dead:
		return
		
	# 1. Subtract the damage from your current HP
	current_hp -= amount
	
	# 2. Update the health bar to show the new HP
	$ProgressBar.value = current_hp
	
	# 3. Only die if HP drops to 0 or below!
	if current_hp <= 0:
		is_dead = true
		set_physics_process(false) # Stops the player from continuing to fall or move
		
		# Tell the UI to pop up
		died.emit()

func _on_trail_timer_timeout() -> void:
	_spawn_trail_ghost()

func _spawn_trail_ghost() -> void:
	var ghost := sprite.duplicate() as AnimatedSprite2D
	get_parent().add_child(ghost)
	ghost.global_position = global_position
	ghost.flip_h = sprite.flip_h
	ghost.pause() # Freezes the animation frame for the ghost
	ghost.modulate = Color(0.4, 0.9, 1.0, 0.6)
	ghost.z_index = -1
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tw.tween_callback(ghost.queue_free)

func _start_attack(attack_anim: String) -> void:
	is_attacking = true
	velocity.x = 0 # Locks movement for deliberate combat timing
	sprite.play(attack_anim)
	# Turn the blade ON!
	sword_collision.disabled = false
	if attack_sfx:
		attack_sfx.play()

func _on_animation_finished() -> void:
	if sprite.animation == "slash" or sprite.animation == "stab":
		is_attacking = false
		# Turn the blade OFF when the swing finishes!
		sword_collision.disabled = true


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	# If the sword touches an enemy, call their take_damage function
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage()
