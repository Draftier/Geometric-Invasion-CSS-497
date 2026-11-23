extends BaseMenu

const LEVEL_ENTRY = preload("res://level_entry.tscn")

@export_dir var level_dir
@export var test_mode : bool = false

@onready var level_grid = %LevelGrid
@onready var back_button = %BackToMainMenuButton

func _ready() -> void:
	obtain_level_files()
	set_button_neigbors()
	AudioManager.setup_ui_button_audio(self)


# Button should go back to main menu or multiplayer choice menu dependent on multiplayer peer
func _on_back_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

# Function to obtain levels from levels directory
func obtain_level_files() -> void:
		# Load level directory
		var directory = ResourceLoader.list_directory(level_dir)
		
		# For each entry in directory
		for i in directory:
			# Obtain the level path
			var level_path = level_dir + "/" + i
			# If the level is a test level, do not list it
			if test_mode == false && i.trim_suffix(".tscn").replace("-", " ").contains("test"):
				continue
			
			# Otherwise list level
			create_level_button(level_path, i)

# Function to create the level and correctly name the level
func create_level_button(level_path : String, level_name : String) -> void:
	# Instantiate the level and set the level's animated button grow size
	var level_entry = LEVEL_ENTRY.instantiate()
	level_entry.grow_size = Vector2(1.05, 1.05)
	
	# Set the button text and name
	level_entry.text = level_name.trim_suffix(".tscn").replace("_", " ")
	level_entry.level_path = level_path
	level_entry.name = level_entry.text + "Button"
	
	# Add the button to the tree
	level_grid.add_child(level_entry) 
	
func set_button_neigbors() -> void:
	var buttons = level_grid.find_children("*", "Button", true, false)
	buttons.get(0).grab_focus()
	
	back_button.focus_neighbor_top = back_button.get_path_to(buttons.get(0))
	
	for i in range(1, buttons.size()):
		var previous_button : Button = buttons.get(i-1)
		var current_button : Button = buttons.get(i)
		if (i - 1) == 0:
			previous_button.focus_neighbor_right = previous_button.get_path_to(current_button)
		previous_button.focus_neighbor_right = previous_button.get_path_to(current_button)
		current_button.focus_neighbor_left = current_button.get_path_to(previous_button)
	pass
