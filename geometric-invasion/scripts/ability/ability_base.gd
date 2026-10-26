# This script is a base class that is supposed to be an interface for abilitie children classes
extends Node
class_name Ability

@export var data : Ability_Resource
@export var is_charged : bool = true

var is_active : bool = false

signal charge_state_changed(id : int, state : bool)

var player_id : int

#@onready var ability_hitbox : Hitbox = $Sprite2D/Hitbox

# Disable ability at start
func _ready() -> void:
	player_id = get_parent().id
	
	set_physics_process(false)
	self.visible = false
	
# Function to activate the ability
@rpc("any_peer", "call_local", "reliable")
func activate() -> bool:
	if is_active == true:
		print("Ability is already active, cannot activate while active")
		return false
	
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
	
	charge_state_changed.emit(player_id, false)
	is_charged = false
	
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
@rpc("any_peer", "call_local", "reliable")
func charge() -> void:
	self.set_block_signals(false)
	if !multiplayer.is_server() and multiplayer.get_remote_sender_id() != 1 and NetworkManager.is_solo == false:
		return
	is_charged = true
	
	charge_state_changed.emit(player_id, true)
	
	

# Function to discharge the ability
func discharge() -> void:
	self.set_block_signals(true)
	self.visible = false
	
	# Make it so that physics server does not check for collision masks and layers
	#self.ability_hitbox.monitorable = false
	#self.ability_hitbox.monitoring = false
	
	is_active = false
	
	if is_charged == true:
		set_physics_process(false)
		return
	
	## Disable ability charge
	#is_charged = false
	
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if is_active:
		fire_ability(delta)
		#if multiplayer.is_server():
			#print("Host is firing ability")
		#else:
			#print("Client is firing ability")
		#fire_ability.rpc(delta)

@rpc("authority", "call_local", "reliable")
func fire_ability(_delta : float) -> void:
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func request_fire_ability(delta : float) -> void:
	if !multiplayer.is_server():
		return
		
	if can_activate() == true:
		activate.rpc()
