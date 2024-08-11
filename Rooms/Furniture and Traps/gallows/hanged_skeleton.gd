@tool
class_name HangedSkeleton extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes

	animation_player.play("swing")
