extends CanvasLayer

@onready var resume_button = %ResumeButton
@onready var restart_button = %RestartButton
@onready var quit_menu_button = %QuitToMenu
@onready var quit_desktop_button = %QuitToDesktop

func _ready() -> void:
	AudioManager.setup_ui_button_audio(self)
	hide()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_game()

func pause_game() -> void:
	if get_tree().paused == false:
		if NetworkManager.is_solo == true:
			get_tree().paused = true
		show()
		#get_node("FinishLabel").hide()
		#get_node("RestartButton").hide()
	else:
		hide()
		get_tree().paused = false

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	#PoolManager.destroy_pools()
	#PoolManager.reset_pools()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/UI/main_menu.tscn")

func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()


func _on_player_death() -> void:
	get_tree().paused = true
	show()
	get_node("ResumeButton").hide()
	get_node("RestartButton").show()
	get_node("FinishLabel").text = "You lost!"
	get_node("FinishLabel").show()


func _on_level_manager_victory() -> void:
	# pause_game()
	get_tree().paused = true
	show()
	get_node("ResumeButton").hide()
	get_node("RestartButton").show()
	get_node("FinishLabel").text = "You won"
	get_node("FinishLabel").show()


func _on_restart_button_pressed() -> void:
	pause_game()
	#PoolManager.destroy_pools()
	#PoolManager.init_pools()
	get_tree().reload_current_scene()
	
func player_connect(player : Player) -> void:
	player.connect("death", _on_player_death)
