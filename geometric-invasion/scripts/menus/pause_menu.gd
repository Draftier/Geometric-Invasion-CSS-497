extends CanvasLayer

@onready var resume_button = %ResumeButton
@onready var restart_button = %RestartButton
@onready var quit_menu_button = %QuitToMenu
@onready var quit_desktop_button = %QuitToDesktop
@onready var root_pause_menu = %RootPauseMenu
@onready var settings_menu = %SettingsMenu
@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SfxSlider
@onready var ui_slider = %UiSoundSlider
@onready var display_mode = %DisplayMode
@onready var fps_dropwdown = %FpsSettingDropDown

var current_display_mode = DisplayServer.window_get_mode()

func _ready() -> void:
	AudioManager.setup_ui_button_audio(self)
	setup_settings_menu()
	hide()

func setup_settings_menu() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear(2)
	sfx_slider.value = AudioServer.get_bus_volume_linear(3)
	ui_slider.value = AudioServer.get_bus_volume_linear(4)
	
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	ui_slider.value_changed.connect(_on_ui_slider_changed)
	
	if current_display_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		display_mode.select(0)
	
	if Overlay.is_fps_overlay_enabled == true:
		fps_dropwdown.select(1)
	else:
		fps_dropwdown.select(0)
		
	AudioManager.setup_ui_button_audio(self)

func _on_music_slider_changed(volume : float) -> void:
	AudioServer.set_bus_volume_linear(2, volume)
	ConfigManager.save_settings_config()

func _on_sfx_slider_changed(volume : float) -> void:
	AudioServer.set_bus_volume_linear(3, volume)
	AudioManager.play_spatial_sound(preload("res://assets/audio/sfx/player/Shoot.ogg"), root_pause_menu.position)

func _on_ui_slider_changed(volume : float) -> void:
	AudioServer.set_bus_volume_linear(4, volume)
	AudioManager.play_ui_focus_audio()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_game()

func pause_game() -> void:
	if get_tree().paused == false:
		if NetworkManager.is_solo == true:
			get_tree().paused = true
		show()
		#get_node("FinishLabel").hide()
		#get_node("RestartButton").hide()
	else:
		hide()
		get_tree().paused = false

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	#PoolManager.destroy_pools()
	#PoolManager.reset_pools()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/UI/main_menu.tscn")

func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	pause_game()
	#PoolManager.destroy_pools()
	#PoolManager.init_pools()
	get_tree().reload_current_scene()
	

func _on_settings_button_pressed() -> void:
	root_pause_menu.hide()
	settings_menu.visible = true
	

func _on_back_to_pause_menu_pressed() -> void:
	settings_menu.hide()
	root_pause_menu.visible = true
	


func _on_fps_settings_toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		Overlay.disable_fps_overlay()
	else:
		Overlay.enable_fps_overlay()


func _on_fps_setting_drop_down_item_selected(index: int) -> void:
	match index:
		0:
			Overlay.disable_fps_overlay()
		1:
			Overlay.enable_fps_overlay()
			
func _on_display_mode_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
