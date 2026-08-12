extends "res://scripts/enemy/base_enemy.gd"

# Set the rotater and shoot timer
@onready var rotater = $Rotater
@onready var shoot_timer = $ShootTimer

# Allow exports of values related to rotater, shoot_timer, and 
@export var rotate_speed : int
@export var shooter_timer_wait_time : float = 0.1
@export var spawn_point_count = 4
@export var radius = 16

# Function to setup shooters
func initialize_shooting_points() -> void:
	# Calculate step distance between each spawn point around enemy
	var step = 2 * PI / spawn_point_count
	
	# Create a spawn point at each rotated distance
	for i in range (spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)

# Function to rotate the pivot of the shoot_points
func rotate_pivot(delta) -> void:
	# Calculate new rotation for pivot each frame
	var new_rotation = rotater.rotation_degrees + rotate_speed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360)

# Function to shoot bullets per timer
func _on_shoot_timer_timeout() -> void:
	for s in rotater.get_children():
		#var bullet = manager.pull_from_pool("enemy") as Bullet
		var bullet = PoolManager.give_enemy_bullet()
		bullet.speed = 250
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation

func _ready() -> void:
	# Do same ready as parent
	super._ready()
	
	# Then do values for own ready
	
	# Initialize the rotaters shooting points
	initialize_shooting_points()
	
	# Set the shooting timer
	shoot_timer.wait_time = shooter_timer_wait_time
	
	# Start the shooting timer
	shoot_timer.start()

func _process(delta: float) -> void:
	# Do same process as before
	super._process(delta)
	
	# Then rotate shoot point pivots
	rotate_pivot(delta)
	pass
