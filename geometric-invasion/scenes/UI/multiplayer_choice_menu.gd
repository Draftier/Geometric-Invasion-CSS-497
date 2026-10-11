extends Control

@onready var host_button = %HostButton
@onready var ip_input = %IpInput
@onready var error_label = %ErrorLabel

var error

func _on_host_button_pressed() -> void:
	if !NetworkManager.start_server():
		error_label.text = "Unable to start server"
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		error_label.text = ""
		return

	get_tree().change_scene_to_file("res://multiplayer_lobby_menu.tscn")

func _on_join_button_pressed() -> void:
	var ip_address = ip_input.text
	#var error = NetworkManager.start_client(ip_address)
	
	if ip_address == "" or !ip_address.is_valid_ip_address():
		error_label.text = "Invalid ip_address"
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		ip_input.clear()
		error_label.text = ""
		return
	
	if !NetworkManager.start_client(ip_address):
		error_label.text = "Could not start connection"
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		error_label.text = ""
	else:
		get_tree().change_scene_to_file("res://multiplayer_lobby_menu.tscn")
	

func _on_back_button_pressed() -> void:
	NetworkManager.stop_server()	
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
