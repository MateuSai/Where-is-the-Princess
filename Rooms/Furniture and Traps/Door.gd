@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/tiles/wall/door_anim_opening_f0.png")
class_name Door extends StaticBody2D

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")


func open() -> void:
	animation_player.play("open")

