extends Node2D

var has_shoot : bool
var did_activate_ability : bool
var is_enemy_dead : bool
var has_moved : bool

@onready var tutorial_text : AnimatedLabel = %TutorialLabel
@onready var enemy_spawn_point : Marker2D = %EnemySpawnPoint

@export var tutorial_enemy : PackedScene
var spawned_enemy
@export var power_up_scene : PackedScene

@export var strings_to_display : Array[String]
var current_string_to_display

enum States {WELCOME, WAIT, MOVE, SHOOT, ACTIVATE, DEATH_BY_BULLET, DEATH_BY_ENEMY, DEAD_ENEMY, USE_PICKUP}

var state : States = States.WELCOME
var previous_state : States
var displaying_text : bool = false
var state_changed : bool = false

func _ready() -> void:
	#tutorial_text.text_to_display = "Welcome to the Geometric Invasion tutorial!"
	#tutorial_text.display_text()
	spawned_enemy = tutorial_enemy.instantiate()
	spawned_enemy.death.connect(_on_tutorial_enemy_death)
	
	spawned_enemy.hit_report.connect(_on_tutorial_enemy_hit)
	
	spawned_enemy.global_position = enemy_spawn_point.global_position
	add_child(spawned_enemy)
	spawned_enemy.disable()
	
	tutorial_text.finished_displaying_text.connect(_on_text_finished_display)
	
	state = States.WAIT
	change_label_text("Welcome to Geometric Invasion!")
	state = States.WELCOME

func _process(delta: float) -> void:
	pass
	#if state == States.WELCOME:
		#change_label_text("Welcome to Geometric Invasion!")
		#state = States.WAIT
	#elif state == States.WAIT:
		#if tutorial_text.is_text_finished_displaying == true:
			#change_label_text("Press the arrow keys to move!")
			#state = States.MOVE
		

func change_label_text(text : String) -> void:
		tutorial_text.text_to_display = text
		tutorial_text.display_text()
		displaying_text = true
			
func set_state(new_state : int) -> void:
	previous_state = state
	state = new_state

func _on_text_finished_display() -> void:
	if state == States.WELCOME:
		set_state(States.WAIT)
		change_label_text("Press the arrow keys to move")
	if state == States.MOVE:
		set_state(States.WAIT)
		change_label_text("Press Z to shoot guns")
	elif state == States.SHOOT:
		set_state(States.WAIT)
		change_label_text("Your ability charge state is displayed in the bottom left \nPress X to activate it")
	elif state == States.ACTIVATE:
		set_state(States.WAIT)
		spawned_enemy.activate()
		change_label_text("Kill the spawned enemy with your gun or ability")
	elif state == States.DEAD_ENEMY:
		set_state(States.WAIT)
		
		
	
	

func _unhandled_input(event: InputEvent) -> void:
	print("Current state: ", state)
	print("Previous state: ", previous_state)
	
	if state != States.WAIT || tutorial_text.is_displaying_text == true:
		return
	
	if previous_state == States.WELCOME && (Input.is_action_just_pressed("up") || Input.is_action_just_pressed("down")
	|| Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")):
		state = States.MOVE
		_on_text_finished_display()
	
	if previous_state == States.MOVE && Input.is_action_just_pressed("shoot"):
		state = States.SHOOT
		_on_text_finished_display()
	
	if previous_state == States.SHOOT && Input.is_action_just_pressed("ability"):
		state = States.ACTIVATE
		_on_text_finished_display()
	
func _on_tutorial_enemy_death(id : int) -> void:
	spawned_enemy.queue_free()

func spawn_pickup(id : int, position : Vector2):
	var power_up = power_up_scene.instantiate()
	power_up.position = position

	power_up.id = id
	power_up.name = "power_up_" + str(power_up.id)

	get_parent().call_deferred("add_child", power_up)

func _on_tutorial_enemy_hit(id : int, damage : float) -> void:
	spawned_enemy.take_damage(damage)

#func _unhandled_input(event: InputEvent) -> void:
	#if has_moved == false && (Input.is_action_just_pressed("up") || Input.is_action_just_pressed("down")
	#|| Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")):
		#has_moved = true
		#
	#if has_moved == false:
		#tutorial_text.text_to_display = "Press the arrow keys to move!"
		#tutorial_text.display_text()
		#if (Input.is_action_just_pressed("up") || Input.is_action_just_pressed("down")
			#|| Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")):
				#has_moved = true
		#else:
			#return
