class_name SlidingWall extends Node2D

@export var dir: int = 1

var tween: Tween

enum {
    CLOSED,
    OPEN,
}

var state: int = CLOSED

@onready var tilemap: TileMap = $TileMap

func _ready() -> void:
    tilemap.set_cell(0, Vector2i(0, -2), SavedData.get_biome_conf().room_atlas_id, Rooms.UPPER_WALL_COOR)
    tilemap.set_cell(0, Vector2i(0, -1), SavedData.get_biome_conf().room_atlas_id, Rooms.FULL_WALL_COORDS[randi() % Rooms.FULL_WALL_COORDS.size()])

func activate() -> void:
    tween = create_tween()
    if state == CLOSED:
        state = OPEN
        tween.tween_property(tilemap, "position:x", Rooms.TILE_SIZE * dir, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    else:
        state = CLOSED
        tween.tween_property(tilemap, "position:x", 0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
