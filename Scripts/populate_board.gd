extends Control

@export var board_width = 7
@export var total_tiles = 56
@export var tile_margin = 2.0 # Margin between tiles
@export var tile_resource_group: ResourceGroup
@export var class_image: TextureRect 
@export var tile_scene: PackedScene

var tiles: Array[Tile] = []

# Called when the node enters the scene tree for the first time.
func _ready():
    _load_tile_group()
    _set_dashboard()
    populate_game_board()

func _load_tile_group():
    tile_resource_group.load_all_into(tiles)

func _set_dashboard():
    var image_data = Globals.class_data.icon.get_image()
    var image_texture = ImageTexture.create_from_image(image_data)
    class_image.texture = image_texture

func populate_game_board():
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    var game_board: GridContainer = $MarginContainer/VBoxContainer/GameBoard/GridContainer

    for i in range(56):
        var tile_index = rng.randi_range(0, len(tiles) - 1 ) # grab random tile type
        var tile_data = tiles[tile_index]
        while tile_data.tile_type == Tile.TileType.Empty:
            tile_index = rng.randi_range(0, len(tiles) - 1 ) # grab random tile type
            tile_data = tiles[tile_index]
        var tile = tile_scene.instantiate()
        tile.name = str(i)
        tile.texture_normal = tile_data.icon
        tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        tile.size_flags_vertical = Control.SIZE_EXPAND_FILL
        tile.stretch_mode = TextureButton.STRETCH_SCALE
        tile.connect("pressed", Callable(self, "_on_Button_pressed").bind(tile)) # Bind to the Callable for custom signal functionality
        game_board.add_child(tile)

# Function to convert a 1D index to a 2D Vector2 coordinate
func index_to_vector2(index: int) -> Vector2:
    var row = index / board_width
    var column = index % board_width
    return Vector2(column, row)

func _on_Button_pressed(button: BaseButton): # Normally "pressed" does not take in a button but Bind to callable allows for this (?)
    print("Tile Clicked: ", button.name)
    var x = index_to_vector2(int(str(button.name))) # name is a "StringName" but we need a base string class to cast to int
    print("Coordinate: (%s,%s)" % [x.x, x.y])
