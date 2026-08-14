extends Node2D

@export_range(0, 2 * PI) var change_in_angle : float
@export var num_spawn_points : int = 3
@export_range(0, 2 * PI) var distance_between_bullets : float = 0.0

@export var bullet : PackedScene

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	$Marker2D.rotation += deg_to_rad(10)
	pass
	

func spawn_bullets() -> void:
	for i in range(num_spawn_points):
			
		pass
	pass


func _on_timer_timeout() -> void:
	print("fart")
	var b : Bullet = bullet.instantiate()
	
	b.global_rotation = $Marker2D.rotation
	b.global_position = $Marker2D.position
	add_child(b)
	b.speed = 250
	b.activate()
	$Timer.start()
	
	pass # Replace with function body.
