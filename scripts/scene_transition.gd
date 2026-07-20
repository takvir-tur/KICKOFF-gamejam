extends CanvasLayer

# ============================================================
# SCENE TRANSITION (AUTOLOAD)
# ============================================================
# SETUP: Project Settings > Autoload > add scenes/scene_transition.tscn,
# Node Name = "SceneTransition"
# ============================================================

@onready var color_rect: ColorRect = $ColorRect
var is_transitioning: bool = false


func _ready() -> void:
	layer = 100  # Always on top of everything
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func transition_to(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true

	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween.finished

	# Change scene
	get_tree().change_scene_to_file(scene_path)

	# Wait a frame for the new scene to initialize
	await get_tree().process_frame

	# Fade from black
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "color:a", 0.0, 0.5)
	await tween2.finished

	is_transitioning = false


func fade_from_black() -> void:
	color_rect.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 0.5)
	await tween.finished
