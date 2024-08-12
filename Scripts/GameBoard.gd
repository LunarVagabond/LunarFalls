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
@export var agi_label: Label
@export var willpower_label: Label
@export var health_bar: StatBar
@export var ap_bar: StatBar
@export var experience_proggress_bar: ProgressBar

@export_category("Required Nodes")
@export var game_over_node: Control
@export var game_board: GridContainer
@export var game_title_label: Label
@export var player_level_title: Label
@export var tile_scene: PackedScene
@export var audio_player: AudioStreamPlayer

var is_dragging: bool = false
var start_tile = null

# Called when the node enters the scene tree for the first time.
func _ready():
    game_over_node.hide()
    SignalManager.connect("game_over", _handle_game_over)
    SignalManager.connect("level_up", _handle_levelup)
    player_level_title.text = ""
    _clear_board()
    _set_dashboard()
    _populate_game_board()

func _input(event):
    if event.is_action_pressed("mouse_click"):
        # Detect the start of the drag
        start_tile = _get_tile_at_position(event.position)
        if start_tile:
            start_tile.toggle_selected()
            is_dragging = true
            Globals.current_selection.clear()
            Globals.current_selection.append(start_tile)
            print("Drag started at:", event.position)

    elif event.is_action_released("mouse_click"):
        # Detect the end of the drag
        if is_dragging:
            is_dragging = false
            _handle_drag_end()
            for n: Node in game_board.get_children():
                var tile = n as GameTile
                tile.toggle_off_selection()
            Globals.current_selection.clear()
            print("Drag ended at:", event.position)
    
    elif is_dragging and (event is InputEventMouseMotion or event is InputEventScreenTouch):
        # Handle dragging
        var tile = _get_tile_at_position(event.position)
        if tile:
            if tile in Globals.current_selection:
                # Check if the tile being hovered is the one before the last tile in the chain
                var array_len = Globals.current_selection.size()
                if array_len > 1 and tile == Globals.current_selection[array_len - 2]:
                    # Remove the last tile from the chain
                    var last_tile = Globals.current_selection.pop_back()
                    last_tile.toggle_selected()
                    print("Removed tile:", last_tile.name, "at:", event.position)
            elif tile not in Globals.current_selection and tile._allowed_to_add():
                Globals.current_selection.append(tile)
                tile.toggle_selected()
                print("Dragging over tile:", tile.name, "at:", event.position)



func _get_tile_at_position(pos: Vector2) -> GameTile:
    # Placeholder function to find a tile at a position
    for tile in game_board.get_children():
        if tile is GameTile and tile.get_global_rect().has_point(pos):
            return tile
    return null

func _handle_drag_end():
    # Valid move made progress the game
    if len(Globals.current_selection) >= 3:
        print("Valid selection with", len(Globals.current_selection), "tiles")
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
        player_level_title.text = "Player Level %s" % Player.level
    # Invalid move player go again
    else:
        print("Invalid selection with", len(Globals.current_selection), "tiles")
    
# Handle user clicking done


func _handle_enemy_turn():
    var dmg = 0
    var nodes: Array[Node] = game_board.get_children()
    var active_enemies = nodes.map(func(n: Node): return n as GameTile).filter(func(t: GameTile): return t.tile_type == Tile.TileType.Enemy)
    print("Active Enemy Count: %s" % active_enemies.size())
    for e: GameTile in active_enemies:
        dmg += e.atk_power 
        # print("Damage Count: %s" % dmg)
    # FIXME: update to handle damage to armor / health algorithim 
    Player.take_damage(dmg)

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
    # TODO: Figure out the scaling and what not
    match tile_type:
        Tile.TileType.Health:
            SignalManager.emit_signal("update_health", len(Globals.current_selection) * randi_range(1, Player.will_power))
            Player.gain_xp(Globals.current_selection.size())
        Tile.TileType.Armor:
            SignalManager.emit_signal("update_armor", len(Globals.current_selection) * randi_range(1, Player.agility))
            Player.gain_xp(Globals.current_selection.size())
        Tile.TileType.Enemy or Tile.TileType.Strength:
            print("Enemy Selected not doing a damnd thing baby!")
            var xp_gained = 0
            for node: GameTile in Globals.current_selection:
                match node.tile_type:
                    Tile.TileType.Enemy:
                        xp_gained += node.atk_power + node.hp
                    _:
                        xp_gained += 1
            Player.gain_xp(xp_gained)
        Tile.TileType.GoldPts:
            Player.current_gold += len(Globals.current_selection)
            Player.gain_xp(Globals.current_selection.size())
            gold_label.text = "Gold: %s" % Player.current_gold
        _: 
            print("You should not be here!")
    experience_proggress_bar.value = Player.xp
    

func _replace_tiles_with_empty(selected_tiles: Array[GameTile]):
    var player_damage = (Globals.current_selection.filter(func(tile: GameTile): return tile.tile_type == Tile.TileType.Strength)).size() + Player.current_str
    var should_replace = true
    for tile: GameTile in selected_tiles:
        if tile.tile_type == Tile.TileType.Enemy:
            should_replace = tile.take_damage(player_damage)
        if should_replace:
            var new_tile = tile_scene.instantiate().create(tile.index_on_board, board_width, true, Tile.TileType.Empty, tile.coordinate)
            game_board.remove_child(tile)
            tile.queue_free()
            game_board.add_child(new_tile)
            game_board.move_child(new_tile, new_tile.index_on_board)

func _set_dashboard():
    var image_data = Player.class_data.icon.get_image()
    var image_texture = ImageTexture.create_from_image(image_data)
    str_label.text = "Base ATK: %s" % Player.class_data.starting_str
    gold_label.text = "GOLD: %s" % Player.class_data.starting_gold 
    agi_label.text = "BASE AGI: %s" % Player.class_data.starting_agility
    willpower_label.text = "BASE Will: %s" % Player.class_data.starting_will_power
    experience_proggress_bar.value = 0
    experience_proggress_bar.max_value = Player.xp_to_next_level
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

func _on_quit_pressed():
    Globals.game_state["game_board"] = game_board.get_children()
    Globals.save_game()
    get_tree().change_scene_to_file(main_menu_scene)

func _handle_game_over():
    print("Game Over")
    game_over_node.show()

func _handle_levelup():
    Player.handle_levelup()
    experience_proggress_bar.value = Player.xp
    experience_proggress_bar.max_value = Player.xp_to_next_level

func _handle_sfx_toggled(on: bool):
    if on:
        audio_player.stop()
    else:
        audio_player.play()
