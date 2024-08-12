extends Node

signal add_selection(tile: GameTile)

signal update_health(change_amount: int)
signal update_armor(change_amount: int)

signal level_up()
signal gain_experience(exp_gained: int) # I think eventually we do this so each component can self handle an xp gain

signal game_over()