extends Control

@onready var player_count_label = %PlayerCountLabel
@onready var ip_label = %IPLabel
@onready var error_label = %ConnectionErrorLabel
@onready var start_game_warning_label = %StartGameWarningLabel

var num_players : int = 0 

func _ready() -> void:
	num_players += 1
	player_count_label.text = "Player count : " + str(num_players) + " / 3"
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	%IPLabel.text += NetworkManager.ip_address

func _on_start_game_button_pressed() -> void:
	if !is_multiplayer_authority():
		start_game_warning_label.text = "Only host can start game"
		
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		
		start_game_warning_label.text = ""
	pass


func _on_peer_connected(id : int) -> void:
	num_players += 1
	player_count_label.text = "Player count : " + str(num_players) + " / 3"
	
func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	
	$MarginContainer/Lobby/MarginContainer/VBoxContainer.hide()
	
	error_label.text = "Server connection lost"
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")

func _on_back_button_pressed() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")
