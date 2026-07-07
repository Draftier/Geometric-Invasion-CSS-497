class_name ShootPoint
extends Node2D

const PLAYER_BULLET = preload("uid://iie43arv0boo")
@export var stats : ShootPointStats

var can_shoot : bool = true

func _ready() -> void:
	$FireRateTimer.wait_time = stats.fire_rate

func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true

func shoot() -> void:
	if can_shoot == true:
		var player_bullet = PLAYER_BULLET.instantiate() as Area2D
		player_bullet.setup($Muzzle.position, Vector2.UP)
		add_child(player_bullet)
		$FireRateTimer.start()
		can_shoot = false
