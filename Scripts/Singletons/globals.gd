# Singleton set in Autoload
extends Node

# ---- Game State ---- #
var is_palyers_turn: bool = true
var current_round = 1
var current_selection: Array[GameTile] = []

var tile_resource_group: ResourceGroup = preload("res://Scripts/data/all_tiles.tres")
var enemy_resource_group: ResourceGroup = preload("res://Scripts/data/all_enemies.tres")
var tiles = {} # Contains pointers to resources for tiles

# Default state, updated in save game and set when loading
var game_state = {
	"class_data": null,
	"current_health": 100,
	"current_armor": 100,
	"current_gold": 0,
	"game_board": []

}

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_tile_groups()
	print("Globals Loaded")

func _load_tile_groups():
	var tiles_array: Array[Tile] = []
	var enemy_array: Array[EnemyTile] = []
	tile_resource_group.load_all_into(tiles_array)
	enemy_resource_group.load_all_into(enemy_array)
	tiles["Tiles"] = {}
	tiles["Enemies"] = {}

	for tile: Tile in tiles_array:
		tiles["Tiles"][Tile.TileType.keys()[tile.tile_type]] = tile
	for enemey: EnemyTile in enemy_array:
		tiles["Enemies"][EnemyTile.EnemyType.keys()[enemey.enemy_type]] = enemey
	print("Tile Keys: %s" % tiles)
	


func _handle_selection(tile: GameTile):
	print("Selected: %s" % tile)
	# current_selection.append(tile)

func save_game():
	var save_dir = "./game_data/"
	DirAccess.make_dir_recursive_absolute(save_dir)
	# Prepare game state for saving
	var serializable_state = {
		# "chosen_class": class_data.character_class,
		"current_health": game_state["current_health"],
		"current_armor": game_state["current_armor"],
		"current_gold": game_state["current_gold"],
		"game_board": []
	}

	# Convert game_board pieces to a serializable format
	for piece in game_state["game_board"]:
		var piece_data = {}
		if piece.tile_type == Tile.TileType.Enemy:
			piece_data = {
				"type": piece.tile_type,
				"index_in_grid": piece.name,
				"health": 0 # FIXME: When adding enemy health this should pull from there
			}
		else:
			piece_data = {
				"type": piece.tile_type,
				"index_in_grid": piece.name
			}
		serializable_state["game_board"].append(piece_data)
	
	var file = FileAccess.open(save_dir + "save.json", FileAccess.WRITE)
	if file:
		print("Saving Game to: ", file.get_path_absolute())
		var json_string = JSON.stringify(serializable_state)
		file.store_string(json_string)
		file.close()
	else:
		print("Failed to open file for saving.")
