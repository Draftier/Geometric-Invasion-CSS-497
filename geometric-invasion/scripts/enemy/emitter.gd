@tool
extends Node2D
class_name Emitter

signal event_finished

@export var attack_event : EnemyAttackData

@export var bullet_speed : float
@export var is_home : bool = false

var theta : float


var num_times_fired : int = 0
var num_times_rotated : int = 0

#func _ready() -> void:
	#$Timer.start()
	#$Timer.wait_time = attack_event.fire_rate

func set_attack_event(attack : EnemyAttackData) -> void:
	num_times_fired = 0
	num_times_rotated = 0
	theta = attack.initial_theta
	is_home = attack.is_homing
	
	$Marker2D.rotation = attack.initial_theta
	theta = $Marker2D.rotation
	$Timer.wait_time = attack.fire_rate
	$Timer.start()
	attack_event = attack

@rpc("authority", "call_local", "reliable")
func spawn_bullets(origin_pos : Vector2, base_angle : float, angular_spread : float, num_spawn_points : int, bullet_speed : float, homing : bool) -> void:
	
	for i in range (1, num_spawn_points+1):
		var bullet	
		if is_home == true:
			#bullet = PoolManager.give_enemy_homing_bullet()
			bullet = PoolManager.receive_from_pool(PoolManager.Pools.ENEMY_HOMING_BULLET)
		else:
			#bullet = PoolManager.give_enemy_bullet()
			bullet = PoolManager.receive_from_pool(PoolManager.Pools.ENEMY_BULLET)		
		
		#var bullet = bullet_scene.instantiate()
		
		bullet.speed = attack_event.bullet_speed
		
		bullet.global_position = origin_pos
		
		var space_between_bullets = angular_spread / num_spawn_points
		bullet.global_rotation = base_angle + space_between_bullets * i
		
		#add_child(bullet)
		bullet.activate()
	pass

func _on_timer_timeout() -> void:
	#print("Time fired: ", str(Time.get_ticks_msec()))
	if !multiplayer.is_server() || (!multiplayer.is_server() && NetworkManager.is_solo == false):
		return
		
	$Timer.stop()
	
	if num_times_fired < attack_event.max_times_to_fire:
		$Timer.start()
	else:
		event_finished.emit()
		return
	
	spawn_bullets.rpc(global_position, global_rotation + theta, attack_event.angular_spread, attack_event.num_spawn_points, attack_event.bullet_speed, is_home)
	
	if attack_event.is_rotate == true:
		if num_times_rotated < attack_event.max_times_to_rotate:
			num_times_rotated += 1
			theta += attack_event.change_in_angle
	
	num_times_fired += 1
	#print("Emitter position: ", self.global_position)
	pass
