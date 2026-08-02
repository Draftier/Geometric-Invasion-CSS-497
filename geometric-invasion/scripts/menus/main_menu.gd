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


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res:://scenes/tutorial.tscn")
	pass # Replace with function body.


func _on_controls_button_pressed() -> void:
	$MarginContainer/VBoxContainer/TitleLabel.visible = false
	%ButtonsVbox.visible = false
	%ControlsVbox.visible = true

func _on_back_button_pressed() -> void:
	$MarginContainer/VBoxContainer/TitleLabel.visible = true
	%ButtonsVbox.visible = true
	%ControlsVbox.visible = false
