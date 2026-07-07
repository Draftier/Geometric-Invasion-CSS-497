extends Area2D

@export var speed = 250
var direction 

# Will utilize to play some sort of animation on instantiation
func _ready() -> void:
	pass

# Called every physics tick
func _physics_process(delta: float) -> void:
	# Move the bullet up
	position += direction * speed * delta
	
# Setup the bullet to be shot in the direction of the gun
func setup(pos: Vector2, dir: Vector2) -> void:
	global_position = pos
	direction = dir


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	print(area)
	if "hit" in area:
		area.hit()
	queue_free()
