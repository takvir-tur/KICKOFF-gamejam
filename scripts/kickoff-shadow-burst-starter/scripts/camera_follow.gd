extends Camera2D

# ============================================================
# CAMERA MODULE   (owned by Person 1)
# ============================================================
# Add this Camera2D to the "camera" group (Node dock > Groups tab)
# so the player's dash can trigger shake() automatically.
#
# If this Camera2D is a direct child of the Player, leave target_path
# empty - it will just follow its parent for free. Only fill in
# target_path if the camera lives outside the Player scene.
# ============================================================

@export var target_path: NodePath
@export var follow_speed: float = 6.0

@onready var target: Node2D = get_node_or_null(target_path)


func _ready() -> void:
	add_to_group("camera")
	if target == null:
		target = get_parent()


func _process(delta: float) -> void:
	if target and target != get_parent():
		global_position = global_position.lerp(target.global_position, follow_speed * delta)


func shake(strength: float = 8.0, duration: float = 0.2) -> void:
	var original_offset := offset
	var tw := create_tween()
	var steps := 6
	for i in steps:
		var rand_offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tw.tween_property(self, "offset", rand_offset, duration / steps)
	tw.tween_property(self, "offset", original_offset, duration / steps)
