class_name LightningLine2D extends Line2D

func _init() -> void:
	width = 8
	z_index = 1
	texture = load("res://Art/effects/lightning_animated.tres")
	texture_mode = Line2D.LINE_TEXTURE_TILE
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED


func lightning(to: Vector2, from: Vector2) -> void:
	points = PackedVector2Array([to, from])
	await create_tween().tween_property(self, "modulate:a", 0, 1.0).finished
	queue_free()
