class_name Hurtbox
extends Area2D

# These variables are here to set an optional initial collision layer and mask, by default both on 0
# Make sure the col layer and mask complement each other 
@export var col_layer : int = 0
@export var col_mask : int = 0

# Func used to initailize values, use ready over init for values that are in inspector tree
# Initialize col layer and mask on area2d and connect signal for hurtbox to deal damage to hitbox
func _ready() -> void:
	collision_layer = col_layer
	collision_mask = col_mask
	
	area_entered.connect(_on_area_entered)
	

# Function to check what hitbox the hurtbox has detected and deal damage to the hitbox
func _on_area_entered(hitbox: Hitbox) -> void:
	# Initial check to see if null
	if hitbox == null:
		return
		
	# Checks to see if owner node has any function that hurtbox can dish out
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	elif owner.has_method("destroy"):
		owner.destroy()
	
	pass
