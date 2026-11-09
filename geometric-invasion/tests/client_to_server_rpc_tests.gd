extends TestBase

# This test should only be ran when client is connected to server
var player : Player
var player_spawner
var level_manager

func find_current_player() -> void:
	var timeout_time = Time.get_ticks_msec() + 3000
	print("Finding player")
	
	level_manager = get_tree().current_scene.find_child("Level_Manager")
	player_spawner = level_manager.find_child("Spawner")
	
	while !player_spawner.players.has(multiplayer.get_unique_id()) && Time.get_ticks_msec() < timeout_time:
		await get_tree().process_frame

	player = player_spawner.players.get(multiplayer.get_unique_id())
	assert(player != null)
	print("Player found")

func before() -> void:
	NetworkManager.start_client("127.0.0.1")
	
	var tree := get_tree()
	var placeholder := Node.new()
	placeholder.name = "TestLobby"
	tree.root.add_child(placeholder)
	tree.current_scene = placeholder

	
	await tree.scene_changed
	print("Client entered: ", tree.current_scene.scene_file_path)

func before_test() -> void:
	monitor_signals(NetworkManager, false)
	await find_current_player()

func test_invalid_shoot_request() -> void:
	print("Test is running")
	
	
	# Given a client player gun
	var gun = player.guns[0]
	
	# Fire the gun twice in succession to attempt to fire before
	# Firing cooldown ends
	gun.request_shoot.rpc_id(1)
	gun.request_shoot.rpc_id(1)
	
	await await_millis(3000)
	
	# Gun should have shot only once
	print("Gun was shot", gun.times_shot)
	assert_int(gun.times_shot).is_equal(1)

func test_invalid_ability_activation_request() -> void:
	# Given a player ability
	var ability = player.ability
	
	# Discharge by activating the ability
	print("Firing ability")
	var delta : float = 1.0 / 60.0
	ability.request_fire_ability.rpc_id(1, delta)
	await await_millis(3000)
	print("Ability finished firing")
	
	# Check if the ability has been discharged
	assert_bool(ability.is_charged).is_false()
	
	# Send invalid ability activation to server
	ability.request_fire_ability.rpc_id(1, delta)
	await await_millis(3000)
	
	# Check if the ability was only fired once when it was charged
	assert_int(ability.activation_count).is_equal(1)
	

func test_invalid_damage_on_player_request() -> void:	
	# And this player's current health 
	var health = player.lives
	
	# Attempt to damage the player 
	player_spawner.request_take_damage(multiplayer.get_unique_id(), 1)
	
	# Check that the player did not take damage
	assert_int(player.lives).is_equal(health)

func test_invalid_victory_request() -> void:
	pass
	
func test_invalid_ability_pickup_request() -> void:
	pass

func test_invalid_enemy_death_request() -> void:
	pass

func test_invalid_player_death_request() -> void:
	pass


#func after_test() -> void:
	#if multiplayer.multiplayer_peer != null:
		#multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		#NetworkManager.peer = null
	#
	#if multiplayer.is_server():
		#NetworkManager.is_solo = false
	#
	#if NetworkManager.broadcast_peer != null:
		#NetworkManager.broadcast_peer.close()
	#
	#if NetworkManager.listen_peer != null:
		#NetworkManager.listen_peer.close()
