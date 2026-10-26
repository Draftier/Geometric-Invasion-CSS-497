extends MultiplayerSpawner

@export var network_player : PackedScene
@export var player_user_interface : PlayerUserInterface

var players = {}

signal player_removed

func _ready() -> void:
	get_node(spawn_path).child_entered_tree.connect(on_player_entered_tree)
	add_spawnable_scene(Global.player.resource_path)
	if NetworkManager.is_solo == false:
		NetworkManager.server_level_entered.connect(_on_server_level_entered)
		multiplayer.peer_disconnected.connect(remove_player)
		
		print("Connected: ", NetworkManager.server_level_entered.is_connected(_on_server_level_entered))
	else:
		spawn_player(1)
		player_user_interface.init_entry(multiplayer.get_unique_id(), 3, true)
	
func _on_server_level_entered():
	print("Players are spawning")
	
	if !multiplayer.is_server():
		return
	
	spawn_player(multiplayer.get_unique_id())
	player_user_interface.init_entry.rpc(multiplayer.get_unique_id(), 3, true)
	
	
	for id in multiplayer.get_peers():
		spawn_player(id)
		player_user_interface.init_entry.rpc(id, 3, true)
	

func spawn_player(id : int) -> void:
	
	network_player = Global.player

	if !multiplayer.is_server(): return
	
	var player : Node = network_player.instantiate()
	player.ability_scene = Global.ability
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player)

	players[id] = player
	
	print("spawned player with id of: " + player.name)

func on_player_hit_reported(id : int, damage : float) -> void:
	if multiplayer.is_server():
		request_take_damage(id, damage)
	else:
		request_take_damage.rpc_id(1, id, damage)

@rpc("any_peer", "call_remote", "reliable")
func request_take_damage(id : int, damage : float) -> void:	
	if !multiplayer.is_server():
		return
	
	var cur_player : Player = players[id]
	
	if !is_instance_valid(cur_player):
		return
	
	if cur_player.is_queued_for_deletion():
		return
	
	cur_player.take_damage(damage)
	player_user_interface.update_entry_lives.rpc(id, cur_player.lives)
	
	print("Player damaged, lives left : " + str(cur_player.lives))

func remove_player(id : int) -> void:
	if !multiplayer.is_server():
		return
		
	disable_player.rpc(id)

@rpc("authority", "call_local", "reliable")
func disable_player(id : int) -> void:
	
	var player_to_remove = players.get(id)
	
	if player_to_remove == null:
		return
	
	if player_to_remove.lives <= 0:
		player_to_remove.is_dead = true
		player_user_interface.set_entry_dead(id)
	else:
		player_user_interface.set_entry_disconnected(id)
	
	
	player_to_remove.hide()
	player_to_remove.set_process(false)
	player_to_remove.set_physics_process(false)
	
	player_to_remove.hitbox.set_deferred("monitoring", false)
	player_to_remove.hitbox.set_deferred("monitorable", false)
	
	player_to_remove.hurtbox.set_deferred("monitoring", false)
	player_to_remove.hurtbox.set_deferred("monitorable", false)
	
	if player_to_remove.hit_report.is_connected(on_player_hit_reported):
		player_to_remove.hit_report.disconnect(on_player_hit_reported)
	
	if player_to_remove.death.is_connected(remove_player):
		player_to_remove.death.disconnect(remove_player)
	
func on_player_entered_tree(player : Node) -> void:
	if player is not Player:
		return
		
	var player_to_track = player as Player
	
	player_to_track.id = str(player.name).to_int()
	
	players[player.name.to_int()] = player_to_track
	
	player_to_track.hit_report.connect(on_player_hit_reported)
	player_to_track.death.connect(remove_player)
	
	#player_to_track.ability_charge_changed.connect(on_charge_state_change)
	if !player_to_track.is_node_ready():
		await player_to_track.ready
		
	player_to_track.ability.charge_state_changed.connect(on_charge_state_change)
	print("CONNECTED instance: ", player_to_track.ability.get_instance_id())
	
func on_charge_state_change(id : int, status : bool) -> void:
	print("Charge status changed to: " + str(status))
	if !multiplayer.is_server():
		return
	player_user_interface.update_entry_charge_state.rpc(id, status)
	
