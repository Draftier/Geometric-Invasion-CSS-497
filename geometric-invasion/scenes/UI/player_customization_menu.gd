extends Control

@onready var start_button : Button = %StartGameButton
@onready var shoot_style_dropdown : OptionButton = %ShootOptions
@onready var ability_dropdown : OptionButton = %AbilityOptions

signal game_start

func _ready() -> void:
	shoot_style_dropdown.grab_focus()
	AudioManager.setup_ui_button_audio(self)

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_start_game_button_pressed() -> void:
	game_start.emit()
	call_deferred("change_scene")


func _on_ability_options_item_selected(index: int) -> void:
	match ability_dropdown.get_item_text(index):
		"Destroyer": Global.ability = load("res://scenes/Ability/ability_laser.tscn")
		"Tank": Global.ability =  load("res://scenes/Ability/shield_ability.tscn")


func _on_shoot_options_item_selected(index: int) -> void:
	match shoot_style_dropdown.get_item_text(index):
		"Shooting forward": Global.player = load("res://scenes/Player/player_default_shooting_style.tscn")
		"Shooting forward and side": Global.player =  load("res://scenes/Player/player_shooting_style_two.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
