# This class represents a basic object pool that currently only pools objects of the bullet class
# TODO Track a bullet if it's active and re add that bullet to the pool if reloading or leaving scene
# This could help with performance by making it so that users don't constantly reinitialize the pool
extends Node
class_name ObjectPool

# Variable used to id objects in a pool
var current_id : int = 0

# Bullet scene that we pool
#@export var bullet_scene : PackedScene
@export var poolable_scene : PackedScene

# Variables to store bullets and the max number of objects in pool
var poolables : Array [ Poolable ]
@export var max_pool_size : int = 1000

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_change)

# Function to add bullets to the object pool
func add_to_pool(poolable : Node) -> void:
	#bullet.reset()
	#get_instance_id()
	## We reparent the bullet to make sure it appears correctly in scene tree
	## Without this the bullet is visually invisible
	#poolable.id = current_id + 1
	#current_id = poolable.id
		
	#bullets.append(bullet)
	#if poolable is enemy_homing_bullet:
		#poolable.name = "Homing_bullet" + str(poolable.id)
	
	poolable.reset()
	poolable.is_active = false
	poolables.append(poolable)

# Function to initialize the pool with max num of objects
func initialize_pool() -> void:
	# Destroy any past pool to make sure that we don't go past max bullet count
	destroy_pool()
	# Loop to initialize the object pool whilst interleaving player and enemy bullets
	# Check if the array actually changes in size
	for i in range(0, max_pool_size):
		# Start adding bullets to the pool
			var poolable = poolable_scene.instantiate()
			
			poolable.id = current_id + 1
			current_id = poolable.id
			
			poolable.name = poolable.get_script().get_global_name() + str(poolable.id)
			add_child(poolable)
			# Connect bullet exit signal to pool so that when bullet exits screen bullet is repooled
			poolable.connect("exited_screen", _on_bullet_exit_screen)
			add_to_pool(poolable)

# Function to pull bullets from the pool
func pull_from_pool() -> Node:
	var poolable: Node
	# Check if pool is empty or not empty, either way check type of bullet
	if poolables.is_empty():
		poolable = poolable_scene.instantiate()
	else:
		#bullet = bullets[0]
		#bullets.remove_at(0)
		for i in poolables:
			if i.is_active == false:
				poolable = i
	
	if poolable is Bullet && poolable == null:
		poolable = poolable_scene.instantiate()
		add_child(poolable)
		poolable.connect("exited_screen", _on_bullet_exit_screen)
		add_to_pool(poolable)
	
	# Unpause calculation from bullet being pulled from pool
	poolable.activate()
	
	return poolable

# Function to add bullet to pool when bullet exits screen
func _on_bullet_exit_screen(poolable : Node) -> void:
	add_to_pool(poolable)

# Function to go through all bullets and get them out of pool
# Called when exiting scene or when reinitializing pool
func destroy_pool() -> void:
	for i in poolables:
		if is_instance_valid(i):
			i.queue_free()
	poolables.clear()

func reset_pool() -> void:
	for i in poolables:
		if i.is_active == true:
			i.reset()

func _on_scene_change() -> void:
	reset_pool()
