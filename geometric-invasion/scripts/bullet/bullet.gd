class_name Bullet
extends Poolable

@export var speed = 250
@export var shooter : String

#@onready var level_manager = get_tree().get_first_node_in_group("level_manager")

@onready var bullet_hitbox = $Sprite2D/Hitbox
#@onready var bullet_hurtbox = get_node_or_null("Sprite2D/Hurtbox")

#var is_active : bool = false

signal exited_screen

func _ready() -> void:
	bullet_hitbox.connect("hit", _on_hit)
	pass

# Called every physics tick
func _physics_process(delta: float) -> void:
	# Move the bullet up
	position += transform.x * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()	
	exited_screen.emit(self)
func _on_hit() -> void:
	pass
