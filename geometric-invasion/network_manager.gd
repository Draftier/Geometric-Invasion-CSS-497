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

var wifi_ip_address : String
var ethernet_ip_address : String

# Rpc to change scene for all players based on a given path
@rpc("authority", "call_local", "reliable")
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
	# Clean up any zombie servers in case
	stop_server()
	
	# Create new peer and server for that peer
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port)
	
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
	# Set ip_address to given ip_address
	ip_address = ip_addres
	
	# Create new ENetMultiplayerPeer
	peer = ENetMultiplayerPeer.new()
	
	# Error check
	var error := peer.create_client(ip_address, port)
	if error != OK:
		push_error("Server creation failed: %s" % error_string(error))
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
	multiplayer.multiplayer_peer = null
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
