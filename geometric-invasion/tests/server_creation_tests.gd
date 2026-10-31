extends TestBase

func before_test() -> void:
	monitor_signals(NetworkManager, false)


func test_server_creation():
	# Given network manager
	NetworkManager.start_server()
	
	# Multiplayer peer is created as a server when start server is called
	assert_bool(multiplayer.is_server()).is_true()
	assert_int(multiplayer.multiplayer_peer.host.get_local_port()).is_equal(NetworkManager.port)
	assert_object(multiplayer.multiplayer_peer).is_not_instanceof(OfflineMultiplayerPeer)
	assert_int(multiplayer.multiplayer_peer.get_unique_id()).is_equal(1)

func test_server_stop():
	# Given network manager with a started server
	NetworkManager.start_server()
	
	# The network manager will stop the server upon stop server call
	NetworkManager.stop_server()
	
	# Then multiplayer peer is offline and multiplayer is not server
	assert_object(multiplayer.multiplayer_peer).is_instanceof(OfflineMultiplayerPeer)
	assert_int(multiplayer.multiplayer_peer.get_unique_id()).is_equal(1)


func test_server_start_and_restart():
	# Given network manager, when start server is called
	NetworkManager.start_server()
	
	# The multiplayer peer is created as a server
	assert_bool(multiplayer.is_server()).is_true()
	assert_int(multiplayer.multiplayer_peer.host.get_local_port()).is_equal(NetworkManager.port)
	assert_object(multiplayer.multiplayer_peer).is_not_instanceof(OfflineMultiplayerPeer)
	assert_int(multiplayer.multiplayer_peer.get_unique_id()).is_equal(1)
	
	# When server is closed
	NetworkManager.stop_server()
	
	# The multiplayer peer is set to offline multiplayer peer and broadcast port is stopped
	assert_object(multiplayer.multiplayer_peer).is_instanceof(OfflineMultiplayerPeer)

	# After stopping server you can create server again and all asserts used before are still correct
	NetworkManager.start_server()
	
	# The multiplayer peer is created as a server
	assert_int(multiplayer.multiplayer_peer.host.get_local_port()).is_equal(NetworkManager.port)
	assert_object(multiplayer.multiplayer_peer).is_not_instanceof(OfflineMultiplayerPeer)
	assert_int(multiplayer.multiplayer_peer.get_unique_id()).is_equal(1)
	


func after_test() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		NetworkManager.peer = null
	
	if multiplayer.is_server():
		NetworkManager.is_solo = false
	
	if NetworkManager.broadcast_peer != null:
		NetworkManager.broadcast_peer.close()
	
	if NetworkManager.listen_peer != null:
		NetworkManager.listen_peer.close()
