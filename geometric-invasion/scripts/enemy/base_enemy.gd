class_name basic_enemy
extends Node2D

# TODO Make it so that bullet scenes can be varied
# TODO Tie many variables to a class that inherits some variables, but has things like a rotater
# TODO Consider making pathing based on set mathematical directions given by resources since pathing could get painful
# Depending on how levels are going to be designed

# Temp death signal for playatest
signal death
signal movement_finished

# Movement and attack resources that enemies will utilize
@export var movement_events : EnemyMovementData
@export var attack_events : EnemyAttackData

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
@onready var screen : Vector2 = get_viewport_rect().size
var target_pos : Vector2
var function_direction

func _ready() -> void:
	# Run the movement events as a coroutine
	execute_movement_events()
	pass
	
func _process(delta: float) -> void:
	# Store current time for possible function calculations
	time += delta
	
	if function_direction == null:
		print("function direction null")
	elif speed == null:
		print("speed null")
	
	
	#if movement_events.function != null:
		#apply_offset()
	
	# Move the enemy
	global_position += function_direction * speed * delta
	
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
		# Check the current direction key
		if i.movement == "right" or i.movement == "left":
			# Multiply the distance to move by the screen size
			distance_to_move = i.distance * screen.x
			if i.movement == "right":
				direction_vector = Vector2.RIGHT
			elif i.movement == "left":
				direction_vector = Vector2.LEFT
		elif i.movement == "up" or i.movement == "down":
			# Multiply the distance to move by the screen size
			distance_to_move = i.distance * screen.y
			if i.movement == "up":
				direction_vector = Vector2.UP
			elif i.movement == "down":
				direction_vector = Vector2.DOWN
		else:
			direction_vector = Vector2.ZERO
		# Figure out the target position based on the distance to move and cur direction vector
		target_pos = self.position + direction_vector.normalized() * distance_to_move
		print(distance_to_move)
		print(target_pos)
		# Variables to store initial direction and angle
		function_direction = direction_vector
		var angle
		
		
		# Wait for current movement to finish then do next movement		
		
		await movement_finished

	# Stop moving
	function_direction = Vector2.ZERO
	
	# Check if we want to loop or leave screen
	if movement_events.leave_screen == true:
		leave_screen()
	elif movement_events.wrap == true:
		execute_movement_events()
		pass

func apply_offset() -> void:
	# If we want sine wave then set sine offset
		if movement_events.function == "sin":
			var amplitude = 0.1
			var frequency = 0.01
			#while sin(time * frequency)
			var angle = sin(time * 1.5) * 2
			function_direction = direction_vector.rotated(deg_to_rad(angle))
			#print(global_position)

func leave_screen() -> void:
	# Move using previous direction vector until out of screen
	function_direction = direction_vector
