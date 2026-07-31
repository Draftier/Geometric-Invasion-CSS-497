extends Control

signal game_start()
@onready var buttons_vbox: VBoxContainer = %ButtonsVbox

func _ready() -> void:
	print_orphan_nodes()
	print(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	focus_button()

func _on_start_button_pressed() -> void:
	game_start.emit()
	PoolManager.init_pools()
	call_deferred("change_scene")
	hide()
	

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
	if visible:
		focus_button()
		
func focus_button() -> void:
	if buttons_vbox:
		var button : Button = buttons_vbox.get_child(0)
		if button is Button:
			button.grab_focus()
