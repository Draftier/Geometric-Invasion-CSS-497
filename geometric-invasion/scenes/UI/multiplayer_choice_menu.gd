extends Control

@onready var host_button = %HostButton
@onready var ip_input = %IpInput
@onready var error_label = %ErrorLabel

@onready var ability_dropdown = %AbilityOptions
@onready var shoot_style_dropdown = %ShootOptions

var error

func _ready() -> void:
	NetworkManager.server_joined.connect(_on_server_connected)
	NetworkManager.connecting_to_server.connect(_connecting_to_server)
	NetworkManager.connection_to_server_failed.connect(_on_connection_failed)
	NetworkManager.game_started_signal.connect(_on_game_started_error)

func _on_ability_options_item_selected(index: int) -> void:
	match ability_dropdown.get_item_text(index):
		"Destroyer": Global.ability = load("res://scenes/Ability/ability_laser.tscn")
		"Tank": Global.ability =  load("res://scenes/Ability/shield_ability.tscn")
	print("Ability change to" + str(Global.ability))

func _on_shoot_options_item_selected(index: int) -> void:
	match shoot_style_dropdown.get_item_text(index):
		"Shooting forward": Global.player = load("res://scenes/Player/player_default_shooting_style.tscn")
		"Shooting forward and side": Global.player =  load("res://scenes/Player/player_shooting_style_two.tscn")

func _on_host_button_pressed() -> void:
	if !NetworkManager.start_server():
		error_label.text = "Unable to start server"
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		error_label.text = ""
		return

	get_tree().change_scene_to_file("res://multiplayer_lobby_menu.tscn")


func _on_back_button_pressed() -> void:
	NetworkManager.stop_server()	
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
	
func _on_server_connected() -> void:
	get_tree().change_scene_to_file("res://multiplayer_lobby_menu.tscn")
	
func _connecting_to_server() -> void:
	error_label.text = "Connecting to server..."
	await NetworkManager.server_joined
	error_label.text = ""

func _on_connection_failed() -> void:
	error_label.text = "Connection to server failed"
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	ip_input.clear()
	error_label.text = ""

func _on_game_started_error() -> void:
	error_label.text = "Game has already started"
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	ip_input.clear()
	error_label.text = ""


func _on_join_by_ip_pressed() -> void:
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
	
	
		
	#get_tree().change_scene_to_file("res://multiplayer_lobby_menu.tscn")
	pass

# Function should open a listen port on the lan
# When receiving packet from listen port, parse packet and obtain server ip and port
func _on_open_server_browser_pressed() -> void:
	get_tree().change_scene_to_file("res://server_browser.tscn")
