class_name basic_enemy
extends Node2D

# TODO Make it so that bullet scenes can be varied
# TODO Tie many variables to a class that inherits some variables, but has things like a rotater
# TODO Consider making pathing based on set mathematical directions given by resources since pathing could get painful
# Depending on how levels are going to be designed

# Temp death signal for playatest
signal death

# Initialize the shoot timer and rotater at ready
# @onready var free_timer = $FreeTimer

# Allow shooter and rotater values to be edited in editor to add easier time for editing enemy behavior
# Consider making a class and resources that have different values for specific enemy types
@export var speed = 10
@export var distance_to_move : float
@export var health = 100
@export var path : PathFollow2D
@export var direction : String
@export var equation : String = "None"

# Variable that stores the packed scene for ability pickup
@export var power_up_charge : PackedScene

# Store direction vector and current time
var direction_vector
var time : float = 0.0
var is_dead : bool = false

func _ready() -> void:
	# Initialize the direction based on inspector values
	if direction == "right":
		direction_vector = Vector2.RIGHT
	elif direction == "left":
		direction_vector = Vector2.LEFT
	elif direction == "up":
		direction_vector = Vector2.UP
	elif direction == "down":
		direction_vector = Vector2.DOWN
	else:
		direction_vector = Vector2.ZERO
	
func _process(delta: float) -> void:
	# Store current time for possible function calculations
	time += delta
	# Move the enemy
	move_body(delta)
	

# Function to calculate health and hit upon getting hit by player bullet
func take_damage(damage : int) -> void:
	# Subtract one  health	
	if health - damage < 0:
		health = 0
	else:
		health -= damage
	
	# If health zero then free
	if health == 0 and is_dead == false:
		# death.emit.call_deferred()
		is_dead = true
		death.emit()
		print("dying")
		
		if randf() < 0.5:
			var power_up = power_up_charge.instantiate()
			power_up.position = self.position
			get_parent().call_deferred("add_child", power_up)
		
		queue_free()
	# If health not zero then set progress of flash shader
	var tween = create_tween()
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 0.0, 0.01)
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 1.0, 0.02)	

# Function to move the enemy body based on path or direction and function
func move_body(delta) -> void:
	# If there's a given path then follow the path
	if path != null:
		path.progress_ratio += delta * speed / 8
	else:
		# Otherwise check if there's an equation
		
		# Variables to store initial direction and angle
		var function_direction = direction_vector
		var angle
		
		# Check what equation we want to apply and apply it
		if equation == "sin":
			angle = sin(time * 1.5) * 50
			function_direction = direction_vector.rotated(deg_to_rad(angle))
		elif equation == "cosin":
			# This code is currently broken ignore this
			function_direction = direction_vector.rotated(cos(0.0 * 8.0) * 0.3)
		
		# Move the enemy based on direction speed and delta
		position += function_direction * speed * delta

# If the enemy exits the screen then free it
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	death.emit()
	queue_free()
