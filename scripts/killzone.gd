extends Area2D

func _ready() -> void:
	# Connect the body_entered signal via code
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the thing that fell in is the player
	print("Something touched the killzone: ", body.name) # Add this!
	if body.is_in_group("player"):
		body.take_hit(100)
