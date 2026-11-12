extends Control

const LEVEL_ENTRY = preload("res://level_entry.tscn")

@export_dir var level_dir

@onready var level_grid = %LevelGrid

func _ready() -> void:
	obtain_level_files()
	AudioManager.setup_ui_button_audio(self)


# Button should go back to main menu or multiplayer choice menu dependent on multiplayer peer
func _on_back_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func obtain_level_files() -> void:
		var directory = ResourceLoader.list_directory(level_dir)
		
		for i in directory:
			var level_path = level_dir + "/" + i
			create_level_button(level_path, i)

func create_level_button(level_path : String, level_name : String) -> void:
	var level_entry = LEVEL_ENTRY.instantiate()
	level_entry.text = level_name.trim_suffix(".tscn").replace("_", " ")
	level_entry.level_path = level_path
	level_entry.name = level_entry.text + "Button"
	level_grid.add_child(level_entry) 
