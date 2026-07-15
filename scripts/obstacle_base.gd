extends Area2D

# ============================================================
# OBSTACLE BASE SCRIPT   (owned by Person 2)
# ============================================================
# Don't attach this script directly to a node. Instead, make new
# scripts that start with:
#     extends "res://scripts/obstacle_base.gd"
# and override _on_dash_hit() / _on_normal_hit(). This is how
# breakable_wall.gd, spike.gd, and switch_trigger.gd all work -
# they share this one rule: "check if the player is dashing."
#
# Scene setup for ANY obstacle: an Area2D (this script or a child of
# it) with a CollisionShape2D covering its trigger zone. Make sure
# the Player is in the "player" group (player.gd already does this).
# ============================================================

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if "is_dashing" in body and body.is_dashing:
		_on_dash_hit(body)
	else:
		_on_normal_hit(body)


# Override in child script: what happens when the player DASHES into this.
func _on_dash_hit(_body: Node) -> void:
	pass


# Override in child script: what happens when the player just WALKS into this.
func _on_normal_hit(_body: Node) -> void:
	pass
