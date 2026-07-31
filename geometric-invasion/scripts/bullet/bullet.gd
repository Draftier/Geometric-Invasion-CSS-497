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
	bullet_hitbox.connect("hit", _on_hit)

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

func reset() -> void:
	pass
	#self.set_block_signals(true)
	#self.set_process(false)
	#self.set_physics_process(false)
	#
	## Modifying monitoring of hitbox and hurtbox trying to see if this improves performance
	#if bullet_hurtbox != null:
		#bullet_hurtbox.monitoring = false
		#bullet_hurtbox.monitorable = false
	#
	#bullet_hitbox.monitoring = false
	#bullet_hitbox.monitorable = false
	#
	#self.visible = false
	#self.speed = 0

func _on_hit() -> void:
	pass
