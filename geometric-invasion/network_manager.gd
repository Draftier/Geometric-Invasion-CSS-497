extends Node

var ip_address : String
# Going to arbitraily utilize port 25566 for this project
var port : int = 42069

var peer : ENetMultiplayerPeer
var is_solo : bool = true

signal server_created
signal server_joined

func _ready():
	ip_address = get_host_ip()
	print(ip_address)

func get_host_ip() -> String :
	# Loop through the ip addresses and find the first address that is not a loop back address, ipv6 address or 
	for i in IP.get_local_addresses():
		if i.begins_with("192.168.") or i.begins_with("10.") or i.begins_with("172."):
			return i
		pass
	return "host ip cannot be found"

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port)
	if error != OK:
		push_error("Server creation failed: %s" % error_string(error))
	multiplayer.multiplayer_peer = peer
	
	server_created.emit()
	
	is_solo = false


func start_client(ip_addres : String) -> bool:
	ip_address = ip_addres
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(ip_address, port)
	if error != OK:
		push_error("Server creation failed: %s" % error_string(error))
	#if !peer.create_client(ip_address, port):
		#return false
		
	multiplayer.multiplayer_peer = peer
	is_solo = false
	
	server_joined.emit()
	
	return true

	
