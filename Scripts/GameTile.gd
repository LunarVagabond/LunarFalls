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

func _on_pressed_select():
	if Globals.is_palyers_turn:
		# Was Selected so player is deselecting
		if is_selected: 
			is_selected = false
			selected_control.hide()
			var tile_idx = Globals.current_selection.find(self)
			Globals.current_selection.remove_at(tile_idx)
		else:
			## Add logic to only add if tile is of same type AND within a 3x3 grid of tile at center
			if _allowed_to_add():
				selected_control.show()
				is_selected = true
				Globals.current_selection.append(self)

func _allowed_to_add() -> bool:
	if len(Globals.current_selection) > 0:
		var tile: GameTile = Globals.current_selection[0]
		if tile_type == tile.tile_type:
			return true
		# We allow strength and enemy combination
		elif (tile_type == Tile.TileType.Enemy and tile.tile_type == Tile.TileType.Strength) or (tile_type == Tile.TileType.Strength and tile.tile_type == Tile.TileType.Enemy):
			return true
		else: 
			return false
	# The array is empty so it's okay to add
	return true
