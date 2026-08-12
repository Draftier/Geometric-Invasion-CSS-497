# This class represents a basic object pool that currently only pools objects of the bullet class
# TODO Track a bullet if it's active and re add that bullet to the pool if reloading or leaving scene
# This could help with performance by making it so that users don't constantly reinitialize the pool
extends Node
class_name ObjectPool

# Bullet scene that we pool
@export var bullet_scene : PackedScene

# Variables to store bullets and the max number of objects in pool
@export var max_bullet_count : int = 1000
var bullets : Array [ Bullet ]

# Function to add bullets to the object pool
func add_to_pool(bullet : Bullet) -> void:
	bullet.reset()
	get_instance_id()
	# We reparent the bullet to make sure it appears correctly in scene tree
	# Without this the bullet is visually invisible
	bullets.append(bullet)

# Function to initialize the pool with max num of objects
func initialize_pool() -> void:
	# Destroy any past pool to make sure that we don't go past max bullet count
	destroy_pool()
	# Loop to initialize the object pool whilst interleaving player and enemy bullets
	# Check if the array actually changes in size
	for i in range(0, max_bullet_count):
		# Start adding bullets to the pool
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			# Connect bullet exit signal to pool so that when bullet exits screen bullet is repooled
			bullet.connect("exited_screen", _on_bullet_exit_screen)
			add_to_pool(bullet)

# Function to pull bullets from the pool
func pull_from_pool() -> Bullet:
	var bullet: Bullet
	# Check if pool is empty or not empty, either way check type of bullet
	if bullets.is_empty():
		bullet.instantiate()
	else:
		bullet = bullets[0]
		bullets.remove_at(0)
	# Unpause calculation from bullet being pulled from pool
	bullet.activate()
	
	# Send bullet to the game scene
	# bullet.reparent(get_tree().current_scene)
	
	return bullet

# Function to add bullet to pool when bullet exits screen
func _on_bullet_exit_screen(bullet : Bullet) -> void:
	add_to_pool(bullet)

# Function to go through all bullets and get them out of pool
# Called when exiting scene or when reinitializing pool
func destroy_pool() -> void:
	for i in bullets:
		if is_instance_valid(i):
			i.queue_free()
	bullets.clear()
