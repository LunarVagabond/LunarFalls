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

var base_color: String = "6e6e6ec1"
var second_to_last_color: String = "7a7016c1"
var leader_color: String = "a55528c1"

# --- Enemy Specifics --- #
var atk_power: int
var hp: int

func _ready():
    selected_control.hide()  # Hide the panel initially
    selected_control.mouse_filter = Control.MOUSE_FILTER_IGNORE 
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    stretch_mode = TextureButton.STRETCH_SCALE
    if tile_type == Tile.TileType.Enemy:
        # Scale enemy stats based on the current round
        var game_round = Globals.current_round
        hp = calculate_scaled_stat(game_round, 2, 1.2)
        atk_power = calculate_scaled_stat(game_round, 2, 1.2)
        hp_label.text = str(hp)
        atk_label.text = str(atk_power)
        hp_label.show()
        atk_label.show()
    else:
        hp_label.hide()
        atk_label.hide()

func calculate_scaled_stat(game_round: int, base_value: int, scaling_factor: float) -> int:
    # Calculate the base scaled stat (ceiling)
    var base_stat = int(base_value * pow(scaling_factor, game_round / 5))
    
    # Generate a weighted random value within the range [1, base_stat]
    var random_value = int(pow(randi_range(1, base_stat), 0.7))  # Adjust 0.5 to control skewness

    # Ensure the final value is within the range [1, base_stat]
    return clamp(random_value, 1, base_stat)

func create(idx:int, board_width: int, empty_allowed: bool, enforce_tile: Tile.TileType = -1, enforce_vector: Vector2 = Vector2.ZERO) -> GameTile:
    var tile_data: Tile
    if enforce_tile != -1:
        tile_data = Globals.tiles.get("Tiles").get(Tile.TileType.keys()[enforce_tile])
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
    _set_selection_color()

func _set_selection_color():
    var selection_length: int = Globals.current_selection.size()
    if selection_length == 0:
        return
    elif selection_length == 1:
        selected_control.color = leader_color
    elif selection_length == 2:
        selected_control.color = leader_color
        Globals.current_selection[-2].selected_control.color = second_to_last_color
    else:
        selected_control.color = leader_color
        Globals.current_selection[-2].selected_control.color = second_to_last_color
        Globals.current_selection[-3].selected_control.color = base_color

    

func toggle_off_selection():
    selected_control.hide()
    is_selected = false

# Function to convert a 1D index to a 2D Vector2 coordinate
func index_to_vector2(index: int, board_width: int) -> Vector2:
    var row = floor(index / board_width)
    var column = index % board_width 
    return Vector2(column, row)

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


# Calculate the enemy spawn probability based on the current round
func _calculate_enemy_spawn_probability(game_round: int) -> float:
    var base_probability = 0.05  # Start at 5%
    var max_probability = 0.33  # Cap at 33%
    var scaling_factor = 0.02  # Increase by 2% each interval
    var interval = 5  # Increase probability every 5 rounds

    # Calculate the probability, capped at max_probability
    var probability = min(base_probability + (game_round / interval) * scaling_factor, max_probability)
    
    return probability

func _get_random_dict_key(empty_allowed: bool) -> Tile:
    var group: String = "Tiles"
    var enemy_spawn_probability = _calculate_enemy_spawn_probability(Globals.current_round)
    print("Spawn Probs: %s" % enemy_spawn_probability)
    if randf() < enemy_spawn_probability:
        group = "Enemies"
    var keys = Globals.tiles[group].keys()
    var random_index = randi() % keys.size()
    var tile: Tile = Globals.tiles[group][keys[random_index]]
    while not empty_allowed and tile.tile_type == Tile.TileType.Empty:
        random_index = randi() % keys.size()
        tile = Globals.tiles[group][keys[random_index]]
    return tile
