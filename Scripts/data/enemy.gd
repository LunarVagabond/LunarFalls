class_name EnemyTile
extends Tile

enum EnemyType {
    Basic
}

@export var attack: int
@export var health: int
@export var enemy_type: EnemyType