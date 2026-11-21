extends Button
class_name AnimatedButton

var original_scale = scale
@export var grow_size = Vector2(1.1, 1.1)
@export var anim_duration : float = 0.1

var tween

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_focus_exited)

func grow_button() -> void:
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'scale', grow_size, anim_duration)
	
func shrink_button() -> void:
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'scale', original_scale, anim_duration)

func _on_focus_entered() -> void:
	grow_button()

func _on_focus_exited() -> void:
	shrink_button()

func _on_mouse_entered() -> void:
	grow_button()

func _on_mouse_exited() -> void:
	shrink_button()
