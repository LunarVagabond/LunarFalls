class_name GameTile
extends TextureButton

@export var selected_control: ColorRect
@export var hp_label: Label
@export var atk_label: Label

var is_selected: bool = false
var index_on_board = -1
var tile_type: Tile.TileType
var coordinate = Vector2.ZERO

# --- Enemy Specifics --- #
var atk_power: int = 1
var hp: int = 1

func _ready():
    selected_control.hide()  # Hide the panel initially
    selected_control.mouse_filter = Control.MOUSE_FILTER_IGNORE 
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    stretch_mode = TextureButton.STRETCH_SCALE
    if tile_type == Tile.TileType.Enemy:
        hp_label.text = str(hp)
        atk_label.text = str(atk_power)
        hp_label.show()
        atk_label.show()
    else:
        hp_label.hide()
        atk_label.hide()

func _on_pressed_select():
    if Globals.is_palyers_turn:
        # Was Selected so player is deselecting
        if (is_selected) and (_allowed_to_deselect()): 
            is_selected = false
            selected_control.hide()
            var tile_idx = Globals.current_selection.find(self)
            Globals.current_selection.remove_at(tile_idx)
        else:
            # Add logic to only add if tile is of same type AND within a 3x3 grid of tile at center
            if self not in Globals.current_selection and _allowed_to_add():
                selected_control.show()
                is_selected = true
                Globals.current_selection.append(self)

func _allowed_to_add() -> bool:
    var allowed = false
    # if array has elements in it future elements must match
    if not Globals.current_selection.is_empty():
        var tile: GameTile = Globals.current_selection[Globals.current_selection.size() -1]
        print("Distance allowed: %s" % _within_range())
        if (tile_type == tile.tile_type or 
            (
                tile_type == Tile.TileType.Enemy 
                and 
                tile.tile_type == Tile.TileType.Strength
            ) or 
            (
                tile_type == Tile.TileType.Strength and tile.tile_type == Tile.TileType.Enemy)
            ) and _within_range():
            allowed = true     
        else:
            allowed = false
    # The array is empty so it's okay to add
    else:
        allowed = true
    return allowed

func _within_range() -> bool:
    var last_tile_selected: GameTile = Globals.current_selection[-1]
    var x_dist = abs(last_tile_selected.coordinate.x - coordinate.x)
    var y_dist = abs(last_tile_selected.coordinate.y - coordinate.y)
    print("x: %s - y: %s" % [x_dist, y_dist])
    return (x_dist <= 1 and y_dist <= 1)

func _allowed_to_deselect():
    return (is_selected and self in Globals.current_selection and self == Globals.current_selection[Globals.current_selection.size() -1])

