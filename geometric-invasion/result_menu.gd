extends CanvasLayer

@onready var result_label : Label = %ResultMessageLabel

func _ready() -> void:
	hide()

@rpc("authority", "call_local", "reliable")
func show_loss_menu() -> void:
	#AudioManager.stop_cur_player()
	AudioManager.play_music_track(preload("res://assets/audio/music/level_music/Fallen in Battle.ogg"))
	pause_game()
	result_label.text = "You lost!"
	show()

@rpc("authority", "call_local", "reliable")
func show_victory_menu() -> void:
	#AudioManager.stop_cur_player()
	AudioManager.play_music_track(preload("res://assets/audio/music/level_music/Victory! All Clear.ogg"))
	pause_game()
	result_label.text = "You won!"
	show()

func pause_game() -> void:
	if get_tree().paused == false:
		get_tree().paused = true
		
func _on_quit_to_menu_button_pressed() -> void:
	if multiplayer.multiplayer_peer != OfflineMultiplayerPeer:
		NetworkManager.peer = null
		NetworkManager.is_solo = true
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()
