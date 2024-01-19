class_name CharacterReflection extends Sprite2D


@onready var original_sprite: Sprite2D = get_node("../Sprite2D")


func _init() -> void:
	z_index = -3
	modulate.a = 0.4


func _ready() -> void:
	texture = original_sprite.texture
	hframes = original_sprite.hframes
	vframes = original_sprite.vframes
	original_sprite.texture_changed.connect(func() -> void:
		texture = original_sprite.texture
	)
	scale.y = -1
	position.y = original_sprite.position.y * -1


func _process(_delta: float) -> void:
	frame = original_sprite.frame
	flip_h = original_sprite.flip_h
