@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/tiles/wall/door_anim_opening_f0.png")
class_name Door extends StaticBody2D

signal player_entered_room()

var open_after_combat: bool = true

enum DoorOrientation {VERTICAL, HORIZONTAL_UP, HORIZONTAL_DOWN}
@export var door_type: DoorOrientation = DoorOrientation.VERTICAL

@onready var sprite: Sprite2D = $Sprite2D
#@onready var top_sprite: Sprite2D = get_node_or_null("TopSprite")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var player_detector: Area2D = get_node("PlayerDetector")


func _ready() -> void:
	player_detector.body_entered.connect(func(_body: Node2D) -> void:
		emit_signal("player_entered_room")
	)

	match door_type:
		DoorOrientation.VERTICAL:
			sprite.texture = load(SavedData.get_biome_conf().vertical_door_texture as String) as Texture
		DoorOrientation.HORIZONTAL_UP:
			sprite.texture = load(SavedData.get_biome_conf().horizontal_up_door_texture as String) as Texture
		DoorOrientation.HORIZONTAL_DOWN:
			sprite.texture = load(SavedData.get_biome_conf().horizontal_down_door_texture as String) as Texture

#	if top_sprite:
#		top_sprite.texture = load(SavedData.get_biome_conf().horizontal_door_top_texture)


func open() -> void:
	animation_player.play("open")


func close() -> void:
	animation_player.play("close")
	#player_detector.queue_free()
