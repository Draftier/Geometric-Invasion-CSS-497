extends Area2D

@export var speed = 250


# Will utilize to play some sort of animation on instantiation
func _ready() -> void:
	pass

# Called every physics tick
func _physics_process(delta: float) -> void:
	# Move the bullet up
	position += transform.x * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if "take_damage" in area.get_parent():
		area.get_parent().take_damage()
	if "take_damage" in area:
		area.take_damage()
	queue_free()
	pass
