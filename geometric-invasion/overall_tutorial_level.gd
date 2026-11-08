extends Node2D

var has_shoot : bool
var did_activate_ability : bool
var is_enemy_dead : bool
var has_moved : bool

@onready var tutorial_text : AnimatedLabel = %TutorialLabel
@onready var enemy_spawn_point : Marker2D = %EnemySpawnPoint
@onready var player_ui = $PlayerUserInterface
@onready var time_label = %TimeLabel
@onready var quit_button = %QuitToMainMenuButton

@export var tutorial_enemy : PackedScene
var spawned_enemy
@export var power_up_scene : PackedScene

@export var strings_to_display : Array[String]
var current_string_to_display

enum States {WELCOME, WAIT, MOVE, SHOOT, ACTIVATE, DEAD_ENEMY, USE_PICKUP, LEVEL_EXPLANATION, FINISHED}

var state : States = States.WELCOME
var previous_state : States
var displaying_text : bool = false
var state_changed : bool = false

func _ready() -> void:
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
		change_label_text("Your ability charge state is displayed in the bottom left \nPress X to try to activate it")
		var player = get_node("1")
		player.ability.charge()
	elif state == States.ACTIVATE:
		set_state(States.WAIT)
		spawned_enemy.activate()
		change_label_text("Kill the spawned enemy with your gun or ability")
	elif state == States.DEAD_ENEMY:
		set_state(States.WAIT)
		change_label_text("Enemies may drop pickups that recharge your ability 
		The pickup is the blue box move into it\n to pick it up")
	elif state == States.USE_PICKUP:
		set_state(States.WAIT)
		change_label_text("Player lives are shown on the bottom left
		Getting hit by an enemy or a bullet makes the player lose lives
		Once the player runs out of lives the game is lost")
		state = States.LEVEL_EXPLANATION
	elif state == States.LEVEL_EXPLANATION:
		await get_tree().create_timer(3.0).timeout
		set_state(States.WAIT)
		time_label.visible = true
		change_label_text("On the top left of the screen is a timer. 
		Survive until the timer reaches zero
		Then a boss will spawn
		Kill the boss just like you kill an enemy and you've beat the level")
		state = States.FINISHED
	elif state == States.FINISHED:
		await get_tree().create_timer(3.0).timeout
		set_state(States.WAIT)
		change_label_text("Congratulations on finishing the tutorial!")
		quit_button.visible = true
		

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
	state = States.DEAD_ENEMY
	_on_text_finished_display()
	
	spawn_pickup(id, spawned_enemy.global_position)
	
	spawned_enemy.queue_free()

func spawn_pickup(id : int, position : Vector2):
	var power_up = power_up_scene.instantiate()
	power_up.position = position

	power_up.pickup_removed.connect(_on_pickup_removed)
	
	power_up.id = id
	power_up.name = "power_up_" + str(power_up.id)
	power_up.gravity = 0.00000001
	power_up.mass = 0.0000000001

	get_parent().call_deferred("add_child", power_up)

func _on_tutorial_enemy_hit(id : int, damage : float) -> void:
	spawned_enemy.take_damage(damage)

func _on_pickup_removed() -> void:
	state = States.USE_PICKUP
	_on_text_finished_display()


func _on_quit_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
