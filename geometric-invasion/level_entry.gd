extends Button

@export_file var level_path

func _on_pressed() -> void:
	if level_path == null:
		return
	NetworkManager.selected_level = level_path
	if NetworkManager.is_solo == true:
		get_tree().change_scene_to_file("res://scenes/UI/player_customization_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/UI/multiplayer_lobby_menu.tscn")
	
	
