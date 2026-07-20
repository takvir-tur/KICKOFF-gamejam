extends CanvasLayer

@onready var restart_button = $VBoxContainer/RestartButton
@onready var home_button = $VBoxContainer/HomeButton

func _ready() -> void:
	hide() 
	
	# Wait for one frame so the Player has time to run its own _ready() function
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.died.connect(_on_player_died)
		print("SUCCESS: DeathScreen found the player and connected!")
	else:
		print("ERROR: DeathScreen could NOT find the player!")
		
	restart_button.pressed.connect(_on_restart_pressed)
	home_button.pressed.connect(_on_home_pressed)

func _on_player_died() -> void:
	show()
	# Optional: Pause the game so enemies/timers stop moving in the background
	get_tree().paused = true 

func _on_restart_pressed() -> void:
	get_tree().paused = false # Unpause before reloading
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().paused = false
	# IMPORTANT: Change this path to match your actual Main Menu scene file!
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
