extends "res://scripts/obstacle_base.gd"

# ============================================================
# SWITCH   (owned by Person 2)
# ============================================================
# Scene setup ("Switch.tscn"): Area2D with a CollisionShape2D over
# the switch/lever. In the Inspector, set target_door_path to point
# at the Door node this switch should open (see door.gd).
#
# Only a DASH activates the switch - walking into it does nothing.
# That's the "burst before the exit" decision from Level 4.
# ============================================================

@export var target_door_path: NodePath

signal switch_activated


func _on_dash_hit(_body: Node) -> void:
	switch_activated.emit()
	var door := get_node_or_null(target_door_path)
	if door and door.has_method("open"):
		door.open()
	set_deferred("monitoring", false)  # can't be re-triggered
