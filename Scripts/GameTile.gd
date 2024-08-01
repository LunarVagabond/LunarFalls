class_name GameTile
extends TextureButton

@export var selected_control: ColorRect
var is_selected: bool = false

func _ready():
	selected_control.hide()  # Hide the panel initially
	selected_control.mouse_filter = Control.MOUSE_FILTER_IGNORE 


func _on_pressed_select():
	if is_selected: 
		is_selected = false
		selected_control.hide()
	else:
		is_selected = true
		selected_control.show()
