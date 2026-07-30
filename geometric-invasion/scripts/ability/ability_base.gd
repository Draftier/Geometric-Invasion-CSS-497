# This script is a base class that is supposed to be an interface for abilitie children classes
extends Node
class_name Ability

@export var data : Ability_Resource
@export var is_charged : bool = true

var is_active : bool = false

#@onready var ability_hitbox : Hitbox = $Sprite2D/Hitbox

# Disable ability at start
func _ready() -> void:
	set_physics_process(false)
	self.visible = false

# Function to activate the ability
func activate() -> bool:
	set_physics_process(true)
	
	# Check if we can activate the ability
	if can_activate() == false:
		print("Ability cannot be activated")
		return false
	
	# Active the ability and make it visible
	self.set_block_signals(false)
	self.visible = true
	
	# Make it so that physics server checks for collision masks and layers
	#ability_hitbox.monitorable = true
	#ability_hitbox.monitoring = true
	
	is_active = true
	
	# Wait for ability timer to stop
	await get_tree().create_timer(data.active_time).timeout
	
	# Discharge the ability
	discharge()
	
	return true
	
# Function to check if we can activate ability
func can_activate() -> bool:
	if is_charged == true:
		return true
	return false

# Function to charge ability
func charge() -> void:
	is_charged = true
	
# Function to discharge the ability
func discharge() -> void:
	self.set_block_signals(true)
	self.visible = false
	
	# Make it so that physics server does not check for collision masks and layers
	#self.ability_hitbox.monitorable = false
	#self.ability_hitbox.monitoring = false
	
	is_active = false
	
	# Disable ability charge
	is_charged = false
	
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if is_active:
		fire_ability(delta)

func fire_ability(delta : float) -> void:
	pass
