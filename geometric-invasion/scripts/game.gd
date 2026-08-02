extends Node

@export var player_scene : PackedScene
@export var Level_scene : PackedScene
@export var level_manager : Level_Manager
@export var ui: UI

@onready var pause_menu = $PauseMenu

var player : Player
var level

func _ready() -> void:
	var player : Player = Global.player.instantiate()
	player.ability_scene =  Global.ability
	player.global_position = $SpawnPoint.global_position
	add_child(player)
	pause_menu.player_connect(player)
	print("foo")

func start_game():
	
	pass
