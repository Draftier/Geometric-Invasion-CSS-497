extends Node

var player : PackedScene = load("res://scenes/Player/player_default_shooting_style.tscn")
var ability : PackedScene = load("res://scenes/Ability/ability_laser.tscn")

var current_enemy_id = 0
