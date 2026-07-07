class_name basic_enemy
extends Area2D

@export var health = 5

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass

func hit() -> void:
	health -= 1
	if health <= 0:
		queue_free()
	var tween = create_tween()
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 0.0, 0.1)
	tween.tween_property($Sprite2D.material, 'shader_parameter/Progress', 1.0, 0.2)	
