extends Node


@export var character_selection_scene: PackedScene
@export var new_game_button: Button
@export var continue_game_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Path to CS: %s", character_selection_scene)
	new_game_button.connect("pressed", _on_start_new_game_pressed)
	continue_game_button.connect("pressed", _on_continue_game_pressed)


func _on_start_new_game_pressed():
	print("New game Pressed")
	get_tree().change_scene_to_packed(character_selection_scene)


func _on_continue_game_pressed():
	Globals.load_game()