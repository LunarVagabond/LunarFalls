# Singleton set in Autoload
extends Node

# ---- Player Data ---- #
var class_data: CharacterClass
var current_hp: int
var current_ap: int
var current_str: int
var current_gold: int

func take_damage(amnt: int):
    current_hp -= amnt
    if current_hp <= 0:
        SignalManager.emit_signal("game_over")
    SignalManager.emit_signal("update_health", -amnt)
    SignalManager.emit_signal("update_armor", -amnt)