extends Node2D
class_name EnemySpawnPoint

@export var id : int
@export var spawn_interval : float
@export var event : Spawn_Event

var level_manager : Level_Manager

var num = 0
var time_start : float

func _ready() -> void:
	level_manager = get_parent()


# Function to spawn enemies given a spawn event
func execute_spawn_event(event : Spawn_Event) -> void:
	# Check to see if event is null for debugging
	assert(event != null, "Event given to spawner is null")
	
	# Variables utilized for timing spawns between each other
	
	# What spawn we are at
	var spawn_index : int = 0
	
	# When did the spawn_event start
	var event_execution_start : int = Time.get_ticks_msec()
	
	# Scheduled time to spawn an enemy
	var time_spawn_is_due : float
	
	# How much time has passed since spawn_event start
	var time_passed_in_seconds : float
	
	# How much time left to wait between spawning enemies
	var time_to_wait_in_seconds : float
	
	# Loop through array of spawns and spawn related enemies
	for i in event.spawns:
		for j in i.number_of_enemies:
			# Obtain when next spawn is due relative to wave_start time by multiping the spawn we are 
			# at by how much time is supposed to be between spawns
			time_spawn_is_due = spawn_index * event.time_between_spawns
			
			# Obtain how much time has passed since the start of executing spawn event divide by 1000 to turn ms into seconds
			time_passed_in_seconds = (Time.get_ticks_msec() - event_execution_start) / 1000.0
			
			# Obtain how much time is left to wait to get to time_spawn_is due
			time_to_wait_in_seconds = time_spawn_is_due - time_passed_in_seconds
			
			# If time till spawn is due is greater than 0 then await that time
			# Otherwise immediately go to next spawn event
			if time_to_wait_in_seconds > 0.0:
				var timer = get_tree().create_timer(time_to_wait_in_seconds)
				await timer.timeout
				
			print("Time event spawned at: ", str(level_manager.current_time))
			
			# Create the enemy and set initial position and movement events
			var enemy = i.enemy.instantiate()
			enemy.movement_events = i.enemy_movement_pattern
			enemy.global_position = global_position
			enemy.rotation_degrees = i.rotation
			
			# Set enemy id and go to next enemty id
			enemy.id = level_manager.current_enemy_id
			level_manager.current_enemy_id = enemy.id + 1
			
			# Set enemy attack events
			enemy.attack_events = i.enemy_attack_pattern
			
			# Connect death and hit_report signals to level_manager functions
			enemy.hit_report.connect(get_parent().on_enemy_hit_reported)
			enemy.death.connect(get_parent().on_enemy_death)
			
			if i.enemy_stats != null:
				enemy.enemy_stats = i.enemy_stats
				enemy.health = i.enemy_stats.health
				enemy.speed = i.enemy_stats.speed
			
			# Add enemy to be a child of a "Enemies" node which is a child of level manager
			get_node("../Enemies").add_child.call_deferred(enemy)
			
			# Connect enemy ready signal to level manager function
			enemy.ready.connect(level_manager.on_enemy_ready.bind(enemy), CONNECT_ONE_SHOT)
			
			# Go to next enemy spawn
			spawn_index += 1

# Process to check if logic works
#func _process(delta: float) -> void:
	##num += 1
	##if num == 1:
		##execute_spawn_event(event)
