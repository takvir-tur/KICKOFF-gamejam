extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -350.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Gravity
	if !is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# Move player
	move_and_slide()

	# --------------------
	# Animations
	# --------------------

	if !is_on_floor():
		play_animation("jump")

	elif direction != 0:
		play_animation("run")

	else:
		play_animation("idle")


func play_animation(anim_name: String):
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)
