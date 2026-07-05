extends CharacterBody2D

@export var direction : Vector2 = Vector2.ZERO
@export var speed : int

func _ready() -> void:
	speed = 10

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	print(global_position)
	
func _unhandled_input(event: InputEvent) -> void:
	pass
