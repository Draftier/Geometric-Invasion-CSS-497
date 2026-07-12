class_name Player
extends CharacterBody2D

# TODO add implementation for player classes perhaps different health or move speed for calss
@export var player_class : PlayerClass 

# Initial direction the player is moving at (moving no where)
var direction : Vector2 = Vector2.ZERO

# Lives set to 1000 for testing
var lives : int = 1000

# Flag variable to track if the player is invulnerable
var invulnerable : bool = false

# Number of guns
@export var num_guns : int

func _ready() -> void:
	pass


# Called every physics tick
func _process(delta: float) -> void:
	# Get an input vector and modify velocity of player based on it
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * player_class.speed
	
	# Fire bullets from player guns if shoot button held
	if Input.is_action_pressed("shoot"):
		for i in $guns.get_children():
			i.shoot()
	
	if Input.is_action_pressed("slow"):
		velocity = direction * player_class.speed / 2
	
	# Apply velocity to player
	move_and_slide()
	
	if invulnerable == true:
		var timer = get_tree().create_timer(5.0)
		$AnimationPlayer.play("flash")
		await timer.timeout
		$AnimationPlayer.stop()
	
# Learned this function in another tutorial and read about it being useful for input to UI or menus
# Since this function is not called every frame/physics tick
func _unhandled_input(event: InputEvent) -> void:
	pass

# Function that allows the player to take damage
func take_damage() -> void:
	print("hit")
	if invulnerable == false:
		lives -= 1
		var timer = get_tree().create_timer(0.7)
		$AnimatedSprite2D.play("explosion")
		await timer.timeout
		if lives <= 0:
			queue_free()
		invulnerable = true
		$AnimatedSprite2D.play("default")
		$InvulnerabilityTimer.start()			
	else:
		return


func _on_invulnerability_timer_timeout() -> void:
	invulnerable = false
