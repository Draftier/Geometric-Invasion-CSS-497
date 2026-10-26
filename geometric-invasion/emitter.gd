@tool
extends Node2D
class_name Emitter

signal event_finished

@export var attack_event : EnemyAttackData

@export var bullet_speed : float

var theta : float

@export var bullet : PackedScene

var num_times_fired : int = 0
var num_times_rotated : int = 0

func set_attack_event(attack : EnemyAttackData) -> void:
	num_times_fired = 0
	num_times_rotated = 0
	theta = attack.initial_theta
	
	$Marker2D.rotation = attack.initial_theta
	theta = $Marker2D.rotation
	$Timer.wait_time = attack.fire_rate
	$Timer.start()
	attack_event = attack

func _on_timer_timeout() -> void:
	$Timer.stop()
	
	if num_times_fired < attack_event.max_times_to_fire:
		$Timer.start()
	else:
		event_finished.emit()
		return
	
	for i in range (1, attack_event.num_spawn_points+1):
		var bullet = PoolManager.give_enemy_bullet()
		bullet.speed = attack_event.bullet_speed
		
		bullet.global_position = self.global_position
		
		var space_between_bullets = attack_event.angular_spread / attack_event.num_spawn_points
		bullet.global_rotation = global_rotation + space_between_bullets * i + theta
		
		bullet.activate()
		
	if attack_event.is_rotate == true:
		if num_times_rotated < attack_event.max_times_to_rotate:
			num_times_rotated += 1
			theta += attack_event.change_in_angle
	
	num_times_fired += 1
