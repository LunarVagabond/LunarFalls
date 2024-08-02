extends Control

@export var game_scene: String
@export var main_menu_scene: String
@export var classes_resource_group: ResourceGroup

var CharacterSelection: ItemList
var class_list: Array[CharacterClass] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	CharacterSelection = $MarginContainer/VBoxContainer/ClassList
	_load_character_classes()
	CharacterSelection.select(0)

func _load_character_classes():
	classes_resource_group.load_all_into(class_list)
	for cls in class_list:
		CharacterSelection.add_item(cls.character_class, cls.icon)

func _on_back_button_pressed():
	print("Path %s", main_menu_scene)
	get_tree().change_scene_to_file(main_menu_scene)

func _on_start_pressed():
	# Get the selected class index
	var selected_index = CharacterSelection.get_selected_items()[0]
	
	# Get the selected class
	var selected_class_data: CharacterClass = class_list[selected_index]
	
	# # Store the selected class and its data in the global singleton
	Globals.class_data = selected_class_data
	Globals.game_state["class_data"] = selected_class_data
	
	print("Class Data: ", selected_class_data)
	
	# Change the scene to the game scene
	get_tree().change_scene_to_file(game_scene)
