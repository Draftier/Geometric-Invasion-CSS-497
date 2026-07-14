extends "enemy.gd"

@export var path : PathFollow2D
@export var free_on_path_complete : bool = false

func _process(delta: float) -> void:
	# Have the enemy follow a path at a certain speed
	path.progress_ratio += delta * move_speed / 8
	
	# Rotate the pivot
	rotate_pivot(delta)
	
	# When path done follow free the enemy
	if path.progress_ratio >= 1.0 and free_on_path_complete:
		queue_free()
