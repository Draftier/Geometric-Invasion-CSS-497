class_name AbilityPickup
extends Node2D

var id : int = 0

@rpc("any_peer", "call_local", "reliable")
func remove_pickup() -> void:
	if multiplayer.get_remote_sender_id() != 1 and !multiplayer.is_server():
		return
		
	queue_free()
