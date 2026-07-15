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

@export var speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0

@export var dash_speed: float = 900.0
@export var dash_time: float = 0.2
@export var dash_gravity_scale: float = 0.3  # 0 = perfectly flat dash, 1 = falls like normal

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
	kickoff_ready_changed.emit(has_kickoff)
	trail_timer.timeout.connect(_on_trail_timer_timeout)


func _physics_process(delta: float) -> void:
	if is_dashing:
		_process_dash(delta)
	else:
		_process_normal_movement(delta)

	move_and_slide()
	_update_animation()


func _process_normal_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		facing_direction = int(sign(input_dir))
		sprite.flip_h = facing_direction < 0
	velocity.x = input_dir * speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("kickoff_dash") and has_kickoff:
		_start_dash()


func _start_dash() -> void:
	has_kickoff = false
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
	ghost.modulate = Color(0.4, 0.9, 1.0, 0.6)
	ghost.z_index = -1
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tw.tween_callback(ghost.queue_free)
