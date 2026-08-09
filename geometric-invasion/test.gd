extends Sprite2D

var time : float = 0
var p0 = global_position
var p1 = Vector2(global_position.x + 100, global_position.y + 300)
var p2 = Vector2(global_position.x + 400, global_position.y)
@export var point_array : Array[test_resource] = []
var normalized_vec2_array : Array[Vector2] = []
@onready var screen : Vector2 = get_viewport_rect().size

func normalize_points() -> void:
	normalized_vec2_array.append(global_position)
	for i in point_array:
		var temp_vec = Vector2(global_position.x + (i.x_percent * screen.x), global_position.y + (i.y_percent * screen.y))
		normalized_vec2_array.append(temp_vec)
		pass

func _ready() -> void:
	#point_array.append(global_position)
	#point_array.append(Vector2(global_position.x + 100, global_position.y + 300)) 
	#point_array.append(Vector2(global_position.x + 400, global_position.y))
	normalize_points()

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	print(r)
	return r
	
func _quadratic_bezier_array(av: Array[Vector2], t: float):
	var temp_array : Array[Vector2] = []
	for i in range(av.size()):
		if i + 1 < av.size():
			var temp : Vector2 = av[i].lerp(av[i+1], t)
			temp_array.append(temp)
	var to_return = temp_array[0].lerp(temp_array[temp_array.size()-1], t)
	print(to_return)
	return to_return
	
func _physics_process(delta: float) -> void:
	if round(position) != round(normalized_vec2_array[normalized_vec2_array.size() - 1]):
		position = _quadratic_bezier_array(normalized_vec2_array, time)
	#position = _quadratic_bezier(p0, p1, p2, time)
	time += delta
