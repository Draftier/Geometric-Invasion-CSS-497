# This script is a base class that is supposed to be an interface for abilitie children classes
extends Node
class_name Ability

@export var data : Ability_Resource
@export var is_charged : bool = true

@onready var ability_hitbox : Hitbox = $Sprite2D/Hitbox

# Disable ability at start
func _ready() -> void:
	ability_hitbox.monitorable = false
	ability_hitbox.monitoring = false

# Function to activate the ability
func activate() -> void:
	# Check if we can activate the ability
	if can_activate() == false:
		print("Ability cannot be activated")
		return
	
	# Active the ability and make it visible
	self.set_block_signals(false)
	self.visible = true
	
	ability_hitbox.monitorable = true
	ability_hitbox.monitoring = true
	
	# Allow ability to run for duration and after discharge the ability
	await get_tree().create_timer(data.active_time).timeout
	discharge()
	
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
	
	self.ability_hitbox.monitorable = false
	self.ability_hitbox.monitoring = false

	is_charged = false
