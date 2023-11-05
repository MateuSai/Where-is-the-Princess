class_name AcidPuddle extends Area2D


@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes
