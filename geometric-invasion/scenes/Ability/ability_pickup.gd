class_name AbilityPickup
extends Node2D

var id : int = 0

@export var gravity : float = 1.0
@export var mass : float = 1.0

signal pickup_removed

func _ready() -> void:
	$RigidBody2D.gravity_scale = gravity
	$RigidBody2D.mass = mass

@rpc("any_peer", "call_local", "reliable")
func remove_pickup() -> void:
	if multiplayer.get_remote_sender_id() != 1 and !multiplayer.is_server():
		return
	
	pickup_removed.emit()
	queue_free()
