extends Node2D

# ============================================================
# DIEGETIC TUTORIAL SIGN
# ============================================================
# Drop into any level. Set action_text and key_text in the Inspector.
# Labels fade in when the player enters the detection area.

@export var action_text: String = "MOVE"
@export var key_text: String = "A / D"

@onready var action_label: Label = $ActionLabel
@onready var key_label: Label = $KeyLabel
@onready var area: Area2D = $Area2D

var _tween: Tween


func _ready() -> void:
	action_label.text = action_text
	key_label.text = key_text
	action_label.modulate.a = 0.0
	key_label.modulate.a = 0.0

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_fade_labels(1.0)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_fade_labels(0.0)


func _fade_labels(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(action_label, "modulate:a", target_alpha, 0.3)
	_tween.tween_property(key_label, "modulate:a", target_alpha, 0.3)
