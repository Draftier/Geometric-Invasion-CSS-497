extends Control

@onready var display_mode = %DisplayMode

@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SfxSlider
@onready var ui_slider = %UiSoundSlider
@onready var fps_dropwdown = %FpsSettingDropDown

var current_display_mode = DisplayServer.window_get_mode()

func _ready() -> void:
	setup_settings_menu()

func setup_settings_menu() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear(2)
	sfx_slider.value = AudioServer.get_bus_volume_linear(3)
	ui_slider.value = AudioServer.get_bus_volume_linear(4)
	
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	ui_slider.value_changed.connect(_on_ui_slider_changed)
	
	if current_display_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		display_mode.select(0)
	else:
		display_mode.select(1)
	
	fps_dropwdown.select(0)
		
	AudioManager.setup_ui_button_audio(self)

func _on_music_slider_changed(volume : float) -> void:
	AudioServer.set_bus_volume_linear(2, volume)
	ConfigManager.save_settings_config()

func _on_sfx_slider_changed(volume : float) -> void:
	AudioServer.set_bus_volume_linear(3, volume)
	AudioManager.play_spatial_sound(preload("res://assets/audio/sfx/player/Shoot.ogg"), get_viewport_rect().size / 2)

func _on_ui_slider_changed(volume : float) -> void:
	AudioServer.set_bus_volume_linear(4, volume)
	AudioManager.play_ui_focus_audio()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fps_setting_drop_down_item_selected(index: int) -> void:
	match index:
		0:
			Overlay.disable_fps_overlay()
		1:
			Overlay.enable_fps_overlay()
			
