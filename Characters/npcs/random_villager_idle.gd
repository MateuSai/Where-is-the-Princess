extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    sprite.frame_coords.y = randi_range(0, sprite.vframes - 1)