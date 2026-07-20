extends CanvasLayer

# Make sure this path correctly points to your Player node in the scene tree
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

func _on_charge_started() -> void:
	# Show the meter when the player holds shift
	charge_meter_container.visible = true
	
	
	
func _on_charge_updated(needle_pos: float) -> void:
	# needle_pos is a float between 0.0 and 1.0.
	# We multiply it by the total width of the background bar to get the pixel X position.
	var total_width = background_bar.size.x
	
	# FIX: Renamed 'offset' to 'needle_offset' to avoid shadowing the CanvasLayer property
	var needle_offset = needle.size.x / 2.0 
	
	needle.position.x = (total_width * needle_pos) - needle_offset

func _on_charge_ended() -> void:
	# Hide the meter when the dash executes
	charge_meter_container.visible = false
