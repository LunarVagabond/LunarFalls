class_name GameTile
extends TextureButton

@export var tile_scene: PackedScene
@export var selected_control: ColorRect
@export var hp_label: Label
@export var atk_label: Label

var is_selected: bool = false
var index_on_board = -1
var tile_type: Tile.TileType
var coordinate = Vector2.ZERO

# --- Enemy Specifics --- #
var atk_power: int = randi_range(1,3)
var hp: int = randi_range(1,3)

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

func create(idx:int, board_width: int, empty_allowed: bool, enforce_tile: Tile.TileType = -1, enforce_vector: Vector2 = Vector2.ZERO) -> GameTile:
    var tile_data: Tile
    if enforce_tile != -1:
        tile_data = Globals.tiles.get(Tile.TileType.keys()[enforce_tile])
    else:
        tile_data = _get_random_dict_key(empty_allowed)
    tile_type = tile_data.tile_type
    name = str(idx)
    index_on_board = idx
    if enforce_vector == Vector2.ZERO:
        coordinate = index_to_vector2(idx, board_width)
    else:
        coordinate = enforce_vector
    texture_normal = tile_data.icon
    return self

# How much damage to take if new hp less then 0 remove will be true
func take_damage(amnt: int) -> bool:
    var remove: bool = false
    var new_hp: int =  hp - amnt
    hp_label.text = str(new_hp)
    is_selected = false
    selected_control.hide()
    if (new_hp <= 0):
        remove = true
    return remove

func toggle_selected():
    if is_selected:
        selected_control.hide()
        is_selected = false
    else:
        selected_control.show()
        is_selected = true

# Function to convert a 1D index to a 2D Vector2 coordinate
func index_to_vector2(index: int, board_width: int) -> Vector2:
    var row = floor(index / board_width)
    var column = index % board_width 
    return Vector2(column, row)

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
                # print("Selected Tile Coordinate: %s" % coordinate)
                selected_control.show()
                is_selected = true
                Globals.current_selection.append(self)

func _allowed_to_add() -> bool:
    var allowed = false
    # if array has elements in it future elements must match
    if not Globals.current_selection.is_empty():
        var tile: GameTile = Globals.current_selection[Globals.current_selection.size() -1]
        # print("Distance allowed: %s" % _within_range())
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
    # print("Distance to coord: x: %s - y: %s" % [x_dist, y_dist])
    return (x_dist <= 1 and y_dist <= 1)

func _allowed_to_deselect():
    return (is_selected and self in Globals.current_selection and self == Globals.current_selection[Globals.current_selection.size() -1])


func _get_random_dict_key(empty_allowed: bool) -> Tile:
    var keys = Globals.tiles.keys()
    var random_index = randi() % keys.size()
    var tile: Tile = Globals.tiles[keys[random_index]]
    while not empty_allowed and tile.tile_type == Tile.TileType.Empty:
        random_index = randi() % keys.size()
        tile = Globals.tiles[keys[random_index]]
    return tile
