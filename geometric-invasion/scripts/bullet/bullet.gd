class_name Bullet
extends Area2D

@export var speed = 250
@export var shooter : String

@onready var level_manager = get_tree().get_first_node_in_group("level_manager")

# Will utilize to play some sort of animation on instantiation
func _ready() -> void:
	pass

# Called every physics tick
func _physics_process(delta: float) -> void:
	# Move the bullet up
	position += transform.x * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()
	level_manager.add_to_pool(self)

func _on_area_entered(area: Area2D) -> void:
	if "take_damage" in area.get_parent():
		area.get_parent().take_damage()
	if "take_damage" in area:
		area.take_damage()
	#queue_free()
	level_manager.add_to_pool(self)

func reset() -> void:
	self.set_process(false)
	self.set_physics_process(false)
	self.visible = false
	self.speed = 0
