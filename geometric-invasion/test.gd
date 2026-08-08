extends Sprite2D

var time : float = 0
var p0 = global_position
var p1 = Vector2(global_position.x + 100, global_position.y + 300)
var p2 = Vector2(global_position.x + 400, global_position.y)

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
	
func _physics_process(delta: float) -> void:
	position = _quadratic_bezier(p0, p1, p2, time)
	time += delta
