extends Node

var ip_address : String
# Going to arbitraily utilize port 25566 for this project
var port : int = 42069

var peer : ENetMultiplayerPeer
var is_solo : bool = true

signal server_created
signal server_joined
signal server_level_entered
signal connecting_to_server
signal connection_to_server_failed

@rpc("authority", "call_local", "reliable")
func change_scene_for_all_players(scene_path : String) -> void:
	var error := get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		push_error("Scene change failed: " + error_string(error))
		
	await get_tree().scene_changed
	
	server_level_entered.emit()
	

func _ready():
	ip_address = get_host_ip()
	multiplayer.connected_to_server.connect(_on_connection_to_server)
	multiplayer.connection_failed.connect(_on_connection_to_server_failed)
	
	
	print(ip_address)

func get_host_ip() -> String :
	# Loop through the ip addresses and find the first address that is not a loop back address, ipv6 address or 
	for i in IP.get_local_addresses():
		if i.begins_with("192.168.") or i.begins_with("10.") or i.begins_with("172."):
			return i
		pass
	return "host ip cannot be found"

func start_server() -> bool:
	
	stop_server()
	
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port)
	
	if error != OK:
		push_error("Server creation failed: %s" % error_string(error))
		return false
		
		
	multiplayer.multiplayer_peer = peer
	
	server_created.emit()
	
	is_solo = false
	return true

func start_client(ip_addres : String) -> bool:
	ip_address = ip_addres
	
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(ip_address, port)
	if error != OK:
		#push_error("Server creation failed: %s" % error_string(error))
		return false
	#if !peer.create_client(ip_address, port):
		#return false
	multiplayer.multiplayer_peer = peer
	connecting_to_server.emit()
	return true

func stop_server() -> void:
	if peer != null:
		peer.close()
	
	multiplayer.multiplayer_peer = null
	peer = null
	is_solo = true

func _on_connection_to_server() -> void:
		is_solo = false
		server_joined.emit()
		
func _on_connection_to_server_failed() -> void:
	peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_to_server_failed.emit()
