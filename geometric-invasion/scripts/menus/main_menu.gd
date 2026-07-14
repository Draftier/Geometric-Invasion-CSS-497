extends CanvasLayer





func _on_start_button_pressed() -> void:
	call_deferred("change_scene")
	

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
