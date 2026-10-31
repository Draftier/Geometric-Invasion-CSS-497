extends Control

const PLAYER := preload("res://scenes/Player/player_default_shooting_style.tscn")

@onready var spawn_point : Marker2D = %Spawn
@onready var back_button : Button = %BackButton

var player : Player
var init_speed : float

func _ready() -> void:
	AudioManager.setup_ui_button_audio(self)
	player = PLAYER.instantiate()
	player.preview_mode = true
	player.visible = true
	player.global_position = spawn_point.position
	player.scale = Vector2(3,3)
	add_child(player)
	init_speed = player.player_class.speed
	player.player_class.speed *= 3
	

func _on_back_button_pressed() -> void:
	player.player_class.speed = init_speed
	#PoolManager.destroy_pools()
	#PoolManager.init_pools()
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
		AudioManager.play_ui_select_audio()
