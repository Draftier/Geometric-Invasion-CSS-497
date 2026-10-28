extends CanvasLayer
class_name PlayerUserInterface
@export var player_info_scene : PackedScene

#@onready var lives_container : HBoxContainer = %LivesContainer

var player_info = {}

@rpc("authority", "call_local", "reliable")
func init_entry(id : int, lives : int, charge_state : bool) -> void:
	
	var player_entry = player_info_scene.instantiate()
	var container = get_node("%LivesContainer") as HBoxContainer
	container.add_child(player_entry)
	
	if !player_entry.is_node_ready():
		await player_entry.ready
	
	player_entry.set_player_id(id)
	player_entry.set_player_health(lives)
	player_entry.set_ability_state(charge_state)
	
	player_info[id] = player_entry

@rpc("authority", "call_local", "reliable")
func update_entry_lives(id : int, lives : int) -> void:
	var entry = player_info.get(id) as PlayerUIEntry
	entry.set_player_health(lives)

@rpc("authority", "call_local", "reliable")
func update_entry_charge_state(id : int, charge : bool) -> void:
	var entry = player_info.get(id) as PlayerUIEntry
	entry.set_ability_state(charge)

@rpc("authority", "call_local", "reliable")
func set_entry_dead(id : int) -> void:
	var entry = player_info.get(id) as PlayerUIEntry
	entry.set_player_dead()

@rpc("authority", "call_local", "reliable")
func set_entry_disconnected(id : int) -> void:
	var entry = player_info.get(id) as PlayerUIEntry
	entry.set_player_disconnected()
