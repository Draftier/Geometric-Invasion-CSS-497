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
signal game_started_signal

@export var listen_port : int = 8081
var listen_peer : PacketPeerUDP

@export var broadcast_port : int = 8082
var broadcast_peer : PacketPeerUDP

@export var broadcast_address : String = "255.255.255.255"

# Object that represents ServerInfo to be sent between scripts
class ServerInfo:
	var server_ip : String
	var server_port : int
	var server_dictionary : Dictionary = {}

# Dictionary sent from server to clients to represent server name and player count
var server_dictionary = {"name":"name", "player_count": 0}

var wifi_ip_address : String
var ethernet_ip_address : String

var game_started : bool = false

var max_players : int = 2

# Rpc to change scene for all players based on a given path
@rpc("call_local", "reliable")
#@rpc("authority", call_local", "reliable")
func change_scene_for_all_players(scene_path : String) -> void:
	
	# Error checking for scene change if error push error to error trace
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Scene change failed: " + error_string(error))
		
	# Wait for scene to change
	await get_tree().scene_changed
	
	# Then emit signal that client has entered the level
	server_level_entered.emit()
	

func _ready():
	# Obtain the ip of the host
	ip_address = get_host_ip()
	
	
	wifi_ip_address = get_host_wifi_ip()
	ethernet_ip_address = get_host_ethernet_ip()
	
	print(wifi_ip_address)
	print(ethernet_ip_address)
	# Connect signals to check if connection to server is failed or successful
	multiplayer.connected_to_server.connect(_on_connection_to_server)
	multiplayer.connection_failed.connect(_on_connection_to_server_failed)
	
	
	# Setup authentication
	multiplayer.auth_callback = _on_receive_auth_data
	multiplayer.peer_authenticating.connect(_on_peer_authenticating)

# Function to obtain host ip address
func get_host_ip() -> String :
	# Loop through the ip addresses and find the first address that is not a loop back address, ipv6 address or 
	#for i in IP.get_local_addresses():
		#if i.begins_with("192.168.") or i.begins_with("10.") or i.begins_with("172."):
			#return i
		#pass
	for i in IP.get_local_interfaces():
		print(i["friendly"], ": ", i["addresses"])
	
	#ip_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME"), 1))
	print("Obtained address: ", ip_address)
	return ip_address
	return "host ip cannot be found"
	
func get_host_wifi_ip() -> String : 
	for i in IP.get_local_interfaces():
		if i["friendly"] == "Wi-Fi":
			return i["addresses"][0]
	return "host wifi ip cannot be found"
	pass
	
func get_host_ethernet_ip() -> String:
	for i in IP.get_local_interfaces():
		if i["friendly"] == "Ethernet":
			return i["addresses"][0]
	return "host wifi ip cannot be found"
	pass

# Function to start server
func start_server() -> bool:
	print("This is a host")
	
	# Clean up any zombie servers in case
	stop_server()
	
	# Create new peer and server for that peer
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port, max_players)
	
	# Error check
	if error != OK:
		push_error("Server creation failed: %s" % error_string(error))
		return false
		
	# Set multiplayer_peer to created peer
	multiplayer.multiplayer_peer = peer
	
	# Emit signal and set is_solo to false for player controls
	server_created.emit()
	is_solo = false
	
	return true

# Function to start the client
func start_client(ip_addres : String) -> bool:
	print("This is a client")
	# Set ip_address to given ip_address
	ip_address = ip_addres
	
	# Create new ENetMultiplayerPeer
	peer = ENetMultiplayerPeer.new()
	
	# Error check
	var error := peer.create_client(ip_address, port)
	if error != OK:
		push_error("Client creation failed: %s" % error_string(error))
		return false

	# Set multiplayer_peer to newly created peer and emit that client is attempting to connect to server
	multiplayer.multiplayer_peer = peer
	connecting_to_server.emit()
	return true

# Function to stop server
func stop_server() -> void:
	# If server exists close connections 
	if peer != null:
		peer.close()
	
	# Set peer values to null and is_solo to true
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	
	peer = null
	is_solo = true

# Function that is called when server is successfully joined
func _on_connection_to_server() -> void:
		is_solo = false
		server_joined.emit()

# Function called when connection to server has failed
func _on_connection_to_server_failed() -> void:
	peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_to_server_failed.emit()
		
func _on_receive_auth_data(peer_id : int, payload: PackedByteArray) -> void:
	var data : String = payload.get_string_from_utf8()
	
	if !multiplayer.is_server():
		if data == "Approved":
			multiplayer.complete_auth(peer_id)
		else:
			game_started_signal.emit()
	
func _on_peer_authenticating(peer_id : int) -> void:
	if multiplayer.is_server():
		if game_started == true:
			multiplayer.send_auth(peer_id, "Game started".to_utf8_buffer())
		else:
			multiplayer.send_auth(peer_id, "Approved".to_utf8_buffer())
			multiplayer.complete_auth(peer_id)

func close_multiplayer_connection() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	
func set_up_listen_port() -> void:
	listen_peer = PacketPeerUDP.new()
	
	var error = listen_peer.bind(listen_port)
	
	if error != OK:
		print("Failed to bind to listen port!")
		
func set_up_broadcast_port(name : String) -> void:
	var server_info = ServerInfo.new()
	
	server_info.server_dictionary["name"] = name
	server_info.server_dictionary["player_count"] = multiplayer.get_peers().size() + 1
	
	broadcast_peer = PacketPeerUDP.new()
	broadcast_peer.set_broadcast_enabled(true)
	broadcast_peer.set_dest_address(broadcast_address, listen_port)
	
	var error = broadcast_peer.bind(broadcast_port)
	
	if error != OK:
		print("Failed to bind to broadcast port")
	
func obtain_server_information() -> ServerInfo:
	var current_info = ServerInfo.new()
	
	if listen_peer.get_available_packet_count() > 0:
		# Obtain information from packet header
		current_info.server_ip = listen_peer.get_packet_ip()
		current_info.server_port = listen_peer.get_packet_port()
		
		# Obtain information from within packet
		var bytes = listen_peer.get_packet()
		var data = bytes.get_string_from_ascii()
		
		# Set returned server info dictionary to the dictionary given from server
		current_info.server_dictionary = JSON.parse_string(data)
		
		# Return server information
		return current_info
	return null

func broadcast_server_information() -> void:
	var server_info = ServerInfo.new()
	
	server_info.server_dictionary["name"] = server_dictionary["name"]
	server_info.server_dictionary["player_count"] = multiplayer.get_peers().size() + 1
	
	var data = JSON.stringify(server_info.server_dictionary)
	var packet = data.to_ascii_buffer()
	broadcast_peer.put_packet(packet)
	
	print("Broadcasting server info")

func stop_broadcast() -> void:
	broadcast_peer.close()

func stop_listen() -> void:
	listen_peer.close()
