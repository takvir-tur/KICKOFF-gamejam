extends CanvasLayer

# ============================================================
# UI MODULE - "Kickoff Ready" indicator + timer   (owned by Person 3)
# ============================================================
# Scene setup ("UI.tscn"): a CanvasLayer with children:
#   - KickoffReadyIcon (TextureRect)   the cyan burst icon
#   - TimerLabel (Label)
#
# Wiring: after instancing Player and UI in a level scene, connect
# them in that level's script:
#   $Player.kickoff_ready_changed.connect($UI.set_kickoff_ready)
# ============================================================

@onready var kickoff_icon: TextureRect = $KickoffReadyIcon
@onready var timer_label: Label = $TimerLabel

var _elapsed: float = 0.0
var _running: bool = true


func _process(delta: float) -> void:
	if _running:
		_elapsed += delta
		timer_label.text = "%.2f" % _elapsed


func set_kickoff_ready(is_ready: bool) -> void:
	kickoff_icon.modulate.a = 1.0 if is_ready else 0.25


func stop_timer() -> void:
	_running = false
