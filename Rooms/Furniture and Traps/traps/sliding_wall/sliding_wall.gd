class_name SlidingWall extends Node2D

@export var dir: int = 1

var tween: Tween

enum {
    CLOSED,
    OPEN,
}

var state: int = CLOSED

@onready var tilemap: TileMap = $TileMap

func activate() -> void:
    tween = create_tween()
    if state == CLOSED:
        state = OPEN
        tween.tween_property(tilemap, "position:x", Rooms.TILE_SIZE * dir, 0.8)
    else:
        state = CLOSED
        tween.tween_property(tilemap, "position:x", 0, 0.8)
