extends Node
class_name MusicAutoTrigger 

@export var track : AudioStream

func _ready() -> void:
	AudioManager.play_music_track(track)
