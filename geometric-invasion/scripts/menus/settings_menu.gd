extends Control

@onready var display_mode = %DisplaySetting

var current_display_mode = DisplayServer.window_get_mode()

func _ready() -> void:
	if current_display_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		display_mode.set_block_signals(true)
		display_mode.button_pressed = true
		display_mode.set_block_signals(false)
		
	AudioManager.setup_ui_button_audio(self)

func _on_display_setting_toggled(toggled_on: bool) -> void:
	if current_display_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif current_display_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	current_display_mode = DisplayServer.window_get_mode()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
