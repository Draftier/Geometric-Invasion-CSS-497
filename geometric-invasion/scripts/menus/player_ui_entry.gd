extends Control
class_name PlayerUIEntry

@onready var player_id_and_state = %PlayerNumber
@onready var player_health = %PlayerHealth
@onready var player_ability_state = %PlayerAbilityState

var _id : int

func _ready() -> void:
	player_id_and_state.text = ""
	player_health.text = ""
	player_ability_state.text = ""

func set_player_id(id : int) -> void:
	_id = id
	player_id_and_state.text = "Player: " + str(_id)

func set_player_health(lives : int) -> void:
	player_health.text = "Lives left: " + str(lives)

func set_ability_state(charge : bool) -> void:
	player_ability_state.text = "Ability charge: " + str(charge)

func set_player_dead() -> void:
	player_id_and_state.text = "Player: " + str(_id) + " dead"

func set_player_disconnected() -> void:
	player_id_and_state.text = "Player: " + str(_id) + " disconnected"
