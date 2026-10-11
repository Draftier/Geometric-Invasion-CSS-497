extends MultiplayerSpawner

@export var network_player : PackedScene

func _ready() -> void:
	add_spawnable_scene(Global.player.resource_path)
	
	NetworkManager.server_level_entered.connect(_on_server_level_entered)
	
	print("Connected: ", NetworkManager.server_level_entered.is_connected(_on_server_level_entered))
	
func _on_server_level_entered():
	print("Players are spawning")
	spawn_player(multiplayer.get_unique_id())
	
	for id in multiplayer.get_peers():
		spawn_player(id)


#func _ready() -> void:
	#player = Global.player.instantiate()
	#player.ability_scene =  Global.ability
	#player.global_position = $SpawnPoint.global_position
	#add_child(player)
	#pause_menu.player_connect(player)
	#print("foo")


func spawn_player(id : int) -> void:
	network_player = Global.player

	if !multiplayer.is_server(): return
	
	
	var player : Node = network_player.instantiate()
	player.ability_scene = Global.ability
	player.name = str(id)
	
	print(player.ability_scene)
	
	get_node(spawn_path).call_deferred("add_child", player)
	
	
