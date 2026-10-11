class_name ShootPoint
extends Node2D
@export var stats : ShootPointStats
@export var shooter : String = ""
@onready var level_manager = get_tree().get_first_node_in_group("level_manager")

# Variable used to track whether or not point can fire another bullet within timer
var can_shoot : bool = true

func _ready() -> void:
	# Set the fire rate based on resource
	$FireRateTimer.wait_time = stats.fire_rate

# When the fire rate timer times out, allow shooting bullets
func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true

@rpc("authority", "call_local", "reliable")
func shoot() -> void:
	# Fire bullet then reset can_shoot flag so that we can keep bullet fire rate within timer time
	if can_shoot == true:
		# Instantiate the bullet shot by player, set speed, positiona, and rotation and start firerate timer
		var bullet
		#if get_parent().get_parent().is_in_group("player"):
			#bullet = level_manager.pull_from_pool("player")
		#else:
			#bullet = level_manager.pull_from_pool("enemy")
		
		if shooter == "player":
			bullet = PoolManager.give_player_bullet()
			bullet.speed = 2000 * get_parent().get_parent().scale
			bullet.scale *= get_parent().get_parent().scale
		else:
			bullet = PoolManager.give_enemy_bullet()
			bullet.speed = 100
		
		
		bullet.global_position = $Muzzle.global_position
		bullet.global_rotation = $Muzzle.global_rotation
		bullet.activate()
		#add_child(bullet)
		$FireRateTimer.start()
		can_shoot = false
