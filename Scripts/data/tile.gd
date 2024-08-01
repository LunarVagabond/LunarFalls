class_name Tile
extends Resource

enum TileType {
    Empty,
    Health,
    GoldPts,
    Armor,
    Strength,
    Enemy
}

@export var icon: Texture
@export var positive_effect: bool # Plan to use this later for special Enemy units to "corrupt" tiles like hp potions
@export var tile_type: TileType
@export var base_effect: int
