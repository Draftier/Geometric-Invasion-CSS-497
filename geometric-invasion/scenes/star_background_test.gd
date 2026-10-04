extends Node2D

@onready var screen : Vector2 = get_viewport_rect().size

@export var num_stars = 125

class Star:
	var position : Vector2
	var speed : float
	var size : float
	var brightness : float
	var length : float

var stars : Array = []

func _ready() -> void:
	for i in num_stars:
		var temp_star : Star = Star.new()
		temp_star.position = Vector2(randf_range(0.0, screen.x), randf_range(0.0, screen.y))
		
		var depth := randf()
		
		temp_star.speed = lerp(100, 240, depth)
		temp_star.size = lerp(1.0, 4.0, depth)
		temp_star.brightness = lerp(0.3, 1.0, depth)
		temp_star.length = lerp(1.0, 4.0, depth)
		
		stars.append(temp_star)
		

func _draw():
	for i in stars:
		draw_rect(Rect2(i.position, Vector2(i.size, i.size * i.length)), Color(i.brightness, i.brightness, i.brightness))

func _process(_delta):
	
	for i in stars:
		i.position.y += i.speed * _delta
		
		if i.position.y > screen.y:
			i.position.y = -i.size
			i.position.x = randf_range(0.0, screen.x)
	
	queue_redraw()
