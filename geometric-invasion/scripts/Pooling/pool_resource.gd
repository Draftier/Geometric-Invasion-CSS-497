extends Resource
class_name PoolResource

enum Pools {
	PLAYER_BULLET, 
	ENEMY_BULLET, 
	ENEMY_HOMING_BULLET
	}

@export var poolable_scene : PackedScene
@export var pool_name : Pools
@export var max_pool_size : int
