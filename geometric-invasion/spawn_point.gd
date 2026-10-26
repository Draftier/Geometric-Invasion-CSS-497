extends Node2D
class_name EnemySpawnPoint

@export var id : int
@export var spawn_interval : float
@export var event : Spawn_Event

var level_manager : Level_Manager

var num = 0


func _ready() -> void:
	level_manager = get_parent()


# Function to spawn enemies given a spawn event
func execute_spawn_event(event : Spawn_Event) -> void:
	# Check to see if event is null for debugging
	assert(event != null, "Event given to spawner is null")
	
	# Loop through array of spawns and spawn related enemies
	for i in event.spawns:
		for j in i.number_of_enemies:
			var enemy = i.enemy.instantiate()
			enemy.movement_events = i.enemy_movement_pattern
			enemy.global_position = global_position
			enemy.rotation_degrees = i.rotation
			
			enemy.id = level_manager.current_enemy_id
			level_manager.current_enemy_id = enemy.id + 1
			
			enemy.attack_events = i.enemy_attack_pattern
			
			enemy.hit_report.connect(get_parent().on_enemy_hit_reported)
			enemy.death.connect(get_parent().on_enemy_death)
			get_node("../Enemies").add_child.call_deferred(enemy)
			
			enemy.ready.connect(level_manager.on_enemy_ready.bind(enemy), CONNECT_ONE_SHOT)
			
			var timer = get_tree().create_timer(event.time_between_spawns)
			await timer.timeout
		pass
	print("spawning")

# Process to check if logic works
#func _process(delta: float) -> void:
	##num += 1
	##if num == 1:
		##execute_spawn_event(event)
