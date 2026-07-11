class_name basic_enemy
extends Area2D

const bullet_scene = preload("res://scenes/bullet_2.tscn")
@onready var shoot_timer = $ShootTimer
@onready var rotater = $Rotater

@export var rotate_speed : int = 500
@export var shooter_timer_wait_time : float = 0.1
@export var spawn_point_count = 4
@export var radius = 16
@export var move_speed = 10

@export var health = 100
@export var path : PathFollow2D

func _ready() -> void:
	var step = 2 * PI / spawn_point_count
	
	for i in range (spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
		
	shoot_timer.wait_time = shooter_timer_wait_time
	shoot_timer.start()
	
func _process(delta: float) -> void:
	var new_rotation = rotater.rotation_degrees + rotate_speed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360)
	path.progress_ratio += delta * move_speed / 8
	if path.progress_ratio >= 1.0:
		queue_free()
	

func hit() -> void:
	health -= 1
	if health <= 0:
		queue_free()
	var tween = create_tween()
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 0.0, 0.01)
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 1.0, 0.02)	


func _on_shoot_timer_timeout() -> void:
	for s in rotater.get_children():
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation
