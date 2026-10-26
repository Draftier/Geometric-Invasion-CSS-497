class_name Level_Manager
extends Node

@onready var enemy_node = $Enemies

# Variables to set after scene, spawners, events, and time to complete level
@export var end_change_scene : PackedScene
@export var spawners : Array[Node]
@export var events : Array[Spawn_Event]
@export var level_time : float

# Temp variables for playtest to track enemies on screen
var num_enemies
@export var enemies = {}
@export var power_up_charge : PackedScene

signal victory

# Utilized to index the event array
var event_index = 0
# Utilize to track the current time
var current_time

var current_enemy_id = 0
var current_power_up_id = 0

func _ready() -> void:	
	## Connect enemy death signals
	#for i in enemies:
		#i.connect("death", _on_enemy_death)
	
	## Temporarily count the number of enemies
	#num_enemies = enemies.size()
	#print(enemies.size())	
	
	
	#Store the time in the timer
	$LevelTimer.wait_time = level_time
	
	# Initialize current time
	current_time = (($LevelTimer.get_time_left() - $LevelTimer.wait_time) * -1)
	
	# Sort the events by the time they occur
	events.sort_custom(sort_events_ascending)
	
	# Start the timer
	$LevelTimer.start()
	
func _process(_delta: float) -> void:
	# Calculate the current time every frame
	current_time = (($LevelTimer.time_left - $LevelTimer.wait_time) * -1)
	
	# Iterate and execute events through the events every frame
	# This means events that have the same time will be executed within the same frame
	if(events.size() - event_index > 0 and events.size() != 0):
		## Loop through events
		if events[event_index].time_to_occur <= current_time:
			print("Current_time: ", current_time)
			if multiplayer.is_server():
				execute_event.rpc(event_index)
			#execute_event(events[event_index])
			event_index += 1
	
	$Label.text = "Time left: " + str($LevelTimer.time_left as int)
	# Debug to print out framerate
	# TODO change to logging system in future
	# print(Engine.get_frames_per_second())
	
	# Lazy way to initiate victory scene (Temporary)
	#if num_enemies == 0:
		#victory.emit()
	

# At end of level change scene
func _on_level_timer_timeout() -> void:
	victory.emit()
	

# Function to execute an event
@rpc("authority", "call_local", "reliable")
func execute_event(event_index : int) -> void:
	var event = events[event_index]
	for spawn_data in event.spawns:
		print(
			"Peer: ", multiplayer.get_unique_id(),
			" | Event: ", event_index,
			" | Attack count: ", spawn_data.enemy_attack_pattern.size()
		)
	for i in spawners:
		if i.id == event.spawner:
			i.execute_spawn_event(event)
	print(event.time_to_occur)
	pass
	
# To use custom sort to sort events I create a custom callable
func sort_events_ascending(a : Spawn_Event, b : Spawn_Event) -> bool:
	if a != null and b != null:
		if a.time_to_occur < b.time_to_occur:
			return true
	return false

func _on_enemy_death() -> void:
	num_enemies -= 1
	# print(num_enemies)

@rpc("any_peer", "call_remote", "reliable")
func request_take_damage(id : int, damage : float) -> void:
	if !multiplayer.is_server():
		return
	
	#var enemy = enemies[id]
	var enemy = enemies.get(id)
	
	if !is_instance_valid(enemy):
		return
	
	if enemy.is_dead or enemy.is_queued_for_deletion():
		return
	
	enemy.take_damage(damage)
	

	
func on_enemy_hit_reported(id : int, damage : float) -> void:
	if multiplayer.is_server():
		request_take_damage(id, damage)
	else:
		request_take_damage.rpc_id(1, id, damage)

func on_enemy_death(id : int) -> void:
	if !multiplayer.is_server():
		return
	
	remove_enemy.rpc(id)
	
@rpc("authority", "call_local", "reliable")
func remove_enemy(id : int) -> void:
	
	print("enemy removed")
	var enemy = enemies.get(id)
	if is_instance_valid(enemy):
		print("Enemy with id: " + str(enemy.id) + " removed from dictionary")
		
		if multiplayer.is_server():
			# Roll the dice for spawning a ability pickup
			if randf() < 0.5:
				#spawn_pickup(enemy.position)
				prepare_pickup(enemy.position)
				pass
		
		enemies.erase(id)
		enemy.queue_free()
	pass


@rpc("authority", "call_local", "reliable")
func spawn_pickup(id : int, position : Vector2) -> void:
	var power_up = power_up_charge.instantiate()
	power_up.position = position
	
	power_up.id = id
	power_up.name = "power_up_" + str(power_up.id)
	
	get_parent().call_deferred("add_child", power_up)

func prepare_pickup(position : Vector2) -> void:
	if !multiplayer.is_server():
		return
		
	var id = current_power_up_id
	current_power_up_id += 1
	
	spawn_pickup.rpc(id, position)


func on_enemy_ready(enemy : basic_enemy) -> void:
	enemies[enemy.id] = enemy
