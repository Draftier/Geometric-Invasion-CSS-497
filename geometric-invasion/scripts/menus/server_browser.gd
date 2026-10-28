extends Control

signal found_server
signal server_removed

@onready var connection_status_label : Label = %ConnectionStatusLabel

@export var listen_port : int = 8081
@export var server_info_scene : PackedScene
@export var listen_check_frequency : float = 3.0

func _ready() -> void:
	NetworkManager.set_up_listen_port()
	
	NetworkManager.server_joined.connect(_on_server_connected)
	NetworkManager.connecting_to_server.connect(_connecting_to_server)
	NetworkManager.connection_to_server_failed.connect(_on_connection_failed)
	NetworkManager.game_started_signal.connect(_on_game_started_error)

func clean_up() -> void:
	NetworkManager.stop_listen()
	
	if NetworkManager.broadcast_peer != null:
		NetworkManager.stop_broadcast()
	
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
		
		for i in $MarginContainer/VBoxContainer2/ScrollContainer/ServerList.get_children():
			if i.name == server_info.server_dictionary["name"]:
				i.get_node("IpAddressLabel").text = server_info.server_ip
				i.get_node("PlayerCountLabel").text = str(server_info.server_dictionary["player_count"])
				i.reset_timer()
				return
		
		add_server_to_server_list(server_info)
		

func _connecting_to_server() -> void:
	connection_status_label.text = "Connecting to server..."
	await NetworkManager.server_joined
	connection_status_label.text = ""

func _on_connection_failed() -> void:
	connection_status_label.text = "Connection to server failed"
	var timer = get_tree().create_timer(1.0)
	await timer.timeout


func _on_game_started_error() -> void:
	connection_status_label.text = "Game has already started"
	var timer = get_tree().create_timer(1.0)
	await timer.timeout

func _on_server_connected() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_lobby_menu.tscn")
	
func add_server_to_server_list(server_info) -> void:
	var child = $MarginContainer/VBoxContainer2/ScrollContainer/ServerList.find_child(server_info.server_dictionary["name"])
		
	var current_info = server_info_scene.instantiate()
	current_info.name = server_info.server_dictionary["name"]
	current_info.get_node("RoomNameLabel").text = server_info.server_dictionary["name"]
	current_info.get_node("IpAddressLabel").text = server_info.server_ip
	current_info.get_node("PlayerCountLabel").text = str(server_info.server_dictionary["player_count"])
	$MarginContainer/VBoxContainer2/ScrollContainer/ServerList.add_child(current_info)
