class_name Player
extends CharacterBody2D

@onready var hitbox : Hitbox = %Hitbox
@onready var hurtbox : Hurtbox = %Hurtbox

@onready var user_interface = %PlayerUserInterface

# Check to see if player is in control
var preview_mode : bool = false


# Signal for player death
signal death

# Signal for entering level
signal entered_level
signal hit_report

# TODO add implementation for player classes perhaps different health or move speed for calss
@export var player_class : PlayerClass 

# Initial direction the player is moving at (moving no where)
var direction : Vector2 = Vector2.ZERO

# Lives set to 1000 for testing
@export var lives : int = 1

# Flag variable to track if the player is invulnerable
var invulnerable : bool = false

# Variable to store current ability
@export var ability_scene : PackedScene
var ability : Ability

var is_solo : bool
var is_dead : bool

var id : int

func _enter_tree() -> void:
	#if is_multiplayer_authority():
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:	
	$CanvasLayer/Label.text = "Lives : " + str(lives)
	ability = ability_scene.instantiate()
	add_child(ability)
	
	is_dead = false
	
	$AnimationPlayer.get_animation("flash").loop_mode = Animation.LOOP_LINEAR
	
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
			if multiplayer.is_server():
				i.request_shoot()
			else:
				i.request_shoot.rpc_id(1)
			
	
	if Input.is_action_pressed("slow"):
		velocity = direction * player_class.speed / 2
	
	if Input.is_action_just_pressed("ability"):
		print("Trying to activate ability")
		
		if preview_mode == true:
			ability.charge()
			
		#if ability.can_activate():
			#print("activating")
			#print(preview_mode)
			#ability.activate.rpc()
		
		if multiplayer.is_server():
			ability.request_fire_ability(_delta)
		else:
			ability.request_fire_ability.rpc_id(1, _delta)
	
	# Apply velocity to player
	move_and_slide()
	
	#if lives <= 0:
			#death.emit(multiplayer)
			#hide()
			#self.set_process(false)
	


# Function that allows the player to take damage
func take_damage(damage : int) -> void:
	if is_dead == true:
		return
	
	if !multiplayer.is_server():
		return
	#print("hit")
	if invulnerable == false and lives > 0:
		lives -= damage
		
		if lives <= 0 and is_dead == false:
			report_death()
		
		invulnerable = true
		flash_player.rpc()
	
	if invulnerable == true:
		print("Player is invulnerable cannot be killed with id: " + str(id))


func _on_invulnerability_timer_timeout() -> void:
	$AnimationPlayer.stop()
	invulnerable = false
	

func _on_whole_collision_box_body_entered(body: Node2D) -> void:
	print("Picked up charge")
	print("Is solo: " + str(NetworkManager.is_solo))
	
	if body.owner is not AbilityPickup:
		print("fart")
		return
	
	var pickup = body.owner as AbilityPickup
	
	if pickup == null:
		print("fart 2")
	
	if NetworkManager.is_solo == false:
		print("Picking up for multiplayer")
		
		if !multiplayer.is_server():
			return
			
		ability.charge.rpc()
		pickup.remove_pickup.rpc()
	else:
		print("Picking up for solo player")
		ability.charge()
		pickup.remove_pickup()
#@rpc("any_peer", "call_remote", "reliable")
#func request_take_damage(damage_giver_pos : Vector2, damage_amount : float) -> void:
	#if !multiplayer.is_server():
		#return
	#
	#if damage_giver_pos.distance_to(self.position) <= 5:
		#take_damage.rpc(damage_amount)
	#pass

func report_hit(damage : float) -> void:
	hit_report.emit(id, damage)
	
func report_death() -> void:
	death.emit(id)

@rpc("any_peer", "call_local", "reliable")
func flash_player() -> void:
	$CanvasLayer/Label.text = "Lives : " + str(lives)
	var timer = get_tree().create_timer(0.7)
	$AnimatedSprite2D.play("explosion")
	$AnimatedSprite2D/Circle1.visible = false
	
	await timer.timeout
	
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D/Circle1.visible = true
	
	$InvulnerabilityTimer.start()
	
	$AnimationPlayer.play("flash")
	
