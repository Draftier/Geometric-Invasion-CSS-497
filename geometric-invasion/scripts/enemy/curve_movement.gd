extends Movement
class_name CurveMovement

var normalized_vec2_array : Array[Vector2] = []
var estimated_curve_length : float = 0.0
var target_pos : Vector2

@export var point_array : Array[Point] = []

# Function to take percentages of points and have them be vector2's with pixel values of screen
func normalize_points(node : Node2D, screen_size : Vector2) -> void:
	# Add the initial position to beginning of vector
	normalized_vec2_array.append(node.global_position)
	# Iterate through all points and multiply the percent given by x and y screen size
	for i in point_array:
		var temp_vec = Vector2(node.global_position.x + (i.x_percent * screen_size.x), node.global_position.y + (i.y_percent * screen_size.y))
		normalized_vec2_array.append(temp_vec)
		# Add to curve length 
		estimated_curve_length += temp_vec.length()
	
	target_pos = normalized_vec2_array[normalized_vec2_array.size() - 1]
