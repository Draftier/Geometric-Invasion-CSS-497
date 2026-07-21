extends CanvasLayer

@onready var player = get_node("../Player")

func _ready() -> void:
	player.connect("death", _on_player_death)
	hide()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_game()

func pause_game() -> void:
	if get_tree().paused == false:
		get_tree().paused = true
		show()
		get_node("FinishLabel").hide()
		get_node("RestartButton").hide()
	else:
		hide()
		get_tree().paused = false

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

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
	get_tree().reload_current_scene()
