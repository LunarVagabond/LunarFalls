extends Node

signal add_selection(tile: GameTile)

signal update_health(change_amount: int)
signal update_armor(change_amount: int)

signal game_over()