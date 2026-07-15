extends Area2D

# ============================================================
# GOAL MODULE   (owned by Person 3)
# ============================================================
# Scene setup ("Goal.tscn"): Area2D with a CollisionShape2D. Drop one
# into each level scene. Touching it advances to the next level via
# the GameManager autoload (see game_manager.gd) - make sure that
# autoload is set up first, or this will error.
# ============================================================

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.complete_level()
