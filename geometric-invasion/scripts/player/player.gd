class_name Player
extends CharacterBody2D

# Signal for player death
signal death

# TODO add implementation for player classes perhaps different health or move speed for calss
@export var player_class : PlayerClass 

# Initial direction the player is moving at (moving no where)
var direction : Vector2 = Vector2.ZERO

# Lives set to 1000 for testing
@export var lives : int = 3

# Flag variable to track if the player is invulnerable
var invulnerable : bool = false

# Variable to store current ability
@onready var ability : Ability = $laser_ability

func _ready() -> void:
	$CanvasLayer/Label.text = "Lives : " + str(lives)
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
	
	if Input.is_action_just_pressed("ability"):
		print("Trying to activate ability")
		if ability.can_activate():
			ability.activate()
	
	# Apply velocity to player
	move_and_slide()
	
	if invulnerable == true:
		$AnimationPlayer.play("flash")
	else:
		$AnimationPlayer.stop()
	
	if lives <= 0:
			death.emit()
			hide()
			self.set_process(false)
	
	
	
# Learned this function in another tutorial and read about it being useful for input to UI or menus
# Since this function is not called every frame/physics tick
func _unhandled_input(event: InputEvent) -> void:
	pass

# Function that allows the player to take damage
func take_damage(damage : int) -> void:
	#print("hit")
	if invulnerable == false and lives > 0:
		lives -= damage
		invulnerable = true
		$CanvasLayer/Label.text = "Lives : " + str(lives)
		var timer = get_tree().create_timer(0.7)
		$AnimatedSprite2D.play("explosion")
		await timer.timeout
		$AnimatedSprite2D.play("default")
		$InvulnerabilityTimer.start()			
	else:
		return


func _on_invulnerability_timer_timeout() -> void:
	invulnerable = false
	
