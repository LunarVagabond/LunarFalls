class_name Tile
extends Resource

enum Trait {
    Health,
    GoldPts,
    Armor,
    Strength
}

@export var icon: Texture
@export var positive_effect: bool
@export var effects: Trait
@export var base_effect: int
