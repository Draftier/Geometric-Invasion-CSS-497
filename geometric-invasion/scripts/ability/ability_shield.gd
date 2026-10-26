extends Ability

@onready var hitbox: Hitbox = $Polygon2D/Hitbox

func _ready() -> void:
	super._ready()
	
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active

@rpc("any_peer", "call_local", "reliable")
func fire_ability(delta : float) -> void:
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active

func discharge() -> void:
	super.discharge()
	
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active
