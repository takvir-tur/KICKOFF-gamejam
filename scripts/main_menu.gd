extends Control

# ============================================================
# MAIN MENU
# ============================================================

@onready var press_any_key: Label = $PressAnyKey
@onready var button_container: VBoxContainer = $ButtonContainer
@onready var play_button: Button = $ButtonContainer/PlayButton
@onready var settings_button: Button = $ButtonContainer/SettingsButton
@onready var quit_button: Button = $ButtonContainer/QuitButton
@onready var menu_music: AudioStreamPlayer = $MenuMusic

var menu_active: bool = false
var _pulse_tween: Tween


func _ready() -> void:
	# Hide buttons initially, show "Press Any Key"
	button_container.visible = false
	button_container.modulate.a = 0.0
	press_any_key.visible = true

	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Settings button is a placeholder
	settings_button.disabled = true

	# Start pulsing animation on "Press Any Key"
	_start_pulse()

	# Play menu music
	if menu_music and not menu_music.playing:
		menu_music.play()

	# Fade in from black
	if has_node("/root/SceneTransition"):
		SceneTransition.fade_from_black()


func _unhandled_input(event: InputEvent) -> void:
	if menu_active:
		return

	# Any key/click/button press activates the menu
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			_activate_menu()
			get_viewport().set_input_as_handled()


func _activate_menu() -> void:
	menu_active = true

	# Stop pulsing and hide prompt
	if _pulse_tween:
		_pulse_tween.kill()
	press_any_key.visible = false

	# Show buttons with fade
	button_container.visible = true
	var tween = create_tween()
	tween.tween_property(button_container, "modulate:a", 1.0, 0.3)
	await tween.finished

	# Focus the Play button for keyboard navigation
	play_button.grab_focus()


func _start_pulse() -> void:
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(press_any_key, "modulate:a", 0.3, 0.8)
	_pulse_tween.tween_property(press_any_key, "modulate:a", 1.0, 0.8)


func _on_play_pressed() -> void:
	# Stop music
	if menu_music:
		menu_music.stop()

	# Transition to game
	if has_node("/root/SceneTransition"):
		SceneTransition.transition_to("res://scenes/game.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_settings_pressed() -> void:
	pass # Placeholder


func _on_quit_pressed() -> void:
	get_tree().quit()
