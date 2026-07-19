extends Node

# Variables to set after scene, spawners, events, and time to complete level
@export var end_change_scene : PackedScene
@export var spawners : Array[Node]
@export var events : Array[Spawn_Event]
@export var level_time : float

# Temp variables for playtest to track enemies on screen
@export var enemies : Array[basic_enemy]
var num_enemies

@onready var pool_node = $Pool

signal victory

# Utilized to index the event array
var event_index = 0
# Utilize to track the current time
var current_time

# Variables to store bullets
var max_bullet_count : int = 1000
var bullets : Array [ Bullet ]

# Preloading basic bullets for initial pooling
const basic_enemy_bullet = preload("res://scenes/obstacle_bullet_base.tscn")
const basic_player_bullet = preload("res://scenes/player_bullet.tscn")

# Function to ad bullets to the object pool
func add_to_pool(bullet: Bullet) -> void:
	bullet.reset()
	bullets.append(bullet)
	
# Function to pull a bullet from the pool
func pull_from_pool(type : String) -> Bullet:
	var object: Bullet
	# Check if pool is empty or not empty, either way check type of bullet
	if bullets.is_empty():
		if type == "enemy":
			object = basic_enemy_bullet.instantiate()
		elif type == "player":
			object = basic_player_bullet.instantiate()
	else:
		# Iteratively go through pool and find a bullet related to request type
		for i in range(0, bullets.size()):
			if bullets[i].shooter == null:
				print("Pool bugged")
			# When bullet type matches set reference to it and remove it from pool
			if bullets[i].shooter == type:
				object = bullets[i]
				bullets.remove_at(i)
				break
	# Unpause calculation from bullet being pulled from pool
	object.set_process(true)
	object.set_physics_process(true)
	object.visible = true
	object.set_block_signals(false)
	
	# Return reference to bullet
	return object

func initialize_pool() -> void:
	# Loop to initialize the object pool whilst interleaving player and enemy bullets
	for i in range(0, max_bullet_count):
		# Initialization for enemy bullets
		var bullet : Bullet = basic_enemy_bullet.instantiate()
		bullet.shooter = "enemy"
		add_to_pool(bullet)
		pool_node.add_child(bullet)
		
		# Interleave a player bullet every 2 enemy bullets
		if (i + 1 ) % 2 == 0:
			# Initialization for player bullets
			var player_bullet = basic_player_bullet.instantiate()
			player_bullet.shooter = "player"
			add_to_pool(player_bullet)
			pool_node.add_child(player_bullet)

func _ready() -> void:
	
	print(get_tree().paused)
	# Call to initialize pool
	call_deferred("initialize_pool")
	
	# Temporarily count the number of enemies
	num_enemies = enemies.size()
		
	#Store the time in the timer
	$LevelTimer.wait_time = level_time
	
	# Initialize current time
	current_time = (($LevelTimer.get_time_left() - $LevelTimer.wait_time) * -1)
	
	# Sort the events by the time they occur
	events.sort_custom(sort_events_ascending)
	
	# Start the timer
	$LevelTimer.start()
	
func _process(delta: float) -> void:
	# Calculate the current time every frame
	current_time = (($LevelTimer.get_time_left() - $LevelTimer.wait_time) * -1)
	
	# Iterate and execute events through the events every frame
	# This means events that have the same time will be executed within the same frame
	if(events.size() - event_index > 0 and events.size() != 0):
		# Loop through events
		for i in events.size():
			# Check if event should occur and execute if it does
			if events[i].time >= current_time as int:
				execute_event(events[i])
			event_index += 1
	
	# Debug to print out framerate
	# TODO change to logging system in future
	print(Engine.get_frames_per_second())
	
	# Lazy way to initiate victory scene (Temporary)
	if num_enemies == 0:
		victory.emit()

# At end of level change scene
func _on_level_timer_timeout() -> void:
	pass # Replace with function body.
	
	
	
# Function to execute an event
func execute_event(event : Spawn_Event) -> void:
	for i in spawners:
		if i.id == event.spawner:
			i.spawn(event)
	print(event.time)
	pass
	
# To use custom sort to sort events I create a custom callable
func sort_events_ascending(a : Spawn_Event, b : Spawn_Event) -> bool:
	if a != null and b != null:
		if a.time < b.time:
			return true
	return false


func _on_rotater_shoot_enemy_death() -> void:
	num_enemies -= 1


func _on_tree_exiting() -> void:
	for i in pool_node.get_children():
		i.queue_free()
