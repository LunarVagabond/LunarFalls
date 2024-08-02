extends Control
@export_category("Board Settings")
@export var board_width = 7
@export var total_tiles = 56
@export var tile_margin = 2.0 # Margin between tiles
@export var tile_resource_group: ResourceGroup
@export var tile_scene: PackedScene

@export_category("Dashboard Settings")
@export var class_image: TextureRect
@export var main_menu_scene: String


var game_board: GridContainer
var tiles = {}

# TODO: Somehow we need to make sure when selecting the tile it is of the same type (sword and enemy can be matched as well)
# Called when the node enters the scene tree for the first time.
func _ready():
    game_board = $MarginContainer/VBoxContainer/GameBoard/GridContainer
    _load_tile_group()
    _set_dashboard()
    populate_game_board()

# Handle user clicking done
func _unhandled_input(event):
    if Globals.is_palyers_turn and event.is_action_pressed(GameConstants.IA_SUBMIT_TURN):
        Globals.is_palyers_turn = false
        var selected_tiles = _find_selected_tiles()
        _replace_tiles(selected_tiles)
        _handle_enemy_turn()
        Globals.is_palyers_turn = true
        print("Do this later")

func _handle_enemy_turn():
    pass

func _find_selected_tiles() -> Array[GameTile]:
    var selected_tiles: Array[GameTile] = []
    for txtbtn: GameTile in game_board.get_children():
        if txtbtn.is_selected:
            selected_tiles.append(txtbtn)
    return selected_tiles

func _replace_tiles(selected_tiles: Array[GameTile]):
    for t: GameTile in selected_tiles:
        var new_tile = _new_tile(t.index_on_board)
        game_board.remove_child(t)
        game_board.add_child(new_tile)
        game_board.move_child(new_tile, new_tile.index_on_board)
        t.queue_free()
    
func _load_tile_group():
    var tiles_array: Array[Tile] = []
    tile_resource_group.load_all_into(tiles_array)
    for t in tiles_array:
        tiles[Tile.TileType.keys()[t.tile_type]] = t

func _set_dashboard():
    var image_data = Globals.class_data.icon.get_image()
    var image_texture = ImageTexture.create_from_image(image_data)
    class_image.texture = image_texture

func populate_game_board():
    for i in range(56):
        var tile = _new_tile(i)
        game_board.add_child(tile)

func _new_tile(idx: int) -> GameTile:
    var tile_data: Tile = get_random_dict_key()
    var tile: GameTile = tile_scene.instantiate()
    tile.tile_type = tile_data.tile_type
    tile.name = str(idx)
    tile.index_on_board = idx
    tile.texture_normal = tile_data.icon
    tile.connect("pressed", Callable(self, "_on_Button_pressed").bind(tile)) # Bind to the Callable for custom signal functionality
    return tile

func get_random_dict_key() -> Tile:
    var keys = tiles.keys()
    var random_index = randi() % keys.size()
    var tile: Tile = tiles[keys[random_index]]
    while tile.tile_type == Tile.TileType.Empty:
        random_index = randi() % keys.size()
        tile = tiles[keys[random_index]]
    return tile

# Function to convert a 1D index to a 2D Vector2 coordinate
func index_to_vector2(index: int) -> Vector2:
    var row = index / board_width
    var column = index % board_width
    return Vector2(column, row)

func _on_Button_pressed(button: BaseButton): # Normally "pressed" does not take in a button but Bind to callable allows for this (?)
    # print("Tile Clicked: ", button.name)
    var x = index_to_vector2(int(str(button.name))) # name is a "StringName" but we need a base string class to cast to int
    print("Coordinate: (%s,%s)" % [x.x, x.y])

func _on_quit_pressed():
    Globals.game_state["game_board"] = game_board.get_children()
    Globals.save_game()
    get_tree().change_scene_to_file(main_menu_scene)
