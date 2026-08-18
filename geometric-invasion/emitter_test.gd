@tool
extends Node2D
class_name emitter_test

@export_range(0, 2 * PI) var change_in_angle : float
@export var num_spawn_points : int = 20
@export_range(0, 2 * PI) var distance_between_bullets : float = 0.0
@export var bullet_speed : float

var theta : float
var prev_rotation : float = 0.0
var cur_rotation : float = 0.0

@export var test_array : Array[emitter_test_resource] = []

@export var bullet : PackedScene
@export var emitter : PackedScene

func activate() -> void:
	pass
	
func reset() -> void:
	pass

func _ready() -> void:
	assert(bullet_speed > 0, "Bullet speed is set to 0")
	theta = $Marker2D.rotation
	
	if $Timer.timeout.is_connected(_on_timer_timeout):
		$Timer.timeout.disconnect(_on_timer_timeout)
	
	$Timer.timeout.connect(_on_timer_timeout)
	pass

func _physics_process(delta: float) -> void:
	#$Marker2D.rotation += deg_to_rad(10)
	pass


func _on_timer_timeout() -> void:
	for i in range (1, num_spawn_points+1):
		var b : Bullet = bullet.instantiate()
		#b.global_rotation = clamp(rad_to_deg($Marker2D.rotation), 0, 360)
		theta = distance_between_bullets
		#clamp(theta, 0,distance_between_bullets)
		#fmod(theta, distance_between_bullets)
		#b.global_rotation = self.global_position.rotated(theta * i).angle()
		b.global_rotation = (global_rotation + ((theta / num_spawn_points) * i))
		var temp = PoolManager.emitter_pool.pull_from_pool()
		temp.emitter = emitter
		temp.bullet = bullet
		temp.change_in_angle = change_in_angle
		temp.distance_between_bullets = distance_between_bullets
		temp.bullet_speed = bullet_speed
		temp.global_position = b.global_position
		b.emitter = temp
		add_child(b)
		
		if i == 0:
			print(b.global_rotation)
		#print(self.global_position.rotated(theta * i).angle())
		b.speed = 250
		b.activate()
		
		
	#for i in test_array:
		#var b : Bullet = bullet.instantiate()
		#b.global_rotation = i.radians
		#
		#add_child(b)
		#b.speed = 250
		#b.activate()
		#pass
	$Timer.start()
	
	# Create a spawn point at each rotated distance
	#for i in range (spawn_point_count):
		#var spawn_point = Node2D.new()
		#var pos = Vector2(radius, 0).rotated(step * i)
		#spawn_point.position = pos
		#spawn_point.rotation = pos.angle()
		#rotater.add_child(spawn_point)
	
	pass # Replace with function body.
