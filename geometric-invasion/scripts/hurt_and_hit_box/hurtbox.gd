# This class represents a hurtbox used to detect what hitbo has interacted with an entity
# And check if that hitbox should interact with this entity
class_name Hurtbox
extends Area2D


# Func used to initailize values, use ready over init for values that are in inspector tree
# Connect signal for hurtbox to deal damage to hitbox
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	

# Function to check what hitbox the hurtbox has detected and deal damage to the hitbox
func _on_area_entered(hitbox: Hitbox) -> void:
	# print(owner)
	# Initial check to see if null
	if hitbox == null:
		return
		
	# Checks to see if owner node has function to take damage or if
	# There's another interaction with owner node that is detailed in if statement
	# If owner of hitbox is not ability then check if it can take damage if so dish out damage
	if owner.has_method("take_damage") and hitbox.owner is not Ability:
		owner.take_damage(hitbox.damage)
		# If owner of hitbox is a bullet then add that bullet to the pool
		if hitbox.owner is Bullet:
			hitbox.owner.level_manager.call_deferred("add_to_pool", hitbox.owner)
	# If the owner of the hitbox is an ability then do different checks
	elif hitbox.owner is Ability:
		# Check if ability is laser or shield since both laser and shield delete bullets
		if hitbox.owner.data.ability_name == "laser" or hitbox.owner.data.ability_name == "shield":
			# If ability comes into contact with bullet then add bullet back to pool
			if owner is Bullet:
				owner.level_manager.call_deferred("add_to_pool", owner)
			# If ability comes into contact with enemy then instantly kill enemy
			elif owner is basic_enemy:
				owner.take_damage(999)
	pass
