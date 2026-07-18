extends Node

# ============================================================
# GAME MANAGER (AUTOLOAD)   (owned by Person 3)
# ============================================================
# SETUP: Project Settings > Autoload > add this script, Node Name =
# "GameManager". Set that up BEFORE anyone tests goal.gd, or level
# transitions will error with "Identifier not found: GameManager".
#
# Fill in level_scenes with the real file paths once Person 2 has
# created the level scenes (Level Module).
# ============================================================

var level_scenes: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
]

var current_level_index: int = 0
var level_start_time: float = 0.0
var best_times: Dictionary = {}


func start_level(index: int) -> void:
	current_level_index = index
	level_start_time = Time.get_ticks_msec() / 1000.0
	get_tree().change_scene_to_file(level_scenes[index])


func complete_level() -> void:
	var elapsed := (Time.get_ticks_msec() / 1000.0) - level_start_time
	if not best_times.has(current_level_index) or elapsed < best_times[current_level_index]:
		best_times[current_level_index] = elapsed

	if current_level_index + 1 < level_scenes.size():
		start_level(current_level_index + 1)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")


func restart_level() -> void:
	start_level(current_level_index)
