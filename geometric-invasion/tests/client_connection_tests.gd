extends TestBase

func test_client_creation_on_invalid_server():
	# Given the network manager attempt to start a client on invalid ip
	NetworkManager.start_client("999.999.999.999")
	
	# After starting the client, network manager peer should not be OK after 30 seconds
	await await_millis(30000)
	assert_object(NetworkManager.peer).is_not_equal(OK)


# Server on local host must be running for these tests to pass
func test_client_creation_on_local_host():
	# Given the network manager attempt to start client on valid ip
	var check : bool = NetworkManager.start_client("127.0.0.1")
	
	# After connection attempt starts, peer should be OK
	assert_bool(check).is_equal(true)
	
	# Multiplayer peer should not be null nor offline
	assert_object(multiplayer.multiplayer_peer).is_not_null()
	assert_object(multiplayer.multiplayer_peer).is_not_same(OfflineMultiplayerPeer)

func test_client_creation_on_server_already_started():
	
	
	pass
