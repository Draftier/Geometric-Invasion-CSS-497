extends Node

@export var id : int

func spawn(event : Spawn_Event) -> void:
	print("hi")
	for i in event.num_enemies:
		print("first loop ran")
		for j in event.obstacle_pattern:
			print ("second loop ran")
			var obstacle = j.instantiate()
			obstacle.path = event.path
			get_parent().add_child(obstacle)
