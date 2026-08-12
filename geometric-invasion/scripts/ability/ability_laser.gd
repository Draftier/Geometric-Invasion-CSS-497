@tool
extends Ability

@onready var ray_cast : RayCast2D = $RayCast2D
@onready var line_2d: Line2D = $RayCast2D/Line2D
@onready var collision_shape : CollisionShape2D = $RayCast2D/Hitbox/CollisionShape2D
@onready var hitbox : Hitbox = $RayCast2D/Hitbox

@export var color : Color = Color.WHITE: set = set_color

var cast_speed : float = 7000.0
var max_length : float = -2000.0

func _ready() -> void:
	super._ready()
	
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active
	
	set_color(color)
	
func fire_ability(_delta : float) -> void:
	
	ray_cast.target_position.y = move_toward(
		ray_cast.target_position.y,
		max_length,
		cast_speed * _delta
	)
	
	var laser_end_position := ray_cast.target_position
	
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		laser_end_position = ray_cast.to_local(ray_cast.get_collision_point())
	line_2d.set_point_position(1, laser_end_position)
	
	# Scale the collision shape to go towards the raycast
	collision_shape.shape.size.y = laser_end_position.length()
	collision_shape.position.y = -laser_end_position.length() / 2
	
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active
	

func discharge() -> void:
	super.discharge()
		
	hitbox.monitorable = is_active
	hitbox.monitoring = is_active

func set_color(new_color: Color) -> void:
	color = new_color
	if line_2d == null:
		return
	line_2d.modulate = new_color
