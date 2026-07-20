extends CanvasLayer # <--- IMPORTANT: Change this to 'Control' if your root node is a Control node

@onready var player = get_parent() 

@onready var charge_meter_container = $ChargeMeter
@onready var background_bar = $ChargeMeter/BarBackground
@onready var needle = $ChargeMeter/BarBackground/Needle

func _ready() -> void:
	# 1. Hide the meter by default when the game starts
	charge_meter_container.visible = false
	
	# 2. Connect the UI to the Player's signals
	player.kickoff_charge_started.connect(_on_charge_started)
	player.kickoff_charge_updated.connect(_on_charge_updated)
	player.kickoff_charge_ended.connect(_on_charge_ended)
	
	# Optional: Connect this if you want to add an icon showing the dash is available
	player.kickoff_ready_changed.connect(_on_kickoff_ready_changed)

func _on_charge_started() -> void:
	# Show the meter when the player holds shift
	charge_meter_container.visible = true
	
func _on_charge_updated(needle_pos: float) -> void:
	# needle_pos is a float between 0.0 and 1.0.
	# We multiply it by the total width of the background bar to get the pixel X position.
	var total_width = background_bar.size.x
	
	var needle_offset = needle.size.x / 2.0 
	
	needle.position.x = (total_width * needle_pos) - needle_offset

func _on_charge_ended() -> void:
	# Hide the meter when the dash executes
	charge_meter_container.visible = false

func _on_kickoff_ready_changed(is_ready: bool) -> void:
	# You can use this later to hide the meter completely, 
	# or turn a "Dash Ready" UI icon gray after they use their 1 dash.
	pass
