extends Node

const TOP_LEFT = Vector2    (-1, -1)
const TOP_CENTER = Vector2  (0, -1)
const TOP_RIGHT = Vector2   (1, -1)

const CENTER_LEFT = Vector2 (-1, 0)
const CENTER = Vector2      (0, 0) # Selected Tile
const CENTER_RIGHT = Vector2(1, 0)

const LOWER_LEFT = Vector2  (-1, 1)
const LOWER_CENTER = Vector2(0, 1)
const LOWER_RIGHT = Vector2 (1, 1)


var select_window = [
    TOP_LEFT, TOP_CENTER, TOP_RIGHT,
    CENTER_LEFT, CENTER, CENTER_RIGHT,
    LOWER_LEFT, LOWER_CENTER, LOWER_RIGHT
]