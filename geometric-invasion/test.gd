# This is a test script given to a test node used or me to test out moving something in a 
# Bezier curve
extends Sprite2D

# Time variable is utilized to interpolate points on the curve
var time : float = 0

# These variables are used for manually coding points in a bezier curve (first implementation)
var p0 = global_position
var p1 = Vector2(global_position.x + 100, global_position.y + 300)
var p2 = Vector2(global_position.x + 400, global_position.y)


# Point array holds an array of resources that contain x and y values between 0.0 - 1.0
@export var point_array : Array[test_resource] = []
# Speed curve is a curve that is utilize to control speed at a certain portion of the curve
@export var speed_curve : Curve
# This array stores normalized points to be pixels based on the screen size
var normalized_vec2_array : Array[Vector2] = []
# This gets the screen size
@onready var screen : Vector2 = get_viewport_rect().size
# These variables are used to sample the sepeed curve based on the 
# Distance traveled / estimated curve length
var distance_traveled : float = 0
var estimated_curve_length : float = 0 # Calculated by adding all normalized vec2 lengths (not super accurate)
# Accurate calculation of many points requires a ton of math that I'm thinking is out of scope

# Function to take percentages of points and have them be vector2's with pixel values of screen
func normalize_points() -> void:
	# Add the initial position to beginning of vector
	normalized_vec2_array.append(global_position)
	# Iterate through all points and multiply the percent given by x and y screen size
	for i in point_array:
		var temp_vec = Vector2(global_position.x + (i.x_percent * screen.x), global_position.y + (i.y_percent * screen.y))
		normalized_vec2_array.append(temp_vec)
		# Add to curve length 
		estimated_curve_length += temp_vec.length()
		pass

func _ready() -> void:
	# This code was used when manually inputting points and seeing behaviors
	#point_array.append(global_position)
	#point_array.append(Vector2(global_position.x + 100, global_position.y + 300)) 
	#point_array.append(Vector2(global_position.x + 400, global_position.y))
	
	# Now take in array of points on ready
	normalize_points()

# This function calculates a quadratic bezier based on manually inputted points by lerping
func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	print(r)
	return r

# This function takes in an array of points and calculates a bezier based on that array
func _bezier_array(av: Array[Vector2], t: float):
	# Create a temporray array to store lepred values
	var temp_array : Array[Vector2] = []
	
	# Iterate through the normalized vector array and lerp i + 1
	for i in range(av.size()):
		if i + 1 < av.size():
			var temp : Vector2 = av[i].lerp(av[i+1], t)
			temp_array.append(temp)
	
	# Return the final lerped value 
	var to_return = temp_array[0].lerp(temp_array[temp_array.size()-1], t)
	return to_return

# Calculated every physics frames
func _physics_process(delta: float) -> void:
	# Check if position equals the final position if not then interpolate across the curve
	if round(position) != round(normalized_vec2_array[normalized_vec2_array.size() - 1]):
		
		# Print used for testing
		#print(time * (global_position.length() / estimated_curve_length))
		
		# Interpolate the global position by the returned vector2, with a time affected by the speed curve clamped between 0.0 and 1.0
		global_position = _bezier_array(normalized_vec2_array, clamp(time * speed_curve.sample(global_position.length() / estimated_curve_length), 0.0, 1.0))
		#print(global_position.length())
		#print(estimated_curve_length)
		print(_bezier_array(normalized_vec2_array, clamp(time * speed_curve.sample(global_position.length() / estimated_curve_length), 0.0, 1.0)))
		
		# Other global_position interpolations for testing
		#global_position = _bezier_array(normalized_vec2_array, time * speed_curve.sample(global_position.length() / estimated_curve_length))
		#global_position = _quadratic_bezier_array(normalized_vec2_array, time)

	#position = _quadratic_bezier(p0, p1, p2, time)
	
	# Calculate the current time
	time += delta
