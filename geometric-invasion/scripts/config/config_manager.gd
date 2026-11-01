extends Node

const CONFIG_FILE_PATH = "user://settings.cfg"

func _ready() -> void:
	load_settings_config()

func save_settings_config() -> void:
	var config : ConfigFile = ConfigFile.new()
	
	config.set_value("audio", "music", AudioServer.get_bus_volume_linear(2))
	config.set_value("audio", "sfx", AudioServer.get_bus_volume_linear(3))
	config.set_value("audio", "ui", AudioServer.get_bus_volume_linear(4))
	
	config.save(CONFIG_FILE_PATH)
	

func load_settings_config() -> void:
	var config : ConfigFile = ConfigFile.new()
	var error = config.load(CONFIG_FILE_PATH)
	
	if error != OK:
		AudioServer.set_bus_volume_linear(2, 0.5)
		AudioServer.set_bus_volume_linear(3, 1.0)
		AudioServer.set_bus_volume_linear(4, 1.0)
		return
	
	AudioServer.set_bus_volume_linear(2, config.get_value("audio", "music", 0.5))
	AudioServer.set_bus_volume_linear(3, config.get_value("audio", "sfx", 1.0))
	AudioServer.set_bus_volume_linear(4, config.get_value("audio", "ui", 1.0))
