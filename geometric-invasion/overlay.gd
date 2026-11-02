extends CanvasLayer

@onready var fps_label : Label = %FpsLabel

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(round(Engine.get_frames_per_second()))

func enable_fps_overlay() -> void:
	set_process(true)
	visible = true

func disable_fps_overlay() -> void:
	set_process(false)
	visible = false
