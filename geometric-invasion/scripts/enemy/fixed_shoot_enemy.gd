extends "res://scripts/enemy/base_enemy.gd"

# Set shoot timer
@onready var shoot_point = $ShootPoint
@onready var shoot_timer = $ShootTimer

# Exported values
@export var bullet : PackedScene
@export var shoot_timer_wait_time : float


func _ready() -> void:
	# Initialize base values
	super._ready()
	
	# Initialize fire rate timers
	shoot_timer.wait_time = shoot_timer_wait_time
	
	shoot_timer.start()
	
func _physics_process(delta: float) -> void:
	# Do parent class move function
	super._physics_process(delta)


func _on_shoot_timer_timeout() -> void:
	# print("fire")
	shoot_point.shoot()
