extends CanvasLayer

@onready var result_label : Label = %ResultMessageLabel

func _ready() -> void:
	hide()
	
func show_loss_menu() -> void:
	AudioManager.stop_cur_player()
	pause_game()
	result_label.text = "You lost!"
	show()
	
func show_victory_menu() -> void:
	pause_game()
	result_label.text = "You won!"
	show()

func pause_game() -> void:
	if get_tree().paused == false:
		get_tree().paused = true
		
func _on_quit_to_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()
