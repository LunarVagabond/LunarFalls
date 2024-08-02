class_name GameTile
extends TextureButton

@export var selected_control: ColorRect
var is_selected: bool = false
var index_on_board = -1
var tile_type: Tile.TileType

func _ready():
    selected_control.hide()  # Hide the panel initially
    selected_control.mouse_filter = Control.MOUSE_FILTER_IGNORE 
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    stretch_mode = TextureButton.STRETCH_SCALE

func change_selected():
    # FIXME: this should probably be removed as it is test code
    # eventually the tile should be deleted and a new one isntered
    is_selected = false
    selected_control.hide()


func _on_pressed_select():
    if Globals.is_palyers_turn:
        if is_selected: 
            is_selected = false
            selected_control.hide()
        else:
            is_selected = true
            selected_control.show()
