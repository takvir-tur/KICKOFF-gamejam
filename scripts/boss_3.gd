extends CharacterBody2D

# ==========================================
# BOSS AI & COMBAT SCRIPT
# ==========================================
@export var detection_range: float = 400.0
@export var max_hp: int = 20
var current_hp: int = max_hp
@export var max_poise: int = 4 
var current_poise: int = max_poise
@export var speed: float = 120.0
@export var gravity: float = 1200.0
@export var jump_velocity: float = -400.0
@export var attack_range: float = 70.0 # How close they need to be to swing
@export var attack_cooldown_max: float = 1.5 # Time to wait between attacks
@export var spell_scene: PackedScene # The spell projectile to instantiate when casting

var attack_cooldown: float = 0.0
var is_attacking: bool = false
var is_hurt: bool = false
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
var player: Node2D = null

signal boss_defeated

func _ready() -> void:
	# Add to enemy group so the player's sword can find it
	add_to_group("enemy")
	# Tell the bar what its maximum size should be
	$ProgressBar.max_value = max_hp
	$ProgressBar.value = current_hp
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	
	# Ensure the boss's sword is turned off by default
	hitbox_collision.disabled = true
	
	# Connect signals automatically via code
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	# --- FIX 1: SAFETY CHECK FOR PLAYER ---
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Stop all AI logic if dead, hurt, or mid-attack
	if is_dead or is_hurt or is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# 3. Reduce the attack cooldown timer
	if attack_cooldown > 0:
		attack_cooldown -= delta

	# 4. Chase and Attack AI
	if player:
		var distance = global_position.distance_to(player.global_position)
		var direction = sign(player.global_position.x - global_position.x)
		
		# --- NEW DETECTION CHECK ---
		if distance <= detection_range:
		# Flip the boss, hitbox, AND BOTH RayCasts to face the player
		# Flip the boss, hitbox, AND BOTH RayCasts to face the player
			if direction != 0:
				sprite.flip_h = direction > 0
				$Hitbox.scale.x = -direction
				
				# Move the starting positions of the lasers
				$LedgeCheck.position.x = -20 * direction
				$LandingCheck.position.x = -120 * direction 
				
				# --- THE FIX: Flip the angle of the LedgeCheck laser! ---
				$LedgeCheck.target_position.x = -30 * direction

			# Decide whether to attack or move
			if distance <= attack_range and attack_cooldown <= 0:
				_start_attack()
			elif distance > attack_range:
				velocity.x = direction * speed
				
				# --- THE SMART GAP LOGIC ---
				if is_on_floor() and not $LedgeCheck.is_colliding():
					# The floor just dropped off! Check if we can land safely.
					if $LandingCheck.is_colliding():
						
						# Ask the laser WHAT it is touching
						var landing_surface = $LandingCheck.get_collider()
						# If it exists and has the nametag "moving_platform", DO NOT JUMP
						if landing_surface != null and ("Platform" in landing_surface.name or landing_surface.is_in_group("player")):
							velocity.x = 0 
						else:
							# It is normal, static ground. Safe to jump!
							velocity.y = jump_velocity
					else:
						# The second laser sees NOTHING. It's a massive pit. Hit the brakes!
						velocity.x = 0
		else:
			velocity.x = 0
			
		# 5. --- ANIMATION UPDATES ---
		if not is_attacking:
			if abs(velocity.x) > 10: 
				sprite.play("run")
			else:
				sprite.play("idle")

	move_and_slide()


# --- COMBAT ACTIONS ---

func _start_attack() -> void:
	is_attacking = true
	velocity.x = 0 # Commit to the attack, stop moving
	
	# Randomly choose between the melee attack and the spell
	var attacks = ["attack1", "spell"]
	var chosen_attack = attacks[randi() % attacks.size()]
	
	sprite.play(chosen_attack)


func cast_spell() -> void:
	if spell_scene == null:
		return
		
	var spell = spell_scene.instantiate()
	get_tree().current_scene.add_child(spell)
	
	# Position the spell slightly in front of the boss, based on facing direction
	var facing_direction = $Hitbox.scale.x
	spell.global_position = global_position + Vector2(40 * facing_direction, 0)


func take_damage() -> void:
	# I-frames apply if they are ALREADY stunned or dead
	if is_dead or is_hurt:
		return
		
	current_hp -= 1
	current_poise -= 1
	
	$ProgressBar.value = current_hp
	
	if current_hp <= 0:
		print("Boss Defeated!")
		boss_defeated.emit()
		_die()
		return

	# Only interrupt the boss if their posture breaks!
	if current_poise <= 0:
		is_hurt = true
		is_attacking = false # <--- MOVED THIS INSIDE THE STUN BLOCK
		hitbox_collision.set_deferred("disabled", true) 
		sprite.play("take_hit") 
		
		# Reset the poise meter
		current_poise = max_poise 
	else:
		# SUPER ARMOR: The boss takes damage but powers through to keep attacking!
		pass


func _die() -> void:
	is_dead = true
	velocity.x = 0
	sprite.play("death")
	
	# Remove the boss from the enemy group so the sword stops hitting the corpse
	remove_from_group("enemy")
	
	# (Notice we removed the line that disables the main CollisionShape2D
	# so gravity doesn't pull the boss through the floor!)


# --- SIGNAL CONNECTIONS ---

func _on_animation_finished() -> void:
	if sprite.animation == "death":
		return # Stay dead, don't reset state
		
	if sprite.animation == "take_hit":
		is_hurt = false
		
	if sprite.animation == "attack1" or sprite.animation == "spell":
		is_attacking = false
		attack_cooldown = attack_cooldown_max # Start the cooldown timer
		hitbox_collision.disabled = true # Ensure blade turns off


func _on_frame_changed() -> void:
	if not is_attacking:
		return
		
	# Update these frame numbers to match exactly when the boss swings their weapon!
	if sprite.animation == "attack1":
		if sprite.frame == 4: # Replace X with your Turn ON frame number
			hitbox_collision.disabled = false
		elif sprite.frame == 5: # Replace Y with your Turn OFF frame number
			hitbox_collision.disabled = true
			
	elif sprite.animation == "spell":
		if sprite.frame == 3:
			cast_spell()


func _on_hitbox_body_entered(body: Node2D) -> void:
	# If the boss's attack touches the player, hurt the player
	if body.is_in_group("player"):
		if body.has_method("take_hit"):
			body.take_hit(20)
