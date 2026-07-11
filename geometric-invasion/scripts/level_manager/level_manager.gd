extends Node

@export var end_change_scene : PackedScene
@export var spawners : Dictionary[int, String]
@export var events : Array[Spawn_Event]

var event_index = 0

func _ready() -> void:
	events.sort_custom(sort_events_ascending)
	$LevelTimer.start()
	
func _process(delta: float) -> void:
	event_index += 1
	if events[event_index] == $LevelTimer.get_time_left():
		execute_event(events[event_index])

# At end of level change scene
func _on_level_timer_timeout() -> void:
	pass # Replace with function body.
	
	
func execute_event(event : Spawn_Event) -> void:
	pass

# To use custom sort to sort events I create a custom callable
func sort_events_ascending(a : Spawn_Event, b : Spawn_Event) -> bool:
	if a.time < b.time:
		return true
	return false
