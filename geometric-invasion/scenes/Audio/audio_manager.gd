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
		
		if !button.pressed.is_connected(play_ui_select_audio):
			# Connect button pressed and focused state
			button.pressed.connect(play_ui_select_audio)
		
		if !button.focus_entered.is_connected(play_ui_focus_audio):
			button.focus_entered.connect(play_ui_focus_audio)
		
		if !button.mouse_entered.is_connected(play_ui_focus_audio):
			# Connect mouse cursor to button signals
			button.mouse_entered.connect(play_ui_focus_audio)
		
		if button is OptionButton:
			if !button.item_selected.is_connected(play_ui_option_focus_audio):
					button.item_selected.connect(play_ui_option_focus_audio)
					
			if !button.item_focused.is_connected(play_ui_option_select_audio):
				button.item_focused.connect(play_ui_option_select_audio)
			
			
			

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

#region // Music playing functions
func play_music_track(audio : AudioStream):
	var current_player : AudioStreamPlayer = get_music_player(cur_track)
	
	if current_player.stream == audio:
		return
	
	var next_track : int = wrapi(cur_track + 1, 0, 2)
	var next_player : AudioStreamPlayer = get_music_player(next_track)
	
	next_player.stream = audio
	next_player.play()
	
	cur_track = next_track

	for tween in music_tweens:
		tween.kill()
	music_tweens.clear()

	fade_track_out(current_player)
	fade_track_in(next_player)
	
func get_music_player(player_index : int) -> AudioStreamPlayer:
	if player_index == 0:
		return music_player_1
	else:
		return music_player_2
	
func fade_track_out(player : AudioStreamPlayer) -> void:
	var tween : Tween = create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear", 0.0, 1.5)
	tween.tween_callback(player.stop)

func fade_track_in(player : AudioStreamPlayer) -> void:
	var tween : Tween = create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear", 1.0, 1.0)
	
func stop_cur_player() -> void:
	var cur_player : AudioStreamPlayer = get_music_player(cur_track)
	
	for tween in music_tweens:
		tween.kill()
	music_tweens.clear()
	
	fade_track_out(cur_player)
	
#endregion

#region // SFX playing functions
func play_spatial_sound(audio : AudioStream, position : Vector2) -> void:
	var spatial_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(spatial_player)
	
	spatial_player.bus = "SFX"
	spatial_player.global_position = position
	spatial_player.stream = audio
	
	spatial_player.finished.connect(spatial_player.queue_free)
	
	spatial_player.play()
#endregion
