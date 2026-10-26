extends Bullet

@onready var bullet_hurtbox = %Hurtbox

func _ready() -> void:
	super._ready()
	self.reset()


func reset() -> void:
	self.set_block_signals(true)
	self.set_process(false)
	self.set_physics_process(false)
	
	# Modifying monitoring of hitbox and hurtbox trying to see if this improves performance
	bullet_hurtbox.monitoring = false
	bullet_hurtbox.monitorable = false
	
	
	bullet_hitbox.monitoring = false
	bullet_hitbox.monitorable = false
	
	#bullet_hurtbox.set_deferred("monitoring", false)
	#bullet_hurtbox.set_deferred("monitorable", false)
	#
	#bullet_hitbox.set_deferred("monitoring", false)
	#bullet_hitbox.set_deferred("monitorable", false)
	
	self.visible = false
	self.speed = 0
	
	self.is_active = false

func activate() -> void:	
	self.set_process(true)
	self.set_physics_process(true)
	self.visible = true
	self.set_block_signals(false)
	self.bullet_hitbox.monitorable = true
	self.bullet_hurtbox.monitoring = true
	
	self.is_active = true

func _on_hit() -> void:
	PoolManager.return_to_enemy_pool(self)

func _on_tree_exiting() -> void:
	PoolManager.return_to_enemy_pool(self)
