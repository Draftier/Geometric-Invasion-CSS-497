class_name Level_Manager
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


func _ready() -> void:	
	# Connect enemy death signals
	for i in enemies:
		i.connect("death", _on_enemy_death)
	
	# Temporarily count the number of enemies
	num_enemies = enemies.size()
	print(enemies.size())
		
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
	current_time = (($LevelTimer.get_time_left() - $LevelTimer.wait_time) * -1)
	
	# Iterate and execute events through the events every frame
	# This means events that have the same time will be executed within the same frame
	if(events.size() - event_index > 0 and events.size() != 0):
		# Loop through events
		for i in events.size():
			# Check if event should occur and execute if it does
			if events[i].time_to_occur >= current_time as int:
				execute_event(events[i])
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
func execute_event(event : Spawn_Event) -> void:
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

func _on_tree_exiting() -> void:
	for i in pool_node.get_children():
		i.queue_free()


func _on_enemy_death() -> void:
	num_enemies -= 1
	# print(num_enemies)
