class_name Tile
extends Resource

enum TileType {
    Empty,
    Health,
    GoldPts,
    Armor,
    Strength
}

@export var icon: Texture
@export var positive_effect: bool
@export var tile_type: TileType
@export var base_effect: int
