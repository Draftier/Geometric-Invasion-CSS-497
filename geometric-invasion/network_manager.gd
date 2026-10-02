extends Node

var ip_address : String
# Going to arbitraily utilize port 25566 for this project
var port : int = 25566

var peer : ENetMultiplayerPeer

signal server_created

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
	
	pass

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	server_created.emit()
	



	
