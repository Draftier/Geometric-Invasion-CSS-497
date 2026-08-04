class_name Bullet
extends Node2D

@export var speed = 250
@export var shooter : String


@onready var level_manager = get_tree().get_first_node_in_group("level_manager")

@onready var bullet_hitbox = $Sprite2D/Hitbox
#@onready var bullet_hurtbox = get_node_or_null("Sprite2D/Hurtbox")

signal exited_screen

# Will utilize to play some sort of animation on instantiation
func _ready() -> void: 
	pass

# Called every physics tick
func _physics_process(delta: float) -> void:
	# Move the bullet up
	position += transform.x * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()
	
	# TODO after quit fix bug where when user goes back into game and framerate is low
	# Probably due to something with the object pool
	# This is done as when user quits and scene changes, bullets are still trying to get into object pool?
	if level_manager != null:
		level_manager.add_to_pool(self)
		
	exited_screen.emit(self)
