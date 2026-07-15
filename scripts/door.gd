extends StaticBody2D

# ============================================================
# DOOR   (owned by Person 2)
# ============================================================
# Scene setup ("Door.tscn"): StaticBody2D with a CollisionShape2D
# and a Sprite2D. Referenced by switch_trigger.gd's target_door_path.
# ============================================================

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func open() -> void:
	collision.set_deferred("disabled", true)
	# TODO (Person 2): replace with a slide-open or fade-out animation.
	sprite.visible = false
