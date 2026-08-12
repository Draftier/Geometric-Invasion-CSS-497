# This class represents a general hitbox utilized for this proejct
class_name Hitbox
extends Area2D

signal hit

# This variable is utilized to determine how much damage the hitbox will deal
@export var damage := 10

func _on_hit() -> void:
	hit.emit()
