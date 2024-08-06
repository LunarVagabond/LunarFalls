extends Control
@export_category("Board Settings")
@export var board_width = 7
@export var total_tiles = 56
@export var tile_margin = 2.0 # Margin between tiles

@export_category("Dashboard Settings")
@export var class_image: TextureRect
@export var main_menu_scene: String
@export var str_label: Label
@export var gold_label: Label
@export var health_bar: StatBar
@export var ap_bar: StatBar

@export_category("Required Nodes")
@export var game_over_node: Control
@export var game_board: GridContainer
@export var game_title_label: Label
@export var tile_scene: PackedScene

@export_category("Mobile Nodes")
@export var mobile_submit_button: Button


# Called when the node enters the scene tree for the first time.
func _ready():
	var os = OS.get_name() # "Android", "BlackBerry 10", "Flash", "Haiku", "iOS", "HTML5", "OSX", "Server", "Windows", "WinRT", "X11"
	if os in ["iOS", "Android", "BlackBerry 10"]:
		mobile_submit_button.show()
	game_over_node.hide()
	SignalManager.connect("game_over", _handle_game_over)
	_clear_board()
	_set_dashboard()
	_populate_game_board()

# Handle user clicking done
func _unhandled_input(event):
	if Globals.is_palyers_turn and len(Globals.current_selection) >= 3 and event.is_action_pressed(GameConstants.IA_SUBMIT_TURN):
		Globals.is_palyers_turn = false
		_handle_player_selection()
		_replace_tiles_with_empty(Globals.current_selection)
		_handle_enemy_turn()
		var empty_tiles = _find_empty_tiles() # TODO: we can probably simply grab the name of selected tiles and track that rather then looping again
		if len(empty_tiles) > 0:
			_replace_tiles(empty_tiles, false)
		Globals.current_round +=1 
		Globals.is_palyers_turn = true
		Globals.current_selection.clear() # Reset the array
		game_title_label.text = "Round %s" % Globals.current_round
		print("Do this later")

func _handle_enemy_turn():
	var dmg = 0
	for t: GameTile in game_board.get_children():
		if t.tile_type == Tile.TileType.Enemy:
			dmg += 1
	# FIXME: update to handle damage to armor / health algorithim 
	Player.take_damage(dmg)
	print("Damage Done: ", -dmg)

func _find_empty_tiles() -> Array[GameTile]:
	var empty: Array[GameTile] = []
	for t: GameTile in game_board.get_children():
		if t.tile_type == Tile.TileType.Empty:
			empty.append(t)
	return empty

func _replace_tiles(selected_tiles: Array[GameTile], allow_empty: bool):
	for t: GameTile in selected_tiles:
		var new_tile: GameTile = tile_scene.instantiate().create(t.index_on_board, board_width, allow_empty, -1, t.coordinate)
		game_board.remove_child(t)
		game_board.add_child(new_tile)
		game_board.move_child(new_tile, new_tile.index_on_board)
		t.queue_free()

func _handle_player_selection() -> void:
	var tile_type: Tile.TileType = Globals.current_selection[0].tile_type
	print(tile_type)
	# TODO: Figure out the scaling and what not
	match tile_type:
		Tile.TileType.Health:
			SignalManager.emit_signal("update_health", len(Globals.current_selection))
		Tile.TileType.Armor:
			SignalManager.emit_signal("update_armor", len(Globals.current_selection))
		Tile.TileType.Enemy or Tile.TileType.Strength:
			print("Enemy Selected not doing a damnd thing baby!")
		Tile.TileType.GoldPts:
			Player.current_gold += len(Globals.current_selection)
			gold_label.text = "Gold: %s" % Player.current_gold
		_: 
			print("You should not be here!")
	

func _replace_tiles_with_empty(selected_tiles: Array[GameTile]):
	for tile: GameTile in selected_tiles:
		var new_tile = tile_scene.instantiate().create(tile.index_on_board, true, Tile.TileType.Empty, -1, tile.coordinate)
		game_board.remove_child(tile)
		tile.queue_free()
		game_board.add_child(new_tile)
		game_board.move_child(new_tile, new_tile.index_on_board)

func _set_dashboard():
	var image_data = Player.class_data.icon.get_image()
	var image_texture = ImageTexture.create_from_image(image_data)
	str_label.text = "Base ATK: %s" % Player.class_data.starting_str
	gold_label.text = "GOLD: %s" % Player.class_data.starting_gold 
	health_bar.initilize_instance(Player.class_data.starting_hp)
	ap_bar.initilize_instance(Player.class_data.starting_ap)
	class_image.texture = image_texture

func _populate_game_board():
	for i in range(56):
		var tile: GameTile = tile_scene.instantiate().create(i, board_width, false)
		game_board.add_child(tile)

func _clear_board():
	for child: Node in game_board.get_children():
		game_board.remove_child(child)
		child.queue_free()

# ------- Signals ----- #

# func _on_button_pressed(button: BaseButton): # Normally "pressed" does not take in a button but Bind to callable allows for this (?)
# 	# print("Tile Clicked: ", button.name)
# 	var x = index_to_vector2(int(str(button.name))) # name is a "StringName" but we need a base string class to cast to int
# 	print("Coordinate: (%s,%s)" % [x.x, x.y])

func _on_quit_pressed():
	Globals.game_state["game_board"] = game_board.get_children()
	Globals.save_game()
	get_tree().change_scene_to_file(main_menu_scene)

func _handle_game_over():
	print("Game Over")
	game_over_node.show()

func _handle_mobile_submit():
	_unhandled_input(GameConstants.IA_SUBMIT_TURN)
