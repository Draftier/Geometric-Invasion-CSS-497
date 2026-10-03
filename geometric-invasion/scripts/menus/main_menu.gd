extends Control

signal game_start()
@onready var buttons_vbox: VBoxContainer = %ButtonsVbox

func _ready() -> void:
	print_orphan_nodes()
	print(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	focus_button()

func _on_start_button_pressed() -> void:
	#game_start.emit()
	#PoolManager.init_pools()
	#call_deferred("change_scene")
	$MarginContainer/RootMenu.visible = false
	$MarginContainer/CustomizationChildMenu.visible = true
	pass

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
	$MarginContainer/RootMenu/TitleLabel.visible = false
	%ButtonsVbox.visible = false
	%ControlsVbox.visible = true

func _on_back_button_pressed() -> void:
	$MarginContainer/RootMenu/TitleLabel.visible = true
	%ButtonsVbox.visible = true
	%ControlsVbox.visible = false

func _on_start_game_button_pressed() -> void:
	game_start.emit()
	call_deferred("change_scene")



func _on_multiplayer_not_implemented_pressed() -> void:
	$MarginContainer/RootMenu/TitleLabel.visible = false
	%ButtonsVbox.visible = false
	$MarginContainer/MultiplayerMenu.visible = true
	pass # Replace with function body.


func _on_option_button_item_selected(index: int) -> void:
	match $MarginContainer/CustomizationChildMenu/MarginContainer/VBoxContainer/ShootOptions.get_item_text(index):
		"Shooting forward": Global.player = load("res://scenes/Player/player_default_shooting_style.tscn")
		"Shooting forward and side": Global.player =  load("res://scenes/Player/player_shooting_style_two.tscn")



func _on_ability_options_item_selected(index: int) -> void:
	match $MarginContainer/CustomizationChildMenu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/AbilityOptions.get_item_text(index):
			"Destroyer": Global.ability = load("res://scenes/Ability/ability_laser.tscn")
			"Tank": Global.ability =  load("res://scenes/Ability/shield_ability.tscn")
