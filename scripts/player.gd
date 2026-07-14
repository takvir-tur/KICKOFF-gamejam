extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var max_jumps := 2
var jumps_left := max_jumps
var isAttacking = false
var health = 3       # Total hits they can take
var is_dead = false
var damage_stat = 1 
var has_fire_power = true

#@export var fireball_scene : PackedScene # Drag fireball.tscn here in Inspector
#@export var fire_input := "fire" # Set this in Input Map (e.g., Key 'F')
@onready var animated_sprite = $AnimatedSprite2D

#func activate_fire_power():
	#has_fire_power = true
	#damage_stat = 2 # Double damage!
	#$FireEffect.visible = true # <--- Show the fireball!
	#
	## Visual Feedback: Turn the player red
	#modulate = Color(1, 0.5, 0.5) 
	#
	## Optional: If you want to show the fireball sprite above their head
	## $FireballSprite.visible = true 
	#print("FIRE MODE ACTIVATED!")

func take_damage(amount):
	if is_dead: return # Don't hit them if they are already dead
	
	health -= amount
	print("Health left: ", health) # Debugging helper
	
	if health <= 0:
		die()
	else:
		# Optional: Play a "hurt" animation here if you have one
		# animated_sprite.play("hurt")
		pass
		
func die():
	is_dead = true
	animated_sprite.play("death")
	
#func shoot_fireball():
	## 1. Create the fireball
	#var fireball = fireball_scene.instantiate()
	
	# 2. Set the position (Start at player's center)
	#fireball.position = position
	#
	## 3. Set the direction based on player facing
	#if animated_sprite.flip_h == true:
		#fireball.direction = -1 # Face Left
		#fireball.get_node("AnimatedSprite2D").flip_h = true # Flip sprite too
	#else:
		#fireball.direction = 1  # Face Right
		#fireball.get_node("AnimatedSprite2D").flip_h = false
#
	## 4. Tell the fireball who shot it (so it doesn't kill us immediately)
	#fireball.shooter_ref = self
	#
	## 5. Add it to the Game World (Not as a child of the player!)
	#get_parent().add_child(fireball)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
	
	# Reset jumps when touching ground
	if is_on_floor():
		jumps_left = max_jumps

	# Handle jump.
	if Input.is_action_just_pressed("move_up") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
		#$AttackArea.scale.x = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		#$AttackArea.scale.x = -1

	# 3. Handle Animation States
	if isAttacking:
		pass 
	elif not is_on_floor():
		# PRIORITY 2: Air
		animated_sprite.play("jump")
	elif direction != 0:
		# PRIORITY 3: Run
		animated_sprite.play("run")
	else:
		# PRIORITY 4: Idle
		animated_sprite.play("idle")
		
	if direction:
		velocity.x = direction * SPEED 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#if Input.is_action_just_pressed("Attack11"):
		#animated_sprite.play("attack")
		#$AttackArea/CollisionShape2D.disabled = false
		#isAttacking = true
		#
	#if Input.is_action_just_pressed("fire1") and has_fire_power:
		#shoot_fireball()

	move_and_slide()

#func _on_animated_sprite_2d_animation_finished():
	#if animated_sprite.animation == "attack":
		#$AttackArea/CollisionShape2D.disabled = true
		#isAttacking = false
	#if animated_sprite.animation == "death":
		#queue_free()
		#
#
#func _on_hitbox_area_entered(area: Area2D) -> void:
	#if area.is_in_group("Sword"):
		#var attacker = area.get_parent()
		#
		## Only take damage if the attacker is NOT me
		#if attacker != self:
			#take_damage(attacker.damage_stat)
