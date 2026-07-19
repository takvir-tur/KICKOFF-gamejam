extends "res://scripts/obstacle_base.gd"

# ============================================================
# BREAKABLE WALL   (owned by Person 2)
# ============================================================
# Scene setup ("BreakableWall.tscn"):
#   BreakableWall (Area2D)      <- this script goes here
#     - CollisionShape2D         (covers the wall, detects the dash)
#     - Sprite2D                 (the wall's visual)
#     - SolidBody (StaticBody2D) (physically blocks the player)
#         - CollisionShape2D     (same size as the wall)
#
# Walking into the wall does nothing special - the StaticBody2D just
# blocks movement like a normal wall. Only a DASH breaks it.
# ============================================================

@onready var solid_body: StaticBody2D = $SolidBody
@onready var sprite: Sprite2D = $Sprite2D


func _on_dash_hit(_body: Node) -> void:
	_break()


func _break() -> void:
	# TODO (Person 2 or Person 3): swap this for a crumble animation
	# or a particle burst (Effects Module) before removing the wall.
	if solid_body:
		solid_body.queue_free()
	sprite.visible = false
	queue_free()
