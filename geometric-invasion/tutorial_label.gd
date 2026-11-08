extends Label
class_name AnimatedLabel

@export var text_to_display : String
@export var time_between_chars : float
@export var clear_text_upon_completion : bool = false

@onready var timer : Timer = %Timer

signal finished_displaying_text
var is_displaying_text : bool = false

func _ready() -> void:
	if time_between_chars == null:
		time_between_chars = 0.05

	timer.wait_time = time_between_chars
	display_text()
	

func display_text() -> void:
	if is_displaying_text == true:
		return
	
	is_displaying_text = true
	text = ""
	
	for i in text_to_display:
		text += i
		await timer.timeout
		
	
	if clear_text_upon_completion == true:
		clear_text()
	
	is_displaying_text = false
	finished_displaying_text.emit()

func clear_text() -> void:
	for i in range(text.length() - 1, -1, -1):
		text[i] = ""
		await timer.timeout
