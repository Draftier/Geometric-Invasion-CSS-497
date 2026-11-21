extends Control
class_name BaseMenu

@export_file var scene_path

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file(scene_path)
		
