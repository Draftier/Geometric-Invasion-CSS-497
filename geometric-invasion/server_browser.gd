extends Control

signal found_server
signal server_removed


@export var listen_port : int = 8081
@export var server_info : PackedScene
@export var listen_check_frequency : float = 3.0

func _ready() -> void:
	NetworkManager.set_up_listen_port()

func clean_up() -> void:
	NetworkManager.listen_peer.close()
	
	#if NetworkManager.broadcast_peer != null:
		#NetworkManager.broadcast_peer.close()
	
func _exit_tree() -> void:
	clean_up()

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")

func _process(delta: float) -> void:
	var server_info = NetworkManager.obtain_server_information()
	
	if server_info == null:
		return
	else:
		print("server ip: " + server_info.server_ip + " server port: " + str(server_info.server_port) + " server info: " + str(server_info.server_dictionary))
	
