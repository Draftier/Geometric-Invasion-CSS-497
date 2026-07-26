# This class represents a hurtbox used to detect what hitbo has interacted with an entity
# And check if that hitbox should interact with this entity
# Collision masks and layers changed in editor for ease of use
class_name Hurtbox
extends Area2D


# Func used to initailize values, use ready over init for values that are in inspector tree
# Initialize col layer and mask on area2d and connect signal for hurtbox to deal damage to hitbox
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	

# Function to check what hitbox the hurtbox has detected and deal damage to the hitbox
func _on_area_entered(hitbox: Hitbox) -> void:
	# Initial check to see if null
	if hitbox == null:
		return
	#print(owner)
	
	
	# Checks to see if owner node has any function that hurtbox can dish out
	if owner.has_method("take_damage"):
		owner.take_damage()
		if hitbox.owner is Bullet:
			hitbox.owner.level_manager.call_deferred("add_to_pool", hitbox.owner)
	elif owner.has_method("destroy"):
		owner.destroy()
	
	
	pass
