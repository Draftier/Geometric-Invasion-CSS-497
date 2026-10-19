class_name Player
extends CharacterBody2D

# Check to see if player is in control
var preview_mode : bool = false

# Signal for player death
signal death

# Signal for entering level
signal entered_level

# TODO add implementation for player classes perhaps different health or move speed for calss
@export var player_class : PlayerClass 

# Initial direction the player is moving at (moving no where)
var direction : Vector2 = Vector2.ZERO

# Lives set to 1000 for testing
@export var lives : int = 3

# Flag variable to track if the player is invulnerable
var invulnerable : bool = false

# Variable to store current ability
@export var ability_scene : PackedScene
var ability : Ability

var is_solo : bool

func _enter_tree() -> void:
	#if is_multiplayer_authority():
	set_multiplayer_authority(str(name).to_int())
		

func _ready() -> void:	
	$CanvasLayer/Label.text = "Lives : " + str(lives)
	ability = ability_scene.instantiate()
	add_child(ability)
	
	if preview_mode:
		%Camera2D.enabled = false

# Called every physics tick
func _process(_delta: float) -> void:
	if !NetworkManager.is_solo and !is_multiplayer_authority():
		return

	
	# Get an input vector and modify velocity of player based on it
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * player_class.speed
	
	# Fire bullets from player guns if shoot button held
	if Input.is_action_pressed("shoot"):
		for i in $guns.get_children():
			i.shoot.rpc()
	
	if Input.is_action_pressed("slow"):
		velocity = direction * player_class.speed / 2
	
	if Input.is_action_just_pressed("ability"):
		print("Trying to activate ability")
		
		if preview_mode == true:
			ability.charge()
			
		if ability.can_activate():
			print("activating")
			print(preview_mode)
			ability.activate.rpc()
			
	
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
	

# Function that allows the player to take damage
func take_damage(damage : int) -> void:
	#print("hit")
	if invulnerable == false and lives > 0:
		lives -= damage
		invulnerable = true
		$CanvasLayer/Label.text = "Lives : " + str(lives)
		var timer = get_tree().create_timer(0.7)
		$AnimatedSprite2D.play("explosion")
		$AnimatedSprite2D/Circle1.visible = false
		await timer.timeout
		$AnimatedSprite2D.play("default")
		$AnimatedSprite2D/Circle1.visible = true
		$InvulnerabilityTimer.start()			
	else:
		return

func _on_invulnerability_timer_timeout() -> void:
	invulnerable = false
	

func _on_whole_collision_box_body_entered(body: Node2D) -> void:
	print("Picked up charge")
	ability.charge()
	body.queue_free()
