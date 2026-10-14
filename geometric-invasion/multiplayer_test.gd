extends Node2D

func _ready() -> void:
	#add_spawnable_scene(Global.player.resource_path)
	#
	#NetworkManager.server_level_entered.connect(_on_server_level_entered)
	#
	#print("Connected: ", NetworkManager.server_level_entered.is_connected(_on_server_level_entered))
	multiplayer.server_disconnected.connect(change_scene)
	
	pass

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")
