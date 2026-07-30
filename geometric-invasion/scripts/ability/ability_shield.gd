extends Ability

@onready var hitbox: Hitbox = $Polygon2D/Hitbox

func _ready() -> void:
	super._ready()
	
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active

func fire_ability(delta : float) -> void:
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active
