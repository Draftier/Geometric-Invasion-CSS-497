extends Node2D

@onready var screen : Vector2 = get_viewport_rect().size

@export var num_stars = 125

# Object that represents values of a star
class Star:
	var brightness : float
	var size : float
	var speed : float
	var length : float
	var position : Vector2

# Datastructure to hold stars
var stars : Array = []

func _ready() -> void:
	
	# Loop through and create stars
	for i in num_stars:
		# Allocate a temporary star
		var temp_star : Star = Star.new()
		
		
		# Allocate a "depth" value, this is used as a multiplier to tie together values of star like brightness to size etc
		var depth : float = randf()
		
		# Set the values of the star using lerp to make each value depend on depth
		temp_star.position = Vector2(randf_range(0.0, screen.x), randf_range(0.0, screen.y))
		temp_star.brightness = lerp (0.1, 1.0, depth)
		temp_star.size = lerp(1.0, 4.0, depth)
		temp_star.speed = lerp(100, 240, depth)
		temp_star.length = lerp(1.0, 3.0, depth)
		
		# Add the star to the stars array
		stars.append(temp_star)

# Draw the stars as rectangles 
func _draw() -> void:
	for i in stars:
		draw_rect(Rect2(i.position, Vector2(i.size, i.size * i.length)), Color(i.brightness, i.brightness, i.brightness))
	
func _process(delta: float) -> void:
	# Move the stars down along the screen
	for i in stars:
		i.position.y += i.speed * delta
	
		# Reset star positions if they go out of viewport 
		if i.position.y > screen.y:
			i.position.x = randf_range(0.0, screen.x)
			i.position.y = -1
			
	# Refresh to apply different position to drawn rectangles
	queue_redraw()
