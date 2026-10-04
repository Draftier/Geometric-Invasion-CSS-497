extends Control


func _on_host_button_pressed() -> void:
	NetworkManager.start_server()

func _on_join_button_pressed() -> void:
	pass

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
