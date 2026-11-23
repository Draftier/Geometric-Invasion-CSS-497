extends CanvasLayer

@onready var result_label : Label = %ResultMessageLabel
@onready var retry_button : Button = %RetryButton
@onready var quit_menu_button : Button = %QuitToMenuButton
@onready var quit_to_desktop_button : Button = %QuitToDesktopButton

func _ready() -> void:
	AudioManager.setup_ui_button_audio(self)
	hide()

@rpc("authority", "call_local", "reliable")
func show_loss_menu() -> void:
	#AudioManager.stop_cur_player()
	AudioManager.play_music_track(preload("res://assets/audio/music/level_music/Fallen in Battle.ogg"))

	result_label.text = "You lost!"
	show()
	
	if NetworkManager.is_solo == false:
		retry_button.hide()
		
	if retry_button.visible == true:
		retry_button.grab_focus()
	else:
		quit_menu_button.focus_neighbor_top = quit_menu_button.get_path_to(quit_to_desktop_button)
		quit_menu_button.grab_focus()

@rpc("authority", "call_local", "reliable")
func show_victory_menu() -> void:
	#AudioManager.stop_cur_player()
	AudioManager.play_music_track(preload("res://assets/audio/music/level_music/Victory! All Clear.ogg"))
	
	result_label.text = "You won!"
	show()
	
	if NetworkManager.is_solo == false:
		retry_button.hide()
	
	if retry_button.visible == true:
		retry_button.grab_focus()
	else:
		quit_menu_button.focus_neighbor_top = quit_menu_button.get_path_to(quit_to_desktop_button)
		quit_menu_button.grab_focus()

@rpc("authority", "call_local", "reliable")
func pause_game() -> void:
	if get_tree().paused == false:
		get_tree().paused = true

@rpc("authority", "call_local", "reliable")
func unpause_game() -> void:
	get_tree().paused = false
		
func _on_quit_to_menu_button_pressed() -> void:
	if multiplayer.multiplayer_peer != OfflineMultiplayerPeer:
		NetworkManager.peer = null
		NetworkManager.is_solo = true
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()


func _on_retry_button_pressed() -> void:
	if NetworkManager.is_solo == false && multiplayer.multiplayer_peer == null:
		get_tree().paused = false
		get_tree().reload_current_scene()
	else:
		if multiplayer.is_server():
			unpause_game.rpc()
			NetworkManager.change_scene_for_all_players.rpc(NetworkManager.selected_level)
		else:
			retry_button.text = "Only host can restart level!"
			await get_tree().create_timer(3.0).timeout
			retry_button.text = "Retry"
