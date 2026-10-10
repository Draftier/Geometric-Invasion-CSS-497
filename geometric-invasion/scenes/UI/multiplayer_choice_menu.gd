extends Control

@onready var host_button = %HostButton
@onready var ip_input = %IpInput

var error

func _on_host_button_pressed() -> void:
	NetworkManager.start_server()
	get_tree().change_scene_to_file("res://multiplayer_lobby_menu.tscn")

func _on_join_button_pressed() -> void:
	var ip_address = ip_input.text
	
	if !NetworkManager.start_client(ip_address):
		var timer = get_tree().create_timer(1.0)
		ip_input.text = "Invalid ip_address"
		await timer.timeout
		ip_input.clear()
	
	NetworkManager.start_client(ip_address)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
