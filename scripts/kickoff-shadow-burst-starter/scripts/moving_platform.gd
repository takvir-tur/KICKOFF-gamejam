extends AnimatableBody2D

# ============================================================
# MOVING PLATFORM   (owned by Person 2)
# ============================================================
# Scene setup ("MovingPlatform.tscn"): AnimatableBody2D (Sync to
# Physics = ON) with a CollisionShape2D and Sprite2D. Not dash-related
# - just a background obstacle for level variety.
# ============================================================

@export var move_distance: Vector2 = Vector2(150, 0)
@export var move_time: float = 2.0

var _start_position: Vector2


func _ready() -> void:
	_start_position = global_position
	var tw := create_tween().set_loops()
	tw.tween_property(self, "global_position", _start_position + move_distance, move_time)\
		.set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "global_position", _start_position, move_time)\
		.set_trans(Tween.TRANS_SINE)
