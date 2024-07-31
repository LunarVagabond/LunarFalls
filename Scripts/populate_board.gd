extends Control

@export var board_width = 7
@export var total_tiles = 56
@export var tile_margin = 2.0 # Margin between tiles
@export var tile_resource_group: ResourceGroup

var tiles: Array[Tile] = []

# Called when the node enters the scene tree for the first time.
func _ready():
    _load_tile_group()
    populate_game_board()

func _load_tile_group():
    tile_resource_group.load_all_into(tiles)

func populate_game_board():
    var game_board: GridContainer = $MarginContainer/VBoxContainer/GameBoard/GridContainer

    for i in range(56):
        if i % 2 == 0:
            var tile_data = tiles[0]
            var tile = TextureButton.new()
            tile.name = str(i)
            tile.texture_normal = tile_data.icon
            tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            tile.size_flags_vertical = Control.SIZE_EXPAND_FILL
            tile.stretch_mode = TextureButton.STRETCH_SCALE
            
            tile.connect("pressed", Callable(self, "_on_Button_pressed").bind(tile)) # Bind to the Callable for custom signal functionality

            game_board.add_child(tile)
        else:
            var b = Button.new()
            b.name = str(i)
            b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            b.size_flags_vertical = Control.SIZE_EXPAND_FILL
            b.connect("pressed", Callable(self, "_on_Button_pressed").bind(b)) # Bind to the Callable for custom signal functionality
            game_board.add_child(b)

# Function to convert a 1D index to a 2D Vector2 coordinate
func index_to_vector2(index: int) -> Vector2:
    var row = index / board_width
    var column = index % board_width
    return Vector2(column, row)

func _on_Button_pressed(button: BaseButton): # Normally "pressed" does not take in a button but Bind to callable allows for this (?)
    print("Tile Clicked: ", button.name)
    var x = index_to_vector2(int(str(button.name))) # name is a "StringName" but we need a base string class to cast to int
    print("Coordinate: (%s,%s)" % [x.x, x.y])
