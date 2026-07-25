# This script is a base class that is supposed to be an interface for abilitie children classes
extends Node
class_name Ability

@export var data : Ability_Resource

var is_charged : bool = true
var ability_duration : float = 5.0

# Function to activate the ability
func activate() -> void:
	# Check if we can activate the ability
	if can_activate() == false:
		print("Ability cannot be activated")
		return
	
	# Active the ability and make it visible
	self.set_block_signals(false)
	self.visible = true
	
	# Allow ability to run for duration and after discharge the ability
	await get_tree().create_timer(ability_duration).timeout
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
	is_charged = false
