class_name basic_enemy
extends Node2D

# TODO Make it so that bullet scenes can be varied
# TODO Tie many variables to a class that inherits some variables, but has things like a rotater
# TODO Consider making pathing based on set mathematical directions given by resources since pathing could get painful
# Depending on how levels are going to be designed

# Temp death signal for playatest
signal death
signal movement_finished

@onready var screen : Vector2 = get_viewport_rect().size

# Movement and attack resources that enemies will utilize
@export var movement_events : EnemyMovementData
@export var attack_events : EnemyAttackData

# Variables to controll full speed, health, and move distance
@export var speed = 10
@export var health = 100
# Variable that stores the packed scene for ability pickup
@export var power_up_charge : PackedScene

# Movement variables 
var direction_vector
var target_pos : Vector2
var function_direction
var distance_to_move : float

# Death and time state variables
var time : float = 0.0
var is_dead : bool = false

# Changing variables
var cur_event : Movement
var distance_traveled_progress : float
var temp_speed : float

func _ready() -> void:
	# Run the movement events as a coroutine
	temp_speed = speed
	execute_movement_events()
	pass
	
func _process(delta: float) -> void:
	# Store current time for possible function calculations
	time += delta
	
	# If there's a speed curve then sample the curve based on distance traveled and take speed from curve
	if cur_event != null and cur_event.curve != null:
		distance_traveled_progress = (distance_to_move - global_position.distance_to(target_pos)) / distance_to_move
		temp_speed = speed * cur_event.curve.sample(distance_traveled_progress)
	
	# Move the enemy
	global_position += function_direction * temp_speed * delta
	
	
	# Check if global position is about equal to target pos
	# If so then movement is finished
	if  round(global_position) == round(target_pos):
		movement_finished.emit()
	
	

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


# If the enemy exits the screen then free it
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	death.emit()
	queue_free()


func execute_movement_events() -> void:
	for i in movement_events.movement_array:
		# Check the direction type enum
		match i.direction:
			DirectionalMovement.direction_type.UP, DirectionalMovement.direction_type.DOWN:
				# Claculate distance based off percentage of screen
				distance_to_move = i.distance * screen.y
				if i.direction == DirectionalMovement.direction_type.UP:
					direction_vector = Vector2.UP
				elif i.direction == DirectionalMovement.direction_type.DOWN:
					direction_vector = Vector2.DOWN
			DirectionalMovement.direction_type.LEFT, DirectionalMovement.direction_type.RIGHT:
				# Claculate distance based off percentage of screen
				distance_to_move = i.distance * screen.x
				if i.direction == DirectionalMovement.direction_type.LEFT:
					direction_vector = Vector2.LEFT
				elif i.direction == DirectionalMovement.direction_type.RIGHT:
					direction_vector = Vector2.RIGHT
			_:
				direction_vector = Vector2.ZERO
		# Calculate the target position of the current movement
		target_pos = self.position + direction_vector.normalized() * distance_to_move
		
		
		# Variables to store initial direction and angle
		function_direction = direction_vector
		cur_event = i
		
		
		# Wait for current movement to finish then do next movement		
		await movement_finished

	# Stop moving
	function_direction = Vector2.ZERO
	
	# Check if we want to loop or leave screen
	if movement_events.leave_screen == true:
		leave_screen()
	elif movement_events.wrap_movements == true:
		execute_movement_events()
		pass

func leave_screen() -> void:
	# Move using previous direction vector until out of screen
	function_direction = direction_vector

## Function to take percentages of points and have them be vector2's with pixel values of screen
#func normalize_points() -> void:
	## Add the initial position to beginning of vector
	#normalized_vec2_array.append(global_position)
	## Iterate through all points and multiply the percent given by x and y screen size
	#for i in point_array:
		#var temp_vec = Vector2(global_position.x + (i.x_percent * screen.x), global_position.y + (i.y_percent * screen.y))
		#normalized_vec2_array.append(temp_vec)
		## Add to curve length 
		#estimated_curve_length += temp_vec.length()
		#pass
