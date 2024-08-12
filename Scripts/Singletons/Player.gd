# Singleton set in Autoload
extends Node

# ---- Player Data ---- #
var class_data: CharacterClass
var current_hp: int
var current_ap: int
var current_str: int
var current_gold: int
var defense: int # how much should shields absorb
var will_power: int # The amount each potion should be worth
var agility: int
var level: int = 0
var xp: int = 0
var xp_to_next_level = 100


# func _ready():
    # SignalManager.connect("level_up", handle_levelup)

func take_damage(amnt: int):
    var defense_multiplier = defense / 100.0
    var armor_damage = amnt * defense_multiplier
    var hp_damage = amnt - armor_damage

    current_hp -= hp_damage
    current_ap -= armor_damage

    print("Armor absorbed:", armor_damage, "HP took:", hp_damage)

    if current_ap < 0:
        current_hp += current_ap
        current_ap = 0
    if current_hp <= 0:
        SignalManager.emit_signal("game_over")
    SignalManager.emit_signal("update_health", -amnt)
    SignalManager.emit_signal("update_armor", -amnt)

func gain_xp(xp_gained: int):
    var new_xp: int = xp + xp_gained
    while new_xp >= xp_to_next_level:
        new_xp -= xp_to_next_level
        SignalManager.emit_signal("level_up")
        xp_to_next_level += 25  
    xp = new_xp

func handle_levelup():
    level += 1
    print("level up")
    pass
