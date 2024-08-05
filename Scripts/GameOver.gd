extends Control

@export_category("Required")
@export var character_selection_scene: String
@export var main_menu_scene: String

func _on_new_game() -> void:
	get_tree().change_scene_to_file(character_selection_scene)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)
