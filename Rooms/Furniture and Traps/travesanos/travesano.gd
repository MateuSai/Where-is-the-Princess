class_name Travesano extends StaticBody2D

@onready var skeleton: Sprite2D = $Skeleton

func _ready() -> void:
    skeleton.frame_coords.y = randi() % skeleton.vframes