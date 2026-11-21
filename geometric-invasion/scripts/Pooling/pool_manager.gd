# This script is used for the pool manager to add and pull objects from different object pools
extends Node2D

# These are the pools that the manager is managing
@onready var player_bullet_pool : ObjectPool = %PlayerBulletPool
@onready var enemy_bullet_pool : ObjectPool = %EnemyBulletPool
@onready var enemy_homing_bullet_pool : ObjectPool = %EnemyHomingBulletPool

# Enum to represent each pool inside a dictionary enum used to prevent spelling mistakes when obtaining from pool
enum Pools {
	PLAYER_BULLET, 
	ENEMY_BULLET, 
	ENEMY_HOMING_BULLET
	}

@export var poolable_array : Array[PoolResource]

# Dictionary to represent pools
@export var pool_dictionary  = {
	
}

func _ready() -> void:
	init_pools()
	
# These functions are here to obtain and receive poolables
func return_to_pool(Pool : Pools, poolable : Poolable) -> void:
	var pool : ObjectPool = pool_dictionary.get(Pool)
	pool.call_deferred("add_to_pool", poolable)
	
func receive_from_pool(Pool : Pools) -> Poolable:
	var pool : ObjectPool = pool_dictionary.get(Pool)
	return pool.pull_from_pool()



# These functions are utilized to destroy and initiailize pools upon level loading
func destroy_pools() -> void:
	for pool_type in pool_dictionary:
		var pool : ObjectPool = pool_dictionary.get(pool_type)
		pool.destroy_pool()
	
func init_pools() -> void:
	for pool_resource in poolable_array:
		var pool_type = pool_resource.pool_name
		var pool_scene = pool_resource.poolable_scene
		
		var temp_pool = ObjectPool.new()
		temp_pool.poolable_scene = pool_scene
		temp_pool.max_pool_size = pool_resource.max_pool_size
		
		temp_pool.name = str(Pools.find_key(pool_type)) + "_POOL"
		add_child(temp_pool)
		pool_dictionary[pool_type] = temp_pool
		
		temp_pool.initialize_pool()

# Utilized to reset pools
func reset_pools() -> void:
	for pool_type in pool_dictionary:
		var pool : ObjectPool = pool_dictionary.get(pool_type)
		pool.reset_pool()
