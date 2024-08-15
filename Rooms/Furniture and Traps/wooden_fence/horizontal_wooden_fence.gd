class_name HorizontalWoodenFence extends WoodenFence

const POSSIBLE_COOR: PackedVector2Array = [Vector2(1, 1), Vector2(2, 1), Vector2(2, 1)]

func _ready() -> void:
	super()

	sprite.frame_coords = POSSIBLE_COOR[randi() % POSSIBLE_COOR.size()]
