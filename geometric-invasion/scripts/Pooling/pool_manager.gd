# This script is used for the pool manager to add and pull objects from different object pools
extends Node2D

# These are the pools that the manager is managing
@onready var player_bullet_pool : ObjectPool = %PlayerBulletPool
@onready var enemy_bullet_pool : ObjectPool = %EnemyBulletPool
@onready var emitter_pool : ObjectPool = %EmitterPool

# These functions get bullets from their respective pool
func give_player_bullet() -> Bullet:
	return player_bullet_pool.pull_from_pool()

func give_enemy_bullet() -> Bullet:
	return enemy_bullet_pool.pull_from_pool()

# These function return bullets from their respective pool
func return_to_player_pool(bullet : Bullet) -> void:
	player_bullet_pool.call_deferred("add_to_pool", bullet)
	
func return_to_enemy_pool(bullet : Bullet) -> void:
	enemy_bullet_pool.call_deferred("add_to_pool", bullet)

func give_emitter() -> emitter_test:
	return emitter_pool.pull_from_pool()
	
# These functions are utilized to destroy and initiailize pools upon level loading
func destroy_pools() -> void:
	enemy_bullet_pool.destroy_pool()
	player_bullet_pool.destroy_pool()
	
func init_pools() -> void:
	enemy_bullet_pool.initialize_pool()
	player_bullet_pool.initialize_pool()
	#emitter_pool.initialize_pool()
