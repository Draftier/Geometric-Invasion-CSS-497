extends Node

@export var end_change_scene : PackedScene
@export var spawners : Array[Node]
@export var events : Array[Spawn_Event]
@export var level_time : float

var event_index = 0
var current_time

# Variables to store bullets
var cur_bullet_count : int = 0
var max_bullet_count : int = 1750
var bullets : Array [ Bullet ]
var bullet_index : int = 0

const bullet_scene = preload("res://scenes/obstacle_bullet_base.tscn")

func add_to_pool(bullet: Bullet) -> void:
	bullet.reset()
	bullets.append(bullet)
	

func pull_from_pool() -> Bullet:
	var object: Bullet
	if bullets.is_empty():
		object = bullet_scene.instantiate()
	else:
		object = bullets[0]
		bullets.remove_at(0)
	object.set_process(true)
	object.set_physics_process(true)
	object.visible = true
	return object

func _ready() -> void:
	for i in max_bullet_count:
		var bullet : Bullet = bullet_scene.instantiate()
		
		add_to_pool(bullet)
		
		get_tree().root.add_child(bullet)
		
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
	if(events.size() - event_index > 0 and events.size() != 0):
		for i in events.size():
			if events[i].time >= current_time as int:
				execute_event(events[i])
			event_index += 1
	print(Engine.get_frames_per_second())

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
