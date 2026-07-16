class_name basic_enemy
extends Area2D

# TODO Make it so that bullet scenes can be varied
# TODO Tie many variables to a class that inherits some variables, but has things like a rotater
# TODO Consider making pathing based on set mathematical directions given by resources since pathing could get painful
# Depending on how levels are going to be designed

# Take in a bullet scene the enemy should shoot
const bullet_scene = preload("res://scenes/obstacle_bullet_base.tscn")

# Initialize the shoot timer and rotater at ready
@onready var shoot_timer = $ShootTimer
@onready var rotater = $Rotater

# Allow shooter and rotater values to be edited in editor to add easier time for editing enemy behavior
# Consider making a class and resources that have different values for specific enemy types
@export var rotate_speed : int = 500
@export var shooter_timer_wait_time : float = 0.1
@export var spawn_point_count = 4
@export var radius = 16
@export var move_speed = 10

@export var health = 100


@onready var manager = get_tree().get_first_node_in_group("level_manager")

func _ready() -> void:
	# Calculate the step distance between each spawn point around the enemy
	var step = 2 * PI / spawn_point_count
	
	# Create a spawn_point at each rotated distance
	for i in range (spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
		
	# Initialize the wait time to control fire rate
	shoot_timer.wait_time = shooter_timer_wait_time
	
	# Start the timer
	shoot_timer.start()
	
func _process(delta: float) -> void:
	rotate_pivot(delta)

# Function to calculate health and hit upon getting hit by player bullet
func take_damage() -> void:
	# Subtract one  health
	health -= 1
	
	# If health zero then free
	if health <= 0:
		queue_free()
	# If health not zero then set progress of flash shader
	var tween = create_tween()
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 0.0, 0.01)
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 1.0, 0.02)	

# Each time timer goes out shoot a bullet for each bullet spawn point in scene
func _on_shoot_timer_timeout() -> void:
	for s in rotater.get_children():
		var bullet = manager.pull_from_pool() as Bullet
		#var bullet = bullet_scene.instantiate()
		#get_tree().root.add_child(bullet)
		bullet.speed = 250
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation

func rotate_pivot(delta) -> void:
	# Calculate new rotations for the pivot(rotater) each frame
	var new_rotation = rotater.rotation_degrees + rotate_speed * delta
	# Apply the rotate to the rotater, make sure to use float modulo to wrap around 360
	rotater.rotation_degrees = fmod(new_rotation, 360)
