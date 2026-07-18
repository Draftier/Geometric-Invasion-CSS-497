extends Area2D

# TODO Make it so that bullet scenes can be varied
# TODO Tie many variables to a class that inherits some variables, but has things like a rotater
# TODO Consider making pathing based on set mathematical directions given by resources since pathing could get painful
# Depending on how levels are going to be designed

# Take in a bullet scene the enemy should shoot
@export var bullet_scene : PackedScene

# Initialize the shoot timer and rotater at ready
# @onready var free_timer = $FreeTimer
@onready var manager = get_tree().get_first_node_in_group("level_manager")

# Allow shooter and rotater values to be edited in editor to add easier time for editing enemy behavior
# Consider making a class and resources that have different values for specific enemy types
@export var speed = 10
@export var distance_to_move : float
@export var health = 100
@export var path : PathFollow2D
@export var direction : String
@export var equation : String = "None"

var direction_vector
var time : float = 0.0

func _ready() -> void:
	if direction == "right":
		direction_vector = Vector2.RIGHT
	elif direction == "left":
		direction_vector = Vector2.LEFT
	elif direction == "up":
		direction_vector = Vector2.UP
	elif direction == "down":
		direction_vector = Vector2.DOWN
	
func _process(delta: float) -> void:
	time += delta
	move_body(delta)
	

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

func move_body(delta) -> void:
	if path != null:
		path.progress_ratio += delta * speed / 8
	else:
		var function_direction
		var angle
		if equation == "sin":
			angle = sin(time * 1.5) * 50
			function_direction = direction_vector.rotated(deg_to_rad(angle))
			pass
		elif equation == "cosin":
			function_direction = direction_vector.rotated(cos(0.0 * 8.0) * 0.3)
			pass
		position += function_direction * speed * delta
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
