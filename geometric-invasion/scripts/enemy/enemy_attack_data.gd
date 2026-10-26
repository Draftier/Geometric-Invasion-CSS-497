extends Resource
class_name EnemyAttackData

@export_range(0, 2 * PI) var change_in_angle : float
@export var num_spawn_points : int = 20
@export_range(0, 2 * PI) var angular_spread : float = 0.0
@export var bullet_speed : float

@export var max_times_to_fire : int
@export var fire_rate : float

@export var is_rotate : bool
@export var max_times_to_rotate : int
@export_range(0, 2 * PI) var initial_theta : float
