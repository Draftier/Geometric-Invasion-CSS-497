extends Node

@export var ui_focus_audio : AudioStream
@export var ui_select_audio : AudioStream
@export var ui_cancel_audio : AudioStream
@export var ui_success_audio : AudioStream
@export var ui_error_audio : AudioStream

var cur_track : int = 0
var next_track : int = 1

var music_tweens : Array[Tween]
var ui_audio_player : AudioStreamPlaybackPolyphonic

@onready var music_player_1 : AudioStreamPlayer = %MusicStreamPlayer
@onready var music_player_2 : AudioStreamPlayer = %MusicStreamPlayer2
@onready var ui : AudioStreamPlayer = %UiStreamPlayer

func _ready() -> void:
	ui.play()
	ui_audio_player = ui.get_stream_playback()
	pass

func setup_ui_button_audio(node : Node) -> void:
	for button in node.find_children("*", "Button"):
		button.pressed.connect(play_ui_select_audio)
		button.focus_entered.connect(play_ui_focus_audio)
		
		if button is OptionButton:
			button.item_focused.connect(play_ui_option_select_audio)
			button.item_selected.connect(play_ui_option_focus_audio)

#region /// Ui sound functions
# Ui sound functions, functions made since all ui elements will utilize same ui sounds
# Dictated by the ui audio variables
func play_ui_audio(audio : AudioStream) -> void:
	if ui_audio_player != null:
		ui_audio_player.play_stream( audio )

func play_ui_focus_audio() -> void:
	play_ui_audio(ui_focus_audio)

func play_ui_select_audio() -> void:
	play_ui_audio(ui_select_audio)

func play_ui_cancel_audio() -> void:
	play_ui_audio(ui_cancel_audio)

func play_ui_success_audio() -> void:
	play_ui_audio(ui_success_audio)
	
func play_ui_error_audio() -> void:
	play_ui_audio(ui_error_audio)
	
func play_ui_option_select_audio(item_index : int) -> void:
	play_ui_audio(ui_select_audio)

func play_ui_option_focus_audio(item_index : int) -> void:
	play_ui_audio(ui_focus_audio)
#endregion
