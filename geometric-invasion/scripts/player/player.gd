class_name Player
extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
@export var player_class : PlayerClass


# Called every physics tick
func _physics_process(delta: float) -> void:
	# Get an input vector and modify velocity of player based on it
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * player_class.speed
	# Apply velocity to player
	move_and_slide()
	
	# Fire bullets from player guns if shoot button held
	if Input.is_action_pressed("shoot"):
		$Gun.shoot()
		$Gun2.shoot()
	
	
# Learned this function in another tutorial and read about it being useful for input to UI or menus
# Since this function is not called every frame/physics tick
func _unhandled_input(event: InputEvent) -> void:
	pass
