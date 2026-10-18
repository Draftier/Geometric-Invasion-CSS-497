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

# Movement variables for directional movmeent
var direction_vector
var target_pos : Vector2
var function_direction
var distance_to_move : float

# Death and time state variables
var curve_time : float = 0.0
var is_dead : bool = false

# Changing variables
var cur_event : Movement
var distance_traveled_progress : float
var temp_speed : float

var points_copy : Array[Vector2]

func _ready() -> void:
	# Run the movement events as a coroutine
	temp_speed = speed
	execute_movement_events()
	
	

	pass
	
func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return
	
	# Check if the current movement event is directional or curved
	#print("global position: ", self.global_position)
	#print("target position: ", target_pos)
	if cur_event is DirectionalMovement:
		# If direction then check speed curve and move specified distance in direction at speed of current sampled speed curve
		# If there's a speed curve then sample the curve based on distance traveled and take speed from curve
		if cur_event != null and cur_event.speed_curve != null:
			distance_traveled_progress = (distance_to_move - global_position.distance_to(target_pos)) / distance_to_move
			temp_speed = speed * cur_event.speed_curve.sample(distance_traveled_progress)
		
		# Move the enemy
		global_position += function_direction * temp_speed * delta
		
		#print("Current position: ", global_position)
		#print("Target position: ", target_pos)
		# Check if global position is about equal to target pos
		# If so then movement is finished
		if  global_position.distance_to(target_pos) < 1.0:
			#print("Directional end pos:" ,global_position)
			movement_finished.emit()
		
		#if round(global_position) == round(target_pos):
			#movement_finished.emit()
	# If curved movement, then check if the current position is not equal to target position at end of curve
	elif cur_event is CurveMovement:
		# If current position not equal to target pos at end of curve
		if round(position) != round(cur_event.target_pos):
			# Check if we have a set speed curve
			if cur_event.speed_curve != null:
				# If we have a speed curve move along the bezier curve with sampled speed based on speed curve
				global_position = set_curved_movement(cur_event, clamp(curve_time * cur_event.speed_curve.sample(global_position.length() / cur_event.estimated_curve_length), 0.0, 1.0))
			else:
				# If no speed curve, move based on time taken to move through curve
				global_position = set_curved_movement(cur_event, clamp(curve_time, 0.0, 1.0))
			# Update the time value for curve
			curve_time += delta
		else:
			# Reset curve time to 0 after enemy is about in the target position
			curve_time = 0
			#cur_event.normalized_vec2_array.clear()
			movement_finished.emit()
			
		pass

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
		# If is directional movement then set relevant vars for directional movement
		if i is DirectionalMovement:
			set_directional_movement(i)
		# If is curved movement then set relevant vars for curved movement via screen size and self global pos
		elif i is CurveMovement:
			i.normalize_points(self, screen)
		cur_event = i
		
		# Check if the current movement event is null
		assert(i != null, "Current movement event is null")
		# Wait for current movement to finish then do next movement		
		await movement_finished

	# Stop moving
	function_direction = Vector2.ZERO
		
	# Check if we want to loop or leave screen
	if movement_events.leave_screen == true:
		leave_screen()
	elif movement_events.wrap_movements == true:
		print("Executing movement events again")
		execute_movement_events()
		pass

func set_directional_movement(movement : DirectionalMovement) -> void:
	# Check the direction type enum
		match movement.direction:
			DirectionalMovement.direction_type.UP, DirectionalMovement.direction_type.DOWN:
				# Claculate distance based off percentage of screen
				distance_to_move = movement.distance * screen.y
				if movement.direction == DirectionalMovement.direction_type.UP:
					direction_vector = Vector2.UP
				elif movement.direction == DirectionalMovement.direction_type.DOWN:
					direction_vector = Vector2.DOWN
			DirectionalMovement.direction_type.LEFT, DirectionalMovement.direction_type.RIGHT:
				# Claculate distance based off percentage of screen
				distance_to_move = movement.distance * screen.x
				if movement.direction == DirectionalMovement.direction_type.LEFT:
					direction_vector = Vector2.LEFT
				elif movement.direction == DirectionalMovement.direction_type.RIGHT:
					direction_vector = Vector2.RIGHT
			_:
				direction_vector = Vector2.ZERO
		# Calculate the target position of the current movement
		target_pos = self.global_position + (direction_vector.normalized() * distance_to_move)
		#print(target_pos)
		#var test = direction_vector.normalized() * distance_to_move
		
		# Variables to store initial direction and angle
		function_direction = direction_vector

# This function lerps through the points given in the point array for the curved movemment
func set_curved_movement(movement : CurveMovement, t : float) -> Vector2:
	# Temp array to store prev lerped values
	var temp_array : Array[Vector2] = []
	
	# Loop through the given point array and lerp cur point by point after it
	for i in range(movement.normalized_vec2_array.size()):
		if i + 1 < movement.normalized_vec2_array.size():
			# Then add lerped point to temp array for return
			var temp : Vector2 = movement.normalized_vec2_array[i].lerp(movement.normalized_vec2_array[i+1], t)
			temp_array.append(temp)

	# Return the final interpolated point
	var to_return = temp_array[0].lerp(temp_array[temp_array.size()-1], t)
	return to_return

func leave_screen() -> void:
	# Move using previous direction vector until out of screen
	function_direction = direction_vector
	
func execute_attack_events() -> void:
	
	pass
