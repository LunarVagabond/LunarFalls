extends TextureButton

@export var selected_control: ColorRect
var selection_control: bool = false

func _ready():
	selected_control.hide()  # Hide the panel initially
	selected_control.mouse_filter = Control.MOUSE_FILTER_IGNORE 


func _on_pressed_select():
	if selection_control: 
		selection_control = false
		selected_control.hide()
	else:
		selection_control = true
		selected_control.show()
