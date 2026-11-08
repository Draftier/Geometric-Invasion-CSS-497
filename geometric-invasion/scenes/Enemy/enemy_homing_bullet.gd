extends EnemyBullet
class_name enemy_homing_bullet

var _target
var already_homed : bool = false
var id : int = 0

func _process(delta: float) -> void:
	if _target == null:
		return
	elif already_homed == false:
		if self.global_position.distance_to(_target.global_position) <= 5:
			already_homed = true
			return
		look_at(_target.global_position)
		global_position = global_position.move_toward(_target.global_position, (speed/10) * delta)
		
func _on_detection_area_area_entered(area: Area2D) -> void:
	if multiplayer.is_server():
		set_target.rpc(area.owner.get_path())

@rpc("authority", "call_local", "reliable")
func set_target(player_path : NodePath) -> void:
	_target = get_node(player_path) as Player
