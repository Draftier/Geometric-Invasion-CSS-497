extends Bullet

@onready var bullet_scale : Vector2 = self.scale

func _ready() -> void:
	super._ready()
	self.reset()

func reset() -> void:
	
	self.set_process(false)
	self.set_physics_process(false)
	
	#bullet_hitbox.set_deferred("monitoring", false)
	#bullet_hitbox.set_deferred("monitorable", false)
	
	bullet_hitbox.monitoring = false
	bullet_hitbox.monitorable = false
	
	self.set_block_signals(true)
	
	self.visible = false
	self.speed = 0
	self.scale = bullet_scale

func activate() -> void:
	self.set_process(true)
	self.set_physics_process(true)
	self.visible = true
	self.set_block_signals(false)
	self.bullet_hitbox.monitorable = true

func _on_hit() -> void:
	PoolManager.return_to_player_pool(self)
