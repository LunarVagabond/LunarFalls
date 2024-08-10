class_name CharacterClass
extends Resource

@export var character_class: String
@export var icon: Texture
@export var description: String
@export var starting_hp: int
@export var starting_ap: int
@export var starting_str: int
@export var starting_gold: int
@export var starting_defense: int = 1

## The amount health potions should be worth
@export var starting_will_power: int = 1

## The amount shields are worth
@export var starting_agility: int = 1