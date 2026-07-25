# This class represents a general hitbox utilized for this proejct
class_name Hitbox
extends Area2D

# These variables are here to set an optional initial collision layer and mask, by default both on 0
# Make sure the col layer and mask complement each other 
@export var col_layer : int = 0
@export var col_mask : int = 0

# This variable is utilized to determine how much damage the hitbox will deal
@export var damage := 10

# Func used to initailize values, use ready over init for values that are in inspector tree
# Initialize col layer and mask on area2d
func _ready() -> void:
	collision_layer = col_layer
	collision_mask = col_mask
