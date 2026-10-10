extends Control

@onready var player_count_label = %PlayerCountLabel
@onready var ip_label = %IPLabel

var num_players : int = 0 

func _ready() -> void:
	num_players += 1
	player_count_label.text = "Player count : " + str(num_players) + " / 3"
	multiplayer.peer_connected.connect(_on_peer_connected)
	%IPLabel.text += NetworkManager.ip_address

func _on_start_game_button_pressed() -> void:
	pass


func _on_peer_connected(id : int) -> void:
	num_players += 1
	player_count_label.text = "Player count : " + str(num_players) + " / 3"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/multiplayer_choice_menu.tscn")
