extends Control

@export_category("Required Nodes")
# @export var game_scene: String
@export var main_menu_scene: String
@export var classes_resource_group: ResourceGroup
@export var class_icon: TextureRect
@export var class_description: Label

@onready var CharacterSelection: ItemList = $MarginContainer/VBoxContainer/ClassList
var class_list: Array[CharacterClass] = []

var description_template: String = """
Description: %s\n
Base Stats:
	HP (Health Points): %s
	AP (Armor Points): %s
	Strength: %s
"""

var game_scene = preload("res://Scenes/GameBoard.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	_load_character_classes()
	CharacterSelection.select(0)
	_on_class_list_item_clicked(0, Vector2(0,0), 0) # We want to fire this fuction so that we can update the description panel

func _load_character_classes():
	classes_resource_group.load_all_into(class_list)
	for cls in class_list:
		CharacterSelection.add_item(cls.character_class, cls.icon)

func _on_back_button_pressed():
	get_tree().change_scene_to_file(main_menu_scene)

func _on_start_pressed():
	# Get the selected class index
	var selected_index = CharacterSelection.get_selected_items()[0]
	
	# Get the selected class
	var selected_class_data: CharacterClass = class_list[selected_index]
	
	# # Store the selected class and its data in the global singleton
	Globals.game_state["class_data"] = selected_class_data
	Player.class_data = selected_class_data
	Player.current_hp = selected_class_data.starting_hp
	Player.current_ap = selected_class_data.starting_ap
	Player.current_str = selected_class_data.starting_str
	Player.current_gold = selected_class_data.starting_gold
	Player.defense = selected_class_data.starting_defense
	
	print("Class Data: ", selected_class_data)
	
	# Change the scene to the game scene
	get_tree().change_scene_to_packed(game_scene)


func _on_class_list_item_clicked(_index:int, _at_position:Vector2, _mouse_button_index:int):
	var selected = CharacterSelection.get_selected_items()[0]
	var selected_class_data: CharacterClass = class_list[selected]
	class_icon.texture = selected_class_data.icon
	class_description.text = description_template % [selected_class_data.description, selected_class_data.starting_hp, selected_class_data.starting_ap, selected_class_data.starting_str]
