extends MultiplayerSpawner

@export var network_player : PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	
	NetworkManager.server_level_entered.connect(_on_server_level_entered())
	
func _on_server_level_entered():
	print("foo")
	spawn_player(1)


func spawn_player(id : int) -> void:
	print("pop")
	network_player = Global.player

	
	if !multiplayer.is_server(): return
	
	
	
	var player : Node = network_player.instantiate()
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player)
	
	
