extends Control
class_name PlayerUIEntry

@onready var player_id_and_state = %PlayerNumber
@onready var player_health = %PlayerHealth
@onready var player_ability_state = %PlayerAbilityState
@onready var player_score = %PlayerScore

var _id : int
var _display_id : int

func _ready() -> void:
	player_id_and_state.text = ""
	player_health.text = ""
	player_ability_state.text = ""

func set_player_id(id : int, display_id : int) -> void:
	_id = id
	_display_id = display_id
	player_id_and_state.text = "Player: " + str(display_id)

func set_player_health(lives : int) -> void:
	player_health.text = "Lives left: " + str(lives)

func set_ability_state(charge : bool) -> void:
	player_ability_state.text = "Ability charge: " + str(charge)

func set_player_dead() -> void:
	player_id_and_state.text = "Player: " + str(_display_id) + " dead"

func set_player_disconnected() -> void:
	player_id_and_state.text = "Player: " + str(_display_id) + " disconnected"
	
func set_player_score(score : int) -> void:
	player_score.text = "Score: " + str(score)
