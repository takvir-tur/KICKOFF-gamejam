extends "res://scripts/obstacle_base.gd"

# ============================================================
# SPIKES   (owned by Person 2)
# ============================================================
# Scene setup ("Spike.tscn"): Area2D with a CollisionShape2D over
# the spike tips. No StaticBody2D needed - spikes don't block
# movement, they just hurt on touch.
#
# Whether the player actually takes damage is decided by the
# PLAYER's own is_invincible flag (true only during an active dash),
# so this script always calls take_hit() and lets the player decide.
# That's what makes "dash through spikes safely" possible for free.
# ============================================================

func _on_dash_hit(body: Node) -> void:
	_hurt(body)


func _on_normal_hit(body: Node) -> void:
	_hurt(body)


func _hurt(body: Node) -> void:
	if body.has_method("take_hit"):
		body.take_hit()
