@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/tiles/wall/door_anim_opening_f0.png")
class_name Door extends StaticBody2D

signal player_entered_room()

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var player_detector: Area2D = get_node("PlayerDetector")


func _ready() -> void:
	player_detector.body_entered.connect(func(_body: Node2D):
		emit_signal("player_entered_room")
	)


func open() -> void:
	animation_player.play("open")


func close() -> void:
	animation_player.play("close")
	player_detector.queue_free()
