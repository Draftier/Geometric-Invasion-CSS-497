extends Control

# Storing unique items as variables
@onready var player_count_label = %PlayerCountLabel
@onready var wifi_ip_label = %WifiIpLabel
@onready var error_label = %ConnectionErrorLabel
@onready var start_game_warning_label = %StartGameWarningLabel
@onready var ethernet_ip_label = %EthernetIpLabel

# Variable to keep track of the number of players
var num_players : int = 0

func _ready() -> void:
	# Connecting signals to update number of players based on
	# - Peer connected
	# - Peer disconnected
	# - Peer itself connecting to server
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_peer_connected)
	
	# Connecting signal to update scene when server goes down
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Show the initial player count
	_update_player_count()
	
	# Show the host ip address
	wifi_ip_label.text += NetworkManager.wifi_ip_address
	ethernet_ip_label.text += NetworkManager.ethernet_ip_address
	

# Logic for what happens when start game button is presed
func _on_start_game_button_pressed() -> void:
	# Checks if player pressing start game is host
	# Checks if number of players is greater than two
	# If not host or players is less than two, don't start game and display warning
	if !is_multiplayer_authority():
		start_game_warning_label.text = "Only host can start game"
		
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		
		start_game_warning_label.text = ""
		return
	elif num_players < 2:
		start_game_warning_label.text = "Game can only start with two or more players"
		
		var timer = get_tree().create_timer(1.0)
		await  timer.timeout
		
		start_game_warning_label.text = ""
		return
	
	# Otherwise if host is starting then emit signal 
	#NetworkManager.server_level_entered.emit()
	NetworkManager.game_started = true
	NetworkManager.change_scene_for_all_players.rpc("res://multiplayer_test.tscn")
	pass

# Function utilized to update player count, made since
# Peer disconnected and peer connected signals 
# Require functions to take in a peer's id
func _on_peer_connected(id : int) -> void:	
	_update_player_count()

func _on_peer_disconnected(id : int) -> void:
	_update_player_count()

# Function that shows server gone down or connection to server lost
func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	
	$MarginContainer/Lobby/MarginContainer/VBoxContainer.hide()
	
	error_label.text = "Server connection lost"
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")

# Function for back button
# Makes multiplayer peer offline, and closes current connection to server
# Then puts user back to multiplayer choice menu
func _on_back_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")

# Updates player count based on number of peers
func _update_player_count() -> void:
	num_players = multiplayer.get_peers().size() + 1
	player_count_label.text = "Player count : " + str(num_players) + " / 3"
