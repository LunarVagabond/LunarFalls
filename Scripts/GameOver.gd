extends Control

@export_category("Required")
@export var character_selection_scene: String
@export var main_menu_scene: String
@export var round_label: Label

func _ready():
	SignalManager.connect("round_up", _handle_round_up)

func _on_new_game() -> void:
	get_tree().change_scene_to_file(character_selection_scene)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)


func _handle_round_up(round: int):
	round_label.text = "Final Round: \n%s" % round
