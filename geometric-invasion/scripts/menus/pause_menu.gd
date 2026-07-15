extends CanvasLayer

func _ready() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
			show()
		else:
			hide()
			get_tree().paused = false


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")


func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()
